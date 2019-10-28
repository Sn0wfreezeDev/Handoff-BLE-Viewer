//
//  BLEReceiver.swift
//  BLE-Viewer
//
//  Created by Alexander Heinrich on 25.09.19.
//  Copyright © 2019 Alexander Heinrich. All rights reserved.
//

import Foundation
import CoreBluetooth
import os

protocol BLEReceiverDelegate {
    func didReceive(handoffData: Data, fromDevice device: CBPeripheral)
}

class BLEReceiver: NSObject {
    var centralManager: CBCentralManager!
    var delegate: BLEReceiverDelegate?
    
    private var shouldScanForAdvertisements = false
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func scanForAdvertisements() {
        if self.centralManager.state == .poweredOn {
            self.centralManager.scanForPeripherals(withServices: nil, options: nil)
        }else {
            self.shouldScanForAdvertisements = true
        }
        
    }
    
    func isHandoff(data: Data) -> Bool {
        guard data.count >= 3 else {return false}
        let isAppleData = data[data.startIndex] == 0x4c
        let isHandoffData = data[data.startIndex.advanced(by: 2)] == 0x0c
        
        return isAppleData && isHandoffData
    }
}

extension BLEReceiver: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("CBCentralManager did Update state \(central.state)")
        if central.state == .poweredOn && self.shouldScanForAdvertisements {
            self.scanForAdvertisements()
            self.shouldScanForAdvertisements = false
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        
//        Log.debug(system: .ble, message: "Received advertisement from %@", peripheral.identifier.uuidString)
//        Log.debug(system: .ble, message: "Advertisement data %@", advertisementData)
        guard let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data,
            self.isHandoff(data: manufacturerData) else { return }
        
        self.delegate?.didReceive(handoffData: manufacturerData, fromDevice: peripheral)
    }
    
}
