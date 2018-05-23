//
//  CMPFeatureTests.swift
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

class CMPFeatureTests: XCTestCase {
    
    func testFeatureIsEquatable() {
        let feature1 = CMPFeature(id: 1, name: "name1", description: "description1")
        let feature2 = CMPFeature(id: 1, name: "name1", description: "description1")
        let feature3 = CMPFeature(id: 3, name: "name3", description: "description3")
        
        XCTAssertEqual(feature1, feature2)
        XCTAssertNotEqual(feature1, feature3)
    }
    
}
