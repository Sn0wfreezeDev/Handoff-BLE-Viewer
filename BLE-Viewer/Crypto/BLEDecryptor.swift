//
//  BLEDecryptor.swift
//  BLE-Viewer
//
//  Created by Alexander Heinrich on 25.09.19.
//  Copyright © 2019 Alexander Heinrich. All rights reserved.
//

import Foundation
import CryptoSwift

struct BLEDecryptor {
    var keys: [HandoffKey]
    
    init() throws {
        self.keys = try KeychainAccess.fetchHandoffKeys()
    }
    
    func decrypt(handoffBLE: HandoffBLE) throws -> Data {
        keys.forEach({ (key) in
            
        })
        
        for key in keys {
            do {
                let decrypted = try decrypt(handoffBLE: handoffBLE, withKey: key)
                Log.info(system: .crypto,
                         message:
                        """
                        Successfully decrypted handoff message
                        Key used: %@
                        Decrypted message:
                        %@
                        """,
                        key.keyIdentifier.uuidString, decrypted.hexadecimal )
                
                return decrypted
                
            }catch (_) {
                //Should fail quite often 
//                Log.debug(system: .crypto, message: "Failed decrypting with key %@.\nError %@", key.keyIdentifier.uuidString, error.localizedDescription)
            }
        }
        
        throw DecryptionError.noKeyFound
    }
    
    func decrypt(handoffBLE: HandoffBLE, withKey key: HandoffKey) throws -> Data {
        let version: [UInt8] = [handoffBLE.statusByte]
        
        let gcm = GCM(iv: handoffBLE.counterIV, authenticationTag: handoffBLE.authTag, additionalAuthenticatedData: version, mode: .detached)
        
        gcm.authenticationTag = handoffBLE.authTag
        
        let keyArray = Array(key.keyData)
        let aes  = try AES(key: keyArray, blockMode: gcm, padding: .noPadding)
        
        let encryptedData = Array(handoffBLE.encryptedData)
        
        let decryptedArray = try aes.decrypt(encryptedData)
        return Data(decryptedArray)
        
    }
    
    enum DecryptionError: Error {
        case noKeyFound
    }
}
