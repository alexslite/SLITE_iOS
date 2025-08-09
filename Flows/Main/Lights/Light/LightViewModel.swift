//
//  LightViewModel.swift
//  Slite
//
//  Created by Efraim Budusan on 07.02.2022.
//

import Foundation
import UIKit
import SwiftUI
import Combine

class LightViewModel: ObservableObject, LightControlViewModel {
    
    @Published var data: LightData
    @Published var effect: LightData.Effect? = nil
    
    var shouldStopGroupedEffectCallback: (() -> Void)?
    
    var snapShot: LightSnapshot {
        LightSnapshot(id: data.id, dataOutput: data.dataOutput, mode: data.mode, effect: effect, color: sceneGradientColors)
    }
    
    var lightUpdateCallback: (() -> Void)?
    
    var isDisconnectedOrTurnedOff: Bool {
        data.isDisconnected || data.isTurnedOff
    }
    var isGroup: Bool {
        false
    }
    var showSubtitleIcon: Bool {
        return true
    }
    var subtitle: String {
        return data.state.title
    }
    var powerButtonGradient: LinearGradient {
        switch data.mode {
        case .effect:
            return effect?.gradient ?? data.singleColorGradient
        default:
            return data.singleColorGradient
        }
    }
    var sceneGradientColors: [Color] {
        switch data.mode {
        case .effect:
            return effect?.gradientColors ?? [data.color]
        case .whiteWithTemperature, .color:
            return [data.color]
        }
    }
    
    // used for refreshing group control item when a connection state change for a light in group
    var onStateChanged = PassthroughSubject<Void, Never>()
    
    // MARK: - Init
    
    init(data: LightData) {
        self.data = data
    }
    
    // MARK: - BT Observers
    
    func setupConnectionStateCallback() {
        BLEService.shared.setConnectionStateUpdateCallback(data.id) { [weak self] isConnected in
            guard let self = self else { return }
            if isConnected {
                self.setupLightInfoCallback()
            } else {
                self.data.state = .disconnected
                self.lightUpdateCallback?()
                self.onStateChanged.send()
            }
        }
    }
    
    func setupLightInfoCallback() {
        BLEService.shared.setUpdateCallbackForLightWith(data.id) { [weak self] lightStatusData in
            guard let self = self else { return }
            self.updateState(lightStatusData.blackout ?? self.data.state)
            self.brightness.set(value: lightStatusData.brightness)
            self.temperature.set(value: lightStatusData.temperature)
            self.hue.set(value: lightStatusData.hue)
            self.saturation.set(value: lightStatusData.saturation)
            
            self.restartLastEffect()
            
            self.lightUpdateCallback?()
        }
        
        BLEService.shared.setTurnedOffCallbackForLightWith(data.id) { [weak self] in
            self?.updateState(.turnedOff)
            
            self?.stopOngoingEffect()
        }
        
        BLEService.shared.setModeUpdateCallback(data.id) { [weak self] mode in
            guard mode != self?.data.mode else { return }
            switch mode {
            case .whiteWithTemperature:
                self?.updateToWhiteColorMode()
            case .color:
                self?.updateToColorMode()
            case .effect:
                return
            }
            self?.lightUpdateCallback?()
        }
    }
    
    private func updateState(_ state: LightData.State) {
        data.state = state
        onStateChanged.send()
    }
    
    func updateToColorMode(colorHex: String = "", shouldWrite: Bool = false) {
        stopOngoingEffect()
        self.effect = nil
        data.updateToColorMode(colorHex: colorHex)
        
        guard shouldWrite else { return }
        BLEService.shared.writeMode(.color, for: data.id)
    }
    
    func updateToWhiteColorMode(shouldWrite: Bool = false) {
        stopOngoingEffect()
        self.effect = nil
        data.updateToWhiteColorMode()
        
        guard shouldWrite else { return }
        BLEService.shared.writeMode(.whiteWithTemperature, for: data.id)
    }
    
    func updateToEffectsMode(shouldWrite: Bool = false) {
        stopOngoingEffect()
        data.updateToEffectsMode()
        
        guard shouldWrite else { return }
        BLEService.shared.writeMode(.effect, for: data.id)
    }
    
    func updateLightsToEffectMode(shouldWrite: Bool) {
        data.updateToEffectsMode()
        guard shouldWrite else { return }
        BLEService.shared.writeMode(.effect, for: data.id)
    }
    
    func setEffect(_ effect: LightData.Effect, andUpdateToEffectsMode withWrite: Bool) {
        self.effect = effect
        stopOngoingEffect()
        data.updateToEffectsMode()
        guard withWrite else { return }
        BLEService.shared.writeMode(.effect, for: data.id)
    }
    
    // MARK: - On / Off
    
    func turnLightOff() {
        updateState(.turnedOff)
        BLEService.shared.turnLightOff(data: data.dataOutput, lightId: data.id)
    }
    func turnLightOn() {
        updateState(.turnedOn)
        BLEService.shared.turnLightOn(data: data.dataOutput, lightId: data.id)
    }
    
    // MARK: - Effects
    
    /// restart last effect after a turnedOn if the light was in effects mode when it was shut down ( not applicable if the app is kiled meanwhile)
    func restartLastEffect() {
        if self.data.state == .turnedOn, let effect = self.effect, self.data.mode == .effect {
            EffectLooper.shared.startEffect(effect, lightId: self.data.id)
        }
    }
    func stopOngoingEffect() {
        shouldStopGroupedEffectCallback?()
        EffectLooper.shared.stopEffect(lightId: data.id, shouldUpdate: true)
    }
    
    func startEffect(_ effect: LightData.Effect) {
        self.effect = effect
        EffectLooper.shared.startEffect(effect, lightId: data.id)
    }
    
    func setEffect(_ effect: LightData.Effect) {
        self.effect = effect
    }
    func removeEffect() {
        self.effect = nil
    }
    
    // MARK: - Color value setters
    
    func setBrightnessFromUserAction(percentage: CGFloat) {
        self.brightness.set(percentage: percentage)
        writeOutput()
    }
    func setSaturationFromUserAction(percentage: CGFloat) {
        self.saturation.set(percentage: percentage)
        writeOutput()
    }
    func setTemperatureFromUserAction(percentage: CGFloat) {
        self.temperature.set(percentage: percentage)
        writeOutput()
    }
    func setHueFromUserAction(percentage: CGFloat) {
        self.hue.set(percentage: percentage)
        writeOutput()
    }
    func setHueValueFromUserAction(value: Int) {
        self.hue.set(value: value)
        writeOutput()
    }
    func setHueAndSaturationFromUserAction(hueValue: Int, saturationPercentage: CGFloat) {
        self.hue.set(value: hueValue)
        self.saturation.set(percentage: saturationPercentage)
        
        writeOutput()
    }
    
    var brightness: PercentageRepresentableIntegerBinding {
        return .init(minimumValue: data.minimumBrightness,
                     maximumValue: data.maximumBrightness) {
            return self.data.brightnessLevel
        } set: { newValue in
            self.data.brightnessLevel = newValue
        }
    }
    
    var temperature: PercentageRepresentableIntegerBinding {
        return .init(minimumValue: data.minimumTemperature,
                     maximumValue: data.maximumTemperature) {
            return self.data.temperatureLevel
        } set: { newValue in
            self.data.temperatureLevel = newValue
        }
    }
    
    var saturation: PercentageRepresentableIntegerBinding {
        return .init(minimumValue: 0,
                     maximumValue: 100) {
            return self.data.saturationLevel
        } set: { newValue in
            self.data.saturationLevel = newValue
        }
    }
    
    var hue: PercentageRepresentableIntegerBinding {
        return .init(minimumValue: data.minimumHue,
                     maximumValue: data.maximumHue) {
            return self.data.hue
        } set: { newValue in
            self.data.hue = newValue
        }
    }
    
    private func writeOutput() {
        BLEService.shared.writeLightOutput(data: self.data.dataOutput, lightId: self.data.id)
    }
}
