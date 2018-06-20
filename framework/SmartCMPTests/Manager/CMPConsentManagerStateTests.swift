//
//  CMPConsentManagerStateTests.swift
//  SmartCMPTests
//
//  Created by Loïc GIRON DIT METAZ on 19/06/2018.
//  Copyright © 2018 Smart AdServer.
//
//  This software is distributed under the Creative Commons Legal Code, Attribution 3.0 Unported license.
//  Check the LICENSE file for more information.
//

import XCTest
@testable import SmartCMP

class CMPConsentManagerStateTests: XCTestCase {
    
    class MockManagerStateProvider : CMPConsentManagerStateProvider {
        var saveStringHandler: ((String, String) -> ())?
        var readStringHandler: ((String) -> (String?))?
        func saveString(string: String, key: String) {
            if saveStringHandler != nil {
                saveStringHandler?(string, key)
            }
        }
        func readString(key: String) -> String? {
            if readStringHandler != nil {
                return readStringHandler?(key)
            } else {
                return nil
            }
        }
    }
    
    func testSaveGDPRStatus() {
        let mockManagerStateProvider = MockManagerStateProvider()
        let managerState = CMPConsentManagerState(provider: mockManagerStateProvider)
        
        mockManagerStateProvider.readStringHandler = { (_) -> (String?) in
            XCTFail("Nothing should be read from storage")
            return nil
        }
        
        mockManagerStateProvider.saveStringHandler = { string, key in
            XCTAssertEqual("IABConsent_SubjectToGDPR", key)
            XCTAssertEqual("1", string)
        }
        managerState.saveGDPRStatus(true)
        
        mockManagerStateProvider.saveStringHandler = { string, key in
            XCTAssertEqual("IABConsent_SubjectToGDPR", key)
            XCTAssertEqual("0", string)
        }
        managerState.saveGDPRStatus(false)
    }
    
    func testSaveConsentString() {
        let mockManagerStateProvider = MockManagerStateProvider()
        let managerState = CMPConsentManagerState(provider: mockManagerStateProvider)
        
        mockManagerStateProvider.readStringHandler = { _ -> String? in
            XCTFail("Nothing should be read from storage")
            return nil
        }
        
        mockManagerStateProvider.saveStringHandler = { string, key in
            XCTAssertEqual("IABConsent_ConsentString", key)
            XCTAssertEqual("consent string", string)
        }
        managerState.saveConsentString("consent string")
    }
    
    func testConsentString() {
        let mockManagerStateProvider = MockManagerStateProvider()
        let managerState = CMPConsentManagerState(provider: mockManagerStateProvider)
        
        mockManagerStateProvider.saveStringHandler = { _, _ in
            XCTFail("Nothing should be stored")
        }
        
        mockManagerStateProvider.readStringHandler = { key -> String? in
            XCTAssertEqual("IABConsent_ConsentString", key)
            return nil
        }
        XCTAssertNil(managerState.consentString())
        
        mockManagerStateProvider.readStringHandler = { key -> String? in
            XCTAssertEqual("IABConsent_ConsentString", key)
            return "consent string"
        }
        XCTAssertEqual("consent string", managerState.consentString())
    }
    
    func testSavePurposeConsentString() {
        let mockManagerStateProvider = MockManagerStateProvider()
        let managerState = CMPConsentManagerState(provider: mockManagerStateProvider)
        
        mockManagerStateProvider.readStringHandler = { _ -> String? in
            XCTFail("Nothing should be read from storage")
            return nil
        }
        
        mockManagerStateProvider.saveStringHandler = { string, key in
            XCTAssertEqual("IABConsent_ParsedPurposeConsents", key)
            XCTAssertEqual("purpose string", string)
        }
        managerState.savePurposeConsentString("purpose string")
    }
    
    func testSaveAdvertisingConsentStatus() {
        let mockManagerStateProvider = MockManagerStateProvider()
        let managerState = CMPConsentManagerState(provider: mockManagerStateProvider)
        
        mockManagerStateProvider.readStringHandler = { _ -> String? in
            XCTFail("Nothing should be read from storage")
            return nil
        }
        
        mockManagerStateProvider.saveStringHandler = { string, key in
            XCTAssertEqual("SmartCMP_advertisingConsentStatus", key)
            XCTAssertEqual("1", string)
        }
        let consentString1 = CMPConsentString(version: 1,
                                              created: Date(),
                                              lastUpdated: Date(),
                                              cmpId: 2,
                                              cmpVersion: 3,
                                              consentScreen: 4,
                                              consentLanguage: CMPLanguage.DEFAULT_LANGUAGE,
                                              vendorListVersion: 5,
                                              maxVendorId: 8,
                                              allowedPurposes: [1, 2, 3, 5], /* purpose 3 is present */
                                              allowedVendors: [1, 3, 8])!
        managerState.saveAdvertisingConsentStatus(forConsentString: consentString1)
        
        mockManagerStateProvider.saveStringHandler = { string, key in
            XCTAssertEqual("SmartCMP_advertisingConsentStatus", key)
            XCTAssertEqual("0", string)
        }
        let consentString2 = CMPConsentString(version: 1,
                                              created: Date(),
                                              lastUpdated: Date(),
                                              cmpId: 2,
                                              cmpVersion: 3,
                                              consentScreen: 4,
                                              consentLanguage: CMPLanguage.DEFAULT_LANGUAGE,
                                              vendorListVersion: 5,
                                              maxVendorId: 8,
                                              allowedPurposes: [1, 2, 5], /* purpose 3 is not present */
                                              allowedVendors: [1, 3, 8])!
        managerState.saveAdvertisingConsentStatus(forConsentString: consentString2)
    }
    
    func testSaveVendorConsentString() {
        let mockManagerStateProvider = MockManagerStateProvider()
        let managerState = CMPConsentManagerState(provider: mockManagerStateProvider)
        
        mockManagerStateProvider.readStringHandler = { _ -> String? in
            XCTFail("Nothing should be read from storage")
            return nil
        }
        
        mockManagerStateProvider.saveStringHandler = { string, key in
            XCTAssertEqual("IABConsent_ParsedVendorConsents", key)
            XCTAssertEqual("vendor string", string)
        }
        managerState.saveVendorConsentString("vendor string")
    }
    
    func testSaveLastPresentationDate() {
        let mockManagerStateProvider = MockManagerStateProvider()
        let managerState = CMPConsentManagerState(provider: mockManagerStateProvider)
        
        mockManagerStateProvider.readStringHandler = { _ -> String? in
            XCTFail("Nothing should be read from storage")
            return nil
        }
        
        mockManagerStateProvider.saveStringHandler = { string, key in
            XCTAssertEqual("SmartCMP_lastPresentationDate", key)
            XCTAssertEqual("1234.0", string)
        }
        managerState.saveLastPresentationDate(Date(timeIntervalSince1970: 1234))
    }
    
    func testLastPresentationDate() {
        let mockManagerStateProvider = MockManagerStateProvider()
        let managerState = CMPConsentManagerState(provider: mockManagerStateProvider)
        
        mockManagerStateProvider.saveStringHandler = { _, _ in
            XCTFail("Nothing should be stored")
        }
        
        mockManagerStateProvider.readStringHandler = { key -> String? in
            XCTAssertEqual("SmartCMP_lastPresentationDate", key)
            return nil
        }
        XCTAssertNil(managerState.lastPresentationDate())
        
        mockManagerStateProvider.readStringHandler = { key -> String? in
            XCTAssertEqual("SmartCMP_lastPresentationDate", key)
            return "1234.0"
        }
        XCTAssertEqual(Date(timeIntervalSince1970: 1234), managerState.lastPresentationDate())
    }
    
}
