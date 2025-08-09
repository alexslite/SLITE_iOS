//
// ScenesViewController.swift
// Slite
//
// Created by Efraim Budusan on 24.01.2022.
//
//

import Foundation
import UIKit
import SwiftUIX
import Combine

extension Scenes {
    
    class ViewController: UIHostingController<AnyView> {
        
        let viewModel: ViewModel = ViewModel()
        var disposeBag = [AnyCancellable]()
        
        init() {
            super.init(rootView: ContentView()
                        .environmentObject(viewModel)
                        .hideNavigationBar()
                        .eraseToAnyView()
                )
            setupBindings()
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
        
        private func setupBindings() {
            viewModel.inputName.set { [unowned self] name in
                return self.showNameInput(sceneName: name)
            }
            
            viewModel.onRemoveScene.sink { [unowned self] scene in
                showRemoveSceneInput(scene)
            }.store(in: &disposeBag)
            
            viewModel.onAddScene.sink { [unowned self] in
                self.showSaveNewScene()
            }.store(in: &disposeBag)
        }
        
        private func showSaveNewScene() {
            let viewModel = NameScene.ViewModel()
            let viewController = NameScene.ViewController(viewModel: viewModel)
            
            viewController.onDismiss.sink { [unowned self] in
                self.dismiss(animated: true, completion: nil)
            }.store(in: &self.disposeBag)
            
            viewModel.onFinishedInteraction.sink { [unowned self] sceneName in
                self.viewModel.saveNewSceneWithName(sceneName)
                self.dismiss(animated: true, completion: nil)
            }.store(in: &self.disposeBag)
            
            present(viewController, animated: true)
        }
        
        private func showRemoveSceneInput(_ scene: Scene) {
            let viewController = RemoveScene.ViewController(scene: scene) { [weak self] scene in
                self?.viewModel.remove(scene)
                self?.dismissTopmost()
            } cancelCallback: {
                self.dismissTopmost()
            }
            viewController.onDismiss.sink { [unowned self] in
                self.dismiss(animated: true, completion: nil)
            }.store(in: &disposeBag)
            
            self.present(viewController, animated: true, completion: nil)
        }
        
        private func showNameInput(sceneName: String) -> PassthroughSubject<String, Never> {
            let finished = PassthroughSubject<String, Never>()
            let viewModel = RenameScene.ViewModel(sceneName: sceneName)
            let viewController = RenameScene.ViewController(viewModel: viewModel)
            viewController.onDismiss.sink { [unowned self] in
                self.dismiss(animated: true, completion: nil)
            }.store(in: &disposeBag)
            viewModel.onFinishedInteraction.sink { [unowned self] sceneName in
                finished.send(sceneName)
                self.dismiss(animated: true, completion: nil)
            }.store(in: &disposeBag)
            self.present(viewController, animated: true, completion: nil)
            return finished
        }
    }
}
