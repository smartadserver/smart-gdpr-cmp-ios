//
//  CMPURLSessionTests.swift
//  SmartCMPTests
//
//  Created by Loïc GIRON DIT METAZ on 25/04/2018.
//  Copyright © 2018 Smart AdServer.
//
//  This software is distributed under the Creative Commons Legal Code, Attribution 3.0 Unported license.
//  Check the LICENSE file for more information.
//

import XCTest
@testable import SmartCMP

class CMPURLSessionTests : XCTestCase {
    
    class MockError: Error {
        
        let description: String
        
        init(description: String) {
            self.description = description
        }
        
    }
    
    class MockSessionProvider : CMPURLSessionProvider {
        
        let handler: (URLRequest) -> (Data?, URLResponse?, Error?)
        
        init(handler: @escaping (URLRequest) -> (Data?, URLResponse?, Error?)) {
            self.handler = handler
        }
        
        func dataRequest(urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) {
            DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(100)) {
                let (data, response, error) = self.handler(urlRequest)
                completionHandler(data, response, error)
            }
        }
        
    }
    
    func testURLSessionDelegatesTheNetworkRequestToTheProvider() {
        
        let sessionProviderCalled = expectation(description: "The session provider is called")
        
        let aRequest = URLRequest(url: URL(string: "https://someurl.com")!)
        
        let sessionProvider = MockSessionProvider() { urlRequest in
            sessionProviderCalled.fulfill()
            XCTAssertEqual(aRequest, urlRequest)
            return (
                Data(base64Encoded: "DATA"),
                URLResponse(url: URL(string: "https://someurl.com")!, mimeType: nil, expectedContentLength: 42, textEncodingName: nil),
                MockError(description: "ERROR")
            )
        }
        
        let urlSession = CMPURLSession(sessionProvider: sessionProvider)
        
        urlSession.dataRequest(urlRequest: aRequest) { (data, response, error) in
            XCTAssertEqual(data, Data(base64Encoded: "DATA"))
            XCTAssertEqual(response?.url, URL(string: "https://someurl.com")!)
            XCTAssertEqual((error as? MockError)?.description, "ERROR")
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testURLSessionCanConstructURLRequests() {
        
        let sessionProviderCalled = expectation(description: "The session provider is called")
        
        let sessionProvider = MockSessionProvider() { urlRequest in
            sessionProviderCalled.fulfill()
            
            let expectedRequest = URLRequest(url: URL(string: "https://someurl.com")!, cachePolicy: CMPURLSession.DEFAULT_CACHE_POLICY, timeoutInterval: CMPURLSession.DEFAULT_TIMEOUT_INTERVAL)
            
            XCTAssertEqual(urlRequest, expectedRequest)
            
            return (nil, nil, nil)
        }
        
        let urlSession = CMPURLSession(sessionProvider: sessionProvider)
        
        urlSession.dataRequest(url: URL(string: "https://someurl.com")!) { data, response, error in
            // Nothing to check here
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
}
