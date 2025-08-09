//
//  ImagePickerViewController.swift
//  Slite
//
//  Created by Paul Marc on 11.04.2022.
//

import Foundation
import UIKit

final class ImagePickerViewController: UIImagePickerController {
    
    var imageCallback: ((UIImage) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.allowsEditing = true
        self.mediaTypes = ["public.image"]
        self.sourceType = .camera
        self.showsCameraControls = true
    }
}

extension ImagePickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        imageCallback?(image)
        self.dismiss(animated: true, completion: nil)
    }
}
