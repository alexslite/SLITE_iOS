//
//  AddLightViewController.swift
//  Slite
//
//  Created by Paul Marc on 14.03.2022.
//

import Foundation
import SwiftUI
import SwiftUIX
import Combine

extension Lights {
    
    class LightsDiscoveryViewController: UIHostingController<AnyView> {
        // MARK: - Properties
        
        var viewModel: LightsDiscoveryViewModel
        var disposeBag = [AnyCancellable]()
        
        // MARK: - Init
        
        init(viewModel: LightsDiscoveryViewModel) {
            self.viewModel = viewModel
            super.init(rootView: LightsDiscoveryView().environmentObject(viewModel).eraseToAnyView())
            
            let label = UILabel()
            label.font = UIFont.Main.bold(size: 19)
            label.adjustsFontForContentSizeCategory = false
            label.text = Texts.Discovery.discoveryScreenTitle
            navigationItem.titleView = label
            
            setupBindings()
        }
        
        @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Lifecycle
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            setupNavigationBar()
        }
        
        func setupBindings() {
            viewModel.inputName.set { [unowned self] name in
                return self.showSliteNameInput(sliteName: name)
            }
            viewModel.$lightWasAddedSuccesfully.sink { [unowned self] value in
                guard value else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.navigationController?.popViewController(animated: true)
                }
            }.store(in: &disposeBag)
            viewModel.$lightIsSettingUp.sink { [unowned self] value in
                guard value else { return }
                self.navigationController?.setNavigationBarHidden(true, animated: false)
            }.store(in: &disposeBag)
            
            viewModel.onConnectionFailure.sink { [unowned self] _ in
                self.navigationController?.popViewController(animated: true)
            }.store(in: &disposeBag)
        }
        
        // MARK: - Navigation Bar setup
        
        private func setupNavigationBar() {
            navigationController?.setNavigationBarHidden(false, animated: false)
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .clear
            appearance.titleTextAttributes = [.font: UIFont.Main.bold(size: 19)]
            appearance.shadowColor = .clear
            appearance.largeTitleTextAttributes = [.font: UIFont.Main.bold(size: 19)]
            
            navigationController?.navigationBar.tintColor = .white
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
        
        func showSliteNameInput(sliteName: String) -> PassthroughSubject<String, Never> {
            let finished = PassthroughSubject<String, Never>()
            let viewModel = EditSliteName.ViewModel(sliteName: sliteName, isGroup: false)
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
    }
}
