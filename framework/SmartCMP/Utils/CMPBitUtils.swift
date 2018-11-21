//
//  CMPBitUtils.swift
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
 Util class to manipulate string of bits.
 */
internal class CMPBitUtils {
    
    private static let LANGUAGE_LETTER_BIT_ENCODING_LENGTH = 6
    
    /**
     Encode an integer into a bit string.
     
     - Parameters:
        - number: The integer that needs to be encoded.
        - numberOfBits: The minimum length of the returned string.
     - Precondition: number must be a positive number (or equals to 0).
     - Precondition: numberOfBits must be a positive number (or equals to 0).
     - Returns: A string encoded integer.
     */
    public static func intToBits(_ number: Int, numberOfBits: Int) -> String {
        return int64ToBits(Int64(number), numberOfBits: numberOfBits)
    }
    
    /**
     Decode an int from a bit string.
     
     - Parameter bits: The bit string that must be decoded.
     - Returns: An integer if bits are valid, nil otherwise.
     */
    public static func bitsToInt(_ bits: String) -> Int? {
        return Int(bits, radix: 2)
    }
    
    /**
     Encode a 64 bits integer into a bit string.
     
     This method should be used only for numbers that could overflow a 32 bits integer
     on older iOS devices, like deciseconds encoding.
     
     - Parameters:
         - number: The integer that needs to be encoded.
         - numberOfBits: The minimum length of the returned string.
     - Precondition: number must be a positive number (or equals to 0).
     - Precondition: numberOfBits must be a positive number (or equals to 0).
     - Returns: A string encoded integer.
     */
    public static func int64ToBits(_ number: Int64, numberOfBits: Int) -> String {
        precondition(number >= 0, "'number' must be positive")
        precondition(numberOfBits >= 0, "'numberOfBits' must be positive")
        
        let bits = String(number, radix: 2)
        let padding = numberOfBits - bits.count
        return padding > 0 ? bits.leftPadded(count: padding) : bits
    }
    
    /**
     Decode an 64 bits int from a bit string.
     
     This method should be used only for numbers that could overflow a 32 bits integer
     on older iOS devices, like deciseconds decoding.
     
     - Parameter bits: The bit string that must be decoded.
     - Returns: An integer if bits are valid, nil otherwise.
     */
    public static func bitsToInt64(_ bits: String) -> Int64? {
        return Int64(bits, radix: 2)
    }
    
    /**
     Encode a boolean into a bit string.
     
     - Parameters:
        - boolean: The boolean that needs to be encoded.
        - numberOfBits: The minimum length of the returned string.
     - Precondition: numberOfBits must be a positive number (or equals to 0).
     - Returns: A string encoded boolean.
     */
    public static func boolToBits(_ boolean: Bool, numberOfBits: Int) -> String {
        precondition(numberOfBits >= 0, "'numberOfBits' must be positive")
        
        let bits = boolean ? "1" : "0"
        let padding = numberOfBits - bits.count
        return padding > 0 ? bits.leftPadded(count: padding) : bits
    }
    
    /**
     Decode a boolean from a bit string.
     
     - Parameter bits: The bit string that must be decoded.
     - Returns: A boolean if bits are valid, nil otherwise.
     */
    public static func bitsToBool(_ bits: String) -> Bool? {
        switch bits {
        case "1":
            return true
        case "0":
            return false
        default:
            return nil
        }
    }
    
    /**
     Encode a date into a bit string.
     
     - Parameters:
        - date: The boolean that needs to be encoded.
        - numberOfBits: The minimum length of the returned string.
     - Precondition: numberOfBits must be a positive number (or equals to 0).
     - Returns: A string encoded date.
     */
    public static func dateToBits(_ date: Date, numberOfBits: Int) -> String {
        precondition(numberOfBits >= 0, "'numberOfBits' must be positive")
        
        let deciseconds = date.timeIntervalSince1970 * 10
        return int64ToBits(Int64(deciseconds.rounded()), numberOfBits: numberOfBits)
    }
    
    /**
     Decode a date from a bit string.
     
     - Parameter bits: The bit string that must be decoded.
     - Returns: A date if bits are valid, nil otherwise.
     */
    public static func bitsToDate(_ bits: String) -> Date? {
        if let deciseconds = bitsToInt64(bits) {
            return Date(timeIntervalSince1970: Double(deciseconds) / 10.0)
        } else {
            return nil
        }
    }
    
    /**
     Encode a letter into a bit string.
     
     - Parameters:
        - letter: The letter that needs to be encoded.
        - numberOfBits: The minimum length of the returned string.
     - Precondition: letter must be an unique and valid letter ([a-z] or [A-Z]).
     - Precondition: numberOfBits must be a positive number (or equals to 0).
     - Returns: A string encoded letter.
     */
    public static func letterToBits(_ letter: String, numberOfBits: Int) -> String {
        precondition(CMPLanguage.VALID_LETTERS.contains(letter.lowercased()), "The 'letter' parameter must be an unique letter")
        precondition(numberOfBits >= 0, "'numberOfBits' must be positive")
        
        return intToBits(CMPLanguage.VALID_LETTERS.index(of: letter.lowercased())!, numberOfBits: numberOfBits)
    }
    
    /**
     Decode a letter from a bit string.
     
     - Parameter bits: The bit string that must be decoded.
     - Returns: A letter if bits are valid, nil otherwise.
     */
    public static func bitsToLetter(_ bits: String) -> String? {
        if let letterIndex = bitsToInt(bits) {
            // Checking if the index correspond to a valid letter
            return letterIndex < CMPLanguage.VALID_LETTERS.count ? CMPLanguage.VALID_LETTERS[letterIndex] : nil
        } else {
            return nil
        }
    }
    
    /**
     Encode a language string into a bit string.
     
     - Parameters:
        - language: The language that needs to be encoded.
        - numberOfBits: The minimum length of the returned string.
     - Precondition: numberOfBits must be a positive number (or equals to 0).
     - Returns: A string encoded language.
     */
    public static func languageToBits(_ language: CMPLanguage, numberOfBits: Int) -> String {
        precondition(numberOfBits >= 0, "'numberOfBits' must be positive")
        
        var bits = ""
        for character in language.string.lowercased() {
            bits += letterToBits(String(character), numberOfBits: LANGUAGE_LETTER_BIT_ENCODING_LENGTH)
        }
        
        let padding = numberOfBits - bits.count
        return padding > 0 ? bits.leftPadded(count: padding) : bits
    }
    
    /**
     Decode a language string from a bit string.
     
     - Parameter bits: The bit string that must be decoded.
     - Returns: A language if bits are valid, nil otherwise.
     */
    public static func bitsToLanguage(_ bits: String) -> CMPLanguage? {
        var language = ""
        for letterBitsIndex in bits.group(by: LANGUAGE_LETTER_BIT_ENCODING_LENGTH) {
            if let letter = bitsToLetter(letterBitsIndex) {
                language += letter
            } else {
                return nil
            }
        }
        return CMPLanguage(string: language)
    }
    
    private init() {}
    
}
