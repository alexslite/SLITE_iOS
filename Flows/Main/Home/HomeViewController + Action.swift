//
//  HomeViewController + Action.swift
//  Slite
//
//  Created by Efraim Budusan on 24.01.2022.
//

import Foundation
import UIKit
import SwiftUIX
import Lottie
import Combine

extension Home.ViewController {
    
    func addLightAction() {
        let viewController = AddMenu.ViewController(viewModel: AddMenu.ViewModel(menuInputState: lightsViewController.viewModel))
        
        // On close
        viewController.viewModel.onClose.sink { [unowned self] in
            self.dismiss(animated: true, completion: nil)
        }.store(in: &disposableBag)
        
        // On add light
        viewController.viewModel.onAddLight.sink { [unowned self] in
            let discoveryViewModel = LightsDiscoveryViewModel()
            
            discoveryViewModel.onConnectionFailure.sink { [weak self] name in
                self?.lightsViewController.viewModel.showConnectionFailedToast(name: name)
            }.store(in: &disposableBag)
            
            discoveryViewModel.newLightCallback = { newLight in
                self.lightsViewController.viewModel.addNewLight(light: newLight)
            }
            
            self.dismiss(animated: false) {
                self.navigationController?.pushViewController(Lights.LightsDiscoveryViewController(viewModel: discoveryViewModel), animated: true)
            }
        }.store(in: &disposableBag)
        
        // On add group
        
        viewController.viewModel.onCreateGroup.sink { [unowned self] in
            self.dismiss(animated: false) {
                let viewController = CreateGroup.ViewController(lightsViewModel: self.lightsViewController.viewModel)
                viewController.scenesNameDataSource = self.scenesViewController.viewModel
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }.store(in: &disposableBag)
        
        // On create scene
        
        viewController.viewModel.onCreateScene.sink { [unowned self] in
            self.dismiss(animated: false) {
                
                let viewModel = NameScene.ViewModel()
                let viewController = NameScene.ViewController(viewModel: viewModel)
                
                viewController.onDismiss.sink { [unowned self] in
                    self.dismiss(animated: true, completion: nil)
                }.store(in: &self.disposableBag)
                
                viewModel.onFinishedInteraction.sink { [unowned self] sceneName in
                    scenesViewController.viewModel.saveNewSceneWithName(sceneName)
                    self.dismiss(animated: true, completion: {
                        self.lightsViewController.viewModel.showSceneCreationToast()
                    })
                }.store(in: &self.disposableBag)
                
                self.present(viewController, animated: true, completion: nil)
            }
        }.store(in: &disposableBag)
        
        self.present(viewController, animated: true, completion: nil)
    }
    
    var contentView: some View {
        ScrollView {
            VStack {
                self.item()
                    .ignoresSafeArea(.all, edges: .all)
                self.item()
                    .ignoresSafeArea(.all, edges: .all)
            }
            .ignoresSafeArea(.all, edges: .all)
        }

    }
    
    func item() -> some View {
        VStack {
            Text("Hello this is the title")
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
            TextField("Hello world", text: Self.b)
                .foregroundColor(.black)
                .background(.white)
                .padding()
                .ignoresSafeArea(.all, edges: .all)
            Text("Hello this is the title")
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.yellow)
                .ignoresSafeArea(.all, edges: .all)
        }
        .padding()
        .ignoresSafeArea(.all, edges: .all)
    }
    
    static var _b: String = ""
    
    static var b: Binding<String> = .init {
        return _b
    } set: { value in
                _b = value
    }

    
}
