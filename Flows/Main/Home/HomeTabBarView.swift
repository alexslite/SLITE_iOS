//
//  TabBarView.swift
//  Slite
//
//  Created by Efraim Budusan on 24.01.2022.
//

import Foundation
import SwiftUI
import SwiftUIX

struct Home {
    
    struct TabBarContentView: View {
        
        @EnvironmentObject var viewModel: ViewModel
        
        var body: some View {
            HStack {
                TabBarButton(icon: TabBarItem.lights.icon, title: TabBarItem.lights.title, isSelected: viewModel.selectedTab == .lights, onSelected: {
                    viewModel.selectedTab = .lights
                })
                TabBarButton(icon: TabBarItem.scenes.icon, title: TabBarItem.scenes.title, isSelected: viewModel.selectedTab == .scenes, onSelected: {
                    viewModel.selectedTab = .scenes
                })
            }
            .overlayPreferenceValue(TabBarButtonAnchor.self) { value in
                if let value = value {
                    GeometryReader { proxy in
                        Circle()
                            .fill(Color.tartRed)
                            .frame(width: 4, height: 4)
                            .offset(x: proxy[value].x - 2, y: proxy[value].y - 4)
                    }
                }
            }
        }   
    }
    
    struct TabBarButton: View {
        
        let icon: Image
        let title: String
        let isSelected: Bool
        let onSelected: () -> Void
        
        var body: some View {
            Button(action: onSelected) {
                VStack(spacing: 7) {
                    icon
                        .renderingMode(.template)
                        .foregroundColor(isSelected ? .tartRed : .primaryForeground)
                    Text(title)
                        .font(Font.Main.regular(size: 10))
                        .opacity(isSelected ? 0 : 1.0)
                }
                .padding(.top, 10)
                .anchorPreference(key: TabBarButtonAnchor.self, value: .bottom) { anchor in
                    if isSelected {
                        return anchor
                    } else {
                        return nil
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PlainButtonStyle())

        }
        
    }
    
    struct TabBarButtonAnchor: PreferenceKey {
        static var defaultValue: Anchor<CGPoint>? = nil
        
        static func reduce(value: inout Anchor<CGPoint>?, nextValue: () -> Anchor<CGPoint>?) {
            value = value ?? nextValue()
        }
    }
    
    class TabBarView: UIHostingView<AnyView> {
        
        init(viewModel: ViewModel) {
            let contentView = TabBarContentView().edgesIgnoringSafeArea(.all).environmentObject(viewModel)
            super.init(rootView: contentView.eraseToAnyView())
            self._fixSafeAreaInsets()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        required init(rootView: AnyView) {
            fatalError("init(rootView:) has not been implemented")
        }
        
    }
}
