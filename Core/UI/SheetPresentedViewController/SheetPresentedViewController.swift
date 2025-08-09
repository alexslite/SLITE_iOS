//
//  SheetPresentedViewController.swift
//  Slite
//
//  Created by Efraim Budusan on 27.01.2022.
//

import UIKit
import Combine
import SwiftUI
import SwiftUIX

class SheetPresentedViewController: UIViewController, UIGestureRecognizerDelegate {
    
    lazy var blurBackgroundView = UIVisualEffectView()
    lazy var vibrancyEffect = UIVisualEffectView()
    lazy var sheetBackgroundView = UIView()
    lazy var contentView = PassThroughView()
    
    var hiddenConstraint: NSLayoutConstraint?
    var bottomConstraint: NSLayoutConstraint?
    var contentBottomConstraint: NSLayoutConstraint?
    
    var onDismiss = PassthroughSubject<Void, Never>()
    
    var config: Configuration
    
    var disposableBag = [AnyCancellable]()
    
    var hostingController: UIHostingController<AnyView>?
    
    init(config: Configuration) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
        setupTransition()
    }
    
    init(config: Configuration, rootView: AnyView) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
        setupTransition()
        let _rootView = BottomSheetView {
            rootView
        } onDismiss: {
            self.handleCloseAction()
        } onDragChanged: { value in
            self.handleOnDragChanged(value)
        } onDragEnded: { value in
            self.handleOnDragEnded(value)
        }
        setupContent(with: _rootView.eraseToAnyView())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        setup()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    func setup() {
        setupBackgroundView()
        setupContentView()
        setupSafeAreHandling()
        toggleState(hidden: true)
    }
    
    func setupContent(with view: AnyView) {
        let rootView = view.frame(maxWidth: .infinity, alignment: .bottom)
            .eraseToAnyView()
        let controller = UIHostingController(rootView: rootView, ignoreSafeArea: true)
        self.hostingController = controller
        let uiView: UIView = controller.view
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.backgroundColor = .clear
        self.contentView.addSubview(uiView)
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.constrainAllMargins(with: uiView)
//        self.addChild(controller: controller, to: view)
    }
    
    func setupBackgroundView() {
        if self.traitCollection.userInterfaceStyle == .dark {
            vibrancyEffect.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        } else {
            vibrancyEffect.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        }
        vibrancyEffect.translatesAutoresizingMaskIntoConstraints = false
        vibrancyEffect.isUserInteractionEnabled = false
        blurBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(blurBackgroundView)
        self.view.addSubview(vibrancyEffect)
        blurBackgroundView.constrainAllMargins(with: self.view)
        vibrancyEffect.constrainAllMargins(with: self.view)
        self.view.sendSubviewToBack(blurBackgroundView)

    }
    
    func setupSheetBackgroundView() {
        sheetBackgroundView.backgroundColor = .secondaryBackground
        sheetBackgroundView.clipsToBounds = true
        sheetBackgroundView.layer.cornerRadius = 12
        sheetBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheetBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(sheetBackgroundView)
        NSLayoutConstraint.activate {
            sheetBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
            sheetBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            sheetBackgroundView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 0)
        }
        bottomConstraint = sheetBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        bottomConstraint?.isActive = true
        hiddenConstraint = sheetBackgroundView.topAnchor.constraint(equalTo: self.view.bottomAnchor)
    }
    
    func setupContentView() {
        contentView.backgroundColor = .clear
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.clipsToBounds = true
        view.addSubview(contentView)
        NSLayoutConstraint.activate {
//            contentView.topAnchor.constraint(equalTo: view.topAnchor, constant: 21)
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
            contentView.heightAnchor.constraint(equalTo: view.heightAnchor)
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        }
        bottomConstraint = view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        bottomConstraint?.isActive = true
        hiddenConstraint = contentView.topAnchor.constraint(equalTo: self.view.bottomAnchor)
        
    }
    
    func setupHandleView() {
        let handleView = UIView()
        handleView.backgroundColor = .sonicSilver
        handleView.layer.cornerRadius = 2.5
        handleView.translatesAutoresizingMaskIntoConstraints = false
        self.sheetBackgroundView.addSubview(handleView)
        NSLayoutConstraint.activate {
            handleView.centerXAnchor.constraint(equalTo: sheetBackgroundView.centerXAnchor)
            handleView.widthAnchor.constraint(equalToConstant: 48)
            handleView.heightAnchor.constraint(equalToConstant: 5)
            handleView.topAnchor.constraint(equalTo: sheetBackgroundView.topAnchor, constant: 8)
        }
    }

    
    func setupSafeAreHandling() {
        guard config.handleKeyboard else {
            return
        }
        KeyboardObserver.shared.keyboardHeightOverSafeArea.sink { [unowned self] keyboardHeight in
            let safeAreaPaddig = config.handleSafeArea ? UIWindow.safeAreaPadding(from: .bottom) : 0
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                self.bottomConstraint?.constant = safeAreaPaddig + keyboardHeight
                self.view.layoutIfNeeded()
            }

        }.store(in: &disposableBag)
    }
    
    func setupTransition() {
        let transition = CustomTransitionHandler(viewController: self, duration: 0.3) { [unowned self] info in
            self.view.layoutSubviews()
            DispatchQueue.main.async {
                UIView.animate(withDuration: info.duration, delay: 0, options: .curveEaseInOut) {
                    self.toggleState(hidden: false)
                    var blur: UIBlurEffect
                    if self.traitCollection.userInterfaceStyle == .dark {
                        blur = UIBlurEffect(style: .systemUltraThinMaterialDark)
                    } else {
                        blur = UIBlurEffect(style: .systemUltraThinMaterialLight)
                    }
                    self.blurBackgroundView.effect = blur
                    self.vibrancyEffect.effect = UIVibrancyEffect(blurEffect: blur, style: .fill)
                } completion: { finished in
                    info.completion()
                }
            }
            
        } onDismiss: { [unowned self] info in
            UIView.animate(withDuration: info.duration, delay: 0, options: .curveEaseInOut) {
                self.blurBackgroundView.effect = nil
                self.toggleState(hidden: true)
                self.view.layoutIfNeeded()
            } completion: { finished in
                info.completion()
            }
        }
        view.backgroundColor = .clear
        modalPresentationStyle = .overCurrentContext
        transitioningDelegate = transition
    }

    
    func toggleState(hidden: Bool) {
        if hidden {
            self.bottomConstraint?.isActive = false
            self.hiddenConstraint?.isActive = true
        } else {
            self.hiddenConstraint?.isActive = false
            self.bottomConstraint?.isActive = true
        }
        self.view.layoutIfNeeded()
    }
    
    // MARK: Pan gesture handler
    
    
    @objc func handleCloseAction() {
        onDismiss.send()
    }
    
    
    func handleOnDragChanged(_ gestureValue: DragGesture.Value) {
        if gestureValue.translation.height < 15 {
            contentView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: 0)
        } else if gestureValue.translation.height > 0 {
            contentView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: gestureValue.translation.height)
        }
    }
    
    func handleOnDragEnded(_ gestureValue: DragGesture.Value) {
        if gestureValue.translation.height > 50 {
            onDismiss.send()
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                self.contentView.transform = CGAffineTransform.identity
            } completion: { _ in
            }
        }
    }
}


extension SheetPresentedViewController {

    struct Configuration {
        var handleKeyboard: Bool = true
        var handleSafeArea: Bool = true
    }
}

extension SheetPresentedViewController {
    
    struct BottomSheetView<T: View>: View {
        
        @ViewBuilder var content: () -> T
        
        let onDismiss: () -> Void
        let onDragChanged: (DragGesture.Value) -> Void
        let onDragEnded: (DragGesture.Value) -> Void
    
        var body: some View {
            Color.black.opacity(0.001)
                .gesture(tapGesture.exclusively(before: dragGesture))
                .overlay {
                    VStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 3).fill(Color.sonicSilver)
                            .frame(width: 48, height: 5)
                            .frame(height: 21, alignment: .center)
                            .frame(maxWidth: .infinity, alignment: .center)
                        content()
                    }
                    .background({
                        RoundedCorners(tl: 12, tr: 12, bl: 0, br: 0, fill: Color.eerieBlack)
                    })
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .gesture(dragGesture)
                }
        }
        
        var gesture: some Gesture {
            return dragGesture.exclusively(before: tapGesture)
        }
        
        var dragGesture: some Gesture {
            return DragGesture().onChanged(onDragChanged).onEnded(onDragEnded)
        }
        
        var tapGesture: some Gesture {
            return TapGesture(count: 1).onEnded(onDismiss)
        }
    }
    
}
