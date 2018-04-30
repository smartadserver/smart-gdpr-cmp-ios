//
//  String+Padding.swift
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
 String extension to handle padding and grouping.
 */
internal extension String {
    
    /**
     Split a string in an array of substring of a given length.
     
     - Parameter chunkSize: The size of each chunk of string (except for the last one if the string length isn't a multiple of chunkSize).
     - Returns: An array of strings.
     */
    func group(by chunkSize: Int) -> [String] {
        return stride(from: 0, to: self.count, by: chunkSize).map { value in
            let startIndex = String.Index(encodedOffset: value)
            let endIndex = String.Index(encodedOffset: min(value + chunkSize, self.count))
            return String(self[startIndex..<endIndex])
        }
    }
    
    /**
     Return a left padded version of the string.
     
     - Parameters:
     - count: The number of characters that must be added.
     - character: The character that will be used for padding (default is '0').
     - Precondition: character.count == 1
     - Returns: A left padded string.
     */
    func leftPadded(count: Int, character: String = "0") -> String {
        precondition(character.count == 1, "The 'character' must be exactly 1 character long")
        return String(repeating: character, count: count) + self
    }
    
    /**
     Return a right padded version of the string.
     
     - Parameters:
     - count: The number of characters that must be added.
     - character: The character that will be used for padding (default is '0').
     - Precondition: character.count == 1
     - Returns: A right padded string.
     */
    func rightPadded(count: Int, character: String = "0") -> String {
        precondition(character.count == 1, "The 'character' must be exactly 1 character long")
        return self + String(repeating: character, count: count)
    }
    
}
