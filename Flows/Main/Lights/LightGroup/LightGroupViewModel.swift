//
//  LightGroupViewModel.swift
//  Slite
//
//  Created by Efraim Budusan on 07.02.2022.
//

import Foundation
import UIKit
import Combine
import SwiftUI

// struct for caching group information
struct LightsGroup: Codable {
    var groupData: LightGroupData
    var lightData: LightData
    var lights: [LightData]
}

class LightGroupViewModel: ObservableObject, LightControlViewModel {
    
    var groupSnapshot: GroupSnapshot {
        GroupSnapshot(id: data.id, dataSnapshot: LightSnapshot(id: data.id,
                                                                    dataOutput: data.dataOutput,
                                                                    mode: data.mode,
                                                                    effect: effect,
                                                                    color: sceneGradientColors),
                      lights: lights.map { $0.snapShot })
    }
    
    @Published var data: LightData
    @Published var effect: LightData.Effect? = nil
    
    var groupData: LightGroupData
    var lights: [LightViewModel]
    
    var isDisconnectedOrTurnedOff: Bool {
        allLightsAreDisconnected || allConnectedLightsAreTurnedOff
    }
    var isGroup: Bool {
        true
    }
    var subtitle: String {
        return lightsStateDescription
    }
    var showSubtitleIcon: Bool {
        return true
    }
    private var lightsStateDescription: String {
        let turnedOnCount = lights.filter { $0.data.state == .turnedOn }.count
        let connectedCount = lights.filter { $0.data.state == .turnedOn || $0.data.state == .turnedOff }.count
        let disconnectedCount = lights.filter { $0.data.state == .disconnected }.count
        
        return Texts.LightControlItem.groupDescription(turnedOn: turnedOnCount, connected: connectedCount, disconnected: disconnectedCount)
    }
    var powerButtonGradient: LinearGradient {
        switch data.mode {
        case .effect:
            return effect?.gradient ?? data.singleColorGradient
        default:
            return data.singleColorGradient
        }
    }
    
    var lightUpdateCallback: (() -> Void)?
    var disposeBag: [AnyCancellable] = []
    
    private var allLightsAreDisconnected: Bool {
        lights.first(where: { $0.data.state != .disconnected }) == nil
    }
    private var allConnectedLightsAreTurnedOff: Bool {
        lights.filter { $0.data.state != .disconnected }.first(where: { $0.data.state != .turnedOff }) == nil
    }
    var sceneGradientColors: [Color] {
        switch data.mode {
        case .effect:
            return effect?.gradientColors ?? [data.color]
        case .whiteWithTemperature, .color:
            return [data.color]
        }
    }
    
    // MARK: - init
    
    init(groupData: LightGroupData, lightData: LightData?, lights: [LightViewModel]) {
        self.lights = lights
        self.groupData = groupData
        if let lightData = lightData {
            self.data = lightData
        } else {
            self.data = LightData(id: UUID().uuidString, name: groupData.name, state: .turnedOn)
        }
        
        self.lights.forEach { light in
            light.onStateChanged.sink { [unowned self] in
                self.checkLightDataState()
                
                if light.data.state == .turnedOff {
                    EffectLooper.shared.stopEffectOnLightWithId(light.data.id, fromGroupWith: groupData.id)
                }
                
                self.objectWillChange.send()
            }.store(in: &disposeBag)
        }
        
        self.lights.forEach { light in
            light.shouldStopGroupedEffectCallback = {
                EffectLooper.shared.stopEffectOnLightWithId(light.data.id, fromGroupWith: groupData.id)
            }
        }
        
        checkLightDataState()
    }
    
    // check for UI state of the group
    private func checkLightDataState() {
        if allLightsAreDisconnected {
            data.state = .disconnected
            stopOngoingEffect()
        } else if allConnectedLightsAreTurnedOff {
            data.state = .turnedOff
            stopOngoingEffect()
        } else {
            data.state = .turnedOn
        }
        
        lightUpdateCallback?()
    }
    
    // MARK: - On / Off
    
    func turnLightOff() {
        lights.filter { $0.data.isConnected }.forEach {
            $0.data.state = .turnedOff
            $0.turnLightOff()
        }
    }
    
    func turnLightOn() {
        lights.filter { $0.data.isConnected }.forEach {
            $0.turnLightOn()
        }
    }
    
    // MARK: - Mode updates
    
    func updateToColorMode(colorHex: String = "", shouldWrite: Bool = false) {
        data.updateToColorMode(colorHex: colorHex)
        lights.forEach { $0.updateToColorMode(colorHex: colorHex, shouldWrite: shouldWrite)}
    }
    
    func updateToWhiteColorMode(shouldWrite: Bool = false) {
        data.updateToWhiteColorMode()
        lights.forEach { $0.updateToWhiteColorMode(shouldWrite: shouldWrite)}
    }
    
    func updateToEffectsMode(shouldWrite: Bool = false) {
        data.updateToEffectsMode()
        lights.forEach { $0.updateToEffectsMode(shouldWrite: shouldWrite) }
    }
    
    func updateLightsToEffectMode(shouldWrite: Bool = false) {
        lights.filter { $0.data.mode != .effect }.forEach { $0.updateLightsToEffectMode(shouldWrite: true) }
    }
    
    // MARK: - Effects
    
    func startEffect(_ effect: LightData.Effect) {
        self.effect = effect
        lights.forEach {
            $0.setEffect(effect, andUpdateToEffectsMode: true)
        }
        EffectLooper.shared.startEffect(effect,
                                        lightIds: lights.filter { $0.data.isTurnedOn }.map { $0.data.id },
                                        groupId: groupData.id)
    }
    func stopOngoingEffect() {
        self.effect = nil
        lights.forEach {
            $0.removeEffect()
        }
        EffectLooper.shared.stopEffect(lightId: groupData.id, shouldUpdate: true)
    }
    
    func checkForDisconnectedLights(unavailableLightIds: [String]) {
        self.lights.filter { unavailableLightIds.contains($0.data.id) }.forEach {
            $0.data.state = .disconnected
        }
    }
    func setupLightInfoCallbackForLights() {
        lights.forEach {
            $0.setupLightInfoCallback()
        }
    }
    func setupConnectionStateCallbackForLights() {
        lights.forEach {
            $0.setupConnectionStateCallback()
        }
    }
    
    // Setters for light info triggered only by user action
    func setBrightnessFromUserAction(percentage: CGFloat) {
        brightness.set(percentage: percentage)
        writeGroupLightData()
    }
    
    func setSaturationFromUserAction(percentage: CGFloat) {
        saturation.set(percentage: percentage)
        writeGroupLightData()
    }
    func setTemperatureFromUserAction(percentage: CGFloat) {
        temperature.set(percentage: percentage)
        writeGroupLightData()
    }
    func setHueFromUserAction(percentage: CGFloat) {
        hue.set(percentage: percentage)
        writeGroupLightData()
    }
    func setHueValueFromUserAction(value: Int) {
        hue.set(value: value)
        writeGroupLightData()
    }
    func setHueAndSaturationFromUserAction(hueValue: Int, saturationPercentage: CGFloat) {
        hue.set(value: hueValue)
        saturation.set(percentage: saturationPercentage)
        
        writeGroupLightData()
    }
    
    /// to be used for setting default values on lights after creating a new group
    func writeDefaultValues() {
        lights.forEach {
            $0.stopOngoingEffect()
            #warning("may require update after FW changes")
            $0.updateToColorMode(colorHex: data.colorHex)
            BLEService.shared.writeLightOutput(data: data.dataOutput, lightId: $0.data.id)
        }
    }
    
    func writeGroupLightData() {
        lights.forEach {
            BLEService.shared.writeLightOutput(data: data.dataOutput, lightId: $0.data.id)
        }
    }
    
    // MARK: - Sliders models
    
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
}
