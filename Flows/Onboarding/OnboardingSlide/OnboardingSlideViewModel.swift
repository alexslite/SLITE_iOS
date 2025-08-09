//
// OnboardingSlideViewModel.swift
// Slite
//
// Created by Efraim Budusan on 25.01.2022.
//
//

import Foundation
import Combine
import SwiftUI

extension OnboardingSlide {
    
    class ViewModel: ObservableObject {
        
        let item: OnboardingSlide.Item
        let index: Int
        let pageCount: Int
        
        let onCTA = PassthroughSubject<Void, Never>()
        
        init(item: OnboardingSlide.Item, index: Int, pageCount: Int) {
            self.item = item
            self.index = index
            self.pageCount = pageCount
        }
    }
}

extension OnboardingSlide {
    
    static var allSlides: [Item] {
        return [.welcome, .bringToLife, .scenesEffects]
    }
    
    enum Item {
        case welcome
        case bringToLife
        case scenesEffects
        
        var title: String {
            switch self {
            case .welcome:
                return Texts.Onboarding.firstTitle
            case .bringToLife:
                return Texts.Onboarding.secondTitle
            case .scenesEffects:
                return Texts.Onboarding.thirdTitle
            }
        }
        
        var description: String {
            switch self {
            case .welcome:
                return Texts.Onboarding.firstDescription
            case .bringToLife:
                return Texts.Onboarding.secondDescription
            case .scenesEffects:
                return Texts.Onboarding.thirdDescription
            }
        }
        
        var image: Image {
            switch self {
            case .welcome:
                return Image("walkthrough_1")
            case .bringToLife:
                return Image("walkthrough_2")
            case .scenesEffects:
                return Image("walkthrough_3")
            }
        }
        
        var nextButtonColor: Color {
            switch self {
            case .welcome:
                return .black
            case .bringToLife:
                return .tartRed
            case .scenesEffects:
                return .clear
            }
        }
    }
}
