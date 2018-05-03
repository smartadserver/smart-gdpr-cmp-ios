//
//  CMPVendorList+JSONKeys.swift
//  SmartCMP
//
//  Created by Loïc GIRON DIT METAZ on 24/04/2018.
//  Copyright © 2018 Smart AdServer.
//
//  This software is distributed under the Creative Commons Legal Code, Attribution 3.0 Unported license.
//  Check the LICENSE file for more information.
//

import Foundation

/*
 CMPVendorList extension used to store all JSON keys.
 */
internal extension CMPVendorList {
    
    /**
     Class storing all JSON keys used to parse the vendors list.
     */
    class JsonKey {
        
        static let VENDOR_LIST_VERSION = "vendorListVersion"
        static let LAST_UPDATED = "lastUpdated"
        
        class Purposes {
            static let PURPOSES = "purposes"
            static let ID = "id"
            static let NAME = "name"
            static let DESCRIPTION = "description"
        }
        
        class Features {
            static let FEATURES = "features"
            static let ID = "id"
            static let NAME = "name"
            static let DESCRIPTION = "description"
        }
        
        class Vendors {
            static let VENDORS = "vendors"
            static let ID = "id"
            static let NAME = "name"
            static let PURPOSE_IDS = "purposeIds"
            static let LEGITIMATE_PURPOSE_IDS = "legIntPurposeIds"
            static let FEATURE_IDS = "featureIds"
            static let POLICY_URL = "policyUrl"
            static let DELETED_DATE = "deletedDate"
        }
        
    }
    
}
