//
//  ScenePopUp.swift
//  Slite
//
//  Created by Paul Marc on 23.05.2022.
//

import Foundation
import SwiftUI

extension View {

    public func popup<ContentView: View>(
        isPresented: Binding<Bool>,
        view: @escaping () -> ContentView) -> some View {
        self.modifier(
            Popup(
                isPresented: isPresented,
                view: view)
        )
    }
}

public struct Popup<ContentView>: ViewModifier where ContentView: View {
    
    init(isPresented: Binding<Bool>,
         view: @escaping () -> ContentView) {
        self._isPresented = isPresented
        self.view = view
    }

    @Binding var isPresented: Bool
    var view: () -> ContentView
    
    // MARK: - Private Properties
    
    @State private var presenterContentRect: CGRect = .zero
    @State private var sheetContentRect: CGRect = .zero

    private var displayedOffset: CGFloat {
        -presenterContentRect.midY + screenHeight/2
    }

    private var screenWidth: CGFloat {
        UIScreen.main.bounds.size.width
    }

    private var screenHeight: CGFloat {
        UIScreen.main.bounds.size.height
    }
    
    // MARK: - Content Builders
    public func body(content: Content) -> some View {
        ZStack {
            content
              .frameGetter($presenterContentRect)
              .blur(radius: isPresented ? 5 : 0, opaque: false)
              .overlay(Color.black.opacity(isPresented ? 0.7 : 0))
              
        }
        .overlay(sheet())
    }

    func sheet() -> some View {
        ZStack {
            self.view()
              .simultaneousGesture(
                  TapGesture().onEnded {
                      dismiss()
              })
              .frameGetter($sheetContentRect)
              .frame(width: screenWidth)
              .offset(x: 0, y: displayedOffset)
              .hidden(!isPresented)
              .transition(.opacity)
        }
    }

    private func dismiss() {
        isPresented = false
    }
}

// MARK: - FrameGetter

extension View {
    func frameGetter(_ frame: Binding<CGRect>) -> some View {
        modifier(FrameGetter(frame: frame))
    }
}
  
struct FrameGetter: ViewModifier {
  
    @Binding var frame: CGRect
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy -> AnyView in
                    let rect = proxy.frame(in: .global)
                    // This avoids an infinite layout loop
                    if rect.integral != self.frame.integral {
                        DispatchQueue.main.async {
                            self.frame = rect
                        }
                    }
                return AnyView(EmptyView())
            })
    }
}
