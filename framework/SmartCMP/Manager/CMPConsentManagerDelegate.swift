//
//  CMPConsentManagerDelegate.swift
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
 Delegate of CMPVendorListManager.
 */
@objc
public protocol CMPConsentManagerDelegate : class {
    
    /**
     Called when the consent manager found a reason to display the Consent Tool UI. The publisher should display
     the consent tool has soon as possible.
     
     - Parameters:
        - consentManager: The consent manager instance.
        - vendorList: The vendor list you should ask consent for.
     */
    @objc
    func consentManagerRequestsToShowConsentTool(_ consentManager: CMPConsentManager, forVendorList vendorList: CMPVendorList)
    
}
