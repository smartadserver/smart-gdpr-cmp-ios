//
//  CMPLanguageTests.swift
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

class CMPLanguageTests: XCTestCase {
    
    func testLanguageCanBeCreated() {
        let language1 = CMPLanguage(string: "en")
        XCTAssertNotNil(language1)
        XCTAssertEqual(language1?.string, "en")
        
        let language2 = CMPLanguage(string: "fr")
        XCTAssertNotNil(language2)
        XCTAssertEqual(language2?.string, "fr")
        
        let language3 = CMPLanguage(string: "EN")
        XCTAssertNotNil(language3)
        XCTAssertEqual(language3?.string, "en")
    }
    
    func testInvalidLanguageAreRejected() {
        let language1 = CMPLanguage(string: "eng") // too long
        XCTAssertNil(language1)
        
        let language2 = CMPLanguage(string: "e") // too short
        XCTAssertNil(language2)
        
        let language3 = CMPLanguage(string: "f+") // invalid character
        XCTAssertNil(language3)
    }
    
    func testLanguageAreEquatable() {
        let language1 = CMPLanguage(string: "en")
        let language2 = CMPLanguage(string: "en")
        let language3 = CMPLanguage(string: "fr")
        let language4 = CMPLanguage(string: "EN")
        
        XCTAssertEqual(language1, language2)
        XCTAssertNotEqual(language1, language3)
        XCTAssertEqual(language1, language4)
    }
    
}
