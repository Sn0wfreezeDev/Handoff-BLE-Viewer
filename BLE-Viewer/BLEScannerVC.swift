//
//  BLEScannerVC.swift
//  BLE-Viewer
//
//  Created by Alexander Heinrich on 25.09.19.
//  Copyright © 2019 Alexander Heinrich. All rights reserved.
//

import Cocoa

class BLEScannerVC: NSViewController {
    var decryptor:  BLEDecryptor!
    var receiver: BLEReceiver!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
    }
    @IBAction func startScanning(_ sender: Any) {
        do {
            self.decryptor = try BLEDecryptor()
            self.receiver = BLEReceiver()
            
            self.receiver.delegate = self
            self.receiver.scanForAdvertisements()
    
        }catch (let error) {
            Log.error(system: .app, message: "Error thrown during setup %@", error.localizedDescription)
        }
        
        
        
    }
    
}

extension BLEScannerVC: BLEReceiverDelegate {
    func didReceive(handoffData: Data) {
        
        do {
            //Decrypt the advertisements
            let handoff = try HandoffBLE(handoffData: handoffData)
            try self.decryptor.decrypt(handoffBLE: handoff)
        }catch (let error) {
            Log.error(system: .app, message: "Failed parsing Handoff advertisement %@", error.localizedDescription)
        }
        
    }
    
    
}
