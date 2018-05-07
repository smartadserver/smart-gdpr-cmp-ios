//
//  CMPConsentManager.swift
//  SmartCMP
//
//  Created by Thomas Geley on 24/04/2018.
//  Copyright © 2018 Smart AdServer.
//
//  This software is distributed under the Creative Commons Legal Code, Attribution 3.0 Unported license.
//  Check the LICENSE file for more information.
//

import UIKit
import AdSupport

/**
 A class to manage the CMP.
 */
@objc
public class CMPConsentManager : NSObject, CMPVendorListManagerDelegate, CMPConsentToolManagerDelegate {

    // MARK: - Global singleton
    
    /// Returns the shared CMPConsentManager object.
    @objc(sharedInstance)
    public static let shared = CMPConsentManager()
    
    // MARK: - Public fields
    
    /// CMPConsentManager delegate.
    @objc
    public weak var delegate: CMPConsentManagerDelegate?
    
    /// Must be set as soon as the publisher knows whether or not the user is subject to GDPR law, for example after looking up the user's location, or if the publisher himself is subject to this regulation.
    @objc
    public var subjectToGDPR: Bool = false { didSet { gdrpStatusChanged() } }
    
    /// The consent string.
    @objc
    public var consentString: CMPConsentString? { didSet { consentStringChanged() } }
    
    // MARK: - Private fields
    
    /// Whether or not the CMPConsentManager has been configured by the publisher.
    private var configured: Bool = false
    
    /// The current device language in a format usable by the CMP.
    private var language: CMPLanguage = CMPLanguage.DEFAULT_LANGUAGE
    
    /// Instance of CMPVendorListManager that is responsible for fetching, parsing and creating a model of CMPVendorList.
    private var vendorListManager: CMPVendorListManager?
    
    /// Last vendor list parsed
    private var lastVendorList: CMPVendorList?
    
    /// Whether or not the consent tool should show if user's limited ad tracking from his device's settings.
    /// If false and LAT is On, no consent will be given for any purpose or vendors.
    private var showConsentToolIfLAT: Bool = true
    
    /// Consent tool configuration instance.
    private var consentToolConfiguration: CMPConsentToolConfiguration?
    
    /// Consent tool manager instance.
    private var consentToolManager: CMPConsentToolManager?
    
    /// Whether or not the consent tool is presented.
    private var consentToolIsShown: Bool = false
    
    // MARK: - Constants
    
    /// The default refresh interval for the vendor list.
    @objc
    public static let DEFAULT_VENDORLIST_REFRESH_TIME = 86400.0
    
    /// The behavior if LAT (Limited Ad Tracking) is enabled.
    @objc
    public static let DEFAULT_LAT_VALUE = true
    
    // MARK: - Public methods
    
    /**
     Configure the CMPConsentManager. This method must be called only once per session.
     
     - Parameters:
        - language: an instance of CMPLanguage reflecting the device's current language.
        - consentToolConfiguration: an instance of CMPConsentToolConfiguration to configure of the consent tool UI.
     */
    @objc
    public func configureWithLanguage(_ language: CMPLanguage,
                                      consentToolConfiguration: CMPConsentToolConfiguration) {
        self.configure(
            refreshInterval: CMPConsentManager.DEFAULT_VENDORLIST_REFRESH_TIME,
            language: language,
            consentToolConfiguration: consentToolConfiguration,
            showConsentToolIfUserLimitedAdTracking: CMPConsentManager.DEFAULT_LAT_VALUE
        )
    }
    
    /**
     Configure the CMPConsentManager. This method must be called only once per session.
     
     - Parameters:
        - vendorListURL: The URL from where to fetch the vendor list (vendors.json). If you enter your own URL, your custom list MUST BE compatible with IAB specifications and respect vendorId and purposeId distributed by the IAB.
        - refreshInterval: The interval in seconds to refresh the vendor list.
        - language: an instance of CMPLanguage reflecting the device's current language.
        - consentToolConfiguration: an instance of CMPConsentToolConfiguration to configure of the consent tool UI.
        - showConsentToolIfUserLimitedAdTracking: Whether or not the consent tool UI should be shown if user's checked Limit Ad Tracking in his device's preferences. If false, UI will never be shown if user checked LAT and consent string will be formatted has "user does not give consent".
     */
    @objc
    public func configure(refreshInterval: TimeInterval = CMPConsentManager.DEFAULT_VENDORLIST_REFRESH_TIME,
                          language: CMPLanguage,
                          consentToolConfiguration: CMPConsentToolConfiguration,
                          showConsentToolIfUserLimitedAdTracking: Bool = CMPConsentManager.DEFAULT_LAT_VALUE) {
        // Check that we did not already configure, log error and stop if already configured
        if self.configured {
            logErrorMessage("CMPConsentManager is already configured for this session. You cannot reconfigure.")
            return;
        }
        
        // Change configuration status
        self.configured = true
        
        // Language
        self.language = language
        
        // Consent Tool
        self.consentToolConfiguration = consentToolConfiguration
        self.showConsentToolIfLAT = showConsentToolIfUserLimitedAdTracking
        
        // Instantiate CPMVendorsManager with URL and RefreshTime and delegate
        self.vendorListManager = CMPVendorListManager(url: CMPVendorListURL(), refreshInterval: refreshInterval, delegate: self)
        
        // Check for already existing consent string in NSUserDefaults
        if let storedConsentString = readStringFromUserDefaults(key: CMPConstants.IABConsentKeys.ConsentString) {
            self.consentString = CMPConsentString.from(base64: storedConsentString)
        }

        // Trigger refresh of vendor list
        self.vendorListManager?.refresh();
    }

    /**
     Forces an immediate refresh of the vendors list.
     */
    @objc
    public func refreshVendorsList() {
        // Log error and stop if configuration is not made
        if !self.configured {
            logErrorMessage("CMPConsentManager is not configured for this session. Please call CMPConsentManager.shared.configure() first.")
            return;
        }
        
        // Refresh vendor list
        self.vendorListManager?.refresh();
    }
    
    /**
     Present the consent tool UI modally.
     
     - Parameter controller: The UIViewController instance which should present the consent tool UI.
     */
    @objc
    public func showConsentTool(fromController controller: UIViewController) {
        // Log error and stop if configuration is not made
        guard self.configured else {
            logErrorMessage("CMPConsentManager is not configured for this session. Please call CMPConsentManager.shared.configure() first.")
            return;
        }
        
        guard !self.consentToolIsShown else {
            logErrorMessage("CMPConsentManager is already showing the consent tool view controller.")
            return;
        }
        
        guard let lastVendorList = self.lastVendorList else {
            logErrorMessage("CMPConsentManager cannot show consent tool as no vendor list is available. Please wait.")
            return;
        }
        
        // Consider consent tool as shown
        self.consentToolIsShown = true
        
        // Instantiate consent tool manager from vendor list and current consent
        let manager = CMPConsentToolManager(delegate: self, language: self.language, consentString: self.consentString, vendorList: lastVendorList, configuration: self.consentToolConfiguration!)
        self.consentToolManager = manager
        manager.showConsentTool(fromController: controller)
        
    }
    
    // MARK: - CMPVendorListManagerDelegate
    
    func vendorListManager(_ vendorListManager: CMPVendorListManager, didFailWithError error: Error) {
        logErrorMessage("CMPConsentManager cannot retrieve vendors list because of an error \"\(error.localizedDescription)\" a new attempt will be made later.")
        return;
    }
    
    func vendorListManager(_ vendorListManager: CMPVendorListManager, didFetchVendorList vendorList: CMPVendorList) {
        self.lastVendorList = vendorList
        
        DispatchQueue.main.async {
            // Consent string exist
            if let storedConsentString = self.consentString {
                // Consent string has a different version than vendor list, ask for consent tool display
                if storedConsentString.vendorListVersion != vendorList.vendorListVersion {
                    // TODO migrate the consent string instead of creating a new one with full consent
                    self.consentString = CMPConsentString.consentStringWithFullConsent(consentScreen: 0, consentLanguage: self.language, vendorList: vendorList, date: Date())
                    
                    // Display consent tool
                    self.displayConsentTool(vendorList: vendorList)
                }
            } else { // Consent string does not exist, ask for consent tool display
                self.displayConsentTool(vendorList: vendorList)
            }
        }
    }
    
    // MARK: - CMPConsentToolManagerDelegate
    
    func consentToolManager(_ consentToolManager: CMPConsentToolManager, didFinishWithConsentString consentString: CMPConsentString) {
        self.consentToolIsShown = false
        if self.consentString != consentString {
            self.consentString = consentString
        }
    }
    
    // MARK: - Trigger Consent Tool Display
    
    /**
     Display the consent tool.
     */
    private func displayConsentTool(vendorList: CMPVendorList) {
        if let delegate = self.delegate {
            // Publisher will be responsible to trigger consent tool display
            delegate.consentManagerRequestsToShowConsentTool(self)
        } else {
            // Force consent tool display depending on LAT status
            let isTrackingAllowed = ASIdentifierManager.shared().isAdvertisingTrackingEnabled
            
            if isTrackingAllowed || (!isTrackingAllowed && self.showConsentToolIfLAT) {
                // Find root view controller
                if let viewController = UIApplication.shared.keyWindow?.rootViewController {
                    showConsentTool(fromController: viewController)
                }
            } else {
                // Generate consent string with no consent
                self.consentString = CMPConsentString.consentStringWithNoConsent(consentScreen: 0, consentLanguage: self.language, vendorList: vendorList, date: Date())
            }
        }
    }
    
    // MARK: - Variables changes
    
    /**
     Method called when the GDPR status variable has changed.
     */
    private func gdrpStatusChanged() {
        saveGDPRStatus(self.subjectToGDPR)
    }
    
    /**
     Method called when the consent string has changed.
     */
    private func consentStringChanged() {
        guard let newConsentString = self.consentString else {
            return;
        }
        
        self.saveConsentString(newConsentString.consentString)
        self.saveVendorConsentString(newConsentString.parsedVendorConsents)
        self.savePurposeConsentString(newConsentString.parsedPurposeConsents)
    }
        
    // MARK: - Utils - Error Display
    
    /**
     Log an error message in Xcode console.
 
     - Parameter message: The message that will be logged.
     */
    private func logErrorMessage(_ message: String) {
        NSLog("[ERROR] SmartCMP: \(message)")
    }
    
    // MARK: - Utils - NSUserDefault Management
    
    /**
     Save a string in user defaults.
     
     - Parameters:
        - string: The string that needs to be saved.
        - key: The key in user defaults where the string will be saved.
     */
    private func saveStringToUserDefaults(string: String, key: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(string, forKey: key)
        userDefaults.synchronize()
    }
    
    /**
     Read a string from user defaults.
     
     - Parameters key: The key in user defaults from where the string will be read.
     - Returns: The string read if any, nil otherwise.
     */
    private func readStringFromUserDefaults(key: String) -> String? {
        let userDefaults = UserDefaults.standard
        let string = userDefaults.object(forKey: key) as? String
        return string
    }
    
    /**
     Save the GDPR status in user defaults.
     
     - Parameter status: The status to be saved.
     */
    internal func saveGDPRStatus(_ status: Bool) {
        let statusString = status ? "1" : "0"
        saveStringToUserDefaults(string: statusString, key: CMPConstants.IABConsentKeys.SubjectToGDPR)
    }
    
    /**
     Save the consent string in user defaults.
     
     - Parameter string: The consent string to be saved.
     */
    internal func saveConsentString(_ string: String) {
        saveStringToUserDefaults(string: string, key: CMPConstants.IABConsentKeys.ConsentString)
    }
    
    /**
     Save the purposes consent string in user defaults.
     
     - Parameter string: The purposes consent string to be saved.
     */
    internal func savePurposeConsentString(_ string: String) {
        saveStringToUserDefaults(string: string, key: CMPConstants.IABConsentKeys.ParsedPurposeConsent)
    }
    
    /**
     Save the vendors consent string in user defaults.
     
     - Parameter string: The vendors consent string to be saved.
     */
    internal func saveVendorConsentString(_ string: String) {
        saveStringToUserDefaults(string: string, key: CMPConstants.IABConsentKeys.ParsedVendorConsent)
    }
    
    private override init() {}
    
}
