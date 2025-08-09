//
// LightDetailsViewModel.swift
// Slite
//
// Created by Efraim Budusan on 07.02.2022.
//
//

import Foundation
import Combine
import SwiftUI
import Mixpanel
 
extension LightDetails {
    
    class LightDetailsViewModel: AnyObservableObject {
        
        var light: LightControlViewModel
        let inputName = Delegated<String, PassthroughSubject<String, Never>>()
        let onRemove = PassthroughSubject<LightData, Never>()
        let onTurnOff = PassthroughSubject<LightControlViewModel, Never>()
        let onLightWasTurnedOff = PassthroughSubject<Void, Never>()
        
        @Published var tab: Tab {
            didSet {
                switch tab {
                case .white:
                    light.updateToWhiteColorMode(shouldWrite: true)
                    stopOngoingEffect()
                    
                    Analytics.shared.trackEvent(.advancedModeWhite, properties: [
                        "Brightness value set": "\(light.data.brightnessLevel)",
                        "kelvin value set": "\(light.data.temperatureLevel)"
                    ])
                case .colors:
                    light.updateToColorMode(colorHex: hsv.rgb.hexStringValue, shouldWrite: true)
                    stopOngoingEffect()
                    
                    Analytics.shared.trackEvent(.advancedModeColor, properties: [
                        "Brightness value set": "\(light.data.brightnessLevel)",
                        "Saturation value set": "\(light.data.saturationLevel)",
                        "Hue value set": "\(light.data.hue)"
                    ])
                case .effects:
                    light.updateToEffectsMode(shouldWrite: true)
                    
                    if let effectName = light.effect?.title {
                        Analytics.shared.trackEvent(.advancedModeEffect, properties: ["effectName": "\(effectName)"])
                    } else {
                        Analytics.shared.trackEvent(.advancedModeEffect)
                    }
                }
            }
        }
        
        @Published var hsv: HSV {
            didSet {
                self.light.data.colorHex = hsv.rgb.hexStringValue
            }
        }

        let onTabChange = PassthroughSubject<Tab, Never>()
        let inputHexValue = Delegated<Void, PassthroughSubject<String, Never>>()
        let cameraInput = PassthroughSubject<Void, Never>()
        
        var disposeBag = [AnyCancellable]()
        
        init(_ light: LightControlViewModel) {
            self.light = light
            let hsv = RGB(hexadecimal: light.data.hueColor.hexValue).hsv
            self.hsv = hsv
            
            var brightnessDisplayHSV = RGB(hexadecimal: light.data.hueColor.hexValue).hsv
            brightnessDisplayHSV.v = light.brightness.percentage
            
            switch light.data.mode {
            case .color:
                self.tab = .colors
                light.updateToColorMode(colorHex: hsv.rgb.hexStringValue, shouldWrite: true)
                
                Analytics.shared.trackEvent(.advancedModeColor, properties: [
                    "Brightness value set": "\(light.data.brightnessLevel)",
                    "Saturation value set": "\(light.data.saturationLevel)",
                    "Hue value set": "\(light.data.hue)"
                ])
            case .whiteWithTemperature:
                self.tab = .white
                light.updateToWhiteColorMode(shouldWrite: true)
                
                Analytics.shared.trackEvent(.advancedModeWhite, properties: [
                    "Brightness value set": "\(light.data.brightnessLevel)",
                    "kelvin value set": "\(light.data.temperatureLevel)"
                ])
            case .effect:
                self.tab = .effects
                light.updateLightsToEffectMode(shouldWrite: true)
                
                if let effectName = light.effect?.title {
                    Analytics.shared.trackEvent(.advancedModeEffect, properties: ["effectName": "\(effectName)"])
                } else {
                    Analytics.shared.trackEvent(.advancedModeEffect)
                }
            }
            
            super.init(base: light)
            
            // Callback for updating HSV when hardware settings change
            light.lightUpdateCallback = { [unowned self] in
                updateLight()
            }
        }
        
        func setEffect(_ effect: LightData.Effect) {
            light.startEffect(effect)
        }
        
        func stopOngoingEffect() {
            light.stopOngoingEffect()
        }
        
        func nameAction() {
            (try? inputName.call(with: light.data.name))?.sink { [unowned self] name in
                light.data.name = name
            }.store(in: &disposeBag)
        }
        
        func removeAction() {
            onRemove.send(light.data)
        }
        
        func setTemperature(percentage: CGFloat, animated: Bool) {
            withAnimation(.easeInOut) {
                light.setTemperatureFromUserAction(percentage: percentage)
            }
        }

        func setBrightness(percentage: CGFloat, animated: Bool) {
            withAnimation(.easeInOut) {
                light.setBrightnessFromUserAction(percentage: percentage)
            }
        }
        
        func setRGB(newValue: RGB) {
            self.hsv = newValue.hsv
            self.light.setHueAndSaturationFromUserAction(hueValue: Int(hsv.h), saturationPercentage: hsv.s)
        }
        
        var displayColorBrightness: Binding<CGFloat> {
            .init {
                return self.hsv.v
            } set: { newValue in
                
            }
        }
        
        var colorBrightness: Binding<CGFloat> {
            .init {
                return self.light.brightness.percentage
            } set: { newValue in
                self.light.setBrightnessFromUserAction(percentage: newValue)
            }
        }
        
        var saturation: Binding<CGFloat> {
            .init {
                return self.hsv.s
            } set: { newValue in
                self.hsv.s = newValue
            }
        }
        func setSaturation(newValue: CGFloat) {
            self.hsv.s = newValue
            self.light.setHueAndSaturationFromUserAction(hueValue: Int(hsv.h), saturationPercentage: hsv.s)
        }
        
        var saturationLevel: Int {
            return Int(saturation.wrappedValue * 100.0)
        }
        
        var colorBrightnessLevel: Int {
            return Int(colorBrightness.wrappedValue * 100.0)
        }
        
        func hexAction() {
            (try? inputHexValue.call())?.sink { [unowned self] hexValue in
                hsv = RGB(hexadecimal: hexValue).hsv.fullBrightness
                self.light.setHueAndSaturationFromUserAction(hueValue: Int(hsv.h), saturationPercentage: hsv.s)
            }.store(in: &disposeBag)
        }

        func setColorFromCameraView(_ color: UIColor) {
            self.hsv = RGB(hexadecimal: color.hexValue).hsv.fullBrightness
            self.light.setHueAndSaturationFromUserAction(hueValue: Int(hsv.h), saturationPercentage: hsv.s)
        }
        
        private func updateLight() {
            if light.data.state == .turnedOff {
                self.onLightWasTurnedOff.send()
            }
            self.hsv = RGB(hexadecimal: light.data.hueColor.hexValue).hsv
            
            
            
            switch light.data.mode {
            case .color:
                withAnimation(.easeInOut) {
                    guard tab != .colors else { return }
                    self.tab = .colors
                }
            case .whiteWithTemperature:
                withAnimation(.easeInOut) {
                    guard tab != .white else { return }
                    self.tab = .white
                }
            case .effect:
                withAnimation(.easeInOut) {
                    guard tab != .effects else { return }
                    self.tab = .effects
                }
            }
        }
    }
}
