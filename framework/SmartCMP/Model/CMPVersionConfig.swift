//
//  CMPVersionConfig.swift
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
 Configuration for a given version of the consent string.
 */
@objc
public class CMPVersionConfig: NSObject {
    
    /// The lastest version of the consent string.
    @objc
    public static let LATEST = CMPVersionConfig(version: 1)!
    
    /// The version of the consent string.
    @objc
    public let version: Int
    
    /// The number of bits used to encode the version field.
    static internal let versionBitSize: Int = 6
    
    /// The number of bits used to encode the created field.
    internal let createdBitSize: Int
    
    /// The number of bits used to encode the lastUpdated field.
    internal let lastUpdatedBitSize: Int
    
    /// The number of bits used to encode the cmpId field.
    internal let cmpIdBitSize: Int
    
    /// The number of bits used to encode the cmpVersion field.
    internal let cmpVersionBitSize: Int
    
    /// The number of bits used to encode the consentScreen field.
    internal let consentScreenBitSize: Int
    
    /// The number of bits used to encode the consentLanguage field.
    internal let consentLanguageBitSize: Int
    
    /// The number of bits used to encode the vendorListVersion field.
    internal let vendorListVersionBitSize: Int
    
    /// The number of bits used to encode the purposeAllowed field.
    internal let allowedPurposesBitSize: Int
    
    /// The number of bits used to encode the maxVendorId field.
    internal let maxVendorIdBitSize: Int
    
    /// The number of bits used to encode the encodingType field.
    internal let encodingTypeBitSize: Int
    
    /// The number of bits used to encode the defaultConsent field.
    internal let defaultConsentBitSize: Int
    
    /// The number of bits used to encode the numEntries field.
    internal let numEntriesBitSize: Int
    
    /// The number of bits used to encode the singleOrRange field.
    internal let singleOrRangeBitSize: Int
    
    /// The number of bits used to encode the singleVendorId field.
    internal let singleVendorIdBitSize: Int
    
    /// The number of bits used to encode the startVendorId field.
    internal let startVendorIdBitSize: Int
    
    /// The number of bits used to encode the endVendorId field.
    internal let endVendorIdBitSize: Int
    
    /// The bit representing a bitfield encoding.
    internal let encodingTypeBitfield: String
    
    /// The bit representing a range encoding.
    internal let encodingTypeRange: String
    
    /// The bit representing a single vendor id for a range encoding.
    internal let rangeSingleId: String
    
    /// The bit representing a start/end range vendor id for a range encoding.
    internal let rangeStartEndId: String
    
    /**
     Initialize a consent string version config instance from a version number.
     
     - Parameter version: The consent string version number.
     - Returns: A CMPVersionConfig instance if the version number is valid, nil otherwise.
     */
    init?(version: Int) {
        self.version = version
        
        switch version {
            
        case 1:
            
            self.createdBitSize = 36
            self.lastUpdatedBitSize = 36
            self.cmpIdBitSize = 12
            self.cmpVersionBitSize = 12
            self.consentScreenBitSize = 6
            self.consentLanguageBitSize = 12
            self.vendorListVersionBitSize = 12
            self.allowedPurposesBitSize = 24
            self.maxVendorIdBitSize = 16
            self.encodingTypeBitSize = 1
            self.defaultConsentBitSize = 1
            self.numEntriesBitSize = 12
            self.singleOrRangeBitSize = 1
            self.singleVendorIdBitSize = 16
            self.startVendorIdBitSize = 16
            self.endVendorIdBitSize = 16
            
            self.encodingTypeBitfield = "0"
            self.encodingTypeRange = "1"
            
            self.rangeSingleId = "0"
            self.rangeStartEndId = "1"
            
        default:
            return nil
            
        }
    }
    
}
