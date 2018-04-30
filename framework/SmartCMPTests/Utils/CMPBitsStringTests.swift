//
//  CMPBitsStringTests.swift
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

class CMPBitsStringTests : XCTestCase {
    
    private let SAMPLE_BITS_STRING = "000001001110001001001110011011001000010010001110001001001110011011001000010010000000000000000001000000000000000100001101000000000000111000000000000000000000000000000000101000000000000000000000"
    
    private let SAMPLE_BASE64_STRING = "BOJObISOJObISAABAAENAA4AAAAAoAAA"
    
    func testBitsStringFromBase64() {
        XCTAssertEqual(SAMPLE_BITS_STRING, CMPBitsString(string: SAMPLE_BASE64_STRING)!.bitsValue)
    }
    
    func testBitsStringFromBits() {
        XCTAssertEqual(SAMPLE_BASE64_STRING, CMPBitsString(bitsString: SAMPLE_BITS_STRING)!.stringValue)
    }
    
    func testInvalidBase64StringsAreRejected() {
        XCTAssertNil(CMPBitsString(string: "ABC/+"))
    }
    
    func testInvalidBitsStringsAreRejected() {
        XCTAssertNil(CMPBitsString(bitsString: "0000010011100010010011100A"))
    }
    
}
