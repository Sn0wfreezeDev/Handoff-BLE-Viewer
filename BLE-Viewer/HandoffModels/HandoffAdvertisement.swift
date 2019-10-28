//
//  HandoffAdvertisement.swift
//  BLE-Viewer
//
//  Created by Alexander Heinrich on 26.09.19.
//  Copyright © 2019 Alexander Heinrich. All rights reserved.
//

import Foundation
#if os(macOS)
import AppKit
#endif


/// This struct is used for parsing decrypted Handoff BLE Advertisements.
/// It will reflect the content of the advertisement
struct HandoffAdvertisement {
    let statusByte: UInt8
    let unknownByte: UInt8
    let handoffHash: Data
    private let flagByte: UInt8
    let flags: [HandoffFlags]
    let handoffActivity: HandoffActivity
    
    let dateReceived = Date() 
    
    init(withRawAdvertisement handoffBLE: HandoffBLE, decryptedAdvertisementData advertisementData: Data) {
        self.statusByte = advertisementData[advertisementData.startIndex]
        self.handoffHash = advertisementData[advertisementData.startIndex.advanced(by: 1) ... advertisementData.startIndex.advanced(by: 7)]
        self.flagByte = advertisementData[advertisementData.startIndex.advanced(by: 8)]
        self.unknownByte = advertisementData[advertisementData.startIndex.advanced(by: 9)]
        
        var flags = [HandoffFlags]()
        
        //Parse the flags
        if flagByte & 0x1 != 0 {
            flags.append(.url)
        }
        
        if flagByte & 0x2 != 0 {
            flags.append(.fileProviderUrl)
        }
        
        if flagByte & 0x4 != 0 {
            flags.append(.cloudDocs)
        }
        
        if flagByte & 0x8 != 0 {
            flags.append(.pasteboardAvailable)
        }
        
        if flagByte & 0x10 != 0 {
            flags.append(.pasteboardVersionBit(versionBit: flagByte & 0x10))
        }
        
        if flagByte & 0x20 != 0 {
            flags.append(.activityAutoPullOnReceiver)
        }
        
        self.flags = flags
        
        //Match activity
        if flags.contains(.url) {
            handoffActivity = .viewWebpage
        }else {
            handoffActivity = HandoffActivity(withHash: handoffHash)
        }
        
    }
    
    func description() -> String {
        return(
        """
        Handoff Advertisement:
        Actvity: \(self.handoffActivity.activityName())
        App: \(self.handoffActivity.appBundleId())
        """
        )
    }
    
    #if os(macOS)
    func attributedDescription() -> NSAttributedString {
        let description = NSMutableAttributedString()
        description.append(NSAttributedString(string: "Activity:\t\t\t\t"))
        description.append(NSAttributedString(string: handoffActivity.activityName(), attributes: [NSAttributedString.Key.font : NSFont.boldSystemFont(ofSize: 13.0)]))
        description.append(NSAttributedString(string: "\n"))
        
        description.append(NSAttributedString(string: "App:\t\t\t\t"))
        description.append(NSAttributedString(string: handoffActivity.appBundleId(), attributes: [NSAttributedString.Key.font : NSFont.boldSystemFont(ofSize: 13.0)]))
        description.append(NSAttributedString(string: "\n"))
        
        description.append(NSAttributedString(string: "Contains URL:\t\t"))
        description.append(NSAttributedString(string: flags.contains(.url) ? "true" : "false", attributes: [NSAttributedString.Key.font : NSFont.boldSystemFont(ofSize: 13.0)]))
        description.append(NSAttributedString(string: "\n"))
        
        description.append(NSAttributedString(string: "Clipboard Available:\t"))
        description.append(NSAttributedString(string: flags.contains(.pasteboardAvailable) ? "true" : "false", attributes: [NSAttributedString.Key.font : NSFont.boldSystemFont(ofSize: 13.0)]))
        
        return description
    }
    #endif
}

enum HandoffFlags: Equatable {
    case url
    case fileProviderUrl
    case cloudDocs
    case pasteboardAvailable
    case pasteboardVersionBit(versionBit: UInt8)
    case activityAutoPullOnReceiver
    
}
