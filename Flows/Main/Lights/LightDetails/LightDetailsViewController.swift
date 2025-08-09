//
// LightDetailsViewController.swift
// Slite
//
// Created by Efraim Budusan on 07.02.2022.
//
//

import Foundation
import UIKit
import SwiftUIX
import Combine

extension LightDetails {
    
    class ViewController: SheetPresentedViewController {
        
        let viewModel: LightDetailsViewModel
        
        var disposeBag = [AnyCancellable]()
        
        init(viewModel: LightDetailsViewModel) {
            self.viewModel = viewModel
            let contentView = PassthroughView {
                ContentView()
            }.environmentObject(viewModel)
                .edgesIgnoringSafeArea(.all)
            
                .eraseToAnyView()
            super.init(config: .init(handleKeyboard: false, handleSafeArea: false), rootView: contentView)
        }
        
        override func setup() {
            super.setup()
            setupBindings()
        }
        
        func setupBindings() {
            viewModel.inputHexValue.set { [unowned viewModel] in
                return self.showHexInput(hexValue: viewModel.light.data.colorHex)
            }
            viewModel.cameraInput.sink { [unowned self] in
                self.showCameraViewController()
            }.store(in: &disposeBag)
            
            viewModel.onTurnOff.sink { [unowned self] _ in
                self.dismiss()
            }.store(in: &disposeBag)
            
            viewModel.onLightWasTurnedOff.sink { [unowned self] in
                self.dismiss()
            }.store(in: &disposeBag)
        }
        
        @objc required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func showHexInput(hexValue: String) -> PassthroughSubject<String, Never> {
            let finished = PassthroughSubject<String, Never>()
            let viewModel = EditHexValue.ViewModel(hexValue: hexValue)
            let viewController = EditHexValue.ViewController(viewModel: viewModel)
            viewController.onDismiss.sink { [unowned self] in
                self.dismiss(animated: true, completion: nil)
            }.store(in: &disposeBag)
            viewModel.onFinishedInteraction.sink { [unowned self] hexValue in
                finished.send(hexValue)
                self.dismiss(animated: true, completion: nil)
            }.store(in: &disposeBag)
            self.present(viewController, animated: true, completion: nil)
            return finished
        }
        
        func showCameraViewController() {
            let viewController = CameraViewController()
            viewController.useColorCallback = { color in
                self.viewModel.setColorFromCameraView(color)
            }
            viewController.modalPresentationStyle = .overFullScreen
            self.present(viewController, animated: true)
        }
    }
}
