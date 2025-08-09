//
// HomeViewController.swift
// Slite
//
// Created by Efraim Budusan on 21.01.2022.
//
//

import Foundation
import UIKit
import SwiftUI
import Combine

//class HomeViewController: UIViewController {
//
//    @IBOutlet weak var container: TabBarAnimationConatiner!
//    @IBOutlet weak var tabBarContainer: UIView!
//
//}

extension Home {
    
    class ViewController: UIViewController {
        
        @IBOutlet weak var container: TabBarAnimationConatiner!
        @IBOutlet weak var tabBarContainer: UIView!

        static var singleton: Home.ViewController?
        
        static let tabBarHeight: CGFloat = 51

        //MARK: - Tabs
        
        lazy var lightsViewController = Lights.ViewController()
        lazy var scenesViewController = Scenes.ViewController()
        lazy var tabBar = TabBarView(viewModel: self.viewModel)
        lazy var blurBackground: UIVisualEffectView = UIVisualEffectView()

        var viewControllers: [UIViewController] = []
        
        let viewModel = ViewModel()
        
        var disposableBag = [AnyCancellable]()
        
        //MARK: - Init
        
        init() {
            let bundle = Bundle(for: Home.ViewController.self)
            super.init(nibName: "HomeViewController", bundle: bundle)
            
            scenesViewController.viewModel.sceneDataSource = lightsViewController.viewModel
            scenesViewController.viewModel.scenesDelegate = lightsViewController.viewModel
            
            lightsViewController.scenesNameDataSource = scenesViewController.viewModel
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
        
        //MARK: - View Lifecycle
        
        override func loadView() {
            super.loadView()
            setup()
            self.view.backgroundColor = .primaryBackground
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            addObservers()
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
        }
        
        override func viewDidAppear(_ animated: Bool) {
            navigationController?.setNavigationBarHidden(true, animated: false)
            super.viewDidAppear(animated)
            
            showTutorialScreenIfNeeded()
        }
         
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
        }
        
        //MARK: - Setup

        func setup() {
            addCustomTabBar()
            self.viewControllers = [lightsViewController, scenesViewController]
            self.container.parent = self
            self.container.setNewContent(viewController: lightsViewController)
            setupBindings()
        }

        func addCustomTabBar() {
            setupBlurBackground()
//            tabBarContainer.backgroundColor = .primaryBackground.withAlphaComponent(0.9)
            tabBarContainer.addSubview(tabBar)
            tabBar.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                tabBarContainer.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
                tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                tabBarContainer.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
                tabBarContainer.topAnchor.constraint(equalTo: tabBar.topAnchor),
                tabBar.heightAnchor.constraint(equalToConstant: Self.tabBarHeight)
            ])
        }
        
        func setupBlurBackground() {
            blurBackground.translatesAutoresizingMaskIntoConstraints = false
            tabBarContainer.addSubview(blurBackground)
            blurBackground.constrainAllMargins(with: tabBarContainer)
            
            var blur: UIBlurEffect
            if self.traitCollection.userInterfaceStyle == .dark {
                blur = UIBlurEffect(style: .dark)
            } else {
                blur = UIBlurEffect(style: .light)
            }
            addVibrancyLayer()
            blurBackground.effect = blur
            
        }
        
        func addVibrancyLayer() {
            var blur: UIBlurEffect
            if self.traitCollection.userInterfaceStyle == .dark {
                blur = UIBlurEffect(style: .dark)
            } else {
                blur = UIBlurEffect(style: .light)
            }
            let vibrancyEffect = UIVisualEffectView()
            vibrancyEffect.translatesAutoresizingMaskIntoConstraints = false
            tabBarContainer.addSubview(vibrancyEffect)
            vibrancyEffect.constrainAllMargins(with: tabBarContainer)
            if self.traitCollection.userInterfaceStyle == .dark {
                vibrancyEffect.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            } else {
                vibrancyEffect.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
            }
            vibrancyEffect.effect = UIVibrancyEffect(blurEffect: blur, style: .fill)
        }
        
        func setupBindings() {
            viewModel.objectWillChange.sink { [unowned self] in
                self.set(index: self.viewModel.selectedIndex)
            }.store(in: &disposableBag)
            
            lightsViewController.viewModel.onAddLight.sink { [unowned self] in
                self.addLightAction()
            }.store(in: &disposableBag)
        }

        func selectTab(index:Int) {
            self.viewModel.select(tab: index)
        }
        
        func selectPreviousIndex() {
            if let previousSelectedIndex = viewModel.previousSelectedIndex {
                self.viewModel.select(tab: previousSelectedIndex)
            }
        }
        
        func set(index: Int, animated: Bool = true) {
            guard let viewController = self.viewControllers[safe:index] else {
                return
            }
            let previous = viewModel.previousSelectedIndex ?? 0
            var animation: TabBarAnimationConatiner.Animation?
            if animated {
                if index > previous {
                    animation = .right
                } else {
                    animation = .left
                }
            }
            DispatchQueue.main.async {
                self.handleIndexChange(newIndex: index)
            }
            self.container.setNewContent(viewController: viewController, animation: animation)
        }
        
        func handleIndexChange(newIndex: Int) {
    //        if newIndex == self.planIndex {
    //            self.planViewController.loadData()
    //        }
        }
        
        private func showTutorialScreenIfNeeded() {
            guard !UserDefaults.applicationWasLaunched else { return }
            
            let tutorialBlurBackgroundImage = UIApplication.takeScreenshot()
            let tutorialOverlay = UIHostingController(rootView: TutorialOverlay(backgroundImage: tutorialBlurBackgroundImage,
                                                                                buttonTapCallback: {
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                self.addLightAction()
                
            }), ignoreSafeArea: true)
            
            tutorialOverlay.view.backgroundColor = .clear
            tutorialOverlay.modalPresentationStyle = .overFullScreen
            
            self.present(tutorialOverlay, animated: false, completion: {
                UserDefaults.set(applicationWasLaunched: true)
            })
        }
        
        //MARK: Observers
        func addObservers() {
            NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        }
        
        @objc func applicationDidEnterForeground() {    }
    }

}

