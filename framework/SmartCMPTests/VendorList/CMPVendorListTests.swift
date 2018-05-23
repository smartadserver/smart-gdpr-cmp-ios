//
//  CMPVendorListTests.swift
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

class CMPVendorListTests: XCTestCase {
    
    private func date(from string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return  formatter.date(from: string)!
    }
    
    private lazy var vendorsJSON: Data = {
        let url = Bundle(for: type(of: self)).url(forResource: "vendors", withExtension: "json")!
        return try! Data(contentsOf: url)
    }()
    
    private lazy var updatedVendorsJSON: Data = {
        let url = Bundle(for: type(of: self)).url(forResource: "vendors_updated", withExtension: "json")!
        return try! Data(contentsOf: url)
    }()
    
    private lazy var vendorsFRJSON: Data = {
        let url = Bundle(for: type(of: self)).url(forResource: "vendors-fr", withExtension: "json")!
        return try! Data(contentsOf: url)
    }()
    
    func testVendorListCanBeCreatedFromJSON() {
        let vendorList = CMPVendorList(jsonData: self.vendorsJSON)
        
        XCTAssertNotNil(vendorList)
        XCTAssertEqual(vendorList?.vendorListVersion, 6)
        XCTAssertEqual(vendorList?.lastUpdated, date(from: "2018-04-23T16:03:22Z"))
        
        XCTAssertEqual(vendorList?.purposes.count, 5)
        XCTAssertEqual(vendorList?.purposes[2].id, 3)
        XCTAssertEqual(vendorList?.purposes[2].name, "Ad selection, delivery, reporting")
        XCTAssertEqual(vendorList?.purposes[2].purposeDescription, "The collection of information, and combination with previously collected information, to select and deliver advertisements for you, and to measure the delivery and effectiveness of such advertisements. This includes using previously collected information about your interests to select ads, processing data about what advertisements were shown, how often they were shown, when and where they were shown, and whether you took any action related to the advertisement, including for example clicking an ad or making a purchase. ")
        
        XCTAssertEqual(vendorList?.features.count, 3)
        XCTAssertEqual(vendorList?.features[1].id, 2)
        XCTAssertEqual(vendorList?.features[1].name, "Linking Devices")
        XCTAssertEqual(vendorList?.features[1].featureDescription, "Allow processing of a user's data to connect such user across multiple devices.")
        
        XCTAssertEqual(vendorList?.vendors.count, 17)
        XCTAssertEqual(vendorList?.vendors[4].id, 27)
        XCTAssertEqual(vendorList?.vendors[4].name, "ADventori SAS")
        XCTAssertEqual(vendorList?.vendors[4].policyURL, URL(string: "https://www.adventori.com/with-us/legal-notice/"))
        XCTAssertEqual(vendorList?.vendors[4].purposes, [2])
        XCTAssertEqual(vendorList?.vendors[4].legitimatePurposes, [1, 3, 4, 5])
        XCTAssertEqual(vendorList?.vendors[4].features, [])
    }
    
    func testInvalidPolicyURLAreRejectedByTheParser() {
        let vendorList = CMPVendorList(jsonData: self.vendorsJSON)
        XCTAssertNotNil(vendorList)
        
        XCTAssertEqual(vendorList?.vendors[12].name, "ADITION technologies AG")
        XCTAssertNil(vendorList?.vendors[12].policyURL) // 'adition.com/datenschutz' is not valid because a scheme is needed
    }
    
    func testEmptyJSONIsRejectedByTheParser() {
        let vendorList1 = CMPVendorList(jsonData: "".data(using: String.Encoding.utf8)!)
        XCTAssertNil(vendorList1)
        
        let vendorList2 = CMPVendorList(jsonData: "{}".data(using: String.Encoding.utf8)!)
        XCTAssertNil(vendorList2)
    }
    
    func testInvalidJSONIsRejectedByTheParser() {
        let vendorList = CMPVendorList(jsonData: "not a valid JSON".data(using: String.Encoding.utf8)!)
        XCTAssertNil(vendorList)
    }
    
    func testFindingMaxVendorId() {
        let vendorList = CMPVendorList(jsonData: self.vendorsJSON)
        XCTAssertEqual(vendorList?.maxVendorId, 39)
    }
    
    func testFindingVendorCount() {
        let vendorList = CMPVendorList(jsonData: self.updatedVendorsJSON)
        XCTAssertEqual(vendorList?.vendorCount, 20)
    }
    
    func testFindingEnabledVendorCount() {
        let vendorList = CMPVendorList(jsonData: self.updatedVendorsJSON)
        XCTAssertEqual(vendorList?.activatedVendorCount, 19)
    }
    
    func testVendorListIsEquatable() {
        let vendorList1 = CMPVendorList(jsonData: vendorsJSON)
        let vendorList2 = CMPVendorList(jsonData: vendorsJSON)
        let vendorList3 = CMPVendorList(jsonData: updatedVendorsJSON)
        
        XCTAssertEqual(vendorList1, vendorList2)
        XCTAssertNotEqual(vendorList1, vendorList3)
    }
    
    func testVendorListCanBeEncoded() {
        let vendorList = CMPVendorList(jsonData: vendorsJSON)
        
        let encodedVendorList = try? PropertyListEncoder().encode(vendorList)
        XCTAssertNotNil(encodedVendorList)
        
        let decodedVendorList = try? PropertyListDecoder().decode(CMPVendorList.self, from: encodedVendorList!)
        XCTAssertNotNil(decodedVendorList)
        
        XCTAssertEqual(vendorList, decodedVendorList)
    }
    
    func testVendorListCannotBeCreatedFromTranslatedListOnly() {
        let vendorList = CMPVendorList(jsonData: self.vendorsFRJSON)
        XCTAssertNil(vendorList)
    }
    
    func testVendorListCanBeLocalizedWithAnExternalJson() {
        let vendorList = CMPVendorList(jsonData: self.vendorsJSON, localizedJsonData: self.vendorsFRJSON)
        
        XCTAssertNotNil(vendorList)
        XCTAssertEqual(vendorList?.vendorListVersion, 6)
        XCTAssertEqual(vendorList?.lastUpdated, date(from: "2018-04-23T16:03:22Z"))
        
        XCTAssertEqual(vendorList?.purposes.count, 5)
        XCTAssertEqual(vendorList?.purposes[2].id, 3)
        XCTAssertEqual(vendorList?.purposes[2].name, "Purpose 3 name translated in french")
        XCTAssertEqual(vendorList?.purposes[2].purposeDescription, "Purpose 3 description translated in french")
        
        XCTAssertEqual(vendorList?.features.count, 3)
        XCTAssertEqual(vendorList?.features[1].id, 2)
        XCTAssertEqual(vendorList?.features[1].name, "Feature 2 name translated in french")
        XCTAssertEqual(vendorList?.features[1].featureDescription, "Feature 2 description translated in french")
        
        XCTAssertEqual(vendorList?.vendors.count, 17)
        XCTAssertEqual(vendorList?.vendors[4].id, 27)
        XCTAssertEqual(vendorList?.vendors[4].name, "ADventori SAS")
        XCTAssertEqual(vendorList?.vendors[4].policyURL, URL(string: "https://www.adventori.com/with-us/legal-notice/"))
        XCTAssertEqual(vendorList?.vendors[4].purposes, [2])
        XCTAssertEqual(vendorList?.vendors[4].legitimatePurposes, [1, 3, 4, 5])
        XCTAssertEqual(vendorList?.vendors[4].features, [])
    }
    
    func testVendorListWithInvalidLocalizedJsonFallbackOnDefaultValues() {
        let vendorList = CMPVendorList(jsonData: self.vendorsJSON, localizedJsonData: "{}".data(using: String.Encoding.utf8)!) // Empty localized JSON
        
        XCTAssertNotNil(vendorList)
        XCTAssertEqual(vendorList?.vendorListVersion, 6)
        XCTAssertEqual(vendorList?.lastUpdated, date(from: "2018-04-23T16:03:22Z"))
        
        XCTAssertEqual(vendorList?.purposes.count, 5)
        XCTAssertEqual(vendorList?.purposes[2].id, 3)
        XCTAssertEqual(vendorList?.purposes[2].name, "Ad selection, delivery, reporting")
        XCTAssertEqual(vendorList?.purposes[2].purposeDescription, "The collection of information, and combination with previously collected information, to select and deliver advertisements for you, and to measure the delivery and effectiveness of such advertisements. This includes using previously collected information about your interests to select ads, processing data about what advertisements were shown, how often they were shown, when and where they were shown, and whether you took any action related to the advertisement, including for example clicking an ad or making a purchase. ")
        
        XCTAssertEqual(vendorList?.features.count, 3)
        XCTAssertEqual(vendorList?.features[1].id, 2)
        XCTAssertEqual(vendorList?.features[1].name, "Linking Devices")
        XCTAssertEqual(vendorList?.features[1].featureDescription, "Allow processing of a user's data to connect such user across multiple devices.")
        
        XCTAssertEqual(vendorList?.vendors.count, 17)
        XCTAssertEqual(vendorList?.vendors[4].id, 27)
        XCTAssertEqual(vendorList?.vendors[4].name, "ADventori SAS")
        XCTAssertEqual(vendorList?.vendors[4].policyURL, URL(string: "https://www.adventori.com/with-us/legal-notice/"))
        XCTAssertEqual(vendorList?.vendors[4].purposes, [2])
        XCTAssertEqual(vendorList?.vendors[4].legitimatePurposes, [1, 3, 4, 5])
        XCTAssertEqual(vendorList?.vendors[4].features, [])
    }
    
}
