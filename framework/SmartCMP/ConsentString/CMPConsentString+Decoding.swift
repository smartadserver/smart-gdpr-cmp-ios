//
//  CMPConsentString+Decoding.swift
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
 CMPConsentString extension in charge of decoding an instance into a base64 consent string.
 */
internal extension CMPConsentString {
    
    /**
     Representation of a bits buffer.
     */
    private class BitsBuffer {
        
        /// The bits buffer.
        private var buffer: String
        
        /**
         Initialize a BitsBuffer using a string of bits.
         
         - Parameter bits: A string of bits.
         */
        init(bits: String) {
            self.buffer = bits
        }
        
        /**
         Return a chunk of bits from a given size and remove them from the buffer.
         
         - Parameter numberOfBits: The number of bits to pop.
         - Returns: The chunk of bits removed from the buffer.
         */
        func pop(numberOfBits: Int) -> String {
            let cutIndex = String.Index(encodedOffset: min(numberOfBits, buffer.count))
            let result = String(buffer[buffer.startIndex..<cutIndex])
            buffer = String(buffer[cutIndex..<buffer.endIndex])
            return result
        }
        
    }
    
    /**
     Decode a CMPConsentString from a string of bits.
     
     - Parameter bits: A valid string of bits.
     - Returns: A CMPConsentString instance if the string of bits can be decoded, nil otherwise.
     */
    internal static func decodeFromBits(bits: String) -> CMPConsentString? {
        guard isValid(bits: bits) else {
            return nil
        }
        
        let buffer = BitsBuffer(bits: bits)
        
        if let version = CMPBitUtils.bitsToInt(buffer.pop(numberOfBits: CMPVersionConfig.versionBitSize)),
            let versionConfig = CMPVersionConfig(version: version),
            let created = CMPBitUtils.bitsToDate(buffer.pop(numberOfBits: versionConfig.createdBitSize)),
            let lastUpdated = CMPBitUtils.bitsToDate(buffer.pop(numberOfBits: versionConfig.lastUpdatedBitSize)),
            let cmpId = CMPBitUtils.bitsToInt(buffer.pop(numberOfBits: versionConfig.cmpIdBitSize)),
            let cmpVersion = CMPBitUtils.bitsToInt(buffer.pop(numberOfBits: versionConfig.cmpVersionBitSize)),
            let consentScreen = CMPBitUtils.bitsToInt(buffer.pop(numberOfBits: versionConfig.consentScreenBitSize)),
            let consentLanguage = CMPBitUtils.bitsToLanguage(buffer.pop(numberOfBits: versionConfig.consentLanguageBitSize)),
            let vendorListVersion = CMPBitUtils.bitsToInt(buffer.pop(numberOfBits: versionConfig.vendorListVersionBitSize)) {
            
            let allowedPurposes = consentArray(bitfield: buffer.pop(numberOfBits: versionConfig.allowedPurposesBitSize))
            
            if let maxVendorId = CMPBitUtils.bitsToInt(buffer.pop(numberOfBits: versionConfig.maxVendorIdBitSize)) {
                
                var allowedVendors: IndexSet? = nil
                let encodingType = buffer.pop(numberOfBits: versionConfig.encodingTypeBitSize)
                
                switch encodingType {
                case versionConfig.encodingTypeBitfield:
                    allowedVendors = allowedVendorsFromBitfield(buffer: buffer, maxVendorId: maxVendorId)
                case versionConfig.encodingTypeRange:
                    allowedVendors = allowedVendorsFromRange(versionConfig: versionConfig, buffer: buffer, maxVendorId: maxVendorId)
                default:
                    return nil // invalid encoding
                }
                
                if let allowedVendors = allowedVendors {
                    return CMPConsentString(versionConfig: versionConfig,
                                            created: created,
                                            lastUpdated: lastUpdated,
                                            cmpId: cmpId,
                                            cmpVersion: cmpVersion,
                                            consentScreen: consentScreen,
                                            consentLanguage: consentLanguage,
                                            vendorListVersion: vendorListVersion,
                                            maxVendorId: maxVendorId,
                                            allowedPurposes: allowedPurposes,
                                            allowedVendors: allowedVendors)
                }
            }
        }
        
        return nil
    }
    
    /**
     Check if a bits string is valid.
     
     - Parameter bits: The bits string that needs to be checked.
     - Returns: true if the string is valid, false otherwise.
     */
    private static func isValid(bits: String) -> Bool {
        let invalidCharactersCount = bits.reduce(0) { String($1) == "0" || String($1) == "1" ? $0 : $0 + 1 }
        return bits.count > 1 && invalidCharactersCount == 0
    }
    
    /**
     Decode an allowed vendors array from a bitfield encoded buffer.
     
     - Parameters:
         - buffer: The BitsBuffer from where the bitfield will be retrieved.
         - maxVendorId: The maximum vendor id that can be found in the current vendor list.
     - Returns: An allowed vendors array if the buffer can be decoded, nil otherwise.
     */
    private static func allowedVendorsFromBitfield(buffer: BitsBuffer, maxVendorId: Int) -> IndexSet? {
        let vendorConsentBits = buffer.pop(numberOfBits: maxVendorId)
        guard vendorConsentBits.count == maxVendorId else {
            return nil
        }
        return consentArray(bitfield: vendorConsentBits)
    }
    
    /**
     Convert a valid bitfield into a consent array.
     
     - Parameter bitfield: A valid bitfield.
     - Returns: A consent array.
     */
    private static func consentArray(bitfield: String) -> IndexSet {
        return IndexSet(bitfield.enumerated().compactMap{ id, value in
            // ids are starting at 1 (not 0 as usual)
            value == "1" ? (id + 1) : nil
        })
    }
    
    /**
     Decode an allowed vendors array from a range encoded buffer.
     
     - Parameters:
         - versionConfig: The consent string version configuration.
         - buffer: The BitsBuffer from where the bitfield will be retrieved.
         - maxVendorId: The maximum vendor id that can be found in the current vendor list.
     - Returns:  An allowed vendors array if the buffer can be decoded, nil otherwise.
     */
    private static func allowedVendorsFromRange(versionConfig: CMPVersionConfig, buffer: BitsBuffer, maxVendorId: Int) -> IndexSet? {
        if let defaultValue = CMPBitUtils.bitsToBool(buffer.pop(numberOfBits: versionConfig.defaultConsentBitSize)),
            let numEntries = CMPBitUtils.bitsToInt(buffer.pop(numberOfBits: versionConfig.numEntriesBitSize)) {
            
            var vendors: [Int] = []
            
            // Converting every range into an array of vendor id
            for _ in (1...numEntries) {
                
                let singleOrRange = buffer.pop(numberOfBits: versionConfig.singleOrRangeBitSize)
                guard singleOrRange.count == 1 else {
                    return nil
                }
                
                switch singleOrRange {
                case versionConfig.rangeSingleId:
                    if let singleId = CMPBitUtils.bitsToInt(buffer.pop(numberOfBits: versionConfig.singleVendorIdBitSize)) {
                        vendors.append(singleId)
                    } else {
                        return nil
                    }
                case versionConfig.rangeStartEndId:
                    if let startId = CMPBitUtils.bitsToInt(buffer.pop(numberOfBits: versionConfig.startVendorIdBitSize)),
                        let endId = CMPBitUtils.bitsToInt(buffer.pop(numberOfBits: versionConfig.endVendorIdBitSize)) {
                        (startId...endId).forEach { vendors.append($0) }
                    } else {
                        return nil
                    }
                default:
                    return nil
                }
                
            }
            
            // Inverting the vendor id array if the consent is true by default
            if defaultValue == true {
                vendors = (1...maxVendorId).compactMap { id in vendors.contains(id) ? nil : id }
            }
            
            return IndexSet(vendors)
        }
        
        return nil
    }
    
}
