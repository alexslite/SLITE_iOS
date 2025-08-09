//
//  LightDetailsEffectsTabView.swift
//  Slite
//
//  Created by Efraim Budusan on 22.02.2022.
//

import SwiftUI

extension LightDetails {
    
    struct EffectsTabView: View {
        
        @EnvironmentObject var viewModel: LightDetails.LightDetailsViewModel
        
        var body: some View {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    
                    HStack(spacing: 16) {
                        effectView(.fireworks)
                        effectView(.paparazzi)
                    }
                    HStack(spacing: 16) {
                        effectView(.lightning)
                        effectView(.police)
                    }
                    HStack(spacing: 16) {
                        effectView(.disco)
                        effectView(.faulty)
                    }
                    HStack(spacing: 16) {
                        effectView(.fire)
                        effectView(.pulsing)
                    }
                    HStack(spacing: 16) {
                        effectView(.strobe)
                        effectView(.tv)
                    }
                }
                .onAppear {
                    UIScrollView.appearance().bounces = false
                }
                .onDisappear {
                    UIScrollView.appearance().bounces = true
                }
                .padding(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
            }
            .padding(.bottom, 24)
            .frame(maxHeight: UIScreen.main.bounds.height * 0.6)
        }
        
        func effectView(_ effect: LightData.Effect) -> some View {
            let isSelected = viewModel.light.effect == effect
            return Button {
                viewModel.setEffect(effect)
                Analytics.shared.trackEvent(.advancedModeEffect, properties: [
                    "effectName": "\(effect.title)"
                ])
            } label: {
                effectViewContent(effect, isSelected: isSelected)
            }
            .buttonStyle(PlainButtonStyle())
        }
        
        func effectViewContent(_ effect: LightData.Effect, isSelected: Bool) -> some View {
            VStack(alignment: .leading, spacing: 12) {
                Image(effect.assetName)
                    .renderingMode(.template)
                    .foregroundColor(.primaryForeground)
                Text(effect.title)
                    .font(.Main.bold(size: 19))
                    .foregroundColor(.primaryForeground)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .overlay({
                if isSelected {
                    checkmark
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }
            })
            .padding(.all, 16)
            .background {
                RoundedRectangle(cornerRadius: 5)
                    .fill(isSelected ? Color.primaryBackground : Color.secondaryBackground)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.primaryBackground, lineWidth: 1)
            }
        }
        
        var checkmark: some View {
            Image("core_checkmark")
                .renderingMode(.template)
                .foregroundColor(.primaryForeground)
                .frame(width: 24, height: 24)
                .background {
                    Circle()
                        .fill(Color.tartRed)
                }
        }
        
    }
    
}



