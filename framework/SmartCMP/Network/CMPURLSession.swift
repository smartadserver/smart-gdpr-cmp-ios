//
//  CMPURLSession.swift
//  SmartCMP
//
//  Created by Loïc GIRON DIT METAZ on 25/04/2018.
//  Copyright © 2018 Smart AdServer.
//
//  This software is distributed under the Creative Commons Legal Code, Attribution 3.0 Unported license.
//  Check the LICENSE file for more information.
//

import Foundation

/**
 Minimalist URLSession wrapper for easier unit tests.
 */
internal class CMPURLSession {
    
    /// A CMPURLSession shared instance using the default session provider.
    static let shared = CMPURLSession(sessionProvider: CMPURLDefaultSessionProvider.shared)
    
    /// Default cache policy for network request created by the CMPURLSession instance.
    internal static let DEFAULT_CACHE_POLICY = URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
    
    /// Default timeout interval for network request created by the CMPURLSession instance.
    internal static let DEFAULT_TIMEOUT_INTERVAL = 30.0
    
    /// A session provider instance used to execute actual network requests.
    private let sessionProvider: CMPURLSessionProvider
    
    /**
     Initialize a CMPURLSession with a custom CMPURLSessionProvider implementation.
     
     Note: Only the shared instance of CMPURLSession should be used in production code. Initializing other
     instances should only be done in unit tests.
     
     - Parameter sessionProvider: A session provider instance used to execute actual network requests.
     */
    internal init(sessionProvider: CMPURLSessionProvider) {
        self.sessionProvider = sessionProvider
    }
    
    /**
     Execute a network request.
     
     - Parameters:
        - urlRequest: The URL request to execute.
        - completionHandler: The completion handler that will be called when the request is finished (successfully or not).
     */
    func dataRequest(urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.sessionProvider.dataRequest(urlRequest: urlRequest, completionHandler: completionHandler)
    }
    
    /**
     Execute a network request.
     
     - Parameters:
        - url: The URL that must be retrieved (an URLRequest will be built using default timeout & cache policy).
        - completionHandler: The completion handler that will be called when the request is finished (successfully or not).
     */
    func dataRequest(url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let urlRequest = URLRequest(url: url, cachePolicy: CMPURLSession.DEFAULT_CACHE_POLICY, timeoutInterval: CMPURLSession.DEFAULT_TIMEOUT_INTERVAL)
        self.sessionProvider.dataRequest(urlRequest: urlRequest, completionHandler: completionHandler)
    }
    
}
