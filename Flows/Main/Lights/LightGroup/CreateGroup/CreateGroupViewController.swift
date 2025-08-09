//
//  CreateGroupViewController.swift
//  Slite
//
//  Created by Paul Marc on 15.04.2022.
//

import Foundation
import SwiftUI
import Combine

struct CreateGroup {
    
    final class ViewController: UIHostingController<AnyView> {
        // MARK: - Properties
        
        let viewModel: ViewModel
        var disposeBag = [AnyCancellable]()
        weak var scenesNameDataSource: RemoveLightAlertDataSource?
        
        init(lightsViewModel: Lights.ViewModel) {
            self.viewModel = ViewModel(lightsViewModel: lightsViewModel)
            super.init(rootView: ContentView()
                        .environmentObject(viewModel)
                        .ignoresSafeArea(.keyboard, edges: .all)
                        .eraseToAnyView()
                )
            navigationController?.setNavigationBarHidden(false, animated: false)
            
            let label = UILabel()
            label.font = UIFont.Main.bold(size: 19)
            label.adjustsFontForContentSizeCategory = false
            label.text = Texts.CreateGroup.title
            navigationItem.titleView = label
            
            setupNavigationBar()
            setupBindings()
        }
        
        @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            setupNavigationBar()
        }
        
        private func setupBindings() {
            viewModel.onNext.sink { [unowned self] in
                self.showNameGroupViewController()
            }.store(in: &disposeBag)
        }
        
        private func setupNavigationBar() {
            navigationController?.setNavigationBarHidden(false, animated: false)
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .clear
            appearance.titleTextAttributes = [.font: UIFont.Main.bold(size: 19)]
            appearance.shadowColor = .clear
            
            navigationController?.navigationBar.tintColor = .white
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
        
        private func showNameGroupViewController() {
            var scenesName: Set<String> = []
            
            viewModel.selectedLightsIds.forEach {
                let names = scenesNameDataSource?.scenesNamesThatContainsLightWith($0) ?? []
                scenesName.formUnion(names)
            }
            
            let viewModel = NameGroup.ViewModel()
            let viewController = NameGroup.ViewController(viewModel: viewModel, scenesName: Array(scenesName))
            
            viewController.onDismiss.sink { [unowned self] in
                self.dismiss(animated: true, completion: nil)
            }.store(in: &disposeBag)
            
            viewModel.onFinishedInteraction.sink { [unowned self] groupName in
                self.viewModel.lightsViewModel.createNewGroup(name: groupName, lights: self.viewModel.selectedLightsIds)
                scenesNameDataSource?.removeScenesWithNames(Array(scenesName))
                self.dismiss(animated: true, completion: {
                    self.navigationController?.popViewController(animated: true)
                })
            }.store(in: &disposeBag)
            
            self.present(viewController, animated: true)
        }
    }
}
