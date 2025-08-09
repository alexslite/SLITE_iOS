//
//  UpdateAgent.swift
//  Slite
//
//  Created by Paul Marc on 06.07.2023.
//

import Foundation
import CoreBluetooth

let chunkSize = 512

final class UpdateAgent {
    // MARK: - Properties
    
    var didWriteChunk: (() -> Void)?
    var didFinished: (() -> Void)?
    var didUpdateProgress: ((Int) -> Void)?
    
    private(set) var version: String = ""
    private(set) var inProgress = false
    private let peripheral: CBPeripheral
    private var leftRangeIndex = 0
    private var rightRangeIndex = chunkSize
    private var data: NSData!
    
    // MARK: - init
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
    }
    
    func setVersion(_ version: String) {
        self.version = version
    }
    
    func start() {
        loadFile()
    }
    
    // MARK: - Private
    
    private func loadFile() {
        leftRangeIndex = 0
        rightRangeIndex = chunkSize
        
        if let path = Bundle.main.path(forResource: "slite_v2.8.5.bin", ofType: nil), let data = NSData(contentsOfFile: path) {
            self.data = data
            
            inProgress = true
            didWriteChunk = { [weak self] in
                self?.sendNextChunk()
            }
            sendNextChunk()
        } else {
            didFinished?()
        }
    }
    
    @objc private func sendNextChunk() {
        let totalSize = data.length
        
        let range: Range = leftRangeIndex..<rightRangeIndex
        let chunkData = data.subdata(with: NSRange(range))
        
        if writeChunk(chunkData) {
            didUpdateProgress?(Int((Double(rightRangeIndex) / Double(totalSize)) * 100))
            
            leftRangeIndex = rightRangeIndex
            if rightRangeIndex + chunkSize <= totalSize {
                rightRangeIndex += chunkSize
            } else {
                if totalSize - rightRangeIndex > 0 {
                    leftRangeIndex = rightRangeIndex
                    rightRangeIndex = totalSize
                } else if rightRangeIndex == totalSize {
                    inProgress = false
                    didFinished?()
                }
            }
        } else {
            // save offset
        }
    }
    
    @discardableResult
    private func writeChunk(_ data: Data) -> Bool {
        guard peripheral.state == .connected,
                let characteristic = peripheral.fwUpdateWriteCharacteristic else {
            return false
        }
        
        guard peripheral.maximumWriteValueLength(for: .withResponse) == 512 else {
            print("\nUAT: Invalid MTU: \(peripheral.maximumWriteValueLength(for: .withResponse))\n")
            return false
        }
        
        print("\nUAT: Sending chunk nr: \(leftRangeIndex / chunkSize) Size: \(NSData(data: data).length)\n")
        
        self.peripheral.writeValue(data, for: characteristic, type: .withResponse)
        
        return true
    }
}

// MARK: - CBPeripheral

fileprivate extension CBPeripheral {
    var fwUpdateWriteCharacteristic: CBCharacteristic? {
        guard let service = self.services?.first(where: { $0.uuid == fwUpdateServiceCBUUID }),
                let characteristic = service.characteristics?.first(where: { $0.uuid == fwUpdateWriteCBUUID }) else {
            return nil
        }
        return characteristic
    }
}
