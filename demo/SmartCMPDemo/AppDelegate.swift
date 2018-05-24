//
//  AppDelegate.swift
//  SmartCMPDemo
//
//  Created by Thomas Geley on 24/04/2018.
//  Copyright © 2018 Smart Adserver.
//
//  This software is distributed under the Creative Commons Legal Code, Attribution 3.0 Unported license.
//  Check the LICENSE file for more information.
//

import UIKit
import SmartCMP

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CMPConsentManagerDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Find current language for CMP configuration
        let preferedLanguage = Locale.preferredLanguages[0] as String
        let startIndex = String.Index(encodedOffset: 0)
        let endIndex = String.Index(encodedOffset: 2)
        let isoLg = String(preferedLanguage[startIndex..<endIndex])
        
        // Become the delegate of CMPConsentManager shared instance to know when the user should be asked for consent.
        //
        // This is not mandatory, if no delegate is found the CMPConsentManager will pop every time it is needed, whatever the user
        // is doing. Implementing this delegate is useful if you want to control when the consent tool will be launched (for better
        // user experience) or if you want to provide your own UI instead of using SmartCMP consent tool.
        CMPConsentManager.shared.delegate = self
        
        // Configure the CMPConsentManager shared instance.
        let cmpLanguage = CMPLanguage(string: isoLg) ?? CMPLanguage.DEFAULT_LANGUAGE
        CMPConsentManager.shared.configure(language: cmpLanguage, consentToolConfiguration: self.generateConsentToolConfiguration())
        
        return true
    }

    // MARK: - CMPConsentManagerDelegate
    
    func consentManagerRequestsToShowConsentTool(_ consentManager: CMPConsentManager, forVendorList vendorList: CMPVendorList) {
        NSLog("CMP Requested ConsentTool Display");
        
        // ---------------------------------------------------------------------------------------------------------------------
        
        // You should display the consent tool UI, when user is ready…
        if let controller = self.window?.rootViewController {
            let _ = consentManager.showConsentTool(fromController: controller)
        }
        
        // Since the vendor list is provided in parameter of this delegate method, you can also build your own UI to ask for
        // user consent and simply save the resulting consent string in the relevant IAB keys (see the IAB specification for
        // more details about this).
        //
        // To generate a valid IAB consent string easily, you can use the CMPConsentString class.
        
        // ---------------------------------------------------------------------------------------------------------------------
        
        // Note: depending on the situation, you might also want to allow or revoke all purposes consents without showing
        // the consent tool. You can do it using the allowAllPurposes() and revokeAllPurposes() methods.
        
        // Allow all purposes consents without prompting the user if the user is not subject to GDPR (for instance, when he
        // is not an European citizen).
        // let _ = consentManager.allowAllPurposes()
        
        // Revoke all purposes consents without prompting the user, for instance if the user is under 16 years old (or younger
        // depending on the country where the user is located).
        // let _ = consentManager.revokeAllPurposes()
    }
    
    // MARK: - Consent Tool Configuration
    
    func generateConsentToolConfiguration() -> CMPConsentToolConfiguration {
        return CMPConsentToolConfiguration(logo: UIImage(named: "logo")!,
                                           homeScreenText: "[Place here your legal privacy notice for the consent tool, compliant with GDPR]",
                                           homeScreenManageConsentButtonTitle: "MANAGE MY CHOICES",
                                           homeScreenCloseButtonTitle: "GOT IT, THANKS!",
                                           consentManagementScreenTitle: "Privacy preferences",
                                           consentManagementCancelButtonTitle: "Cancel",
                                           consentManagementSaveButtonTitle: "Save",
                                           consentManagementScreenVendorsSectionHeaderText: "Vendors",
                                           consentManagementScreenPurposesSectionHeaderText: "Purposes",
                                           consentManagementVendorsControllerAccessText: "Authorized vendors",
                                           consentManagementActivatedText: "yes",
                                           consentManagementDeactivatedText: "no",
                                           consentManagementPurposeDetailTitle: "Purpose",
                                           consentManagementPurposeDetailAllowText: "Allowed",
                                           consentManagementVendorDetailViewPolicyText: "View privacy policy",
                                           consentManagementVendorDetailPurposesText: "Required purposes",
                                           consentManagementVendorDetailLegitimatePurposesText: "Legitimate interest purposes",
                                           consentManagementVendorDetailFeaturesText: "Features")
    }
    
}

