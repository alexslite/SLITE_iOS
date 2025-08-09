//
//  Toast.swift
//  Slite
//
//  Created by Paul Marc on 19.05.2022.
//

import Foundation
import SwiftUI

struct Toast: ViewModifier {
    
    @Binding var isShowing: Bool
    let message: String
    let config: Config
    
    func body(content: Content) -> some View {
        ZStack {
            content
            toastView
        }
    }
    
    private var toastView: some View {
        VStack {
            Spacer()
            if isShowing {
                Group {
                    Text(message)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(config.textColor)
                        .font(config.font)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(config.backgroundColor)
                .cornerRadius(5)
                .onTapGesture {
                    isShowing = false
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + config.duration) {
                        isShowing = false
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, UIScreen.main.bounds.height * 0.75)
        .animation(config.animation, value: isShowing)
        .transition(config.transition)
    }
    
    struct Config {
        let textColor: Color
        let font: Font
        let backgroundColor: Color
        let duration: TimeInterval
        let transition: AnyTransition
        let animation: Animation
        
        init(textColor: Color = .white,
             font: Font = Font.Main.regular(size: 15),
             backgroundColor: Color = .midnightGreen,
             duration: TimeInterval = 2,
             transition: AnyTransition = .opacity,
             animation: Animation = .linear(duration: 0.3)) {
            self.textColor = textColor
            self.font = font
            self.backgroundColor = backgroundColor
            self.duration = duration
            self.transition = transition
            self.animation = animation
        }
    }
}

extension View {
    func toast(message: String,
               isShowing: Binding<Bool>,
               config: Toast.Config) -> some View {
        self.modifier(Toast(isShowing: isShowing,
                            message: message,
                            config: config))
    }
    
    func toast(message: String,
               isShowing: Binding<Bool>,
               duration: TimeInterval) -> some View {
        self.modifier(Toast(isShowing: isShowing,
                            message: message,
                            config: .init(duration: duration)))
    }
}
