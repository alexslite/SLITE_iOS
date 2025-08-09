//
//  SceneControlItem.swift
//  Slite
//
//  Created by Paul Marc on 04.05.2022.
//

import Foundation
import SwiftUI

struct SceneControlItem {
    
    struct ContentView: View {
        
        var scene: Scene
        
        @State var swipeState: SwipeState = .programatic(false)
        
        var onRename: (() -> Void) = { }
        var onRemove: (() -> Void) = { }
        var onApply: (() -> Void) = { }
        
        var body: some View {
            VStack(spacing: 0) {
                baseContent
                    .background(
                        VStack {
                            if scene.state == .idle {
                                LinearGradient(colors: scene.gradientColors,
                                               startPoint: .leading,
                                               endPoint: .trailing).transition(.opacity)
                                    .cornerRadius(5)
                            } else {
                                LinearGradient(colors: [Color.eerieBlack],
                                               startPoint: .leading,
                                               endPoint: .trailing).transition(.opacity)
                                    .cornerRadius(5)
                            }
                        }
                            .overlay(LinearGradient(colors: [.black.opacity(0), .black.opacity(0.5)], startPoint: .top, endPoint: .bottom))
                            
                    )
                    .addSwipe(state: $swipeState, maxDragDistance: 148, onTap: {
                        
                    }, background: {
                        slideButtons
                    })
            }
            .transition(.opacity)
            .background(RoundedRectangle(cornerRadius: 5)
                            .fill(Color.primaryBackground)
            )
        }
        
        var baseContent: some View {
            HStack(alignment: .center, spacing: 0) {
                colorView
                    .padding(.trailing, 24)
                    .transition(.opacity)
                centerContentView
                    .padding(.trailing, 8)
                settingsButton
                    .frame(alignment: .trailing)
            }
            .padding(EdgeInsets(top: 24, leading: 24, bottom: 24, trailing: 0))
        }
        
        var settingsButton: some View {
            Button(action: {
                swipeState = swipeState.toggle
            }) {
                Image("core_options")
                    .frame(width: 48)
                    .frame(height: 48)
            }
        }
        
        @ViewBuilder
        var colorView: some View {
            if scene.state == .idle {
                Image("lights_power")
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(.black))
                    .onTapGesture {
                        withAnimation {
                            onApply()
                        }
                    }
                    .transition(.opacity)
            } else {
                ZStack {
                    Circle()
                        .fill(Color.tartRed)
                        .frame(width: 40, height: 40)
                    Image("core_checkmark")
                        .renderingMode(.original)
                        .frame(alignment: .center)
                }
                .transition(.opacity)
            }
        }
        
        var centerContentView: some View {
            Text(scene.name)
                .foregroundColor(.primaryForeground)
                .font(Font.Main.bold(size: 19))
                .truncationMode(.tail)
                .lineLimit(1)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading )
        }
        
        var slideButtons: some View {
            HStack(spacing: 2) {
                Button(action: {
                    onRename()
                }) {
                    VStack {
                        Image("core_edit")
                        Text("Rename")
                            .font(.Main.regular(size: 13))
                            .foregroundColor(.white)
                    }
                    .frame(width: 72)
                    .frame(maxHeight: .infinity)
                    .background(RoundedRectangle(cornerRadius: 5).fill(Color.midnightGreen))
                }
                Button(action: {
                    onRemove()
                }) {
                    VStack {
                        Image("core_remove")
                        Text("Remove")
                            .font(.Main.regular(size: 13))
                            .foregroundColor(.white)
                    }
                    .frame(width: 72)
                    .frame(maxHeight: .infinity)
                    .background(RoundedRectangle(cornerRadius: 5).fill(Color.tartRed))
                }
            }
            .padding(.leading, 2)
        }


    }

}
