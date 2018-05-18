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
    
    /// Whether or not the consent tool should show if user has limited ad tracking in the device settings.
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
            showConsentToolWhenLimitedAdTracking: CMPConsentManager.DEFAULT_LAT_VALUE
        )
    }
    
    /**
     Configure the CMPConsentManager. This method must be called only once per session.
     
     Note: if you set 'showConsentToolWhenLimitedAdTracking' to true, you will be able to ask for user consent even if 'Limited Ad
     Tracking' has been enabled on the device. In this case, remember that you still have to comply to Apple's App Store Terms and
     Conditions regarding 'Limited Ad Tracking'.
     
     - Parameters:
        - vendorListURL: The URL from where to fetch the vendor list (vendors.json). If you enter your own URL, your custom list MUST BE compatible with IAB specifications and respect vendorId and purposeId distributed by the IAB.
        - refreshInterval: The interval in seconds to refresh the vendor list.
        - language: an instance of CMPLanguage reflecting the device's current language.
        - consentToolConfiguration: an instance of CMPConsentToolConfiguration to configure of the consent tool UI.
        - showConsentToolWhenLimitedAdTracking: Whether or not the consent tool UI should be shown if the user has enabled 'Limit Ad Tracking' in his device's preferences. If false, the consent tool will never be shown if user has enabled 'Limit Ad Tracking' and the consent string will be formatted has 'user does not give consent'. Note that if you have provided a delegate, it will not be called either.
     */
    @objc
    public func configure(refreshInterval: TimeInterval = CMPConsentManager.DEFAULT_VENDORLIST_REFRESH_TIME,
                          language: CMPLanguage,
                          consentToolConfiguration: CMPConsentToolConfiguration,
                          showConsentToolWhenLimitedAdTracking: Bool = CMPConsentManager.DEFAULT_LAT_VALUE) {
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
        self.showConsentToolIfLAT = showConsentToolWhenLimitedAdTracking
        
        // Instantiate CPMVendorsManager with URL and RefreshTime and delegate
        self.vendorListManager = CMPVendorListManager(url: CMPVendorListURL(language: language), refreshInterval: refreshInterval, delegate: self)
        
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
     
     Note: the consent tool will not be displayed if
     
     - you haven't called the configure() method first
     - the consent tool is already displayed
     - the vendor list has not been retrieved yet (or can't be retrieved for the moment).
     
     - Parameter controller: The UIViewController instance which should present the consent tool UI.
     - Returns: true if the consent tool has been displayed properly, false if it can't be displayed.
     */
    @objc
    public func showConsentTool(fromController controller: UIViewController) -> Bool {
        // Log error and stop if configuration is not made
        guard self.configured else {
            logErrorMessage("CMPConsentManager is not configured for this session. Please call CMPConsentManager.shared.configure() first.")
            return false;
        }
        
        guard !self.consentToolIsShown else {
            logErrorMessage("CMPConsentManager is already showing the consent tool view controller.")
            return false;
        }
        
        guard let lastVendorList = self.lastVendorList else {
            logErrorMessage("CMPConsentManager cannot show consent tool as no vendor list is available. Please wait.")
            return false;
        }
        
        // Consider consent tool as shown
        self.consentToolIsShown = true
        
        // Instantiate consent tool manager from vendor list and current consent
        let manager = CMPConsentToolManager(delegate: self, language: self.language, consentString: self.consentString, vendorList: lastVendorList, configuration: self.consentToolConfiguration!)
        self.consentToolManager = manager
        manager.showConsentTool(fromController: controller)
        
        return true
    }
    
    // MARK: - CMPVendorListManagerDelegate
    
    func vendorListManager(_ vendorListManager: CMPVendorListManager, didFailWithError error: Error) {
        logErrorMessage("CMPConsentManager cannot retrieve vendors list because of an error \"\(error.localizedDescription)\" a new attempt will be made later.")
        return;
    }
    
    func vendorListManager(_ vendorListManager: CMPVendorListManager, didFetchVendorList vendorList: CMPVendorList) {
        self.lastVendorList = vendorList
        
        // Consent string exist
        if let storedConsentString = self.consentString {
            // Consent string has a different version than vendor list, ask for consent tool display
            if storedConsentString.vendorListVersion != vendorList.vendorListVersion {
                // Fetching the old vendor list to migrate the consent string:
                // Old purposes & vendors must keep their values, new one will be considered as accepted by default
                vendorListManager.refresh(vendorListURL: CMPVendorListURL(version: storedConsentString.vendorListVersion)) { previousVendorList, error in
                    if let error = error {
                        self.logErrorMessage("CMPConsentManager cannot retrieve previous vendors list because of an error \"\(error.localizedDescription)\"")
                    } else if let previousVendorList = previousVendorList {
                        // Generate the updated consent string
                        self.consentString = CMPConsentString.consentString(fromUpdatedVendorList: vendorList,
                                                                            previousVendorList: previousVendorList,
                                                                            previousConsentString: storedConsentString,
                                                                            consentLanguage: self.language)
                        
                        DispatchQueue.main.async {
                            // Display consent tool
                            self.handleVendorListChanged(vendorList)
                        }
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                // Consent string does not exist, ask for consent tool display
                self.handleVendorListChanged(vendorList)
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
     Handle the reception of a new vendor list. Calling this method will either:
     
     - show the consent tool manager (if we don't have any delegate),
     - call the delegate with the new vendor list,
     - generate an consent string without any consent if 'limited ad tracking' is enabled and the CMP is configured to handle it itself.
     
     - Parameter vendorList: The newly retrieved vendor list.
     */
    private func handleVendorListChanged(_ vendorList: CMPVendorList) {
        // Checking the 'Limited Ad Tracking' status of the device
        let isTrackingAllowed = ASIdentifierManager.shared().isAdvertisingTrackingEnabled
        
        // If the 'Limited Ad Tracking' is disabled on the device, or if the 'Limited Ad Tracking' is enabled but the publisher
        // wants to handle this option himself…
        if isTrackingAllowed || self.showConsentToolIfLAT {
            if let delegate = self.delegate {
                // The delegate is called so the publisher can ask for user's consent
                delegate.consentManagerRequestsToShowConsentTool(self, forVendorList: vendorList)
            } else {
                // There is no delegate so the CMP will ask for user's consent automatically
                if let viewController = UIApplication.shared.keyWindow?.rootViewController {
                    let _ = showConsentTool(fromController: viewController)
                }
            }
        } else {
            // If 'Limited Ad Tracking' is enabled and the publisher don't want to handle it himself, a consent string with no
            // consent (for all vendors / purposes) is generated and stored.
            self.consentString = CMPConsentString.consentStringWithNoConsent(consentScreen: 0, consentLanguage: self.language, vendorList: vendorList, date: Date())
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
