//
//  HandoffBLE.swift
//  BLE-Viewer
//
//  Created by Alexander Heinrich on 25.09.19.
//  Copyright © 2019 Alexander Heinrich. All rights reserved.
//

import Foundation


/// This struct parses BLE data with Handoff to a format which can than be processed further
/// It is used for parsing raw advertisements which are encrypted
struct HandoffBLE {
    let statusByte: UInt8
    let counter: UInt16
    let counterIV: Array<UInt8>
    let authTag: Array<UInt8>
    let encryptedData: Data
    
    init(handoffData: Data) throws {
        guard handoffData.count >= 3 else {throw HandoffError.invalidFormat}
        
        let isAppleData = handoffData[handoffData.startIndex] == 0x4c
        let isHandoffData = handoffData[handoffData.startIndex.advanced(by: 2)] == 0x0c
        
        guard isAppleData && isHandoffData else {throw HandoffError.invalidFormat}
        
        let handoffContentLength = Int(handoffData[handoffData.startIndex.advanced(by: 3)])
        let contentStartIdx = handoffData.startIndex.advanced(by: 4)
        let handoffContent  = handoffData[contentStartIdx...(contentStartIdx+handoffContentLength-1)]
        statusByte = handoffContent[handoffContent.startIndex]
        
        let counterData = (handoffContent[handoffContent.startIndex.advanced(by: 1)...handoffContent.startIndex.advanced(by: 2)])
        counter = counterData.uint16
        counterIV = Array(counterData)
        
        let authTagByte = handoffContent[handoffContent.startIndex.advanced(by: 3)]
        authTag = Array([authTagByte])
        
        encryptedData = handoffContent[handoffContent.startIndex.advanced(by: 4)...]
    }
    
    enum HandoffError: Error {
        case invalidFormat
    }
}
