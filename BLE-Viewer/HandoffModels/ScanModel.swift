//
//  ReceivedAdvertisements.swift
//  BLE-Viewer
//
//  Created by Alexander Heinrich on 26.09.19.
//  Copyright © 2019 Alexander Heinrich. All rights reserved.
//

import Foundation
import CoreBluetooth

class ScanModel {
    let peripheral: CBPeripheral
    var advertisements: [HandoffAdvertisement] = []
    
    init(peripheral: CBPeripheral, advertisements: [HandoffAdvertisement] = []) {
        self.peripheral = peripheral
        self.advertisements = advertisements
    }
}
