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
 Delegate of CMPConsentManager.
 */
@objc
public protocol CMPConsentManagerDelegate : class {
    
    /**
     Called when the consent manager found a reason to display the Consent Tool UI. The publisher should display
     the consent tool as soon as possible.
     
     - Parameter consentManager: The consent manager instance.
     */
    @objc
    func consentManagerRequestsToShowConsentTool(_ consentManager: CMPConsentManager)
    
}
