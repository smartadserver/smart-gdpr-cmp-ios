//
//  CMPPurposeTests.swift
//  SmartCMPTests
//
//  Created by Loïc GIRON DIT METAZ on 04/05/2018.
//  Copyright © 2018 Smart AdServer.
//
//  This software is distributed under the Creative Commons Legal Code, Attribution 3.0 Unported license.
//  Check the LICENSE file for more information.
//

import XCTest
@testable import SmartCMP

class CMPPurposeTests: XCTestCase {
    
    func testPurposeIsEquatable() {
        let purpose1 = CMPPurpose(id: 1, name: "name1", description: "description1")
        let purpose2 = CMPPurpose(id: 1, name: "name1", description: "description1")
        let purpose3 = CMPPurpose(id: 3, name: "name3", description: "description3")
        
        XCTAssertEqual(purpose1, purpose2)
        XCTAssertNotEqual(purpose1, purpose3)
    }
    
}
