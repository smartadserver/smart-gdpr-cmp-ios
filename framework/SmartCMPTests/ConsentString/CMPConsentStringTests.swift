//
//  CMPConsentStringTests.swift
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

class CMPConsentStringTests : XCTestCase {
    
    private func date(from string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return  formatter.date(from: string)!
    }
    
    private lazy var vendorList: CMPVendorList = {
        let url = Bundle(for: type(of: self)).url(forResource: "vendors", withExtension: "json")!
        let jsonData = try! Data(contentsOf: url)
        return CMPVendorList(jsonData: jsonData)!
    }()
    
    private lazy var updatedVendorList: CMPVendorList = {
        let url = Bundle(for: type(of: self)).url(forResource: "vendors_updated", withExtension: "json")!
        let jsonData = try! Data(contentsOf: url)
        return CMPVendorList(jsonData: jsonData)!
    }()
    
    func testConsentStringEquatable() {
        let consentString1 = CMPConsentString(versionConfig: CMPVersionConfig(version: 1)!,
                                              created: Date(timeIntervalSince1970: 2),
                                              lastUpdated: Date(timeIntervalSince1970: 3),
                                              cmpId: 4,
                                              cmpVersion: 5,
                                              consentScreen: 6,
                                              consentLanguage: CMPLanguage(string: "en")!,
                                              vendorListVersion: 8,
                                              maxVendorId: 9,
                                              allowedPurposes: [1],
                                              allowedVendors: [2])
        
        let consentString2 = CMPConsentString(versionConfig: CMPVersionConfig(version: 1)!,
                                              created: Date(timeIntervalSince1970: 2),
                                              lastUpdated: Date(timeIntervalSince1970: 3),
                                              cmpId: 4,
                                              cmpVersion: 5,
                                              consentScreen: 6,
                                              consentLanguage: CMPLanguage(string: "en")!,
                                              vendorListVersion: 8,
                                              maxVendorId: 9,
                                              allowedPurposes: [1],
                                              allowedVendors: [2])
        
        let consentString3 = CMPConsentString(versionConfig: CMPVersionConfig(version: 1)!,
                                              created: Date(timeIntervalSince1970: 3),
                                              lastUpdated: Date(timeIntervalSince1970: 4),
                                              cmpId: 5,
                                              cmpVersion: 6,
                                              consentScreen: 7,
                                              consentLanguage: CMPLanguage(string: "fr")!,
                                              vendorListVersion: 9,
                                              maxVendorId: 10,
                                              allowedPurposes: [1, 2],
                                              allowedVendors: [2, 5])
        
        XCTAssertEqual(consentString1, consentString2)
        XCTAssertNotEqual(consentString1, consentString3)
    }
    
    func testConsentStringEncodingWithBitfield() {
        let date = self.date(from: "2017-11-07T18:59:04.9Z")
        
        let consentString = CMPConsentString(versionConfig: CMPVersionConfig(version: 1)!,
                                             created: date,
                                             lastUpdated: date,
                                             cmpId: 1,
                                             cmpVersion: 2,
                                             consentScreen: 3,
                                             consentLanguage: CMPLanguage(string: "en")!,
                                             vendorListVersion: 1,
                                             maxVendorId: 6,
                                             allowedPurposes: [1, 2],
                                             allowedVendors: [1, 2, 4],
                                             vendorListEncoding: .bitfield)
        
        XCTAssertEqual(consentString.consentString, "BOEFBi5OEFBi5ABACDENABwAAAAAZoA")
    }
    
    func testConsentStringEncodingWithBitfieldFromVersion() {
        let date = self.date(from: "2017-11-07T18:59:04.9Z")
        
        let consentString = CMPConsentString(version: 1,
                                             created: date,
                                             lastUpdated: date,
                                             cmpId: 1,
                                             cmpVersion: 2,
                                             consentScreen: 3,
                                             consentLanguage: CMPLanguage(string: "en")!,
                                             vendorListVersion: 1,
                                             maxVendorId: 6,
                                             allowedPurposes: [1, 2],
                                             allowedVendors: [1, 2, 4])
        
        XCTAssertNotNil(consentString)
        XCTAssertEqual(consentString?.consentString, "BOEFBi5OEFBi5ABACDENABwAAAAAZoA")
    }
    
    func testConsentStringEncodingFromVendorList() {
        let date = self.date(from: "2017-11-07T18:59:04.9Z")
        
        let consentString = CMPConsentString(versionConfig: CMPVersionConfig(version: 1)!,
                                             created: date,
                                             lastUpdated: date,
                                             cmpId: 1,
                                             cmpVersion: 2,
                                             consentScreen: 3,
                                             consentLanguage: CMPLanguage(string: "en")!,
                                             allowedPurposes: [1, 2],
                                             allowedVendors: [1, 2, 4],
                                             vendorList: vendorList)
        
        XCTAssertEqual(consentString.consentString, "BOEFBi5OEFBi5ABACDENAGwAAAACdoAAAAAA")
    }
    
    func testConsentStringCreationFailsForInvalidVersions() {
        let date = self.date(from: "2017-11-07T18:59:04.9Z")
        
        let consentString = CMPConsentString(version: 99999,
                                             created: date,
                                             lastUpdated: date,
                                             cmpId: 1,
                                             cmpVersion: 2,
                                             consentScreen: 3,
                                             consentLanguage: CMPLanguage(string: "en")!,
                                             vendorListVersion: 1,
                                             maxVendorId: 6,
                                             allowedPurposes: [1, 2],
                                             allowedVendors: [1, 2, 4])
        
        XCTAssertNil(consentString)
    }
    
    func testConsentStringEncodingWithRange() {
        let date = self.date(from: "2017-11-07T18:59:04.9Z")
        
        let consentString = CMPConsentString(versionConfig: CMPVersionConfig(version: 1)!,
                                             created: date,
                                             lastUpdated: date,
                                             cmpId: 1,
                                             cmpVersion: 2,
                                             consentScreen: 3,
                                             consentLanguage: CMPLanguage(string: "en")!,
                                             vendorListVersion: 1,
                                             maxVendorId: 6,
                                             allowedPurposes: [1, 2],
                                             allowedVendors: [1, 2, 4],
                                             vendorListEncoding: .range)
        
        XCTAssertEqual(consentString.consentString, "BOEFBi5OEFBi5ABACDENABwAAAAAaACgACAAQABA")
    }
    
    func testConsentStringEncodingWithBitfieldAndUnorderedArrays() {
        let date = self.date(from: "2017-11-07T18:59:04.9Z")
        
        let consentString = CMPConsentString(versionConfig: CMPVersionConfig(version: 1)!,
                                             created: date,
                                             lastUpdated: date,
                                             cmpId: 1,
                                             cmpVersion: 2,
                                             consentScreen: 3,
                                             consentLanguage: CMPLanguage(string: "en")!,
                                             vendorListVersion: 1,
                                             maxVendorId: 6,
                                             allowedPurposes: [2, 1],
                                             allowedVendors: [4, 2, 1],
                                             vendorListEncoding: .bitfield)
        
        XCTAssertEqual(consentString.consentString, "BOEFBi5OEFBi5ABACDENABwAAAAAZoA")
    }
    
    func testConsentStringEncodingWithRangeAndUnorderedArrays() {
        let date = self.date(from: "2017-11-07T18:59:04.9Z")
        
        let consentString = CMPConsentString(versionConfig: CMPVersionConfig(version: 1)!,
                                             created: date,
                                             lastUpdated: date,
                                             cmpId: 1,
                                             cmpVersion: 2,
                                             consentScreen: 3,
                                             consentLanguage: CMPLanguage(string: "en")!,
                                             vendorListVersion: 1,
                                             maxVendorId: 6,
                                             allowedPurposes: [1, 2],
                                             allowedVendors: [4, 2, 1],
                                             vendorListEncoding: .range)
        
        XCTAssertEqual(consentString.consentString, "BOEFBi5OEFBi5ABACDENABwAAAAAaACgACAAQABA")
    }
    
    func testConsentStringEncodingAutomatic() {
        let date = self.date(from: "2017-11-07T18:59:04.9Z")
        
        let consentString = CMPConsentString(versionConfig: CMPVersionConfig(version: 1)!,
                                             created: date,
                                             lastUpdated: date,
                                             cmpId: 1,
                                             cmpVersion: 2,
                                             consentScreen: 3,
                                             consentLanguage: CMPLanguage(string: "en")!,
                                             vendorListVersion: 1,
                                             maxVendorId: 6,
                                             allowedPurposes: [1, 2],
                                             allowedVendors: [1, 2, 4],
                                             vendorListEncoding: .automatic)
        
        // Bitfield encoding will be chosen as at leads to a shorter consent string
        XCTAssertEqual(consentString.consentString, "BOEFBi5OEFBi5ABACDENABwAAAAAZoA")
    }
    
    func testConsentStringDecodingFromBitfield() {
        let date = self.date(from: "2017-11-07T18:59:04.9Z")
        
        let consentStringExpected = CMPConsentString(versionConfig: CMPVersionConfig(version: 1)!,
                                                     created: date,
                                                     lastUpdated: date,
                                                     cmpId: 1,
                                                     cmpVersion: 2,
                                                     consentScreen: 3,
                                                     consentLanguage: CMPLanguage(string: "en")!,
                                                     vendorListVersion: 1,
                                                     maxVendorId: 6,
                                                     allowedPurposes: [1, 2],
                                                     allowedVendors: [1, 2, 4])
        
        let consentString = CMPConsentString.from(base64: "BOEFBi5OEFBi5ABACDENABwAAAAAZoA")
        
        XCTAssertNotNil(consentString)
        XCTAssertEqual(consentString, consentStringExpected)
    }
    
    func testConsentStringDecodingFromRange() {
        let date = self.date(from: "2017-11-07T18:59:04.9Z")
        
        let consentStringExpected = CMPConsentString(versionConfig: CMPVersionConfig(version: 1)!,
                                                     created: date,
                                                     lastUpdated: date,
                                                     cmpId: 1,
                                                     cmpVersion: 2,
                                                     consentScreen: 3,
                                                     consentLanguage: CMPLanguage(string: "en")!,
                                                     vendorListVersion: 1,
                                                     maxVendorId: 6,
                                                     allowedPurposes: [1, 2],
                                                     allowedVendors: [1, 2, 4])
        
        let consentString = CMPConsentString.from(base64: "BOEFBi5OEFBi5ABACDENABwAAAAAaACgACAAQABA")
        
        XCTAssertNotNil(consentString)
        XCTAssertEqual(consentString, consentStringExpected)
        
    }
    
    func testInvalidConsentStringCantBeDecoded() {
        XCTAssertNil(CMPConsentString.from(base64: "BOEFBi5OEFBi5ABACDENABwAAAAAaACgADDAAQABA"))
        XCTAssertNil(CMPConsentString.from(base64: "BOEFBi5OEFBi5ABACDENABwABAAZoA"))
    }
    
    func testPurposePermissionCanBeChecked() {
        let date = self.date(from: "2017-11-07T18:59:04.9Z")
        
        let consentString = CMPConsentString(versionConfig: CMPVersionConfig(version: 1)!,
                                             created: date,
                                             lastUpdated: date,
                                             cmpId: 1,
                                             cmpVersion: 2,
                                             consentScreen: 3,
                                             consentLanguage: CMPLanguage(string: "en")!,
                                             vendorListVersion: 1,
                                             maxVendorId: 6,
                                             allowedPurposes: [1, 2],
                                             allowedVendors: [1, 2, 4])
        
        XCTAssertTrue(consentString.isPurposeAllowed(purposeId: 1))
        XCTAssertTrue(consentString.isPurposeAllowed(purposeId: 2))
        
        XCTAssertFalse(consentString.isPurposeAllowed(purposeId: 3))
        XCTAssertFalse(consentString.isPurposeAllowed(purposeId: 4))
    }
    
    func testVendorPermissionCanBeChecked() {
        let date = self.date(from: "2017-11-07T18:59:04.9Z")
        
        let consentString = CMPConsentString(versionConfig: CMPVersionConfig(version: 1)!,
                                             created: date,
                                             lastUpdated: date,
                                             cmpId: 1,
                                             cmpVersion: 2,
                                             consentScreen: 3,
                                             consentLanguage: CMPLanguage(string: "en")!,
                                             vendorListVersion: 1,
                                             maxVendorId: 6,
                                             allowedPurposes: [1, 2],
                                             allowedVendors: [1, 2, 4])
        
        XCTAssertTrue(consentString.isVendorAllowed(vendorId: 1))
        XCTAssertTrue(consentString.isVendorAllowed(vendorId: 2))
        XCTAssertTrue(consentString.isVendorAllowed(vendorId: 4))
        
        XCTAssertFalse(consentString.isVendorAllowed(vendorId: 3))
        XCTAssertFalse(consentString.isVendorAllowed(vendorId: 5))
        XCTAssertFalse(consentString.isVendorAllowed(vendorId: 6))
    }
    
    func testParsedPurposeConsents() {
        let date = self.date(from: "2017-11-07T18:59:04.9Z")
        
        let consentString = CMPConsentString(versionConfig: CMPVersionConfig(version: 1)!,
                                             created: date,
                                             lastUpdated: date,
                                             cmpId: 1,
                                             cmpVersion: 2,
                                             consentScreen: 3,
                                             consentLanguage: CMPLanguage(string: "en")!,
                                             vendorListVersion: 1,
                                             maxVendorId: 6,
                                             allowedPurposes: [1, 2],
                                             allowedVendors: [1, 2, 4])
        
        XCTAssertEqual(consentString.parsedPurposeConsents, "110000000000000000000000")
    }
    
    func testParsedVendorConsents() {
        let date = self.date(from: "2017-11-07T18:59:04.9Z")
        
        let consentString = CMPConsentString(versionConfig: CMPVersionConfig(version: 1)!,
                                             created: date,
                                             lastUpdated: date,
                                             cmpId: 1,
                                             cmpVersion: 2,
                                             consentScreen: 3,
                                             consentLanguage: CMPLanguage(string: "en")!,
                                             vendorListVersion: 1,
                                             maxVendorId: 6,
                                             allowedPurposes: [1, 2],
                                             allowedVendors: [1, 2, 4])
        
        XCTAssertEqual(consentString.parsedVendorConsents, "110100")
    }
    
    func testConsentStringCanBeCopied() {
        let date = self.date(from: "2017-11-07T18:59:04.9Z")
        
        let consentString = CMPConsentString(versionConfig: CMPVersionConfig(version: 1)!,
                                             created: date,
                                             lastUpdated: date,
                                             cmpId: 1,
                                             cmpVersion: 2,
                                             consentScreen: 3,
                                             consentLanguage: CMPLanguage(string: "en")!,
                                             vendorListVersion: 1,
                                             maxVendorId: 6,
                                             allowedPurposes: [1, 2],
                                             allowedVendors: [1, 2, 4])
        
        let consentStringCopy = consentString.copy() as? CMPConsentString
        XCTAssertEqual(consentString, consentStringCopy)
    }
    
    func testConsentStringWithNoConsent() {
        let date = self.date(from: "2017-11-07T18:59:04.9Z")
        
        let noConsentString = CMPConsentString.consentStringWithNoConsent(consentScreen: 3, consentLanguage: CMPLanguage(string: "en")!, vendorList: vendorList, date: date)
        
        let expectedConsentString = CMPConsentString(versionConfig: CMPVersionConfig(version: 1)!,
                                                     created: date,
                                                     lastUpdated: date,
                                                     cmpId: CMPConstants.CMPInfos.ID,
                                                     cmpVersion: CMPConstants.CMPInfos.VERSION,
                                                     consentScreen: 3,
                                                     consentLanguage: CMPLanguage(string: "en")!,
                                                     allowedPurposes:[],
                                                     allowedVendors: [],
                                                     vendorList: vendorList)
        
        XCTAssertEqual(noConsentString, expectedConsentString)
    }
    
    func testConsentStringWithFullConsent() {
        let date = self.date(from: "2017-11-07T18:59:04.9Z")
        
        let fullConsentString = CMPConsentString.consentStringWithFullConsent(consentScreen: 3, consentLanguage: CMPLanguage(string: "en")!, vendorList: vendorList, date: date)
        
        let expectedConsentString = CMPConsentString(versionConfig: CMPVersionConfig(version: 1)!,
                                                     created: date,
                                                     lastUpdated: date,
                                                     cmpId: CMPConstants.CMPInfos.ID,
                                                     cmpVersion: CMPConstants.CMPInfos.VERSION,
                                                     consentScreen: 3,
                                                     consentLanguage: CMPLanguage(string: "en")!,
                                                     allowedPurposes: IndexSet([1, 2, 3, 4, 5]),
                                                     allowedVendors: IndexSet([8, 12, 28, 9, 27, 25, 26, 1, 6, 30, 24, 29, 39, 11, 15, 4, 7]),
                                                     vendorList: vendorList)
        
        XCTAssertEqual(fullConsentString, expectedConsentString)
    }
    
    func testConsentStringFromUpdatedVendorList() {
        let date = self.date(from: "2017-11-07T18:59:04.9Z")
        let updatedDate = self.date(from: "2018-11-07T18:59:04.9Z")
        
        let consentString = CMPConsentString(versionConfig: CMPVersionConfig(version: 1)!,
                                             created: date,
                                             lastUpdated: date,
                                             cmpId: 1,
                                             cmpVersion: 2,
                                             consentScreen: 3,
                                             consentLanguage: CMPLanguage(string: "en")!,
                                             allowedPurposes: [1, 2],
                                             allowedVendors: [1, 2, 4],
                                             vendorList: vendorList)
        
        let expectedConsentString = CMPConsentString(versionConfig: CMPVersionConfig(version: 1)!,
                                                     created: date,
                                                     lastUpdated: updatedDate,
                                                     cmpId: 1,
                                                     cmpVersion: 2,
                                                     consentScreen: 3,
                                                     consentLanguage: CMPLanguage(string: "en")!,
                                                     allowedPurposes: [1, 2, 6, 7],
                                                     allowedVendors: [1, 2, 4, 40, 41, 42],
                                                     vendorList: updatedVendorList)
        
        let updatedConsentString = CMPConsentString.consentString(fromUpdatedVendorList: updatedVendorList,
                                                                  previousVendorList: vendorList,
                                                                  previousConsentString: consentString,
                                                                  lastUpdated: updatedDate)
        
        XCTAssertEqual(updatedConsentString, expectedConsentString)
    }
    
    func testConsentStringByAddingPurpose() {
        let date = self.date(from: "2017-11-07T18:59:04.9Z")
        let updatedDate = self.date(from: "2018-11-07T18:59:04.9Z")
        
        let consentString = CMPConsentString(versionConfig: CMPVersionConfig(version: 1)!,
                                             created: date,
                                             lastUpdated: date,
                                             cmpId: 1,
                                             cmpVersion: 2,
                                             consentScreen: 3,
                                             consentLanguage: CMPLanguage(string: "en")!,
                                             vendorListVersion: 1,
                                             maxVendorId: 6,
                                             allowedPurposes: [1, 2],
                                             allowedVendors: [1, 2, 4])
        
        let expectedConsentString1 = CMPConsentString(versionConfig: CMPVersionConfig(version: 1)!,
                                                      created: date,
                                                      lastUpdated: updatedDate,
                                                      cmpId: 1,
                                                      cmpVersion: 2,
                                                      consentScreen: 3,
                                                      consentLanguage: CMPLanguage(string: "en")!,
                                                      vendorListVersion: 1,
                                                      maxVendorId: 6,
                                                      allowedPurposes: [1, 2, 4],
                                                      allowedVendors: [1, 2, 4])
        
        let expectedConsentString2 = CMPConsentString(versionConfig: CMPVersionConfig(version: 1)!,
                                                      created: date,
                                                      lastUpdated: updatedDate,
                                                      cmpId: 1,
                                                      cmpVersion: 2,
                                                      consentScreen: 3,
                                                      consentLanguage: CMPLanguage(string: "en")!,
                                                      vendorListVersion: 1,
                                                      maxVendorId: 6,
                                                      allowedPurposes: [1, 2],
                                                      allowedVendors: [1, 2, 4])
        
        let idDoesNotExistsConsentString = CMPConsentString.consentStringByAddingConsent(forPurposeId: 4, consentString: consentString, lastUpdated: updatedDate)
        let idExistsConsentString = CMPConsentString.consentStringByAddingConsent(forPurposeId: 1, consentString: consentString, lastUpdated: updatedDate)
        
        XCTAssertEqual(idDoesNotExistsConsentString, expectedConsentString1)
        XCTAssertEqual(idExistsConsentString, expectedConsentString2)
    }
    
    func testConsentStringByRemovingPurpose() {
        let date = self.date(from: "2017-11-07T18:59:04.9Z")
        let updatedDate = self.date(from: "2018-11-07T18:59:04.9Z")
        
        let consentString = CMPConsentString(versionConfig: CMPVersionConfig(version: 1)!,
                                             created: date,
                                             lastUpdated: date,
                                             cmpId: 1,
                                             cmpVersion: 2,
                                             consentScreen: 3,
                                             consentLanguage: CMPLanguage(string: "en")!,
                                             vendorListVersion: 1,
                                             maxVendorId: 6,
                                             allowedPurposes: [1, 2],
                                             allowedVendors: [1, 2, 4])
        
        let expectedConsentString1 = CMPConsentString(versionConfig: CMPVersionConfig(version: 1)!,
                                                      created: date,
                                                      lastUpdated: updatedDate,
                                                      cmpId: 1,
                                                      cmpVersion: 2,
                                                      consentScreen: 3,
                                                      consentLanguage: CMPLanguage(string: "en")!,
                                                      vendorListVersion: 1,
                                                      maxVendorId: 6,
                                                      allowedPurposes: [2],
                                                      allowedVendors: [1, 2, 4])
        
        let expectedConsentString2 = CMPConsentString(versionConfig: CMPVersionConfig(version: 1)!,
                                                      created: date,
                                                      lastUpdated: updatedDate,
                                                      cmpId: 1,
                                                      cmpVersion: 2,
                                                      consentScreen: 3,
                                                      consentLanguage: CMPLanguage(string: "en")!,
                                                      vendorListVersion: 1,
                                                      maxVendorId: 6,
                                                      allowedPurposes: [1, 2],
                                                      allowedVendors: [1, 2, 4])
        
        let idExistsConsentString = CMPConsentString.consentStringByRemovingConsent(forPurposeId: 1, consentString: consentString, lastUpdated: updatedDate)
        let idDoesNotExistsConsentString = CMPConsentString.consentStringByRemovingConsent(forPurposeId: 4, consentString: consentString, lastUpdated: updatedDate)
        
        XCTAssertEqual(idExistsConsentString, expectedConsentString1)
        XCTAssertEqual(idDoesNotExistsConsentString, expectedConsentString2)
    }
    
    func testConsentStringByAddingVendor() {
        let date = self.date(from: "2017-11-07T18:59:04.9Z")
        let updatedDate = self.date(from: "2018-11-07T18:59:04.9Z")
        
        let consentString = CMPConsentString(versionConfig: CMPVersionConfig(version: 1)!,
                                             created: date,
                                             lastUpdated: date,
                                             cmpId: 1,
                                             cmpVersion: 2,
                                             consentScreen: 3,
                                             consentLanguage: CMPLanguage(string: "en")!,
                                             vendorListVersion: 1,
                                             maxVendorId: 6,
                                             allowedPurposes: [1, 2],
                                             allowedVendors: [1, 2, 4])
        
        let expectedConsentString1 = CMPConsentString(versionConfig: CMPVersionConfig(version: 1)!,
                                                      created: date,
                                                      lastUpdated: updatedDate,
                                                      cmpId: 1,
                                                      cmpVersion: 2,
                                                      consentScreen: 3,
                                                      consentLanguage: CMPLanguage(string: "en")!,
                                                      vendorListVersion: 1,
                                                      maxVendorId: 6,
                                                      allowedPurposes: [1, 2],
                                                      allowedVendors: [1, 2, 4, 6])
        
        let expectedConsentString2 = CMPConsentString(versionConfig: CMPVersionConfig(version: 1)!,
                                                      created: date,
                                                      lastUpdated: updatedDate,
                                                      cmpId: 1,
                                                      cmpVersion: 2,
                                                      consentScreen: 3,
                                                      consentLanguage: CMPLanguage(string: "en")!,
                                                      vendorListVersion: 1,
                                                      maxVendorId: 6,
                                                      allowedPurposes: [1, 2],
                                                      allowedVendors: [1, 2, 4])
        
        let idDoesNotExistsConsentString = CMPConsentString.consentStringByAddingConsent(forVendorId: 6, consentString: consentString, lastUpdated: updatedDate)
        let idExistsConsentString = CMPConsentString.consentStringByAddingConsent(forVendorId: 1, consentString: consentString, lastUpdated: updatedDate)
        
        XCTAssertEqual(idDoesNotExistsConsentString, expectedConsentString1)
        XCTAssertEqual(idExistsConsentString, expectedConsentString2)
    }
    
    func testConsentStringByRemovingVendor() {
        let date = self.date(from: "2017-11-07T18:59:04.9Z")
        let updatedDate = self.date(from: "2018-11-07T18:59:04.9Z")
        
        let consentString = CMPConsentString(versionConfig: CMPVersionConfig(version: 1)!,
                                             created: date,
                                             lastUpdated: date,
                                             cmpId: 1,
                                             cmpVersion: 2,
                                             consentScreen: 3,
                                             consentLanguage: CMPLanguage(string: "en")!,
                                             vendorListVersion: 1,
                                             maxVendorId: 6,
                                             allowedPurposes: [1, 2],
                                             allowedVendors: [1, 2, 4])
        
        let expectedConsentString1 = CMPConsentString(versionConfig: CMPVersionConfig(version: 1)!,
                                                      created: date,
                                                      lastUpdated: updatedDate,
                                                      cmpId: 1,
                                                      cmpVersion: 2,
                                                      consentScreen: 3,
                                                      consentLanguage: CMPLanguage(string: "en")!,
                                                      vendorListVersion: 1,
                                                      maxVendorId: 6,
                                                      allowedPurposes: [1, 2],
                                                      allowedVendors: [1, 2, 4])
        
        let expectedConsentString2 = CMPConsentString(versionConfig: CMPVersionConfig(version: 1)!,
                                                      created: date,
                                                      lastUpdated: updatedDate,
                                                      cmpId: 1,
                                                      cmpVersion: 2,
                                                      consentScreen: 3,
                                                      consentLanguage: CMPLanguage(string: "en")!,
                                                      vendorListVersion: 1,
                                                      maxVendorId: 6,
                                                      allowedPurposes: [1, 2],
                                                      allowedVendors: [2, 4])
        
        let idDoesNotExistsConsentString = CMPConsentString.consentStringByRemovingConsent(forVendorId: 6, consentString: consentString, lastUpdated: updatedDate)
        let idExistsConsentString = CMPConsentString.consentStringByRemovingConsent(forVendorId: 1, consentString: consentString, lastUpdated: updatedDate)
        
        XCTAssertEqual(idDoesNotExistsConsentString, expectedConsentString1)
        XCTAssertEqual(idExistsConsentString, expectedConsentString2)
    }
    
}
