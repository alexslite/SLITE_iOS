//
// LightDetailsView.swift
// Slite
//
// Created by Efraim Budusan on 07.02.2022.
//
//

import Foundation
import SwiftUI

struct LightDetails {
    
    struct ContentView: View {
        
        @EnvironmentObject var viewModel: LightDetailsViewModel
        
        var body: some View {
            VStack(spacing: 0) {
                LightControlItem.ContentView(viewModel: .init(viewModel.light), isExpanded: isExpandedBinding, backgroundColor: .black, titleColor: .primaryForeground, isExpandable: false, onRename: {
                    viewModel.nameAction()
                }, onRemove: {
                    viewModel.removeAction()
                }, onStateChanged: {
                    guard viewModel.light.data.state == .turnedOff else { return }
                    viewModel.onTurnOff.send(viewModel.light)
                })
                    .frame(height: 88)
                    .padding(EdgeInsets(top: 0, leading: 24, bottom: 24, trailing: 24))
                Group {
                    switch viewModel.tab {
                    case .white:
                        WhiteTabView()
                    case .colors:
                        ColorTabView()
                    case .effects:
                        EffectsTabView()
                    }
                }
                TabView(selectedTab: $viewModel.tab)
                    .padding(.bottom, UIWindow.safeAreaPadding(from: .bottom))
                    .background(Color.primaryBackground.edgesIgnoringSafeArea(.all))
            }
        }
        
        var isExpandedBinding: Binding<Bool> {
            return .init {
                return false
            } set: { _ in
                
            }
        }
    }
}

extension LightDetails {
    
    struct QuickAdjustButton: View {
        
        let title: String
        let action: () -> Void
        
        var body: some View {
            Button {
                action()
            } label: {
                Text(title)
                    .font(.Main.regular(size: 13))
                    .foregroundColor(.primaryForeground)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.primaryBackground))
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}
