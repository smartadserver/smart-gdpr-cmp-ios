//
//  CMPUIViewController.swift
//  SmartCMP
//
//  Created by Thomas Geley on 24/04/2018.
//  Copyright © 2018 Smart AdServer.
//
//  This software is distributed under the Creative Commons Legal Code, Attribution 3.0 Unported license.
//  Check the LICENSE file for more information.
//

import UIKit

/**
 Main consent tool view controller.
 */
internal class CMPConsentToolViewController: UIViewController {

    static let PreferencesControllerSegue = "preferencesControllerSegue"
    
    // MARK: - UI Elements
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var homeLabel: UILabel!
    @IBOutlet weak var manageConsentButton: UIButton!
    @IBOutlet weak var closeConsentButton: UIButton!
    
    // MARK: - Consent Tool Manager
    
    weak var consentToolManager: CMPConsentToolManager?
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set text of UI
        if let configuration = self.consentToolManager?.configuration {
            logoImageView.image = configuration.homeScreenLogo
            homeLabel.text = configuration.homeScreenText
            homeLabel.sizeToFit()
            manageConsentButton.setTitle(configuration.homeScreenManageConsentButtonTitle, for: .normal)
            closeConsentButton.setTitle(configuration.homeScreenCloseButtonTitle, for: .normal)            
        }
        
    }

    // MARK: - Actions
    
    @IBAction func closeConsentButtonTapped(_ sender: Any) {
        consentToolManager?.dismissConsentTool(save: false)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == CMPConsentToolViewController.PreferencesControllerSegue {
            let navigationController = segue.destination as! UINavigationController
            let preferencesController = navigationController.topViewController as! CMPConsentToolPreferencesViewController
            // Set CMP Consent Tool Manager
            preferencesController.consentToolManager = self.consentToolManager;
        }
    }

}
