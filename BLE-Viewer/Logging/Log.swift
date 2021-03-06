//
//  Logging.swift
//  BLE-Viewer
//
//  Created by Alexander Heinrich on 25.09.19.
//  Copyright © 2019 Alexander Heinrich. All rights reserved.
//

import Foundation
import OSLog
@_exported import os.log

struct Log {
    static func log(log: OSLog, type: OSLogType, message: StaticString,_ a: [CVarArg]) {
        switch a.count {
        case 5: os_log(message, log: log, type: type, a[0], a[1], a[2], a[3], a[4])
        case 4: os_log(message, log: log, type: type, a[0], a[1], a[2], a[3])
        case 3: os_log(message, log: log, type: type, a[0], a[1], a[2])
        case 2: os_log(message, log: log, type: type, a[0], a[1])
        case 1: os_log(message, log: log, type: type, a[0])
        case 0: os_log(message, log: log, type: type)
        default: os_log(message, log: log, type: type, a)
        }
    }
    
    static func info(system: LogSystem, message: StaticString,_ args: CVarArg...) {
        log(log: system.osLog, type: .info, message: message, args)
    }
    
    static func `default`(system: LogSystem, message: StaticString,_ args: CVarArg...) {
        log(log: system.osLog, type: .default, message: message, args)
    }
    
    static func debug(system: LogSystem, message: StaticString,_ args: CVarArg...) {
        log(log: system.osLog, type: .debug, message: message, args)
    }
    
    static func error(system: LogSystem, message: StaticString,_ args: CVarArg...) {
        log(log: system.osLog, type: .error, message: message, args)
    }
    
    struct LogSystem {
        let osLog: OSLog
        
        init(_ osLog: OSLog) {
            self.osLog = osLog
        }
        
        static let ble = LogSystem(OSLog(subsystem: "de.heinrich.alexander.BLE-Viewer", category: "BLE"))
        static let crypto = LogSystem(OSLog(subsystem: "de.heinrich.alexander.BLE-Viewer", category: "Crypto"))
        
         static let app = LogSystem(OSLog(subsystem: "de.heinrich.alexander.BLE-Viewer", category: "App"))
    }
}
