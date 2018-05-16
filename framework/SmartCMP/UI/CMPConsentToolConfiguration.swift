//
//  CMPConsentToolConfiguration.swift
//  SmartCMP
//
//  Created by Thomas Geley on 27/04/2018.
//  Copyright © 2018 Smart AdServer.
//
//  This software is distributed under the Creative Commons Legal Code, Attribution 3.0 Unported license.
//  Check the LICENSE file for more information.
//

import Foundation

/**
 The configuration class of CMPConsentToolManager.
 */
@objc
public class CMPConsentToolConfiguration : NSObject {
    
    // MARK: - Home Screen Fields
    
    /// Image that will be displayed on the first controller of the consent tool.
    ///
    /// Eg: UIImage(named: "logo", in: Bundle(identifier: "com.smartadserver.SmartCMP"), compatibleWith: nil)!
    let homeScreenLogo: UIImage
    
    /// Text that will be displayed on the first controller of the consent tool.
    ///
    /// Eg: "Lorem ipsum sit amet, Lorem ipsum sit amet, Lorem ipsum sit amet, Lorem ipsum sit amet, Lorem ipsum sit amet,Lorem ipsum sit amet"
    let homeScreenText: String
    
    /// Text of the button to open consent management controller.
    ///
    /// Eg: "MANAGE MY CHOICES"
    let homeScreenManageConsentButtonTitle: String
    
    /// Text of the button to close the consent tool directly.
    ///
    // Eg: "GOT IT, THANKS!"
    let homeScreenCloseButtonTitle: String
    
    // MARK: - Consent Management Controllers
    
    /// Text of the navigation bar title.
    ///
    /// Eg: "Privacy Preferences"
    let consentManagementScreenTitle: String
    
    /// Text to cancel presentation of consent management controller.
    ///
    /// Eg: "Cancel"
    let consentManagementCancelButtonTitle: String
    
    /// Text to save consent choices.
    ///
    /// Eg: "Save"
    let consentManagementSaveButtonTitle: String
    
    /// Text of the vendors section header.
    ///
    /// Eg: "Vendors"
    let consentManagementScreenVendorsSectionHeaderText: String
    
    /// Text of the purposes section header.
    ///
    /// Eg: "Purposes"
    let consentManagementScreenPurposesSectionHeaderText: String
    
    /// Text to access the full vendor list.
    ///
    /// Eg: "Authorized vendors"
    let consentManagementVendorsControllerAccessText: String
    
    /// Text to display when a purpose is activated.
    ///
    /// Eg: "yes"
    let consentManagementActivatedText: String
    
    /// Text to display when a purpose is deactivated.
    ///
    /// Eg: "no"
    let consentManagementDeactivatedText: String
    
    /// The title of the purpose detail screen.
    ///
    /// Eg: "Purpose"
    let consentManagementPurposeDetailTitle: String
    
    // MARK: - Purpose Detail Controller
    
    /// Text displayed next to the switch to allow / disallow a purpose.
    ///
    /// Eg: "Allowed"
    let consentManagementPurposeDetailAllowText: String
    
    // MARK: - Vendor Detail Controller
    
    /// Text displayed to access vendor's privacy policy webpage.
    ///
    /// Eg: "View Policy"
    let consentManagementVendorDetailViewPolicyText: String
    
    /// Text displayed as the title of the list of the vendor's purposes.
    ///
    /// Eg: "Required purposes"
    let consentManagementVendorDetailPurposesText: String
    
    /// Text displayed as the title of the list of the vendor's legitimate interest purposes.
    ///
    /// Eg: "Legitimate purposes"
    let consentManagementVendorDetailLegitimatePurposesText: String
    
    /// Text displayed as the title of the list of the vendor's features.
    ///
    /// Eg: "Features"
    let consentManagementVendorDetailFeaturesText: String
    
    
    // MARK: - Initialization
    
    /**
     Initialize a new instance of CMPConsentToolConfiguration.
     
     - Parameters:
        - logo: An image that will be displayed on the Consent Tool home screen.
        - homeScreenText: The text that will be displayed on the home screen.
        - homeScreenManageConsentButtonTitle: The text for the button to manage consent.
        - homeScreenCloseButtonTitle: The text for the button to leave Consent Tool home screen.
        - consentManagementScreenTitle: The navigation bar title for screens where the user manages his consent.
        - consentManagementCancelButtonTitle: The navigation bar cancel button title for screens where the user manages his consent.
        - consentManagementSaveButtonTitle: The navigation bar save button title for screens where the user manages his consent.
        - consentManagementScreenVendorsSectionHeaderText: The title of the vendors section header.
        - consentManagementScreenPurposeSectionHeaderText: The title of the purposes section header.
        - consentManagementVendorsControllerAccessText: The text displayed to access the whole vendor list.
        - consentManagementActivatedText: The text to displayed when a purpose / vendor has consent.
        - consentManagementDeactivatedText: The text to displayed when a purpose / vendor has no consent.
        - consentManagementPurposeDetailTitle: The title of the purpose detail screen.
        - consentManagementPurposeDetailAllowText: Text displayed next to the switch to allow / disallow a purpose.
        - consentManagementVendorDetailViewPolicyText: Text displayed to access vendor's privacy policy webpage.
        - consentManagementVendorDetailPurposesText: Text displayed as the title of the list of the vendor's purposes.
        - consentManagementVendorDetailLegitimatePurposesText: Text displayed as the title of the list of the vendor's legitimate purposes.
        - consentManagementVendorDetailFeaturesText: Text displayed as the title of the list of the vendor's features.
     - Returns: A new instance of CMPConsentToolConfiguration.
     */
    @objc
    public init(logo: UIImage,
                homeScreenText: String,
                homeScreenManageConsentButtonTitle: String,
                homeScreenCloseButtonTitle: String,
                consentManagementScreenTitle: String,
                consentManagementCancelButtonTitle: String,
                consentManagementSaveButtonTitle: String,
                consentManagementScreenVendorsSectionHeaderText: String,
                consentManagementScreenPurposesSectionHeaderText: String,
                consentManagementVendorsControllerAccessText: String,
                consentManagementActivatedText: String,
                consentManagementDeactivatedText: String,
                consentManagementPurposeDetailTitle: String,
                consentManagementPurposeDetailAllowText: String,
                consentManagementVendorDetailViewPolicyText: String,
                consentManagementVendorDetailPurposesText: String,
                consentManagementVendorDetailLegitimatePurposesText: String,
                consentManagementVendorDetailFeaturesText: String) {
        
        self.homeScreenLogo = logo
        self.homeScreenText = homeScreenText
        self.homeScreenManageConsentButtonTitle = homeScreenManageConsentButtonTitle
        self.homeScreenCloseButtonTitle = homeScreenCloseButtonTitle
        self.consentManagementScreenTitle = consentManagementScreenTitle
        self.consentManagementCancelButtonTitle = consentManagementCancelButtonTitle
        self.consentManagementSaveButtonTitle = consentManagementSaveButtonTitle
        self.consentManagementScreenVendorsSectionHeaderText = consentManagementScreenVendorsSectionHeaderText
        self.consentManagementScreenPurposesSectionHeaderText = consentManagementScreenPurposesSectionHeaderText
        self.consentManagementVendorsControllerAccessText = consentManagementVendorsControllerAccessText
        self.consentManagementActivatedText = consentManagementActivatedText
        self.consentManagementDeactivatedText = consentManagementDeactivatedText
        self.consentManagementPurposeDetailTitle = consentManagementPurposeDetailTitle
        self.consentManagementPurposeDetailAllowText = consentManagementPurposeDetailAllowText
        self.consentManagementVendorDetailViewPolicyText = consentManagementVendorDetailViewPolicyText
        self.consentManagementVendorDetailPurposesText = consentManagementVendorDetailPurposesText
        self.consentManagementVendorDetailLegitimatePurposesText = consentManagementVendorDetailLegitimatePurposesText
        self.consentManagementVendorDetailFeaturesText = consentManagementVendorDetailFeaturesText
        
    }
    
}
