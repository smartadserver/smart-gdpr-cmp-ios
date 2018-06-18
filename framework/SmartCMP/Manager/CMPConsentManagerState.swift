//
//  CMPConsentManagerState.swift
//  SmartCMP
//
//  Created by Loïc GIRON DIT METAZ on 18/06/2018.
//  Copyright © 2018 Smart AdServer.
//
//  This software is distributed under the Creative Commons Legal Code, Attribution 3.0 Unported license.
//  Check the LICENSE file for more information.
//

import Foundation

/**
 Store the state of the consent manager in a persistent provider (by default, NSUserDefaults.standard).
 */
internal class CMPConsentManagerState {
    
    /**
     The default implementation of the CMPConsentManagerStateProvider protocol (based on NSUserDefaults.standard).
     */
    class DefaultStateProvider : CMPConsentManagerStateProvider {
        
        func saveString(string: String, key: String) {
            let userDefaults = UserDefaults.standard
            userDefaults.set(string, forKey: key)
            userDefaults.synchronize()
        }
        
        func readString(key: String) -> String? {
            let userDefaults = UserDefaults.standard
            let string = userDefaults.object(forKey: key) as? String
            return string
        }
        
    }
    
    /// The state provider.
    private let provider: CMPConsentManagerStateProvider
    
    /**
     Default initializer relying on the default state provider.
     */
    public init() {
        self.provider = DefaultStateProvider()
    }
    
    /**
     Initializer with a custom state provider.
     
     Note: this initializer should only be used for unit tests.
     
     - Parameter provider: The state provider that will be used.
     */
    internal init(provider: CMPConsentManagerStateProvider) {
        self.provider = provider
    }
    
    // MARK: - IAB state
    
    /**
     Save the GDPR status.
     
     - Parameter status: The status to be saved.
     */
    public func saveGDPRStatus(_ status: Bool) {
        let statusString = status ? "1" : "0"
        provider.saveString(string: statusString, key: CMPConstants.IABConsentKeys.SubjectToGDPR)
    }
    
    /**
     Save the consent string.
     
     - Parameter string: The consent string to be saved.
     */
    public func saveConsentString(_ string: String) {
        provider.saveString(string: string, key: CMPConstants.IABConsentKeys.ConsentString)
    }
    
    /**
     Return the current consent string.
     
     - Returns: The current consent string.
     */
    public func consentString() -> String? {
        return provider.readString(key: CMPConstants.IABConsentKeys.ConsentString)
    }
    
    /**
     Save the purposes consent string.
     
     - Parameter string: The purposes consent string to be saved.
     */
    public func savePurposeConsentString(_ string: String) {
        provider.saveString(string: string, key: CMPConstants.IABConsentKeys.ParsedPurposeConsent)
    }
    
    /**
     Save the advertising consent status.
     
     - Parameters consentString: The consent string from which the advertising consent status will be retrieved.
     */
    public func saveAdvertisingConsentStatus(forConsentString consentString: CMPConsentString) {
        let advertisingConsentStatusString = consentString.isPurposeAllowed(purposeId: CMPConstants.AdvertisingConsentStatus.PurposeId) ? "1" : "0"
        provider.saveString(string: advertisingConsentStatusString, key: CMPConstants.AdvertisingConsentStatus.Key)
    }
    
    /**
     Save the vendor consent string.
     
     - Parameter string: The vendors consent string to be saved.
     */
    public func saveVendorConsentString(_ string: String) {
        provider.saveString(string: string, key: CMPConstants.IABConsentKeys.ParsedVendorConsent)
    }
    
    // MARK: - Consent tool state
    
    // TODO
    
}
