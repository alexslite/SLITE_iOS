//
//  BLEService.swift
//  Slite
//
//  Created by Paul Marc on 17.05.2022.
//

import Foundation
import CoreBluetooth
import Combine

let sliteServiceCBUUID = CBUUID(string: "9C193637-B20B-49D7-B9C5-8560C97328F5")

let lightOutputSettings = CBUUID(string: "F0C93649-05FC-45FA-b0C8-D80B83EE00F6")
let deviceStatus = CBUUID(string: "F0C93649-05FC-45FA-B0C8-D80B83EE00F7")
let serviceCBUUID = CBUUID(string: "1811")

let fwUpdateServiceCBUUID = CBUUID(string: "C8659210-AF91-4AD3-A995-A58D6FD26145")
let fwUpdateWriteCBUUID = CBUUID(string: "C8659211-AF91-4AD3-A995-A58D6FD26145")
let fwVersionReadCBUUID = CBUUID(string: "C8659212-AF91-4AD3-A995-A58D6FD26145")

let latestSwVersion = "2.8.5"

typealias VoidCompletion = (() -> Void)
typealias BoolCompletion = ((Bool) -> Void)
typealias BluetoothStateCompletion = ((CBManagerState) -> Void)

final class BLEService: NSObject {
    // MARK: - Properties
    
    static let shared = BLEService()
    
    var scanningTimer: Timer?
    var connectionTimer: Timer?
    
    var bleManager: CBCentralManager?
    var bluetoothStateCompletion: BluetoothStateCompletion?
    var bluetoothStateCallback: BluetoothStateCompletion?
    let throttle = Throttle(minimumDelay: 0.25)
    
    var connectionHandlers: [String: SliteConnectionHandler] = [:]
    var onPeripheralDisconnected = PassthroughSubject<String, Never>()
    
    var getBLEState: CBManagerState? {
        bleManager?.state
    }
    
    // Add light
    var peripheralToConnect: CBPeripheral?
    var connectionSuccessfull: BoolCompletion?
    var sliteDiscoveryCallback: ((CBPeripheral) -> Void)?
    
    // Reopen App
    var peripheralsToConnect: [CBPeripheral] = []
    var peripheralsToSearch: [String : (Bool, CBPeripheral?)] = [:]
    
    // return all the identifiers for which the device was not in range of BT
    var peripheralsReconnectCallback: (([String]) -> Void)?
    
    func handlerFor(_ lightId: String) -> SliteConnectionHandler? {
        return connectionHandlers[lightId]
    }
    
    // MARK: - Central manager actions
    
    func initialiseBluetooth(completion: @escaping BluetoothStateCompletion) {
        bleManager = CBCentralManager(delegate: self, queue: .main)
        bluetoothStateCompletion = completion
    }
    
    func scanForPeripherals(withTimetout: Bool = true) {
        bleManager?.scanForPeripherals(withServices: [serviceCBUUID])
        
        guard withTimetout else { return }
        startScanningTimer()
    }
    
    func stopScan() {
        bleManager?.stopScan()
    }
    
    // MARK: - FW Update
    
    var isFirmwareUpdateAvailable: Bool {
        !connectionHandlers.values.filter { $0.firmwareStatus.version != latestSwVersion }.isEmpty
    }
    
    func startFWUpdateForPeripheralWith(_ id: String) {
        connectionHandlers[id]?.startFirmwareUpdate()
    }
    
    func setFirmwareUpdateDelegate(_ delegate: FirmwareUpdateDelegate, for peripheralId: String) {
        connectionHandlers[peripheralId]?.firmwareUpdateDelegate = delegate
    }
    
    func getFirmwareStatusForConnectedLights() -> [SliteFirmwareStatus] {
        let models = connectionHandlers.values.map { $0.firmwareStatus }
        return models
    }
    
    // MARK: - Add Light
    
    func connectToPerihperal(_ peripheral: CBPeripheral, completion: @escaping BoolCompletion) {
        self.peripheralToConnect = peripheral
        self.connectionSuccessfull = completion
        bleManager?.connect(peripheral)
        
        connectionTimer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(connectionDidFail), userInfo: nil, repeats: false)
    }
    @objc private func connectionDidFail() {
        guard peripheralToConnect != nil else { return }
        connectionTimer?.invalidate()
        connectionTimer = nil
        peripheralToConnect = nil
        
        connectionSuccessfull?(false)
    }
    
    // MARK: - Remove Light
    
    func removePeripheralWithId(_ id: String) {
        guard let handler = handlerFor(id) else { return }
        bleManager?.cancelPeripheralConnection(handler.peripheral)
        connectionHandlers.removeValue(forKey: id)
    }
    
    func reconnectToPeripheralsWith(_ ids: [String], completion: (([String]) -> Void)?) {
        guard !(bleManager?.isScanning ?? true) else {
            return
        }
        peripheralsReconnectCallback = completion
        
        ids.forEach { peripheralsToSearch[$0] = (false, nil) }
        
        sliteDiscoveryCallback = { [weak self] peripheral in
            guard let self = self, ids.contains(peripheral.identifier.uuidString) else { return }
            
            self.peripheralsToConnect.append(peripheral)
            self.peripheralsToSearch[peripheral.identifier.uuidString] = (true, peripheral)
            
            self.bleManager?.connect(peripheral)
        }
        scanForPeripherals()
    }
    
    // MARK: - Scan timer
    
    private func startScanningTimer() {
        scanningTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(checkUnavailableLights), userInfo: nil, repeats: false)
    }
    
    @objc private func checkUnavailableLights() {
//        guard !(bleManager?.isScanning ?? false) else { return }
        let disconnectedLightsIds = peripheralsToSearch.filter { $0.value.1 == nil }.map { $0.key }
        peripheralsReconnectCallback?(disconnectedLightsIds)
        bleManager?.stopScan()
    }
    
    // MARK: - Observers
    
    func setUpdateCallbackForLightWith(_ id: String, callback: @escaping (LightStatusData) -> Void) {
        handlerFor(id)?.updateCallback = callback
    }
    
    func setTurnedOffCallbackForLightWith(_ id: String, callback: (() -> Void)? ) {
        handlerFor(id)?.onLightTurnedOff = callback
    }
    
    func setUpdateCallbackForEffectOnLightWith(_ id: String, callback: (() -> Void)?) {
        handlerFor(id)?.effectWriteCompletion = callback
    }
    
    func setConnectionStateUpdateCallback(_ id: String, callback: @escaping (Bool) -> Void) {
        handlerFor(id)?.connectionStateUpdateCallback = callback
    }
    
    func setModeUpdateCallback(_ id: String, callback: @escaping ((LightData.Mode) -> Void)) {
        handlerFor(id)?.modeUpdateCallback = callback
    }
    
    // MARK: - Write
    
    func effectWillStopForLightWith(_ id: String, shouldUpdate: Bool) {
        guard let handler = handlerFor(id) else { return }
        handler.effectWillStop()
        
        guard shouldUpdate else { return }
        handler.readLightStatus()
    }
    
    func writeEffectInstruction(data: Data, lightId: String, throttled: Bool = false) {
        handlerFor(lightId)?.writeEffectInstruction(data: data)
    }
    
    func writeLightOutput(data: Data, lightId: String) {
        handlerFor(lightId)?.throttledWrite(data: data)
    }
    
    func writeMode(_ mode: LightData.Mode, for lightId: String) {
        handlerFor(lightId)?.writeMode(mode: mode)
    }
    
    // MARK: - Turn Off / On
    
    func turnLightOff(data: Data, lightId: String) {
        EffectLooper.shared.stopEffect(lightId: lightId, shouldUpdate: false)
        
        if let handler = handlerFor(lightId), handler.lastEffectData != nil {
            handler.turnLightOffWithEffectOngoing(fallbackData: data)
        } else {
            writeLightOutput(data: data, lightId: lightId)
        }
    }
    func turnLightOn(data: Data, lightId: String) {
        writeLightOutput(data: data, lightId: lightId)
    }
    
    // MARK: - Read
    
    func readLightStatusFor(_ id: String) {
        guard let handler = handlerFor(id) else { return }
        handler.readLightStatus()
    }
}

// MARK: - CBCentralManagerDelegate

extension BLEService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bluetoothStateCompletion?(central.state)
        bluetoothStateCallback?(central.state)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("\nBLEService: Did discover peripheral \(peripheral.name ?? "") \(peripheral.identifier)")
        sliteDiscoveryCallback?(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheralsToConnect.remove(object: peripheral)
        peripheralsToSearch.removeValue(forKey: peripheral.identifier.uuidString)
        
        let connectionHandler = SliteConnectionHandler(peripheral: peripheral)
        connectionHandlers[peripheral.identifier.uuidString] = connectionHandler
    
        checkUnavailableLights()
        
        guard let peripheralToConnect = peripheralToConnect else { return }
        if peripheral.isPeripheral(peripheralToConnect) {
            connectionSuccessfull?(true)
            self.peripheralToConnect = nil
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
        // Add Light
        guard let peripheralToConnect = peripheralToConnect else { return }
        if peripheral.isPeripheral(peripheralToConnect) {
            connectionSuccessfull?(false)
            self.peripheralToConnect = nil
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        onPeripheralDisconnected.send(peripheral.identifier.uuidString)
        
        if let handlerForDisconnectedLight = handlerFor(peripheral.identifier.uuidString) {
            handlerForDisconnectedLight.connectionStateUpdateCallback?(false)
        }
        
        connectionHandlers.removeValue(forKey: peripheral.identifier.uuidString)
        
        print("\nBLEService: Did disconnect peripheral \(peripheral.name!)")
    }
}

extension CBPeripheral {
    func isPeripheral(_ peripheral: CBPeripheral) -> Bool {
        self.identifier == peripheral.identifier
    }
    
    var isSliteDevice: Bool {
        name?.contains("Slite") ?? false
    }
}

extension CBCharacteristic {
    var displayName: String {
        if uuid == lightOutputSettings {
            return "Light Settings"
        } else if uuid == deviceStatus {
            return "Device Status"
        } else {
            return "Unknown"
        }
    }
    
    var isLightStatus: Bool {
        uuid == lightOutputSettings
    }
    var isDeviceStatus: Bool {
        uuid == deviceStatus
    }
    var isFWUpdateWrite: Bool {
        uuid == fwUpdateWriteCBUUID
    }
    var isFWVersionRead: Bool {
        uuid == fwVersionReadCBUUID
    }
}
