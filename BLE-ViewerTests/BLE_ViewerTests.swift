//
//  BLE_ViewerTests.swift
//  BLE-ViewerTests
//
//  Created by Alexander Heinrich on 24.09.19.
//  Copyright © 2019 Alexander Heinrich. All rights reserved.
//

import XCTest
@testable import BLE_Viewer
import CryptoSwift

class BLE_ViewerTests: XCTestCase {
    var bleExpect: XCTestExpectation?

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLoadingKeys() throws {
        do {
            let handoffKeys = try KeychainAccess.fetchHandoffKeys()
            
            XCTAssertGreaterThanOrEqual(handoffKeys.count, 1)
            
            var keyMatch = false
            handoffKeys.forEach { (key) in
                if key.keyData == "9cdbb22f 8dfc0198 bbf9b31e 7d64438e 1755094b ad224d32 d897c634 e71ffb9c".hexadecimal! {
                    keyMatch = true
                }
                print(key.keyData.hexEncodedString())
            }
            
            XCTAssertTrue(keyMatch)
            
        }catch (let err) {
             print(err)
            XCTFail("Error thrown")
        }
        
    }
    
    func testBLE() throws {
        let receiver = BLEReceiver()
        receiver.scanForAdvertisements()
        receiver.delegate = self
        
        let expect = self.expectation(description: "Advertisements")
        self.bleExpect = expect
        
        self.wait(for: [expect], timeout: 10.0)
    }
    
    func testIsHandoff() {
        let handoffData = "<4c000c0e 0057cd3b 3cbd48f2 9e6bf563 f0921006 5b1e1d49 e249>".hexadecimal!
        let receiver = BLEReceiver()
        
        XCTAssert(receiver.isHandoff(data: handoffData), "Failed")
        
    }
    
    func testParsing() throws {
        let handoffData = "<4c000c0e 0057cd3b 3cbd48f2 9e6bf563 f0921006 5b1e1d49 e249>".hexadecimal!
        let handoffBLE = try HandoffBLE(handoffData: handoffData)
        
        XCTAssertEqual(handoffBLE.counter, UInt16(52567))
        XCTAssertEqual(handoffBLE.authTag, [0x3b])
        XCTAssertEqual(Array(handoffBLE.encryptedData), Array("3cbd48f2 9e6bf563 f092".hexadecimal!))
    }
    
    func testDecryption() throws {
        do {
            let handoffData = " <4c000c0e 00a9cd77 c546bb00 79902fbf 09371006 5b1ec335 0d71>".hexadecimal!
            let decryptor = try BLEDecryptor()
            let handoffBLE = try HandoffBLE(handoffData: handoffData)
            XCTAssertEqual(Array(handoffBLE.encryptedData), Array("<c546bb0079902fbf0937>".hexadecimal!))
            
            let decrypted = try decryptor.decrypt(handoffBLE: handoffBLE)
            
            XCTAssertNotNil(decrypted)
            XCTAssertEqual(decrypted, "<0088085c342dc9ed408e>".hexadecimal!)
            
        }catch(let error) {
            XCTFail(error.localizedDescription)
        }
        
        
    }
    
    
    func testDecryption2() {
        let encryptedData = Array("3d ce a5 d2 17 21 0f ec 20 3b".hexadecimal!)
        let counter: [UInt8] = [0xf2, 0xcd]
        let tag: [UInt8] = [0xfb]
        let version: [UInt8] = [0x0]
        let key = Array("9cdbb22f 8dfc0198 bbf9b31e 7d64438e 1755094b ad224d32 d897c634 e71ffb9c".hexadecimal!)
        
        let gcm = GCM(iv: counter, authenticationTag: tag, additionalAuthenticatedData: version, mode: .detached)
        
        do {
            let aes = try AES(key: key, blockMode: gcm, padding: .noPadding)
            let decrypted = try aes.decrypt(encryptedData)
            
            XCTAssertNotNil(decrypted)
        }catch {
            XCTFail()
        }
        
        
    }


}

extension BLE_ViewerTests: BLEReceiverDelegate {
    func didReceive(handoffData: Data) {
        self.bleExpect?.fulfill()
    }
}
