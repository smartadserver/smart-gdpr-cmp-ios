//
//  CMPConstants.swift
//  SmartCMP
//
//  Created by Thomas Geley on 25/04/2018.
//  Copyright © 2018 Smart AdServer.
//
//  This software is distributed under the Creative Commons Legal Code, Attribution 3.0 Unported license.
//  Check the LICENSE file for more information.
//

import Foundation

/**
 General constants for SmartCMP
 */
internal struct CMPConstants {
    
    /// Generic information on the CMP framework
    struct CMPInfos {
        static let VERSION = 1
        static let ID = 33  // '33' IS THE OFFICIAL CMP ID FOR SmartCMP.
                            // You can use this ID as long as you don't change the source code of this project.
                            // If you don't use it exactly as distributed in the official Smart AdServer repository,
                            // you must get your own CMP ID by registering here: https://register.consensu.org/CMP
    }
    
    /// IAB Keys for NSUserDefault storage
    struct IABConsentKeys {
        static let CMPPresent                       = "IABConsent_CMPPresent"
        static let SubjectToGDPR                    = "IABConsent_SubjectToGDPR"
        static let ConsentString                    = "IABConsent_ConsentString"
        static let ParsedPurposeConsent             = "IABConsent_ParsedPurposeConsent"
        static let ParsedVendorConsent              = "IABConsent_ParsedVendorConsent"        
    }
 
    /// Vendor list configuration
    struct VendorList {
        static let DefaultEndPoint                  = "https://vendorlist.consensu.org/vendorlist.json"
        static let VersionedEndPoint                = "https://vendorlist.consensu.org/v-{version}/vendorlist.json"
        
        static let DefaultLocalizedEndPoint         = "https://vendorlist.consensu.org/purposes-{language}.json"
        static let VersionedLocalizedEndPoint       = "https://vendorlist.consensu.org/purposes-{language}-{version}.json"
    }
    
}
