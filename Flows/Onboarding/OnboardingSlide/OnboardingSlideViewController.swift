//
// OnboardingSlideViewController.swift
// Slite
//
// Created by Efraim Budusan on 25.01.2022.
//
//

import Foundation
import UIKit
import SwiftUIX
import SwiftUI

extension OnboardingSlide {
    
    class ViewController: UIViewController {
        
        let viewModel: ViewModel
        var nextButtonCallback: () -> Void
        
        init(viewModel: ViewModel, nextButtonCallback: @escaping () -> Void) {
            self.viewModel = viewModel
            self.nextButtonCallback = nextButtonCallback
            super.init(nibName: nil, bundle: nil)
            setup()
        }
        
        func setup() {
            let view = ContentView(nextButtonCallback: nextButtonCallback).edgesIgnoringSafeArea(.all).environmentObject(viewModel).eraseToAnyView()
            let child = UIHostingController<AnyView>.init(rootView: view)
            self.addChild(controller: child, to: self.view)
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            navigationController?.setNavigationBarHidden(true, animated: false)
        }

        @objc required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
