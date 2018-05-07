//
//  CMPVendorListManagerTests.swift
//  SmartCMPTests
//
//  Created by Loïc GIRON DIT METAZ on 26/04/2018.
//  Copyright © 2018 Smart AdServer.
//
//  This software is distributed under the Creative Commons Legal Code, Attribution 3.0 Unported license.
//  Check the LICENSE file for more information.
//

import XCTest
@testable import SmartCMP

class CMPVendorListManagerTests : XCTestCase {
    
    private lazy var vendorListJSON: String = {
        let url = Bundle(for: type(of: self)).url(forResource: "vendors", withExtension: "json")!
        let jsonData = try! Data(contentsOf: url)
        return String(data: jsonData, encoding: String.Encoding.utf8)!
    }()
    
    class MockSessionProvider : CMPURLSessionProvider {
        
        let handler: (URLRequest) -> (String?, Error?)
        
        init(handler: @escaping (URLRequest) -> (String?, Error?)) {
            self.handler = handler
        }
        
        func dataRequest(urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) {
            DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(100)) {
                let (vendorListJSON, error) = self.handler(urlRequest)
                if let vendorListJSON = vendorListJSON {
                    let data = vendorListJSON.data(using: String.Encoding.utf8)!
                    let response = URLResponse(url: urlRequest.url!, mimeType: nil, expectedContentLength: data.count, textEncodingName: nil)
                    completionHandler(data, response, nil)
                } else {
                    completionHandler(nil, nil, error)
                }
            }
        }
        
    }
    
    class MockDelegate : CMPVendorListManagerDelegate {
        
        var successHandler: ((CMPVendorListManager, CMPVendorList) -> ())?
        var failureHandler: ((CMPVendorListManager, Error) -> ())?
        
        func vendorListManager(_ vendorListManager: CMPVendorListManager, didFetchVendorList vendorList: CMPVendorList) {
            successHandler?(vendorListManager, vendorList)
        }
        
        func vendorListManager(_ vendorListManager: CMPVendorListManager, didFailWithError error: Error) {
            failureHandler?(vendorListManager, error)
        }
        
    }
    
    func testVendorListCanBeRetrievedManually() {
        let mockSessionProvider = MockSessionProvider(handler: { urlRequest in
            XCTAssertEqual(urlRequest.url, URL(string: "https://vendorlist.consensu.org/vendorlist.json"))
            return (self.vendorListJSON, nil)
        })
        
        let urlSession = CMPURLSession(sessionProvider: mockSessionProvider)
        
        let mockDelegate = MockDelegate()
        
        let vendorListManager = CMPVendorListManager(
            url: CMPVendorListURL(),
            refreshInterval: 1.0,
            delegate: mockDelegate,
            pollInterval: 0.1,
            urlSession: urlSession
        )
        
        let successExpectation = expectation(description: "The call should be successful")
        
        mockDelegate.successHandler = { _, vendorList in
            XCTAssertEqual(vendorList.vendorListVersion, 6)
            XCTAssertEqual(vendorList.purposes.count, 5)
            XCTAssertEqual(vendorList.features.count, 3)
            XCTAssertEqual(vendorList.vendors.count, 17)

            successExpectation.fulfill()
        }
        mockDelegate.failureHandler = { _, _ in
            XCTFail("The call should not fail")
        }
        
        vendorListManager.refresh()
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testVendorListCanBeRetrievedManuallyForCustomVersionOnce() {
        let mockSessionProvider = MockSessionProvider(handler: { urlRequest in
            XCTAssertEqual(urlRequest.url, URL(string: "https://vendorlist.consensu.org/v-42/vendorlist.json"))
            return (self.vendorListJSON, nil)
        })
        
        let urlSession = CMPURLSession(sessionProvider: mockSessionProvider)
        
        let mockDelegate = MockDelegate()
        
        let vendorListManager = CMPVendorListManager(
            url: CMPVendorListURL(),
            refreshInterval: 1.0,
            delegate: mockDelegate,
            pollInterval: 0.1,
            urlSession: urlSession
        )
        
        let successExpectation = expectation(description: "The call should be successful")
        
        mockDelegate.successHandler = { _, vendorList in
            XCTAssertEqual(vendorList.vendorListVersion, 6)
            XCTAssertEqual(vendorList.purposes.count, 5)
            XCTAssertEqual(vendorList.features.count, 3)
            XCTAssertEqual(vendorList.vendors.count, 17)
            
            successExpectation.fulfill()
        }
        mockDelegate.failureHandler = { _, _ in
            XCTFail("The call should not fail")
        }
        
        // refresh() is called with a custom vendor list url, the url provided in the constructor will not be used
        vendorListManager.refresh(vendorListURL: CMPVendorListURL(version: 42))
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testVendorListRefreshCanFailWithUnparsableJSON() {
        let mockSessionProvider = MockSessionProvider(handler: { urlRequest in
            return ("not a valid JSON", nil)
        })
        
        let urlSession = CMPURLSession(sessionProvider: mockSessionProvider)
        
        let mockDelegate = MockDelegate()
        
        let vendorListManager = CMPVendorListManager(
            url: CMPVendorListURL(),
            refreshInterval: 1.0,
            delegate: mockDelegate,
            pollInterval: 0.1,
            urlSession: urlSession
        )
        
        let failureExpectation = expectation(description: "The call should fail")
        
        mockDelegate.successHandler = { _, _ in
            XCTFail("The call should fail")
        }
        mockDelegate.failureHandler = { _, error in
            if let error = error as? CMPVendorListManager.RefreshError {
                XCTAssertTrue(error == CMPVendorListManager.RefreshError.parsingError)
            } else {
                XCTFail("Not the expected error")
            }
            failureExpectation.fulfill()
        }
        
        vendorListManager.refresh()
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testVendorListRefreshCanFailWithNetworkError() {
        enum FakeNetworkError : Error {
            case timeout
        }
        
        let mockSessionProvider = MockSessionProvider(handler: { urlRequest in
            return (nil, FakeNetworkError.timeout)
        })
        
        let urlSession = CMPURLSession(sessionProvider: mockSessionProvider)
        
        let mockDelegate = MockDelegate()
        
        let vendorListManager = CMPVendorListManager(
            url: CMPVendorListURL(),
            refreshInterval: 1.0,
            delegate: mockDelegate,
            pollInterval: 0.1,
            urlSession: urlSession
        )
        
        let failureExpectation = expectation(description: "The call should fail")
        
        mockDelegate.successHandler = { _, _ in
            XCTFail("The call should fail")
        }
        mockDelegate.failureHandler = { _, error in
            if let error = error as? CMPVendorListManager.RefreshError {
                XCTAssertTrue(error == CMPVendorListManager.RefreshError.networkError)
            } else {
                XCTFail("Not the expected error")
            }
            failureExpectation.fulfill()
        }
        
        vendorListManager.refresh()
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testVendorListCanBeRefreshedAutomatically() {
        let mockSessionProvider = MockSessionProvider(handler: { urlRequest in
            return (self.vendorListJSON, nil)
        })
        
        let urlSession = CMPURLSession(sessionProvider: mockSessionProvider)
        
        let vendorListManager = CMPVendorListManager(
            url: CMPVendorListURL(),
            refreshInterval: 1.0,
            delegate: MockDelegate(),
            pollInterval: 0.1,
            urlSession: urlSession
        )
        
        // Initial call
        let refreshCalledImmediatelyExpectation = expectation(description: "Refresh is called automatically at start")
        vendorListManager.refreshHandler = { lastRefreshDate in
            refreshCalledImmediatelyExpectation.fulfill()
        }
        vendorListManager.startRefreshTimer()
        waitForExpectations(timeout: 0.5)
        
        // Auto refresh call
        let refreshCalledAfterIntervalExpectation = expectation(description: "Refresh is called automatically when the refresh interval is elapsed")
        vendorListManager.refreshHandler = { lastRefreshDate in
            refreshCalledAfterIntervalExpectation.fulfill()
        }
        waitForExpectations(timeout: 1.5)
        
        vendorListManager.refreshHandler = nil
    }
    
}
