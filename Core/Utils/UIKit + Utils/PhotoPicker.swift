//
//  PhotoPicker.swift
//  Slite
//
//  Created by Efraim Budusan on 21.01.2022.
//

import Foundation
import UIKit
import PhotosUI

public protocol PhotoPickerDelegate: AnyObject {
    
    func didReceiveError(_ error: Error)
    
    func didSelectImages(_ uiImages: [UIImage])
}

open class PhotoPicker: NSObject {
    
    private weak var presentationController: UIViewController?
    private var pickerVC: PHPickerViewController?
    private let selectionLimit: Int
    
    private weak var delegate: PhotoPickerDelegate?
    
    public init(presentationController: UIViewController?, selectionLimit: Int, delegate: PhotoPickerDelegate) {
        self.presentationController = presentationController
        self.selectionLimit = selectionLimit
        self.delegate = delegate
        super.init()
        present()
    }
    
    private func present() {
        var configuration: PHPickerConfiguration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selectionLimit = selectionLimit /// when set to 0, there is no limit
        self.pickerVC = PHPickerViewController(configuration: configuration)
        self.pickerVC?.delegate = self
        presentationController?.present(pickerVC!, animated: true)
    }
    
    @available(iOS 15, *)
    private func loadImages(_ results: [PHPickerResult]) async -> [UIImage] {
        
        var images: [UIImage?] = []
        
        await withTaskGroup(of: UIImage?.self, body: { group in
            for result in results {
                group.addTask(priority: .background) {
                    var image: UIImage?
                    do {
                        image = try await self.loadImage(result)
                    } catch {
                        DispatchQueue.main.async {
                            self.delegate?.didReceiveError(error)
                        }
                    }
                    return image
                }
            }
            for await image in group {
                images.append(image)
            }
        })
        
        return images.compactMap({$0})
    }
    
    @available(iOS 15, *)
    private func loadImage(_ result: PHPickerResult) async throws -> UIImage? {
        guard result.itemProvider.canLoadObject(ofClass: UIImage.self) else {
            return nil
        }
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<UIImage?, Error>) in
            result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: image as? UIImage)
            }
        })
    }
}

extension PhotoPicker: PHPickerViewControllerDelegate {
    
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        if #available(iOS 15, *) {
            Task.init(priority: .background) {
                let images = await loadImages(results)
                DispatchQueue.main.async {
                    self.delegate?.didSelectImages(images)
                }
            }
        } else {
            //iOS 14
        }
    }
}

struct PhotoPickerError: Error {
    let message: String
    var localizedDescription: String {
        return message
    }
}
