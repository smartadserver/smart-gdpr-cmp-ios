//
//  CMPConsentToolManagerDelegate.swift
//  SmartCMP
//
//  Created by Thomas Geley on 26/04/2018.
//  Copyright © 2018 Smart AdServer.
//
//  This software is distributed under the Creative Commons Legal Code, Attribution 3.0 Unported license.
//  Check the LICENSE file for more information.
//

import Foundation

/**
 Delegate of CMPConsentToolManager.
 */
internal protocol CMPConsentToolManagerDelegate: class {
    
    /**
     Method called when the consent tool manager is closed with a new consent string.
     
     - Parameters:
        - consentToolManager: The consent tool manager that has retrieved a consent string.
        - contentString: The consent string retrieved.
     */
    func consentToolManager(_ consentToolManager: CMPConsentToolManager, didFinishWithConsentString contentString: CMPConsentString)
    
}
