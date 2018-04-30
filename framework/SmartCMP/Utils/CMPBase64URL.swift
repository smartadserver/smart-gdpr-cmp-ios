//
//  CMPBase64URL.swift
//  SmartCMP
//
//  Created by Loïc GIRON DIT METAZ on 24/04/2018.
//  Copyright © 2018 Smart AdServer.
//
//  This software is distributed under the Creative Commons Legal Code, Attribution 3.0 Unported license.
//  Check the LICENSE file for more information.
//

import Foundation

/**
 Util class to encode / decode base64url strings (without padding) & Data objects.
 */
internal class CMPBase64URL {
    
    private static let STRING_ENCODING = String.Encoding.utf8
    
    /**
     Create a base64url (without padding) from string.
     
     - Parameter string: The string that needs to be converted.
     - Returns: A base64url string without padding.
     */
    public static func base64URL(fromString string: String) -> String? {
        guard let data = string.data(using: STRING_ENCODING) else {
            return nil
        }
        return base64URL(fromData: data)
    }
    
    /**
     Decode a base64url string without padding.
     
     - Parameter base64URLString: The base64url string to be decoded.
     - Returns: The decoded string.
     */
    public static func string(fromBase64URL base64URLString: String) -> String? {
        guard let data = data(fromBase64URL: base64URLString) else {
            return nil;
        }
        
        return String(data: data, encoding: STRING_ENCODING)
    }
    
    /**
     Create a base64url (without padding) from a Data object.
     
     - Parameter string: The Data object that needs to be converted.
     - Returns: A base64url string without padding.
     */
    public static func base64URL(fromData data: Data) -> String {
        // Basic base64 conversion
        let base64String = data.base64EncodedString()
        
        // Conversion to a base64url string without padding
        return base64String
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
    
    /**
     Decode a base64url string without padding.
     
     - Parameter base64URLString: The base64url string to be decoded.
     - Returns: The decoded Data object.
     */
    public static func data(fromBase64URL base64URLString: String) -> Data? {
        // Conversion to a regular base64 string with padding
        let base64String = base64URLString
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        // Conversion into Data structure with padded base64 string
        return Data(base64Encoded: paddedBase64String(base64String))
    }
    
    /**
     Add the appropriate padding to a base64 string without padding.
     
     - Parameter string: A base64 string without padding.
     - Returns: A base64 string with padding.
     */
    private static func paddedBase64String(_ string: String) -> String {
        let padding = (4 - (string.count % 4)) % 4
        return string + String(repeating: "=", count: padding)
    }
    
    private init() {}
    
}
