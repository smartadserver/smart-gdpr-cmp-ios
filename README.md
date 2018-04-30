# SmartCMP for iOS

> WORK IN PROGRESS: DO NOT USE IN PRODUCTION!
>
> - APIs not final
> - Configuration object not final
> - UI not final
> - Vendor list model parsing may be too strict
> - Some public APIs are missing in ObjC headers
> - Localization is not implemented, this version leaves this whole topic to the publisher
>
> OPEN FOR COMMENT - create a Github issue if you want to participate

## Introduction

_SmartCMP_ is a framework allowing you to retrieve and store the user's consent for data usage in your iOS apps.

Retrieving user consent will be mandatory in EU starting May 25th due to the _General Data Protection Regulation (GDPR)_.

<p align="center">
  <img src="images/ios-consent-tool.gif" alt="Consent tool on iOS"/>
</p>

## Usage

### Installation

Drag the ```SmartCMP.xcodeproj``` to your project and add the ```SmartCMP.framework``` target to the _Embedded Binaries_ section of your project _General_ properties.

### Integration

You must setup the CMP before using it. Start by creating a configuration object that will define how the first screen of the consent tool will look like:

    let config = CMPConsentToolConfiguration(logo: UIImage(named: "logo")!,
                                           homeScreenText: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                                           homeScreenManageConsentButtonTitle: "MANAGE MY CHOICES",
                                           homeScreenCloseButtonTitle: "GOT IT, THANKS!",
                                           consentManagementScreenTitle: "Privacy preferences",
                                           consentManagementCancelButtonTitle: "Cancel",
                                           consentManagementSaveButtonTitle: "Save",
                                           consentManagementScreenVendorsSectionHeaderText: "Vendors",
                                           consentManagementScreenPurposeSectionHeaderText: "Purpose",
                                           consentManagementVendorsControllerAccessText: "Customize authorized vendors",
                                           consentManagementActivatedText: "yes",
                                           consentManagementDeactivatedText: "no",
                                           consentManagementPurposeDetailAllowText: "Allowed",
                                           consentManagementVendorDetailViewPolicyText: "View privacy policy",
                                           consentManagementVendorDetailPurposesText: "Required purposes",
                                           consentManagementVendorDetailFeaturesText: "Features")

Call the ```configure()``` method on ```CMPConsentManager.shared``` to start the CMP.

    CMPConsentManager.shared.configure(language: CMPLanguage(string: "en")!, consentToolConfiguration: self.generateConsentToolConfiguration())

When the CMP is started, it will automatically fetch the most recent vendors list _(vendors.json)_ and prompt the user for consent if necessary, saving the resulting consent string in iOS _NSUserDefaults_ (according to the IAB specifications).

You might want to control when the user will be prompted for consent for better user experience. In this case, define a delegate for ```CMPConsentManager.shared```:

    CMPConsentManager.shared.delegate = self

When retrieval of the user consent is required, the ```consentManagerRequestsToShowConsentTool```
 method will be called on the delegate and it will be the app's responsability to display the consent tool UI when appropriate.

    func consentManagerRequestsToShowConsentTool(_ consentManager: CMPConsentManager) {
      // It is necessary to update the user consent using the consent tool.
    }

Showing the consent tool is done using the method ```showConsentTool```. Note that this method can be used not only when it has been requested by the consent manager, but also anytime you want to provide a way for the user to change its consent options.

    CMPConsentManager.shared.showConsentTool(fromController: self)

## License

This software is distributed under the _Creative Commons Legal Code, Attribution 3.0 Unported_ license.

Check the [LICENSE file](LICENSE) for more details.
