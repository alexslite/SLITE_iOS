//
//  HomeViewModel.swift
//  Slite
//
//  Created by Efraim Budusan on 24.01.2022.
//

import Foundation
import SwiftUI
import Combine

extension Home {
    
    class ViewModel: ObservableObject {
         
        var selectedIndex: Int = 0
        var previousSelectedIndex: Int?

        var selectedTab: TabBarItem {
            get {
                return allTabs[selectedIndex]
            }
            set {
                let index = allTabs.firstIndex(of: newValue) ?? 0
                select(tab: index, animated: true)
            }
        }
        
        var allTabs: [TabBarItem] = [.lights, .scenes]
        
        func select(tab: Int, animated: Bool = true) {
            if tab == selectedIndex {
                return
            }
            self.previousSelectedIndex = selectedIndex
            self.selectedIndex = tab
            if animated {
                withAnimation {
                    self.objectWillChange.send()
                }
            } else {
                self.objectWillChange.send()
            }
        }
    }
    
    enum TabBarItem {
        case lights
        case scenes
        
        var icon: Image {
            switch self {
            case .lights:
                return Image("home_lights")
            case .scenes:
                return Image("home_scenes")
            }
        }
        
        var title: String {
            switch self {
            case .lights:
                return "Lights"
            case .scenes:
                return "Scenes"
            }
        }
    }
}
