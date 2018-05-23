//
//  CMPVendorTests.swift
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

class CMPVendorTests: XCTestCase {
    
    func testVendorIsEquatable() {
        let vendor1 = CMPVendor(id: 1, name: "name1", purposes: [1], legitimatePurposes: [2], features: [3], policyURL: URL(string: "http://url1")!)
        let vendor2 = CMPVendor(id: 1, name: "name1", purposes: [1], legitimatePurposes: [2], features: [3], policyURL: URL(string: "http://url1")!)
        let vendor3 = CMPVendor(id: 3, name: "name3", purposes: [3], legitimatePurposes: [4], features: [5], policyURL: URL(string: "http://url3")!)
        let vendor4 = CMPVendor(id: 1, name: "name1", purposes: [1], legitimatePurposes: [2], features: [3], policyURL: URL(string: "http://url1")!, deletedDate: Date())
        
        XCTAssertEqual(vendor1, vendor2)
        XCTAssertNotEqual(vendor1, vendor3)
        XCTAssertNotEqual(vendor1, vendor4)
    }
    
}
