//
//  View + Extensions.swift
//  Slite
//
//  Created by Efraim Budusan on 21.01.2022.
//

import Foundation
import SwiftUI

extension View {
    @inlinable
    public func then(_ body: (inout Self) -> Void) -> Self {
        var result = self
        body(&result)
        return result
    }
    
    /// Returns a type-erased version of `self`.
    @inlinable
    public func eraseToAnyView() -> AnyView {
        return .init(self)
    }
}

extension View {
    
    func onTouchDown(_ callback: @escaping (Bool) -> Void) -> some View{
        return self.modifier(TouchDownListenerViewModifier(onChange: callback))
    }

    func emailStyle() -> some View {
        modifier(EmailViewModifier())
    }

    func passwordStyle() -> some View {
        modifier(PasswordViewModifier())
    }
}


struct TouchDownListenerViewModifier: ViewModifier {

    let onChange: (Bool) -> ()

    func body(content: Content) -> some View {
        let tap = DragGesture(minimumDistance: 0)
            .onChanged({ _ in
                onChange(true)
            })
            .onEnded { _ in
                onChange(false)
            }
        return content.simultaneousGesture(tap)
    }
}

struct EmailViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .frame(height: 50)
            .padding(.horizontal)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.coral))
    }
}

struct PasswordViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .frame(height: 50)
            .padding(.horizontal)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.coral))
    }
}

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: @autoclosure () -> Bool, transform: (Self) -> Content) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder func ignoreKeyboard() -> some View {
        if #available(iOS 14.0, *) {
            self.ignoresSafeArea(.keyboard, edges: .bottom)
        } else {
            self
        }
    }
    
    @ViewBuilder func `unwrap`<Content: View, Value>(_ value: Value?, transform: (Self, Value) -> Content) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }
}
