//
// LightsViewController.swift
// Slite
//
// Created by Efraim Budusan on 24.01.2022.
//
//

import Foundation
import UIKit
import SwiftUIX
import Combine

extension Lights {
    
    class ViewController: UIHostingController<AnyView> {
        
        let viewModel: ViewModel = ViewModel()
        let refreshButtonHelper = ButtonStateHelper()
        
        weak var scenesNameDataSource: RemoveLightAlertDataSource?
        
        init() {
            super.init(rootView: ContentView(refreshButtonHelper: refreshButtonHelper)
                        .environmentObject(viewModel)
                        .ignoresSafeArea(.keyboard, edges: .all)
                        .hideNavigationBar()
                        .eraseToAnyView()
                )
            setupBindings()
        }
        
        var disposeBag = [AnyCancellable]()
        
        func setupBindings() {
            viewModel.onLightDetails.sink { [weak self] light in
                self?.showLightDetails(light)
            }.store(in: &disposeBag)
            
            viewModel.onRemoveLight.sink { [weak self] light in
                self?.showRemoveLightInput(light: light)
            }.store(in: &disposeBag)
            
            viewModel.inputName.set { [unowned self] name in
                return self.showNameInput(sliteName: name, isGroup: false)
            }
            viewModel.groupInputName.set { [unowned self] name in
                return self.showNameInput(sliteName: name, isGroup: true)
            }
            
            viewModel.onRemoveGroup.sink { [weak self] group in
                self?.showRemoveGroupInput(light: group)
            }.store(in: &disposeBag)
            
            viewModel.onTapDisconnectedLight.sink { [weak self] in
                self?.showDisconnectedLightInfo()
            }.store(in: &disposeBag)
            
            viewModel.onTapOptions.sink { [weak self] in
                self?.showOptionsView()
            }.store(in: &disposeBag)
        }
        
        override func viewDidAppear(_ animated: Bool) {
            navigationController?.setNavigationBarHidden(true, animated: false)
            super.viewDidAppear(animated)
        }
        
        override func viewWillAppear(_ animated: Bool) {
            navigationController?.setNavigationBarHidden(true, animated: false)
            super.viewWillAppear(animated)
        }
        
        @objc required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func showOptionsView() {
            let viewController = PrivacyAndTerms.ViewController()
            
            viewController.onDismiss.sink { [unowned self] in
                self.dismiss(animated: true, completion: nil)
            }.store(in: &disposeBag)
            self.present(viewController, animated: true)
            
            viewController.onTapFirmware.sink { [unowned self] in
                self.dismiss(animated: true, completion: nil)
                self.navigationController?.pushViewController(FirmwareUpdate.ViewController(), animated: true)
            }.store(in: &disposeBag)
        }
        
        func showLightDetails(_ light: LightControlViewModel) {
        
            let viewModel: LightDetails.LightDetailsViewModel = .init(light)
            
            viewModel.inputName.set { [unowned self] name in
                self.showSliteNameInputFromDetails(sliteName: name, light: light, isGroup: light.isGroup)
            }
            
            viewModel.onRemove.sink { [unowned self] lightData in
                self.dismiss(animated: true, completion: {
                    guard light.isGroup else {
                        self.showRemoveLightInput(light: lightData)
                        return
                    }
                    
                    self.showRemoveGroupInput(light: lightData)
                })
            }.store(in: &disposeBag)
            
            viewModel.onTurnOff.sink { [unowned self] light in
                self.viewModel.onTurnOff.send(light)
            }.store(in: &disposeBag)
            
            let viewController = LightDetails.ViewController(viewModel: viewModel)
            viewController.onDismiss.sink { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }.store(in: &disposeBag)
            self.present(viewController, animated: true, completion: nil)
        }
        
        func showSliteNameInputFromDetails(sliteName: String, light: LightControlViewModel, isGroup: Bool) -> PassthroughSubject<String, Never> {
            let finished = PassthroughSubject<String, Never>()
            let viewModel = EditSliteName.ViewModel(sliteName: sliteName, isGroup: isGroup)
            let viewController = EditSliteName.ViewController(viewModel: viewModel)
            viewController.onDismiss.sink { [unowned self] in
                self.dismiss(animated: true, completion: {
                    self.showLightDetails(light)
                })
            }.store(in: &disposeBag)
            viewModel.onFinishedInteraction.sink { [unowned self] sliteName in
                finished.send(sliteName)
                self.dismiss(animated: true, completion: {
                    self.showLightDetails(light)
                })
            }.store(in: &disposeBag)
            self.dismiss(animated: true) {
                self.present(viewController, animated: true, completion: nil)
            }
            
            return finished
        }
        
        func showNameInput(sliteName: String, isGroup: Bool) -> PassthroughSubject<String, Never> {
            let finished = PassthroughSubject<String, Never>()
            let viewModel = EditSliteName.ViewModel(sliteName: sliteName, isGroup: isGroup)
            let viewController = EditSliteName.ViewController(viewModel: viewModel)
            viewController.onDismiss.sink { [unowned self] in
                self.dismiss(animated: true, completion: nil)
            }.store(in: &disposeBag)
            viewModel.onFinishedInteraction.sink { [unowned self] sliteName in
                finished.send(sliteName)
                self.dismiss(animated: true, completion: nil)
            }.store(in: &disposeBag)
            self.present(viewController, animated: true, completion: nil)
            return finished
        }
        
        func showRemoveLightInput(light: LightData) {
            let scenesName = scenesNameDataSource?.scenesNamesThatContainsLightWith(light.id) ?? []
            let viewController = RemoveSlite.ViewController(light: light,
                                                            isGroup: false,
                                                            scenesName: scenesName) { [weak self] light in
                self?.viewModel.removeLight(light: light)
                self?.scenesNameDataSource?.removeScenesWithNames(scenesName)
                self?.dismissTopmost()
            } cancelCallback: {
                self.dismissTopmost()
            }
            viewController.onDismiss.sink { [unowned self] in
                self.dismiss(animated: true, completion: nil)
            }.store(in: &disposeBag)
            
            self.present(viewController, animated: true, completion: nil)
        }
        
        func showRemoveGroupInput(light: LightData) {
            let scenesName = scenesNameDataSource?.scenesNamesThatContainsGroupWith(light.id) ?? []
            
            let viewController = RemoveSlite.ViewController(light: light, isGroup: true, scenesName: scenesName) { [weak self] group in
                self?.viewModel.removeGroup(with: group)
                self?.scenesNameDataSource?.removeScenesWithNames(scenesName)
                self?.dismissTopmost()
            } cancelCallback: {
                self.dismissTopmost()
            }
            viewController.onDismiss.sink { [unowned self] in
                self.dismiss(animated: true, completion: nil)
            }.store(in: &disposeBag)
            
            self.present(viewController, animated: true, completion: nil)
        }
        
        func showDisconnectedLightInfo() {
            let viewController = DisconnectedLight.ViewController(reconnectCallback: { [unowned self] in
                self.presentedViewController?.dismiss(animated: true)
                self.refreshButtonHelper.isSpinning.toggle()
                self.viewModel.reconnectToDisconnectedLights()
            })
            viewController.onDismiss.sink { [unowned self] in
                self.dismiss(animated: true, completion: nil)
            }.store(in: &disposeBag)
            self.present(viewController, animated: true, completion: nil)
        }
    }
}
