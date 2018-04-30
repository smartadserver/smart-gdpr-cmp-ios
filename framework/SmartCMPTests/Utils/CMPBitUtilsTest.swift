//
//  CMPBitUtils.swift
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

class CMPBitUtilsTests : XCTestCase {
    
    private func date(from string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return  formatter.date(from: string)!
    }
    
    func testIntToBits() {
        XCTAssertEqual(CMPBitUtils.intToBits(0, numberOfBits: 1), "0")
        XCTAssertEqual(CMPBitUtils.intToBits(1, numberOfBits: 1), "1")
        XCTAssertEqual(CMPBitUtils.intToBits(2, numberOfBits: 1), "10")
        XCTAssertEqual(CMPBitUtils.intToBits(2, numberOfBits: 4), "0010")
        XCTAssertEqual(CMPBitUtils.intToBits(42, numberOfBits: 8), "00101010")
    }
    
    func testBoolToBits() {
        XCTAssertEqual(CMPBitUtils.boolToBits(false, numberOfBits: 1), "0")
        XCTAssertEqual(CMPBitUtils.boolToBits(true, numberOfBits: 1), "1")
        XCTAssertEqual(CMPBitUtils.boolToBits(false, numberOfBits: 2), "00")
        XCTAssertEqual(CMPBitUtils.boolToBits(true, numberOfBits: 3), "001")
    }
    
    func testDateToBits() {
        XCTAssertEqual(CMPBitUtils.dateToBits(date(from: "2017-11-07T18:59:04.9Z"), numberOfBits: 1), "1110000100000101000001100010111001")
        XCTAssertEqual(CMPBitUtils.dateToBits(date(from: "2017-11-07T18:59:04.9Z"), numberOfBits: 40), "0000001110000100000101000001100010111001")
        XCTAssertEqual(CMPBitUtils.dateToBits(Date(timeIntervalSince1970: 1512661975.200), numberOfBits: 36), "001110000101100111011110011001101000")
    }
    
    func testLetterToBits() {
        XCTAssertEqual(CMPBitUtils.letterToBits("a", numberOfBits: 1), "0")
        XCTAssertEqual(CMPBitUtils.letterToBits("K", numberOfBits: 1), "1010")
        XCTAssertEqual(CMPBitUtils.letterToBits("z", numberOfBits: 1), "11001")
        XCTAssertEqual(CMPBitUtils.letterToBits("a", numberOfBits: 6), "000000")
        XCTAssertEqual(CMPBitUtils.letterToBits("K", numberOfBits: 6), "001010")
        XCTAssertEqual(CMPBitUtils.letterToBits("z", numberOfBits: 6), "011001")
    }
    
    func testLanguageToBits() {
        XCTAssertEqual(CMPBitUtils.languageToBits(CMPLanguage(string: "en")!, numberOfBits: 12), "000100001101")
        XCTAssertEqual(CMPBitUtils.languageToBits(CMPLanguage(string: "EN")!, numberOfBits: 12), "000100001101")
        XCTAssertEqual(CMPBitUtils.languageToBits(CMPLanguage(string: "fr")!, numberOfBits: 12), "000101010001")
        XCTAssertEqual(CMPBitUtils.languageToBits(CMPLanguage(string: "FR")!, numberOfBits: 12), "000101010001")
    }
    
    func testBitsToInt() {
        XCTAssertEqual(CMPBitUtils.bitsToInt("0"), 0)
        XCTAssertEqual(CMPBitUtils.bitsToInt("1"), 1)
        XCTAssertEqual(CMPBitUtils.bitsToInt("10"), 2)
        XCTAssertEqual(CMPBitUtils.bitsToInt("00101010"), 42)
        XCTAssertNil(CMPBitUtils.bitsToInt("00101a10"))
    }
    
    func testBitsToBool() {
        XCTAssertEqual(CMPBitUtils.bitsToBool("0"), false)
        XCTAssertEqual(CMPBitUtils.bitsToBool("1"), true)
        XCTAssertNil(CMPBitUtils.bitsToBool("00"))
        XCTAssertNil(CMPBitUtils.bitsToBool("01"))
        XCTAssertNil(CMPBitUtils.bitsToBool("a"))
    }
    
    func testBitsToDate() {
        XCTAssertEqual(CMPBitUtils.bitsToDate("1110000100000101000001100010111001"), date(from: "2017-11-07T18:59:04.9Z"))
        XCTAssertEqual(CMPBitUtils.bitsToDate("0000001110000100000101000001100010111001"), date(from: "2017-11-07T18:59:04.9Z"))
        XCTAssertEqual(CMPBitUtils.bitsToDate("001110000101100111011110011001101000"), Date(timeIntervalSince1970: 1512661975.200))
        XCTAssertNil(CMPBitUtils.bitsToDate("0a01110000101100111011110011001101000"))
    }
    
    func testBitsToLetter() {
        XCTAssertEqual(CMPBitUtils.bitsToLetter("0"), "a")
        XCTAssertEqual(CMPBitUtils.bitsToLetter("1010"), "k")
        XCTAssertEqual(CMPBitUtils.bitsToLetter("11001"), "z")
        XCTAssertEqual(CMPBitUtils.bitsToLetter("000000"), "a")
        XCTAssertEqual(CMPBitUtils.bitsToLetter("001010"), "k")
        XCTAssertEqual(CMPBitUtils.bitsToLetter("011001"), "z")
        XCTAssertNil(CMPBitUtils.bitsToLetter(""))
        XCTAssertNil(CMPBitUtils.bitsToLetter("a"))
    }
    
    func testBitsToLanguage() {
        XCTAssertEqual(CMPBitUtils.bitsToLanguage("000100001101"), CMPLanguage(string: "en"))
        XCTAssertEqual(CMPBitUtils.bitsToLanguage("000101010001"), CMPLanguage(string: "fr"))
        XCTAssertNil(CMPBitUtils.bitsToLanguage("a000101010001"))
    }
    
}
