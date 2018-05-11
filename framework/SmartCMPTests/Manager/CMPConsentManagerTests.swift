//
//  CMPConsentManagerTests.swift
//  SmartCMPTests
//
//  Created by Thomas Geley on 25/04/2018.
//  Copyright © 2018 Smart AdServer.
//
//  This software is distributed under the Creative Commons Legal Code, Attribution 3.0 Unported license.
//  Check the LICENSE file for more information.
//

import XCTest
@testable import SmartCMP

class CMPConsentManagerTests : XCTestCase {
    
    override func à() {
        super.setUp()
        cleanUserDefaults()
    }
    
    override func tearDown() {
        cleanUserDefaults()
        super.tearDown()
    }

    private func readUserDefaults(key: String) -> String? {
        let userDefaults = UserDefaults.standard
        let value = userDefaults.object(forKey: key) as? String
        return value
    }
    
    private func cleanUserDefaults() {
        let defaults = UserDefaults.standard
        for key in [CMPConstants.IABConsentKeys.ConsentString, CMPConstants.IABConsentKeys.ParsedPurposeConsent, CMPConstants.IABConsentKeys.ParsedVendorConsent, CMPConstants.IABConsentKeys.SubjectToGDPR] {
            defaults.removeObject(forKey: key)
        }
        defaults.synchronize()
    }
    
    func testSaveConsentString() {
        // First value is nil
        let initialValue = readUserDefaults(key: CMPConstants.IABConsentKeys.ConsentString)
        XCTAssertNil(initialValue)
        
        // Save string to NSUserDefaults
        let newValue = "consentString"
        CMPConsentManager.shared.saveConsentString(newValue)
        
        // Read string from NSUserDefaults
        let readValue = readUserDefaults(key: CMPConstants.IABConsentKeys.ConsentString)
        XCTAssertEqual(newValue, readValue)
    }
    
    func testSaveGDPRStatus() {
        // First value is nil
        let initialValue = readUserDefaults(key: CMPConstants.IABConsentKeys.SubjectToGDPR)
        XCTAssertNil(initialValue)
        
        // Save string to NSUserDefaults
        let newValue = false
        CMPConsentManager.shared.saveGDPRStatus(newValue)
        
        // Read string from NSUserDefaults
        let readValue = readUserDefaults(key: CMPConstants.IABConsentKeys.SubjectToGDPR)
        XCTAssertEqual(newValue ? "1":"0", readValue)
    }
    
    func testSavePurpose() {
        // First value is nil
        let initialValue = readUserDefaults(key: CMPConstants.IABConsentKeys.ParsedPurposeConsent)
        XCTAssertNil(initialValue)
        
        // Save string to NSUserDefaults
        let newValue = "purpose"
        CMPConsentManager.shared.savePurposeConsentString(newValue)
        
        // Read string from NSUserDefaults
        let readValue = readUserDefaults(key: CMPConstants.IABConsentKeys.ParsedPurposeConsent)
        XCTAssertEqual(newValue, readValue)
    }
        
    func testSaveVendors() {
        // First value is nil
        let initialValue = readUserDefaults(key: CMPConstants.IABConsentKeys.ParsedVendorConsent)
        XCTAssertNil(initialValue)
        
        // Save string to NSUserDefaults
        let newValue = "vendors"
        CMPConsentManager.shared.saveVendorConsentString(newValue)
        
        // Read string from NSUserDefaults
        let readValue = readUserDefaults(key: CMPConstants.IABConsentKeys.ParsedVendorConsent)
        XCTAssertEqual(newValue, readValue)
    }
    
}

