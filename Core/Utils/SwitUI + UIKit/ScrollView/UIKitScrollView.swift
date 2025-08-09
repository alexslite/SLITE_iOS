//
//  UIKitScrollView.swift
//  Wellory
//
//  Created by Efraim Budusan on 24.09.2021.
//  Copyright © 2021 Wellory. All rights reserved.
//

import SwiftUI
import SwiftUIX

struct UIKitScrollView<Content: View>: UIViewRepresentable {
    
    typealias UIViewType = _UIHostingScrollView<Content>
    
    let content: () -> Content
    
    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }
    
    func makeUIView(context: Context) -> _UIHostingScrollView<Content> {
        let view = _UIHostingScrollView(frame: CGRect.zero, view: content())
        view.contentInsetAdjustmentBehavior = .never
        return view
    }
    
    func updateUIView(_ uiView: _UIHostingScrollView<Content>, context: Context) {
        uiView.contentHostingController.mainView = content().eraseToAnyView()
    }
}


class _UIHostingScrollView<Content: View>: UIScrollView, UIScrollViewDelegate {
    
    
    var contentHostingController: CocoaHostingController<AnyView>!

    var lastIndexPath: IndexPath?
    
    init(frame: CGRect, view: Content) {
        super.init(frame: frame)
        configure(with: view)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with view: Content) {
        if let hosting = self.contentHostingController {
            hosting.mainView = view.eraseToAnyView()
            hosting.view.setNeedsLayout()
            hosting.view.setNeedsDisplay()
            hosting.view.layoutIfNeeded()
        } else {
            addHostingController(view: view)
        }
    }
    
    func addHostingController(view: Content) {
        let contentHostingController = CocoaHostingController(mainView: view.eraseToAnyView())
        self.contentHostingController = contentHostingController
        contentHostingController._fixSafeAreaInsetsIfNecessary()
        contentHostingController.view.backgroundColor = .clear
        contentHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentHostingController.view)
        contentLayoutGuide.topAnchor.constraint(equalTo: contentHostingController.view.topAnchor).isActive = true
        contentLayoutGuide.bottomAnchor.constraint(equalTo: contentHostingController.view.bottomAnchor).isActive = true
        contentLayoutGuide.leadingAnchor.constraint(equalTo: contentHostingController.view.leadingAnchor).isActive = true
        contentLayoutGuide.trailingAnchor.constraint(equalTo: contentHostingController.view.trailingAnchor).isActive = true
        contentHostingController.view.constrainAllMargins(with: self)
    }
}
