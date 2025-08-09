//
//  LightsDiscoveryViewModel.swift
//  Slite
//
//  Created by Paul Marc on 14.03.2022.
//

import Foundation
import SwiftUI
import Combine

import CoreBluetooth

struct Slite: Identifiable {
    var id: String = UUID().uuidString
    var data: LightData
    var peripheral: CBPeripheral?
}

class LightsDiscoveryViewModel: ObservableObject {
    // MARK: - Properties
    
    var onConnectionFailure = PassthroughSubject<String, Never>()
    
    @Published var discoveredPeripherals: [Slite] = []
    @Published var discoveryFailed = false
    @Published var lightWasAddedSuccesfully = false
    @Published var lightIsSettingUp = false {
        didSet {
            guard lightIsSettingUp, let slite = lightToConnect else { return }
            
            guard let peripheral = slite.peripheral else {
                self.onConnectionFailure.send(slite.data.name)
                return
            }
            
            BLEService.shared.connectToPerihperal(peripheral) { [weak self] success in
                guard let self = self, let light = self.lightToConnect?.data else { return }
                
                guard success else {
                    self.onConnectionFailure.send(light.name)
                    return
                }
                
                self.lightWasAddedSuccesfully = true
                self.lightIsSettingUp = false
                self.newLightCallback?(light)
            }
        }
    }
    
    var lightToConnect: Slite?
    var newLightCallback: ((LightData) -> Void)?
    
    var disposeBag = [AnyCancellable]()
    let inputName = Delegated<String, PassthroughSubject<String, Never>>()
    
    private var timer: Timer?
    
    var hasDiscoveredAnyLights: Bool {
        return !discoveredPeripherals.compactMap { $0.peripheral }.isEmpty
    }
    
    // MARK: - Init
    
    init() {
        checkBLState()
    }
    
    func checkBLState() {
        if BLEService.shared.getBLEState == nil {
            BLEService.shared.initialiseBluetooth { [weak self] state in
                guard state == .poweredOn else {
                    return
                }
                self?.startDiscoveryTimer()
                self?.scanForPeripherals()
            }
        } else {
            scanForPeripherals()
            startDiscoveryTimer()
        }
    }
    
    func scanForPeripherals() {
        BLEService.shared.scanForPeripherals(withTimetout: false)
        BLEService.shared.sliteDiscoveryCallback = { [weak self] peripheral in
            self?.stopDiscoveryTimer()
            self?.discoveredPeripherals.append(Slite(data: .init(id: peripheral.identifier.uuidString,
                                                                     name: peripheral.name ?? "Slite",
                                                                     state: .turnedOn,
                                                                     temperatureLevel: 5600,
                                                                     brightnessLevel: 5),
                                                         peripheral: peripheral))
        }
    }
    
    func retryDiscovery() {
        discoveryFailed = false
    }
    
    func nameAction(slite: Slite) {
        (try? inputName.call(with: slite.data.name))?.sink { [weak self] name in
            guard let self = self else { return }
            
            self.lightToConnect = slite
            self.lightToConnect?.data.name = name
            
            self.lightIsSettingUp = true
            BLEService.shared.stopScan()
        }.store(in: &disposeBag)
    }
    
    // MARK: - Discovery timer
    
    func startDiscoveryTimer() {
        timer = Timer.scheduledTimer(timeInterval: 15,
                                     target: self,
                                     selector: #selector(discoveryTimerExpired),
                                     userInfo: nil,
                                     repeats: false)
    }
    
    func stopDiscoveryTimer() {
        timer?.invalidate()
        timer = nil
        discoveryFailed = true
    }
    
    @objc private func discoveryTimerExpired() {
        stopDiscoveryTimer()
    }
}
