//
//  LightDetailsTabView.swift
//  Slite
//
//  Created by Efraim Budusan on 11.02.2022.
//

import Foundation
import SwiftUIX

extension LightDetails {
    
    enum Tab {
        case white
        case colors
        case effects
    }

    struct TabView: View {
        
        @Binding var selectedTab: Tab

        var body: some View {
            HStack {
                TabBarButton(title: "White", isSelected: selectedTab == .white) {
                    withAnimation(.easeInOut) {
                        selectedTab = .white
                    }
                    
                }
                TabBarButton(title: "Colors", isSelected: selectedTab == .colors) {
                    withAnimation(.easeInOut) {
                        selectedTab = .colors
                    }
                }
                TabBarButton(title: "Effects", isSelected: selectedTab == .effects) {
                    if UIApplication.shouldShowWarning {
                        UIApplication.showWarningAlert {
                            withAnimation(.easeInOut) {
                                selectedTab = .effects
                            }
                        }
                    } else {
                        withAnimation(.easeInOut) {
                            selectedTab = .effects
                        }
                    }
                }
            }
            .overlayPreferenceValue(TabBarButtonAnchor.self) { value in
//                HStack {
//                    Rectangle()
//                        .background(.tartRed)
//                        .frame(.init(width: UIScreen.main.bounds.width / 3, height: 2), alignment: .leading)
//                }
//                .frame(maxWidth: .infinity)
                
            }
            .frame(height: 51)
        }
    }
    
    struct TabBarButton: View {
        
        let title: String
        let isSelected: Bool
        let onSelected: () -> Void
        
        @ViewBuilder
        var image: some View {
            switch title {
            case "White":
                Image("tab_whiteMode")
                    .renderingMode(.template)
                    .foregroundColor(isSelected ? .tartRed : .primaryForeground)
            case "Colors":
                Image("tab_colorMode")
                    .renderingMode(.template)
                    .foregroundColor(isSelected ? .tartRed : .primaryForeground)
            case "Effects":
                Image("tab_effectsMode")
                    .renderingMode(.template)
                    .foregroundColor(isSelected ? .tartRed : .primaryForeground)
            default:
                Image("")
            }
        }
        
        var body: some View {
            Button(action: onSelected) {
                VStack(spacing: 7) {
                    Rectangle()
                        .frame(maxWidth: .infinity)
                        .frame(height: 2)
                        .foregroundColor(isSelected ? .tartRed : .clear)
                    image
                    Text(title)
                        .font(Font.Main.regular(size: 13))
                        .foregroundColor(isSelected ? .tartRed : .primaryForeground)
                        .frame(height: 16)
                }
                .anchorPreference(key: TabBarButtonAnchor.self, value: .bottom) { anchor in
                    if isSelected {
                        return anchor
                    } else {
                        return nil
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
}
