//
//  SliteConnectionHandler.swift
//  Slite
//
//  Created by Paul Marc on 17.05.2022.
//

import Foundation
import CoreBluetooth

protocol FirmwareUpdateDelegate: AnyObject {
    func connectionHandler(_ handler: SliteConnectionHandler, didStartedFirmwareUpdateFor peripheralId: String)
    func connectionHandler(_ handler: SliteConnectionHandler, didFinishedFirmwareUpdateFor peripheralId: String)
    func connectionHandler(_ handler: SliteConnectionHandler, didUpdateUploadProgressWith progress: Int)
}

struct SliteFirmwareStatus {
    var id: String
    var version: String
    var inProgress: Bool
}

typealias LightStatusData = (temperature: Int, hue: Int, saturation: Int, brightness: Int, blackout: LightData.State?)

final class SliteConnectionHandler: NSObject {
    // MARK: - Properties
    
    var peripheral: CBPeripheral
    var isEffectOngoing = false
    var updateCallback: ((LightStatusData) -> Void)?
    var onLightTurnedOff: (() -> Void)?
    
    weak var firmwareUpdateDelegate: FirmwareUpdateDelegate?
    
    var firmwareStatus: SliteFirmwareStatus {
        SliteFirmwareStatus(id: peripheral.identifier.uuidString, version: updateAgent.version, inProgress: updateAgent.inProgress)
    }
    
    // callback for effects looper to check write completion
    var effectWriteCompletion: (() -> Void)?
    
    // callback for connection state
    var connectionStateUpdateCallback: ((_ isConnected: Bool) -> Void)?
    
    // callback for light mode update
    var modeUpdateCallback: ((LightData.Mode) -> Void)?
    
    var lastEffectData: Data?
    var mode: LightData.Mode?
    
    private let throttle = Throttle(minimumDelay: 0.25)
    private let updateAgent: UpdateAgent
    
    // MARK: - Init
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        self.updateAgent = UpdateAgent(peripheral: peripheral)
        super.init()
        
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    // MARK: - Firmware update
    
    func startFirmwareUpdate() {
        guard let service = peripheral.services?.first(where: { $0.uuid == sliteServiceCBUUID }),
                let characteristic = service.characteristics?.first(where: { $0.uuid == deviceStatus }) else {
            return
        }
                
        updateAgent.didFinished = { [weak self] in
            guard let self else { return }
            self.firmwareUpdateDelegate?.connectionHandler(self, didFinishedFirmwareUpdateFor: self.peripheral.identifier.uuidString)
        }
        
        updateAgent.didUpdateProgress = { [weak self] progress in
            guard let self else { return }
            self.firmwareUpdateDelegate?.connectionHandler(self, didUpdateUploadProgressWith: progress)
        }
        
        firmwareUpdateDelegate?.connectionHandler(self, didStartedFirmwareUpdateFor: peripheral.identifier.uuidString)
        updateAgent.start()
    }
    
    // MARK: - Effects
    
    func writeEffectInstruction(data: Data) {
        guard mode == .effect else { return }
        isEffectOngoing = true
        lastEffectData = data
        write(data: data)
    }
    func effectWillStop() {
        isEffectOngoing = false
    }
    
    // MARK: - Write
    
    func throttledWrite(data: Data) {
        throttle.throttle { [weak self] in
            self?.write(data: data)
        }
    }
    
    func turnLightOffWithEffectOngoing(fallbackData: Data) {
        guard let lastEffectData = lastEffectData, let turnedOffData = lastEffectData.turnedOff else {
            throttledWrite(data: fallbackData)
            self.lastEffectData = nil
            return
        }
        self.lastEffectData = nil
        throttledWrite(data: turnedOffData)
    }
    
    private func write(data: Data) {
        guard let service = peripheral.services?.first(where: { $0.uuid == sliteServiceCBUUID }),
                let characteristic = service.characteristics?.first(where: { $0.uuid == lightOutputSettings }) else {
            return
        }
                
//        print("\nBLEService: Did write \(data.lightValues) for \(peripheral.displayName)")
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
    
    func writeMode(mode: LightData.Mode) {
        guard let service = peripheral.services?.first(where: { $0.uuid == sliteServiceCBUUID }),
                let characteristic = service.characteristics?.first(where: { $0.uuid == deviceStatus }) else {
            return
        }
                
        peripheral.writeValue(mode.rawValue.data(using: .utf8)!, for: characteristic, type: .withResponse)
    }
    
    // MARK: - Read
    
    func readLightStatus() {
        guard let service = peripheral.services?.first(where: { $0.uuid == sliteServiceCBUUID }),
                let characteristic = service.characteristics?.first(where: { $0.uuid == lightOutputSettings }) else {
            return
        }
        
        peripheral.readValue(for: characteristic)
    }
    
    // MARK: - DEVICE STATUS update
    
    private func didUpdateDeviceStatusWith(_ data: Data) {
        let mode = modeFor(data)
        self.mode = mode
        modeUpdateCallback?(mode)
    }
    private func modeFor(_ data: Data) -> LightData.Mode {
        let stringValue = String(data: data, encoding: .utf8)
        
        guard let modeRawValue = stringValue?.components(separatedBy: ",").first else {
            return .color
        }
        return LightData.Mode.valueForMode(modeRawValue)
    }
    
    // MARK: - LIGHT STATUS update
    
    private func didUpdateLightStatusWith(_ data: Data) {
        let stringValue = String(data: data, encoding: .utf8)
        
        guard let lightStateData = stringValue?.lightStatusData else {
            updateCallback?((temperature: 5600,hue: 0, saturation: 50, brightness: 2, blackout: .turnedOn))
            return
        }
        
        // check if light was turned off from button during an effect
        if isEffectOngoing {
            checkIfLightWasTurnedOff(lightStateData)
        } else {
            // general callback is disabled while effect is ongoing
            updateCallback?(lightStateData)
        }
    }
    
    private func checkIfLightWasTurnedOff(_ lightStateData: LightStatusData) {
        if lightStateData.blackout == .turnedOff {
            print("\nBLEService: Light was turned OFF")
            isEffectOngoing = false
            onLightTurnedOff?()
        }
    }
}

// MARK: - CBPeripheralDelegate

extension SliteConnectionHandler: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        print("\nBLEService: Did discover services \(peripheral.services!)")
//        guard let service = peripheral.services?.first(where: { $0.uuid == sliteServiceCBUUID }) else { return }
        peripheral.services?.forEach {
            peripheral.discoverCharacteristics(nil, for: $0)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//        print("\nBLEService: Did discover caracteristics \(service.characteristics ?? [])")
        
        service.characteristics?.forEach {
            peripheral.discoverDescriptors(for: $0)
            if $0.isFWVersionRead {
                peripheral.readValue(for: $0)
            }
        }
        print("\nMTTU: MaxSize: \(peripheral.maximumWriteValueLength(for: .withoutResponse))\n")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.isLightStatus || characteristic.isDeviceStatus {
            peripheral.setNotifyValue(true, for: characteristic)
            peripheral.readValue(for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
//        print("\nUAT: Confirm write for \(peripheral.displayName)")
        if characteristic.isLightStatus {
            effectWriteCompletion?()
        } else if characteristic.isDeviceStatus {
            
        } else if characteristic.isFWUpdateWrite {
            print("\nUAT: Confirm write FW file\n")
            updateAgent.didWriteChunk?()
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        print("\nUAT: Value: \(characteristic.value?.description)\n")
        if characteristic.isLightStatus, let value = characteristic.value {
//            print("\nBLEServiceC: Did update light value: \(String(data: value, encoding: .utf8)!)")
            didUpdateLightStatusWith(value)
        } else if characteristic.isDeviceStatus, let value = characteristic.value {
//            print("\nBLEServiceC: Did update status value: \(String(data: value, encoding: .utf8)!)")
            didUpdateDeviceStatusWith(value)
        } else if characteristic.isFWUpdateWrite {
//            print("\nUAT: Value: \(characteristic.value?.description)\n")
//            fatalError()
        } else if characteristic.isFWVersionRead {
            guard let version = characteristic.value else { return }
            let swVersion = "\(version[2]).\(version[3]).\(version[4])"
            updateAgent.setVersion(swVersion)
        }
    }
        
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("\nBLEService: Did update notification state for \(characteristic.displayName) isNotifying: \(characteristic.isNotifying)")
    }
}

// MARK: - LightStatusData

extension String {
    var lightStatusData: LightStatusData? {
        let components = self.components(separatedBy: ",")
        guard let temperatureComponent = Int(components[0]),
              let hueComponent = Double(components[1]),
              let saturationComponent = Double(components[2]),
              let brightnessComponent = Double(components[3]) else { return nil }
        
        var blackoutComponent: Int?
        if components.count > 4 {
            blackoutComponent = Int(components[4])
        }
        if let blackoutComponent = blackoutComponent {
            let lightState: LightData.State = blackoutComponent == 0 ? .turnedOn : .turnedOff
            return (temperatureComponent, Int(hueComponent), Int(saturationComponent), Int(brightnessComponent), lightState)
        } else {
            return (temperatureComponent, Int(hueComponent), Int(saturationComponent), Int(brightnessComponent), nil)
        }
    }
}

extension Data {
    var turnedOff: Data? {
        guard let string = String(data: self, encoding: .utf8), var lightValues = string.lightStatusData else { return nil }
        lightValues.blackout = .turnedOff
        let newString = "\(lightValues.temperature),\(lightValues.hue),\(lightValues.saturation),\(lightValues.brightness),\(lightValues.blackout!.outputValue)"
        let newData = newString.data(using: .utf8)
        
        return newData
    }
    
    var lightValues: String {
        String(data: self, encoding: .utf8) ?? ""
    }
    
    static var defaultLightValues: Data? {
        let string = "5600,0,50,0.02,0"
        return string.data(using: .utf8)
    }
}

extension CBPeripheral {
    var displayName: String {
        if identifier.uuidString == "D41B3F0A-B2E6-7CF6-E34E-60EB72428E54" {
            return "mic"
        } else {
            return "mare"
        }
    }
}
