//
//  Keyboard.swift
//  Wellory
//
//  Created by Efraim Budusan on 04.05.2021.
//  Copyright © 2021 Wellory. All rights reserved.
//

import Foundation
import SwiftUI
import Combine


class KeyboardObserver: ObservableObject {
    
    static var shared: KeyboardObserver = .init()

    let willShowPublisher = NotificationCenter.Publisher.init(
        center: .default,
        name: UIResponder.keyboardWillShowNotification
    )

    let willHidePublisher = NotificationCenter.Publisher.init(
        center: .default,
        name: UIResponder.keyboardWillHideNotification
    )

    let keyboardHeightPublisher: AnyPublisher<CGFloat, Never>
    
    let keyboardHeightOverSafeArea: AnyPublisher<CGFloat, Never>
    
    init() {
        let keyboardHeight = willShowPublisher.map { (notification) -> CGFloat in
            if let rect = notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect {
                return rect.size.height
            } else {
                return 0
            }
        }
        let keyboardHeightMinusSafeArea = keyboardHeight.map { height in
            return max(0, height - UIWindow.safeAreaPadding(from: .bottom))
        }
        
        let hiddenKeyboardHeight = willHidePublisher.map({ _ in return CGFloat(0) })
        keyboardHeightPublisher = keyboardHeight.merge(with: hiddenKeyboardHeight).eraseToAnyPublisher()
        keyboardHeightOverSafeArea = keyboardHeightMinusSafeArea.merge(with: willHidePublisher.map({ _ in return 0 })).eraseToAnyPublisher()
    }
}


struct KeyboardHost<Content: View>: View {
    
    var handleSafeArea: Bool = true
    let view: Content

    @State private var keyboardHeight: CGFloat = 0

    // Like HStack or VStack, the only parameter is the view that this view should layout.
    // (It takes one view rather than the multiple views that Stacks can take)
    init(@ViewBuilder content: () -> Content) {
        view = content()
    }
    
    var body: some View {
        if #available(iOS 14.0, *) {
            return AnyView(view)
        } else {
            let heightPublisher = handleSafeArea ? KeyboardObserver.shared.keyboardHeightOverSafeArea : KeyboardObserver.shared.keyboardHeightPublisher
            return AnyView(
            VStack {
                view
                    .padding(.bottom, keyboardHeight)
                    .animation(.default)
            }
            .onReceive(heightPublisher) { (height) in
                self.keyboardHeight = height
            }
            )
        }
    }

}


struct GeometryGetter: View {
    @Binding var rect: CGRect
    
    var body: some View {
        GeometryReader { geometry in
            Group { () -> AnyView in
                DispatchQueue.main.async {
                    self.rect = geometry.frame(in: .global)
                }
                
                return AnyView(Color.clear)
            }
        }
    }
}
