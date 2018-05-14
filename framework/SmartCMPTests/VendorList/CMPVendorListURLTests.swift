//
//  CMPVendorListURLTests.swift
//  SmartCMPTests
//
//  Created by Loïc GIRON DIT METAZ on 07/05/2018.
//  Copyright © 2018 Smart AdServer.
//
//  This software is distributed under the Creative Commons Legal Code, Attribution 3.0 Unported license.
//  Check the LICENSE file for more information.
//

import XCTest
@testable import SmartCMP

class CMPVendorListURLTests : XCTestCase {
    
    func testDefaultVendorListURLCorrespondsToTheLatest() {
        let expectedUrl = URL(string: "https://vendorlist.consensu.org/vendorlist.json")!
        XCTAssertEqual(CMPVendorListURL().url, expectedUrl)
    }
    
    func testVendorListURLCanCorrespondToSpecificVersion() {
        let expectedUrl = URL(string: "https://vendorlist.consensu.org/v-42/vendorlist.json")!
        XCTAssertEqual(CMPVendorListURL(version: 42).url, expectedUrl)
    }
    
}
