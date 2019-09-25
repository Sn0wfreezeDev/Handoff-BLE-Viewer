//
//  KeychainAccess.swift
//  BLE-Viewer
//
//  Created by Alexander Heinrich on 24.09.19.
//  Copyright © 2019 Alexander Heinrich. All rights reserved.
//

import Foundation

struct KeychainAccess {
    
    static func fetchHandoffKeys() throws -> [HandoffKey] {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: "com.apple.continuity.encryption",
            kSecReturnAttributes: true,
            kSecMatchLimit: kSecMatchLimitAll
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess else {throw KeychainError.secKeychain(err: NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil))}
        
        guard let itemArray = item as? [[CFString: Any]] else {throw KeychainError.keychainResponse}
        
        var responseArray = Array<Data>()
        
        for item in itemArray {
            let fetchedData = try fetchItem(withAttributes: item)
            responseArray.append(fetchedData)
        }
        
        //Fetch the NSDictionary
        let dictionaryResponses = try responseArray.compactMap({try PropertyListSerialization.propertyList(from: $0, options: [], format: nil) as? [String: Any]})
        
        return try dictionaryResponses.map({try HandoffKey(withDictionary: $0)})
    }
    
    static func fetchItem(withAttributes item: [CFString: Any]) throws -> Data {
        let itemQuery : [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount : item[kSecAttrAccount]!,
            kSecAttrLabel : item[kSecAttrLabel]!,
            kSecAttrService: item[kSecAttrService]!,
            kSecReturnData : true
            ]
        
        var fetchedItem: CFTypeRef?
        let status = SecItemCopyMatching(itemQuery as CFDictionary, &fetchedItem)
        
        guard status == errSecSuccess,
            let fetchedData = fetchedItem as? Data else {throw KeychainError.secKeychain(err: NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil))}
        
        return fetchedData
    }
}

enum KeychainError: Error {
    case secKeychain(err: NSError)
    case keychainResponse
    case keyParsing
}

struct HandoffKey {
    let dateCreated: Date
    let isWrappedKey: Bool
    let keyData: Data
    let keyIdentifier: UUID
    let lastUsedCounter: Int
    
    init(withDictionary dict: [String: Any]) throws {
        guard let dC = dict["dateCreated"] as? Date,
            let wrapped = dict["isWrappedKey"] as? Bool,
            let kD = dict["keyData"] as? Data,
            let keyId = dict["keyIdentifier"] as? String,
            let keyUUID = UUID(uuidString: keyId),
            let counter = dict["lastUsedCounter"] as? Int else {
                throw KeychainError.keyParsing
        }
        
        dateCreated = dC
        isWrappedKey = wrapped
        keyData = kD
        keyIdentifier = keyUUID
        lastUsedCounter = counter
    }
}
