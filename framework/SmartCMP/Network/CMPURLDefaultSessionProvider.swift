//
//  CMPURLDefaultSessionProvider.swift
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
 Default implementation of CMPURLSessionProvider, used by the shared instance of CMPURLSession.
 */
internal class CMPURLDefaultSessionProvider : CMPURLSessionProvider {
    
    /// A shared instance of CMPURLDefaultSessionProvider (using the shared instance of URLSession).
    static let shared = CMPURLDefaultSessionProvider(session: URLSession.shared)
    
    /// The URL session used by this provider.
    private let session: URLSession
    
    /**
     Initialize a new instance of CMPURLDefaultSessionProvider.
     
     - Parameter session: The URL session used by this provider.
     */
    private init(session: URLSession) {
        self.session = session
    }
    
    /**
     Execute a network request.
     
     - Parameters:
        - urlRequest: The URL request to execute.
        - completionHandler: The completion handler that will be called when the request is finished (successfully or not).
     */
    func dataRequest(urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        session.dataTask(with: urlRequest, completionHandler: completionHandler).resume()
    }
    
}
