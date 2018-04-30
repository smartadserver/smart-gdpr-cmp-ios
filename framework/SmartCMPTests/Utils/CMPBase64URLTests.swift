//
//  CMPBase64URLTests.swift
//  SmartCMP
//
//  Created by Loïc GIRON DIT METAZ on 24/04/2018.
//  Copyright © 2018 Smart AdServer.
//
//  This software is distributed under the Creative Commons Legal Code, Attribution 3.0 Unported license.
//  Check the LICENSE file for more information.
//

import XCTest
@testable import SmartCMP

class CMPBase64URLTests : XCTestCase {
    
    func testEncodeString() {
        XCTAssertEqual("dGVzdCBzdHJpbmc", CMPBase64URL.base64URL(fromString: "test string"))
    }
    
    func testDecodeString() {
        XCTAssertEqual("test string", CMPBase64URL.string(fromBase64URL: "dGVzdCBzdHJpbmc"))
    }
    
    func testEncodeData() {
        let data = "test string".data(using: String.Encoding.utf8)!
        XCTAssertEqual("dGVzdCBzdHJpbmc", CMPBase64URL.base64URL(fromData: data))
    }
    
    func testDecodeData() {
        let data = "test string".data(using: String.Encoding.utf8)!
        XCTAssertEqual(data, CMPBase64URL.data(fromBase64URL: "dGVzdCBzdHJpbmc"))
    }
    
}
