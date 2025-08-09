//
// AddMenuViewController.swift
// Slite
//
// Created by Efraim Budusan on 24.01.2022.
//
//

import Foundation
import UIKit
import SwiftUI
import SwiftUIX

extension AddMenu {
    
    class ViewController: UIViewController {
        
        let viewModel: ViewModel
        
        lazy var blurBackground: UIVisualEffectView = {
            let view = UIVisualEffectView()
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
            view.constrainAllMargins(with: self.view)
            self.view.sendSubviewToBack(view)
            return view
        }()
        
        init(viewModel: ViewModel) {
//            super.init(rootView: ContentView()
//                        .environmentObject(viewModel)
//                        .eraseToAnyView()
//                )
//            setup()
            self.viewModel = viewModel
            super.init(nibName: nil, bundle: nil)
            setup()
        }
        
        @objc required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setup() {
            let contentView = ContentView().environmentObject(self.viewModel)
            let hostingView = UIHostingView(rootView: contentView)
            hostingView.translatesAutoresizingMaskIntoConstraints = false
            hostingView._fixSafeAreaInsets()
            self.view.addSubview(hostingView)
            hostingView.constrainAllMargins(with: self.view)
            modalPresentationStyle = .overCurrentContext
            view.backgroundColor = .clear
            let transition = CustomTransitionHandler(viewController: self, duration: 0.3, onPresent: { [unowned self] info in
                DispatchQueue.main.async {
                    viewModel.entranceAnimation = .finished
                    info.completion()
                }
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                    var blur: UIBlurEffect
                    if self.traitCollection.userInterfaceStyle == .dark {
                        blur = UIBlurEffect(style: .dark)
                    } else {
                        blur = UIBlurEffect(style: .dark)
                    }
                    blurBackground.effect = blur
                } completion: { finished in
                        
                }
            }, onDismiss: { [unowned self] info in
                viewModel.entranceAnimation = .armed
                DispatchQueue.main.after(seconds: 0.3) {
                    info.completion()
                }
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                    blurBackground.effect = nil
                } completion: { finished in
                        
                }
            })
            transitioningDelegate = transition
            _ = blurBackground
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
        }
    }
}


