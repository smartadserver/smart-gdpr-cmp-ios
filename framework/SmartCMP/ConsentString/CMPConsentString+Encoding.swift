//
//  CMPConsentString+Encoding.swift
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
 CMPConsentString extension in charge of encoding an instance into a base64 consent string.
 */
internal extension CMPConsentString {
    
    /**
     Return a base64 consent string corresponding to the CMPConsentString instance.
     
     - Parameters:
         - versionConfig: The consent string version configuration.
         - created: The date of the first consent string creation.
         - lastUpdated: The date of the last consent string update.
         - cmpId: The id of the last Consent Manager Provider that updated the consent string.
         - cmpVersion: The version of the Consent Manager Provider.
         - consentScreen: The screen number in the CMP where the consent was given.
         - consentLanguage: The language that the CMP asked for consent in (in two-letters ISO 639-1 format).
         - vendorListVersion: The version of the vendor list used in the most recent consent string update.
         - maxVendorId: The maximum vendor id that can be found in the current vendor list.
         - allowedPurposes: An array of allowed purposes id.
         - allowedVendors: An array of allowed vendors id.
         - vendorListEncoding: The type of vendors encoding that should be used to generate the base64 consent string.
     - Returns: A base64 consent string corresponding to the CMPConsentString instance.
     */
    internal static func encodeToBits(versionConfig: CMPVersionConfig,
                                      created: Date,
                                      lastUpdated: Date,
                                      cmpId: Int,
                                      cmpVersion: Int,
                                      consentScreen: Int,
                                      consentLanguage: CMPLanguage,
                                      vendorListVersion: Int,
                                      maxVendorId: Int,
                                      allowedPurposes: IndexSet,
                                      allowedVendors: IndexSet,
                                      vendorListEncoding: ConsentEncoding) -> String {
        var bits = ""
        
        bits += CMPBitUtils.intToBits(versionConfig.version, numberOfBits: CMPVersionConfig.versionBitSize)
        bits += CMPBitUtils.dateToBits(created, numberOfBits: versionConfig.createdBitSize)
        bits += CMPBitUtils.dateToBits(lastUpdated, numberOfBits: versionConfig.lastUpdatedBitSize)
        bits += CMPBitUtils.intToBits(cmpId, numberOfBits: versionConfig.cmpIdBitSize)
        bits += CMPBitUtils.intToBits(cmpVersion, numberOfBits: versionConfig.cmpVersionBitSize)
        bits += CMPBitUtils.intToBits(consentScreen, numberOfBits: versionConfig.consentScreenBitSize)
        bits += CMPBitUtils.languageToBits(consentLanguage, numberOfBits: versionConfig.consentLanguageBitSize)
        bits += CMPBitUtils.intToBits(vendorListVersion, numberOfBits: versionConfig.vendorListVersionBitSize)
        bits += purposesBitfield(versionConfig: versionConfig, allowedPurposes: allowedPurposes)
        
        switch vendorListEncoding {
        case .bitfield:
            bits += vendorListBitfield(versionConfig: versionConfig, maxVendorId: maxVendorId, allowedVendors: allowedVendors)
        case .range:
            bits += vendorListRange(versionConfig: versionConfig, maxVendorId: maxVendorId, allowedVendors: allowedVendors, defaultValue: false)
        case .automatic:
            let bitfield = vendorListBitfield(versionConfig: versionConfig, maxVendorId: maxVendorId, allowedVendors: allowedVendors)
            let range = vendorListRange(versionConfig: versionConfig, maxVendorId: maxVendorId, allowedVendors: allowedVendors, defaultValue: false)
            bits += bitfield.count < range.count ? bitfield : range // Automatic select the most efficient encoding
        }
        
        return bits
    }
    
    /**
     Return a bitfield string that encodes an 'allowed purposes' array.
     
     - Parameters:
         - versionConfig: The consent string version configuration.
         - allowedPurposes: An array of allowed purposes id.
     - Returns: A bitfield string that encodes an 'allowed purposes' array.
     */
    private static func purposesBitfield(versionConfig: CMPVersionConfig, allowedPurposes: IndexSet) -> String {
        return (1...versionConfig.allowedPurposesBitSize).map { allowedPurposes.contains($0) ? "1" : "0" }.joined()
    }
    
    /**
     Return a bitfield string that encodes an 'allowed vendors' array.
     
     - Parameters:
         - versionConfig: The consent string version configuration.
         - maxVendorId: The maximum vendor id that can be found in the current vendor list.
         - allowedVendors: An array of allowed vendors id.
     - Returns: A bitfield string that encodes an 'allowed vendors' array.
     */
    private static func vendorListBitfield(versionConfig: CMPVersionConfig, maxVendorId: Int, allowedVendors: IndexSet) -> String {
        var bits = ""
        
        bits += CMPBitUtils.intToBits(maxVendorId, numberOfBits: versionConfig.maxVendorIdBitSize)
        bits += versionConfig.encodingTypeBitfield
        bits += (1...maxVendorId).map { allowedVendors.contains($0) ? "1" : "0" }.joined()
        
        return bits
    }
    
    /**
     Return a complete range string that encodes an 'allowed vendors' array.
     
     - Parameters:
         - versionConfig: The consent string version configuration.
         - maxVendorId: The maximum vendor id that can be found in the current vendor list.
         - allowedVendors: An array of allowed vendors id.
         - defaultValue: The default consent value.
     - Returns: A range string that encodes an 'allowed vendors' array.
     */
    private static func vendorListRange(versionConfig: CMPVersionConfig, maxVendorId: Int, allowedVendors: IndexSet, defaultValue: Bool) -> String {
        var bits = ""
        
        bits += CMPBitUtils.intToBits(maxVendorId, numberOfBits: versionConfig.maxVendorIdBitSize)
        bits += versionConfig.encodingTypeRange
        bits += CMPBitUtils.boolToBits(defaultValue, numberOfBits: versionConfig.defaultConsentBitSize)
        bits += CMPConsentString.rangesBits(versionConfig: versionConfig, maxVendorId: maxVendorId, allowedVendors: allowedVendors, defaultValue: defaultValue)
        
        return bits
    }
    
    /**
     Returns the range part of a complete range string that encodes an 'allowed vendors' array.
     
     - Parameters:
         - versionConfig: The consent string version configuration.
         - maxVendorId: The maximum vendor id that can be found in the current vendor list.
         - allowedVendors: An array of allowed vendors id.
         - defaultValue: The default consent value.
     - Returns: The range part of a complete range string that encodes an 'allowed vendors' array.
     */
    private static func rangesBits(versionConfig: CMPVersionConfig, maxVendorId: Int, allowedVendors: IndexSet, defaultValue: Bool) -> String {
        var bits = ""
        
        let ranges = CMPConsentString.ranges(maxVendorId: maxVendorId, allowedVendors: allowedVendors, defaultValue: defaultValue)
        bits += CMPBitUtils.intToBits(ranges.count, numberOfBits: versionConfig.numEntriesBitSize)
        for range in ranges {
            let rangeLength = range.count
            if rangeLength > 1 {
                bits += versionConfig.rangeStartEndId
                bits += CMPBitUtils.intToBits(range.lowerBound, numberOfBits: versionConfig.startVendorIdBitSize)
                bits += CMPBitUtils.intToBits(range.upperBound, numberOfBits: versionConfig.endVendorIdBitSize)
            } else {
                bits += versionConfig.rangeSingleId
                bits += CMPBitUtils.intToBits(range.lowerBound, numberOfBits: versionConfig.singleVendorIdBitSize)
            }
        }
        
        return bits
    }
    
    /**
     Returns a ranges array corresponding to an allowed vendors array, for a given default value.
     
     - Parameters:
         - maxVendorId: The maximum vendor id that can be found in the current vendor list.
         - allowedVendors: An array of allowed vendors id.
         - defaultValue: The default consent value.
     - Returns: A ranges array corresponding to an allowed vendors array, for a given default value.
     */
    private static func ranges(maxVendorId: Int, allowedVendors: IndexSet, defaultValue: Bool) -> [ClosedRange<Int>] {
        let allowedArray = (1...maxVendorId).map { allowedVendors.contains($0) }
        
        var currentId = 1
        var startId: Int? = nil
        var ranges = [ClosedRange<Int>]()
        
        for allowed in allowedArray {
            // Finding start & end bounds of each range
            if startId == nil && allowed != defaultValue {
                startId = currentId
            } else if startId != nil && allowed == defaultValue {
                ranges.append(startId!...(currentId - 1))
                startId = nil
            }
            
            currentId += 1
        }
        if startId != nil {
            // Closing the last range if needed
            ranges.append(startId!...(currentId - 1))
        }
        
        return ranges
    }
    
}
