//
//  CMPURLSessionProvider.swift
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
 Protocol that must be implemented by objects executing network requests.
 */
internal protocol CMPURLSessionProvider {
    
    /**
     Execute a network request.
     
     - Parameters:
        - urlRequest: The URL request to execute.
        - completionHandler: The completion handler that will be called when the request is finished (successfully or not).
     */
    func dataRequest(urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> ())
    
}
