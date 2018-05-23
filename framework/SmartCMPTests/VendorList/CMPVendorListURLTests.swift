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

class CMPVendorListURLTests: XCTestCase {
    
    func testDefaultVendorListURLCorrespondsToTheLatest() {
        let expectedUrl = URL(string: "https://vendorlist.consensu.org/vendorlist.json")!
        XCTAssertEqual(CMPVendorListURL().url, expectedUrl)
        XCTAssertNil(CMPVendorListURL().localizedUrl)
    }
    
    func testVendorListURLCanCorrespondToSpecificVersion() {
        let expectedUrl = URL(string: "https://vendorlist.consensu.org/v-42/vendorlist.json")!
        XCTAssertEqual(CMPVendorListURL(version: 42).url, expectedUrl)
        XCTAssertNil(CMPVendorListURL(version: 42).localizedUrl)
    }
    
    func testDefaultVendorListSupportLocalization() {
        let expectedUrl = URL(string: "https://vendorlist.consensu.org/vendorlist.json")!
        let expectedLocalizedUrl = URL(string: "https://vendorlist.consensu.org/purposes-fr.json")!
        XCTAssertEqual(CMPVendorListURL(language: CMPLanguage(string: "fr")!).url, expectedUrl)
        XCTAssertEqual(CMPVendorListURL(language: CMPLanguage(string: "fr")!).localizedUrl, expectedLocalizedUrl)
    }
    
    func testVersionSpecificVendorListSupportLocalization() {
        let expectedUrl = URL(string: "https://vendorlist.consensu.org/v-42/vendorlist.json")!
        let expectedLocalizedUrl = URL(string: "https://vendorlist.consensu.org/purposes-fr-42.json")!
        XCTAssertEqual(CMPVendorListURL(version: 42, language: CMPLanguage(string: "fr")!).url, expectedUrl)
        XCTAssertEqual(CMPVendorListURL(version: 42, language: CMPLanguage(string: "fr")!).localizedUrl, expectedLocalizedUrl)
    }
    
}
