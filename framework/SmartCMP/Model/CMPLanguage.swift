//
//  CMPLanguage.swift
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
 ISO 639-1 language representation for the CMPConsentString
 */
@objc
public class CMPLanguage: NSObject {
    
    /// The CMP default language ('en' / English).
    @objc
    public static let DEFAULT_LANGUAGE = CMPLanguage(string: "en")!
    
    /// The list of valid letters for the language string.
    @objc
    public static let VALID_LETTERS = (0..<26).map({ String(UnicodeScalar("a".unicodeScalars.first!.value + $0)! )})
    
    /// The valid length for the language string.
    @objc
    public static let VALID_LENGTH = 2
    
    /// The string representation of the CMPLanguage instance.
    @objc
    public let string: String
    
    /**
     Initialize a new instance of CMPLanguage from a string representation.
     
     - Parameter string: The string representation of the language (it must be ISO 639-1 compliant).
     - Returns: A CMPLanguage instance if the string is valid, nil otherwise.
     */
    @objc
    public init?(string: String) {
        
        // The language string must be ISO 639-1 compliant, aka:
        // - two characters long
        // - using only letters between A and Z (no special characters).
        
        let invalidCharactersCount = string.reduce(0) { (acc, character) in
            CMPLanguage.VALID_LETTERS.contains(String(character).lowercased()) ? acc : acc + 1
        }
        guard string.count == CMPLanguage.VALID_LENGTH && invalidCharactersCount == 0 else {
            return nil
        }
        
        self.string = string.lowercased()
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        if let object = object as? CMPLanguage {
            return self == object
        } else {
            return false
        }
    }
    
    public static func == (lhs: CMPLanguage, rhs: CMPLanguage) -> Bool {
        return lhs.string == rhs.string
    }
    
}
