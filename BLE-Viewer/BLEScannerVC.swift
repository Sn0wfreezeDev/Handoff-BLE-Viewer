//
//  BLEScannerVC.swift
//  BLE-Viewer
//
//  Created by Alexander Heinrich on 25.09.19.
//  Copyright © 2019 Alexander Heinrich. All rights reserved.
//

import Cocoa
import CoreBluetooth

class BLEScannerVC: NSViewController {
    var decryptor:  BLEDecryptor!
    var receiver: BLEReceiver!
    
    var scannedDevices = [ScanModel]()
    var selectedDevice: ScanModel? {
        didSet {
            self.contentTableView.reloadData()
        }
    }
    
    @IBOutlet weak var startButton: NSButton!
    @IBOutlet weak var scanOverlay: NSView!
    @IBOutlet weak var sidebar: NSScrollView!
    @IBOutlet weak var outlineView: NSOutlineView!
    @IBOutlet weak var contentTableView: NSTableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        outlineView.delegate = self
        outlineView.dataSource = self
        
        contentTableView.delegate = self
        contentTableView.dataSource = self
        
        scanOverlay.isHidden = false
    }
    @IBAction func startScanning(_ sender: Any) {
        do {
            self.decryptor = try BLEDecryptor()
            self.receiver = BLEReceiver()
            
            self.receiver.delegate = self
            self.receiver.scanForAdvertisements()
            
            //Dismiss the scan overlay
            self.scanOverlay.isHidden = true
    
        }catch (let error) {
            Log.error(system: .app, message: "Error thrown during setup %@", error.localizedDescription)
        }

    }
    
    func addAdvertisement(_ advertisement: HandoffAdvertisement, fromDevice peripheral: CBPeripheral) {
        if var scanModel = self.scannedDevices.first(where: {$0.peripheral.identifier == peripheral.identifier}) {
            
            scanModel.advertisements.append(advertisement)
            guard scanModel.peripheral.identifier == self.selectedDevice?.peripheral.identifier else {return}
            
            contentTableView.insertRows(at: IndexSet(integer: scanModel.advertisements.count-1), withAnimation: .effectFade)
            
        }else {
            let scanModel = ScanModel(peripheral: peripheral, advertisements: [advertisement])
            self.scannedDevices.append(scanModel)
            outlineView.insertItems(at: IndexSet(integer: scannedDevices.count-1), inParent: nil, withAnimation: .slideLeft)
        }
        
    }
    
}

extension BLEScannerVC: BLEReceiverDelegate {
    func didReceive(handoffData: Data, fromDevice device: CBPeripheral) {
        
        do {
            //Decrypt the advertisements
            let handoff = try HandoffBLE(handoffData: handoffData)
            let handoffAdvData = try self.decryptor.decrypt(handoffBLE: handoff)
            
            let handoffAdv = HandoffAdvertisement(withRawAdvertisement: handoff, decryptedAdvertisementData: handoffAdvData)
            
            Log.info(system: .app, message: "\nRaw status byte %02x \nDecrypted status byte %02x", handoff.statusByte, handoffAdv.statusByte)
            Log.info(system: .app, message: "\nUnknown byte %02x", handoffAdv.unknownByte)
            
            Log.info(system: .app, message: "\nReceived advertisement from device: %@", device.name ?? device.identifier.uuidString)
            Log.info(system: .app, message: "%@", handoffAdv.description())
            
            self.addAdvertisement(handoffAdv, fromDevice: device)
            
            
        }catch (let error) {
//            Log.error(system: .app, message: "Failed parsing Handoff advertisement: \n%@", error.localizedDescription)
        }
        
    }
}

extension BLEScannerVC: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        return scannedDevices[index]
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return false
    }

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        guard item == nil else {return 0}
        
        return scannedDevices.count
    }

//    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
//
//    }
}

extension BLEScannerVC: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
      var view: NSTableCellView?
        
        guard let scan = item as? ScanModel else {return view}
      
        view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DeviceCell"), owner: self) as? NSTableCellView
        
        view?.textField?.stringValue = scan.peripheral.name ?? scan.peripheral.identifier.uuidString
        view?.textField?.sizeToFit()
        
      return view
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let outlineView = notification.object as? NSOutlineView else {
           return
         }
        
        let selectedIndex = outlineView.selectedRow
        
        guard let scannedDevice = outlineView.item(atRow: selectedIndex) as? ScanModel else {return}
        
        self.selectedDevice = scannedDevice
        
    }
}

extension BLEScannerVC: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.selectedDevice?.advertisements.count ?? 0
    }
    
//    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
//        return self.selectedDevice?.advertisements[row] ?? nil
//    }
    
}

extension BLEScannerVC: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let adv = selectedDevice!.advertisements[row]
        
        if tableColumn?.identifier.rawValue == "DateColumn" {
            let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DateCell"), owner: self) as? NSTableCellView
            
            let df = DateFormatter()
            df.dateFormat = "HH:mm:ss dd.MM.yy"
            
            view?.textField?.stringValue = df.string(from: adv.dateReceived)
            view?.textField?.sizeToFit()
            return view
        }else {
             let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ActivityCell"), owner: self) as? NSTableCellView
            
            view?.textField?.attributedStringValue = adv.attributedDescription()
            
            return view
        }
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 68
    }
}
