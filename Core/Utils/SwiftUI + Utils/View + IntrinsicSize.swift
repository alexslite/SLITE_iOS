//
//  View + IntrinsicSize.swift
//  THX
//
//  Created by Efraim Budusan on 24.06.2021.
//  Copyright © 2021 THX. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
    
    func intrinsicContentSize(fittingWidth: CGFloat? = nil,  fittingHeight: CGFloat? = nil, _ callback: @escaping (CGSize) -> ()) -> some View {
        return self.modifier(IntrinsicSizeReaderModifier(fittingWidth: fittingWidth, fittingHeight: fittingHeight, onSizeChange: callback))
    }

    /// WARNING: This is a thread blocking method. Use it only on a background thread or with care on the main thread
    
    func intrinsicContentSize(fittingWidth: CGFloat? = nil,  fittingHeight: CGFloat? = nil) -> CGSize {
        let hostingViewController = UIHostingController(rootView: self)
        return hostingViewController.view.systemLayoutSizeFitting(CGSize(width: fittingWidth ?? 0, height: fittingHeight ?? 0), withHorizontalFittingPriority: fittingWidth != nil ? .required : .defaultLow, verticalFittingPriority: fittingHeight != nil ? .required : .defaultLow)
    }
}

extension UIHostingController {
    
    func intrinsicContentSize(fittingWidth: CGFloat? = nil,  fittingHeight: CGFloat? = nil) -> CGSize {
        return self.view.systemLayoutSizeFitting(CGSize(width: fittingWidth ?? 0, height: fittingHeight ?? 0), withHorizontalFittingPriority: fittingWidth != nil ? .required : .defaultLow, verticalFittingPriority: fittingHeight != nil ? .required : .defaultLow)
    }
}


struct IntrinsicSizeReaderModifier: ViewModifier {
    
    let fittingWidth: CGFloat?
    let fittingHeight: CGFloat?
    let onSizeChange: (CGSize) -> ()
    
    func body(content: Content) -> some View {
        content.background(
            content
                .unwrap(fittingWidth, transform: { view, value in
                    return view.frame(width: value)
                })
                .unwrap(fittingHeight, transform: { view, value in
                    return view.frame(height: value)
                })
            .fixedSize(horizontal: fittingWidth == nil, vertical: fittingHeight == nil)
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: _PreferenceKey.self, value: proxy.size)
                }
            )
            .hidden()
        )
        .onPreferenceChange(_PreferenceKey.self) { preferences in
            if let value = preferences {
                self.onSizeChange(value)
            }
        }
    }
    
    struct _PreferenceKey: PreferenceKey {
        typealias Value = CGSize?
        static var defaultValue: Value = nil
        
        static func reduce(value _: inout Value, nextValue: () -> Value) {
            _ = nextValue()
        }
    }
}
