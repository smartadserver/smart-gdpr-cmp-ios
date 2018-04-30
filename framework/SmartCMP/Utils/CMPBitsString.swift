//
//  CMPBitsString.swift
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
 Consent string expressed as a base64url string or a bit array string.
 */
internal class CMPBitsString {
    
    /// The base64url representation of the string.
    let stringValue: String
    
    /// The bits representation of the string.
    let bitsValue: String
    
    /**
     Initialize a CMPBitsString from a base64url string.
     
     - Parameter bitsString: A valid base64url string.
     */
    init?(string: String) {
        self.stringValue = string
        
        guard let data = CMPBase64URL.data(fromBase64URL: stringValue) else {
            return nil
        }
        
        self.bitsValue = [UInt8](data).map { byte -> String in
            let bits = String(byte, radix: 2)
            return bits.leftPadded(count: 8 - bits.count)
        }.joined()
    }
    
    /**
     Initialize a CMPBitsString from a string of bits.
     
     - Parameter bitsString: A valid string of bits (that will be right padded if not a multiple of 8).
     */
    init?(bitsString: String) {
        self.bitsValue = bitsString
        
        guard CMPBitsString.isValidBitsString(bitsString) else {
            return nil
        }
        
        // The string is right padded so it always corresponds to complete bytes
        let paddingCount = 7 - ((bitsString.count + 7) % 8)
        let paddedBitsString = bitsString.rightPadded(count: paddingCount)
        
        // Bits conversion into base64url
        let bytes = paddedBitsString.group(by: 8).map { UInt8($0, radix: 2)! }
        self.stringValue = CMPBase64URL.base64URL(fromData: Data(bytes))
    }
    
    /**
     Validate if a bits string is valid: ie if it's only containing '0' and '1' digits.
     
     - Parameter string: The string to be validated.
     - Returns: true if the string is valid, false otherwise.
     */
    private static func isValidBitsString(_ string: String) -> Bool {
        return Array(string).reduce(true) { result, character in
            result && (character == "0" || character == "1")
        }
    }
    
}
