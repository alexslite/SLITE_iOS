//
// AddMenuView.swift
// Slite
//
// Created by Efraim Budusan on 24.01.2022.
//
//

import Foundation
import SwiftUIX

struct AddMenu {
    
    struct ContentView: View {
        
        @EnvironmentObject var viewModel: ViewModel
        
        var body: some View {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    closeButton
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .frame(height: 44)
                        .padding(.top, UIWindow.safeAreaPadding(from: .top) + 20)
                        .background(Color.tartRed)
                    item(icon: Image("navigation_plus"), title: "Add Light", color: .tartRed, enabled: true)
                        .frame(height: 70)
                        .background(.tartRed)
                        .onTapGesture {
                            viewModel.onAddLight.send()
                        }
                }
                .offset(x: 0, y: viewModel.entranceAnimation == .armed ? -150 : 0)
                .animation(animationType(), value: viewModel.entranceAnimation)
                item(icon: Image("add_menu_group"), title: "Create Group", color: .coral, enabled: viewModel.isGroupEnabled)
                    .frame(height: 70)
                    .padding(.top, 20)
                    .background(.coral)
                    .zIndex(-1)
                    .offset(x: 0, y: viewModel.entranceAnimation == .armed ? -220 : -20)
                    .animation(animationType(), value: viewModel.entranceAnimation)
                    .onTapGesture {
                        viewModel.onCreateGroup.send()
                    }
                    .disabled(!viewModel.isGroupEnabled)
                item(icon: Image("add_menu_save_scene"), title: "Save Scene", color: .midnightGreen, enabled: viewModel.isScenesEnabled)
                    .frame(height: 70)
                    .padding(.top, 20)
                    .background(.midnightGreen)
                    .zIndex(-2)
                    .offset(x: 0, y: viewModel.entranceAnimation == .armed ? -290 : -40)
                    .animation(animationType(), value: viewModel.entranceAnimation)
                    .onTapGesture {
                        viewModel.onCreateScene.send()
                    }
                    .disabled(!viewModel.isScenesEnabled)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, -20)
            .edgesIgnoringSafeArea(.all)
        }
        
        func animationType() -> Animation {
            if viewModel.entranceAnimation == .finished {
                return .interpolatingSpring(stiffness: 300, damping: 20)
            } else {
                return .easeInOut
            }
        }
        
        
        
        func item(icon: Image, title: String, color: Color, enabled: Bool) -> some View {
            HStack {
                icon
                    .padding(.trailing, 20)
                Text(title)
                    .font(.Main.bold(size: 19))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .opacity(enabled ? 1 : 0.3)
            .padding(.horizontal, 24)
        }
        
        var closeButton: some View {
            Button(action: {
                viewModel.onClose.send()
            }) {
                Image("navigation_close")
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .frame(width: 68)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}
