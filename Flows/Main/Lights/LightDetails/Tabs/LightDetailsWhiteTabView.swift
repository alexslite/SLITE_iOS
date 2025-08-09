//
//  LightDetailsWhiteTabView.swift
//  Slite
//
//  Created by Efraim Budusan on 21.02.2022.
//

import Foundation
import SwiftUIX
import SwiftUI

extension LightDetails {
    
    struct WhiteTabView: View {
        
        @EnvironmentObject var viewModel: LightDetails.LightDetailsViewModel
        
        var body: some View {
            VStack(spacing: 0) {
                brightnessSlider
                    .padding(.bottom, 8)
                temperatureSlider
                    .padding(.bottom, 8)
            }
            .padding(EdgeInsets(top: 3, leading: 24, bottom: 0, trailing: 24))
        }
        
        var brightnessSlider: some View {
            SliderView(icon: Image("lights_brightness"), title: "\(viewModel.light.data.brightnessLevel)%", subtitle: Text("Brightness"), buttons: {
                brightnessQuickAction
                    .padding(.bottom, 48)
            }, sliderProgress: .init(get: {
                return viewModel.light.data.brightnessPercentage
            }, set: { percentage in
                viewModel.light.setBrightnessFromUserAction(percentage: percentage)
            }), onGestureEnd: {
                Analytics.shared.trackEvent(.advancedModeWhite, properties: [
                    "Brightness value set": "\(viewModel.colorBrightnessLevel)",
                    "Kelvin value set": "\(viewModel.light.data.temperatureLevel)"
                ])
            })
        }
        
        var brightnessQuickAction: some View {
            HStack(spacing: 2) {
                QuickAdjustButton(title: "0%") {
                    viewModel.setBrightness(percentage: 0, animated: true)
                    
                    Analytics.shared.trackEvent(.advancedModeWhite, properties: [
                        "Brightness value set": "0",
                        "Kelvin value set": "\(viewModel.light.data.temperatureLevel)"
                    ])
                }
                QuickAdjustButton(title: "25%") {
                    viewModel.setBrightness(percentage: 0.25, animated: true)
                    
                    Analytics.shared.trackEvent(.advancedModeWhite, properties: [
                        "Brightness value set": "25",
                        "Kelvin value set": "\(viewModel.light.data.temperatureLevel)"
                    ])
                }
                QuickAdjustButton(title: "50%") {
                    viewModel.setBrightness(percentage: 0.5, animated: true)
                    
                    Analytics.shared.trackEvent(.advancedModeWhite, properties: [
                        "Brightness value set": "50",
                        "Kelvin value set": "\(viewModel.light.data.temperatureLevel)"
                    ])
                }
                QuickAdjustButton(title: "75%") {
                    viewModel.setBrightness(percentage: 0.75, animated: true)
                    
                    Analytics.shared.trackEvent(.advancedModeWhite, properties: [
                        "Brightness value set": "75",
                        "Kelvin value set": "\(viewModel.light.data.temperatureLevel)"
                    ])
                }
                QuickAdjustButton(title: "100%") {
                    viewModel.setBrightness(percentage: 1, animated: true)
                    
                    Analytics.shared.trackEvent(.advancedModeWhite, properties: [
                        "Brightness value set": "100",
                        "Kelvin value set": "\(viewModel.light.data.temperatureLevel)"
                    ])
                }
            }
            .frame(height: 32)
        }
        
        var temperatureSlider: some View {
            TemperatureSliderView(icon: Image("lights_temperature"), title: "\(viewModel.light.data.temperatureLevel)K", subtitle: Text("Temperature"), buttons: {
                temperatureQuickAction
                    .padding(.bottom, 48)
            }, sliderProgress: .init(get: {
                return viewModel.light.data.temperaturePercentage
            }, set: { percentage in
                viewModel.light.setTemperatureFromUserAction(percentage: percentage)
            }), onGestureEnded: {
                Analytics.shared.trackEvent(.advancedModeWhite, properties: [
                    "Brightness value set": "\(viewModel.light.data.brightnessLevel)",
                    "Kelvin value set": "\(viewModel.light.data.temperatureLevel)"
                ])
            })
        }
        
        var temperatureQuickAction: some View {
            HStack(spacing: 2) {
                QuickAdjustButton(title: "Tungsten") {
                    viewModel.setTemperature(percentage: 0.15, animated: true)
                    Analytics.shared.trackEvent(.advancedModeWhite, properties: [
                        "Brightness value set": "\(viewModel.light.data.brightnessLevel)",
                        "Kelvin value set": "3200"])
                }
                QuickAdjustButton(title: "Daylight") {
                    viewModel.setTemperature(percentage: 0.45, animated: true)
                    Analytics.shared.trackEvent(.advancedModeWhite, properties: [
                        "Brightness value set": "\(viewModel.light.data.brightnessLevel)",
                        "Kelvin value set": "5600"])
                }
                QuickAdjustButton(title: "Cool White") {
                    viewModel.setTemperature(percentage: 0.6875, animated: true)
                    Analytics.shared.trackEvent(.advancedModeWhite, properties: [
                        "Brightness value set": "\(viewModel.light.data.brightnessLevel)",
                        "Kelvin value set": "7500"])
                }
            }
            .frame(height: 32)
        }
    }
}
