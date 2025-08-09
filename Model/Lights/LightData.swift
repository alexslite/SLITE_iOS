//
//  Light.swift
//  Slite
//
//  Created by Efraim Budusan on 03.02.2022.
//

import Foundation
import SwiftUI
import CoreBluetooth

struct LightData: Identifiable, Codable {
    
    var dataOutput: Data {
        let hue = self.hue == 0 ? 1 : self.hue
        let stringValue = "\(temperatureLevel),\(hue),\(saturationLevel),\(brightnessLevel),\(state.outputValue)"
        let data = stringValue.data(using: .utf8)
        return data!
    }
    
    let id: String
    var name: String
    var state: State
    var colorHex: String
    
    var brightnessLevel: Int
    var temperatureLevel: Int
    var saturationLevel: Int
    var hue: Int
    
    var batteryLevel: Float = 0
    
    var mode: Mode
    
    var isTurnedOff: Bool {
        state == .turnedOff
    }
    var isDisconnected: Bool {
        state == .disconnected
    }
    var isConnected: Bool {
        state != .disconnected
    }
    var isTurnedOn: Bool {
        state == .turnedOn
    }
    
    mutating func onOffToggle() {
        if state == .turnedOn { state = .turnedOff } else
            if state == .turnedOff { state = .turnedOn }
        
    }
    
    mutating func updateWith(data: Data) {
        guard let values = data.lightValues.lightStatusData else { return }
        self.brightnessLevel = values.brightness
        self.temperatureLevel = values.temperature
        self.hue = values.hue
        self.saturationLevel = values.saturation
    }

    // Color mode init
    init(id: String, name: String, state: State, colorHex: String, brightnessLevel: Int)  {
        self.id = id
        self.name = name
        self.state = state
        self.colorHex = colorHex
        self.brightnessLevel = brightnessLevel
        self.mode = .color
        
        self.temperatureLevel = minimumTemperature
        
        let hsv = RGB(hexadecimal: colorHex).hsv
        self.saturationLevel = Int(hsv.s) * 100
        self.hue = Int(hsv.h)
    }
    
    // White color with temperature value
    init(id: String, name: String, state: State, temperatureLevel: Int, brightnessLevel: Int)  {
        self.id = id
        self.name = name
        self.state = state
        self.temperatureLevel = temperatureLevel
        self.brightnessLevel = brightnessLevel
        self.mode = .whiteWithTemperature
        
        self.colorHex = ""
        self.saturationLevel = 0
        self.hue = minimumHue
    }
    
    // Initialiser with default values
    init(id: String, name: String, state: State) {
        self.id = id
        self.name = name
        
        self.temperatureLevel = 4500
        self.saturationLevel = 50
        self.hue = 0
        self.brightnessLevel = 2
        self.mode = .color
        self.state = .turnedOn
        self.colorHex = HSV(h: 0, s: 0.5, v: 0.02).rgb.hexStringValue
    }
    
    var overlayColor: Color {
        Color(temperature: CGFloat(temperatureLevel))
    }
    var overlayOpacity: CGFloat {
        1 - saturationPercentage
    }
    
    var whiteColor: Color {
        Color(temperature: CGFloat(temperatureLevel))
    }
    var hueColor: Color {
        // force full brightness for display color
        let hsv = HSV(h: CGFloat(hue), s: saturationPercentage, v: 1)
        return Color(hexadecimal: hsv.rgb.hexStringValue)
    }
    
    var color: Color {
        switch self.mode {
        case .whiteWithTemperature:
            return Color(temperature: CGFloat(temperatureLevel))
        case .color:
            let hsv = HSV(h: CGFloat(hue), s: saturationPercentage, v: 1)
            return Color(hexadecimal: hsv.rgb.hexStringValue)
        case .effect:
            return .white
        }
    }
    
    var singleColorGradient: LinearGradient {
        LinearGradient(colors: [color], startPoint: .leading, endPoint: .trailing)
    }
    
    var batteryLines: Int {
        return Int((batteryLevel * 4.0).rounded())
    }
    
    static func dummyWithColor() -> LightData {
        return .init(id: UUID().uuidString, name: "Slite_a", state: .turnedOn, colorHex: "FF0000", brightnessLevel: 100)
    }
    
    static func dummyWithTemperature() -> LightData {
        return .init(id: UUID().uuidString, name: "Slite_b", state: .turnedOn, temperatureLevel: 5600, brightnessLevel: 10)
    }
    
    static func dummyList() -> [LightData] {
        return [dummyWithColor(),
                dummyWithTemperature(),
                LightData(id: UUID().uuidString, name: "Slite_off", state: .turnedOff, temperatureLevel: 5600, brightnessLevel: 10),
                LightData(id: UUID().uuidString, name: "Slite_disconnected", state: .disconnected, colorHex: "FF0000", brightnessLevel: 10)]
    }
    
    static func dummyGroupLights() -> [LightData] {
        return [LightData(id: UUID().uuidString, name: "UngroupedSlite", state: .turnedOn, colorHex: "FF00FF", brightnessLevel: 10),
                LightData(id: UUID().uuidString, name: "UngroupedSlite_2", state: .turnedOff, colorHex: "FFFF00", brightnessLevel: 10)]
    }
    
    static func discoveryDummy() -> [LightData] {
        return [LightData(id: UUID().uuidString, name: "slite_mocked", state: .turnedOn, temperatureLevel: 5600, brightnessLevel: 10),
                LightData(id: UUID().uuidString, name: "slite_mocked", state: .turnedOn, temperatureLevel: 5600, brightnessLevel: 10),
                LightData(id: UUID().uuidString, name: "slite_mocked", state: .turnedOn, temperatureLevel: 5600, brightnessLevel: 10)]
    }
    
    var minimumBrightness: Int = 0
    var maximumBrightness: Int = 100
    
    var minimumTemperature: Int = 2_000
    var maximumTemperature: Int = 10_000
    
    var minimumHue: Int = 0
    var maximumHue: Int = 360
    
    func brightnessValue(for percentage: CGFloat) -> Int {
        return minimumBrightness + Int(percentage * CGFloat(maximumBrightness - minimumBrightness))
    }
    
    mutating func setBrightnessValue(for percentage: CGFloat) {
        brightnessLevel = brightnessValue(for: percentage)
    }
    
    func temperatureValue(for percentage: CGFloat) -> Int {
        return minimumTemperature + Int(percentage * CGFloat(maximumTemperature - minimumTemperature))
    }
    
    var brightnessPercentage: CGFloat {
        let percentage = CGFloat(brightnessLevel - minimumBrightness)  / CGFloat(maximumBrightness - minimumBrightness)
        return max(min(percentage, 1), 0)
    }
    
    var temperaturePercentage: CGFloat {
        let percentage =  CGFloat(temperatureLevel - minimumTemperature)  / CGFloat(maximumTemperature - minimumTemperature)
        return max(min(percentage, 1), 0)
    }
    
    var saturationPercentage: CGFloat {
        let percentage =  CGFloat(saturationLevel - 0)  / CGFloat(100 - 0)
        return max(min(percentage, 1), 0)
    }
    
    var huePercentage: CGFloat {
        let percentage = CGFloat(CGFloat(hue) / CGFloat(360))
        let rounded = percentage.rounded(toPlaces: 2)
        
        return max(min(rounded, 1), 0)
    }
    
    // MARK: - Color mode update
    
    mutating func updateToColorMode(colorHex: String = "") {
        self.mode = .color
        self.colorHex = colorHex
    }
    
    mutating func updateToWhiteColorMode() {
        self.mode = .whiteWithTemperature
    }
    
    mutating func updateToEffectsMode() {
        self.mode = .effect
    }
}

extension LightData {
    enum Mode: String, Codable {
        case whiteWithTemperature = "COLOURTEMP"
        case color = "HUE"
        case effect = "EFFECT_STREAMING"
        
        static func valueForMode(_ key: String) -> Mode {
            if let mode = Mode(rawValue: key) {
                return mode
            } else if key == "SATURATION" {
                return .color
            } else if key == "WHITE_GM_ADJUST" {
                return .whiteWithTemperature
            } else {
                return .color
            }
        }
    }
}

extension LightData {
    
    enum State: Codable {
        case turnedOn
        case turnedOff
        case disconnected
        
        var outputValue: String {
            switch self {
            case .turnedOn:
                return "0"
            case .turnedOff:
                return "1"
            case .disconnected:
                return ""
            }
        }
        
        var title: String {
            switch self {
                case .disconnected: return "Disconnected"
                case .turnedOn: return "Turned On"
                case .turnedOff: return "Turned Off"
            }
        }
        
        var powerImage: Image {
            switch self {
            case .turnedOn, .turnedOff: return Image("lights_power")
            case .disconnected: return Image("lights_info")
            }
        }
        
        var powerImageForegroundColor: Color {
            switch self {
            case .disconnected: return .tartRed
            case .turnedOff, .turnedOn: return .black
            }
        }
        
        func powerImageBackground(colorGradient: LinearGradient) -> LinearGradient {
            switch self {
            case .disconnected: return LinearGradient(colors: [.black], startPoint: .leading, endPoint: .trailing)
            case .turnedOff: return LinearGradient(colors: [.sonicSilver], startPoint: .leading, endPoint: .trailing)
            case .turnedOn: return colorGradient
            }
        }
    }
}

extension LightData {
    
    
    enum Effect: String, CaseIterable, Codable {
        case fireworks
        case paparazzi
        case lightning
        case police
        case disco
        case faulty
        case fire
        case pulsing
        case strobe
        case tv
        
        var assetName: String {
            switch self {
            case .fireworks:
                return "effects_fireworks"
            case .paparazzi:
                return "effects_paparazzi"
            case .lightning:
                return "effects_lightning"
            case .police:
                return "effects_police"
            case .disco:
                return "effects_disco"
            case .faulty:
                return "effects_faulty"
            case .fire:
                return "effects_fire"
            case .pulsing:
                return "effects_pulsing"
            case .strobe:
                return "effects_strobe"
            case .tv:
                return "effects_tv"
            }
        }
        
        var title: String {
            switch self {
            case .fireworks:
                return "Fireworks"
            case .paparazzi:
                return "Paparazzi"
            case .lightning:
                return "Lightning"
            case .police:
                return "Police"
            case .disco:
                return "Disco/Party"
            case .faulty:
                return "Faulty Globe"
            case .fire:
                return "Fire"
            case .pulsing:
                return "Pulsing"
            case .strobe:
                return "Strobe"
            case .tv:
                return "TV"
            }
        }
        
        var gradient: LinearGradient {
            switch self {
            case .fireworks:
                return LinearGradient(colors: [Color(hex: "F53B83"), Color(hex: "1182F5")], startPoint: .bottomLeading, endPoint: .topTrailing)
            case .paparazzi:
                return LinearGradient(colors: [.white, Color(hex: "DCE5FD")], startPoint: .leading, endPoint: .trailing)
            case .lightning:
                return LinearGradient(colors: [Color(hex: "E6D1FF"), Color(hex: "FDFCFF"), Color(hex: "3F3194")], startPoint: .leading, endPoint: .trailing)
            case .police:
                return LinearGradient(colors: [Color(hex: "000CF7"), Color(hex: "FF0101")], startPoint: .leading, endPoint: .trailing)
            case .disco:
                return LinearGradient(colors: [Color(hex: "E01E00"), Color(hex: "0CEDD7")], startPoint: .leading, endPoint: .trailing)
            case .faulty:
                return LinearGradient(colors: [.white, Color(hex: "F2F1BD")], startPoint: .leading, endPoint: .trailing)
            case .fire:
                return LinearGradient(colors: [Color(hex: "#E04201"), Color(hex: "F7BE0C")], startPoint: .bottom, endPoint: .top)
            case .pulsing:
                return LinearGradient(colors: [.white, Color(hex: "E84C0C")], startPoint: .leading, endPoint: .trailing)
            case .strobe:
                return LinearGradient(colors: [.white, Color(hex: "505050")], startPoint: .leading, endPoint: .trailing)
            case .tv:
                return LinearGradient(colors: [Color(hex: "4A00FF"), Color(hex: "15B126"), Color(hex: "FF00CC")], startPoint: .leading, endPoint: .trailing)
            }
        }
        
        var gradientColors: [Color] {
            switch self {
            case .fireworks:
                return [Color(hex: "F53B83"), Color(hex: "1182F5")]
            case .paparazzi:
                return [.white, Color(hex: "DCE5FD")]
            case .lightning:
                return [Color(hex: "E6D1FF"), Color(hex: "FDFCFF"), Color(hex: "3F3194")]
            case .police:
                return [Color(hex: "000CF7"), Color(hex: "FF0101")]
            case .disco:
                return [Color(hex: "E01E00"), Color(hex: "0CEDD7")]
            case .faulty:
                return [.white, Color(hex: "F2F1BD")]
            case .fire:
                return [Color(hex: "#E04201"), Color(hex: "F7BE0C")]
            case .pulsing:
                return [.white, Color(hex: "E84C0C")]
            case .strobe:
                return [.white, Color(hex: "505050")]
            case .tv:
                return [Color(hex: "4A00FF"), Color(hex: "15B126"), Color(hex: "FF00CC")]
            }
        }
    }
    
}

extension CGFloat {
    func rounded(toPlaces places:Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(places))
        return (self * divisor).rounded() / divisor
    }
}
