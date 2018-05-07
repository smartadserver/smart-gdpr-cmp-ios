//
//  CMPConsentToolDetailViewController.swift
//  SmartCMP
//
//  Created by Thomas Geley on 25/04/2018.
//  Copyright © 2018 Smart AdServer.
//
//  This software is distributed under the Creative Commons Legal Code, Attribution 3.0 Unported license.
//  Check the LICENSE file for more information.
//

import UIKit

/**
 Consent tool purposes view controller.
 */
internal class CMPConsentToolPurposeViewController: UITableViewController {
    
    /// The purpose displayed by the view controller
    weak var purpose: CMPPurpose?
    
    // MARK: - UI Elements
   
    @IBOutlet weak var purposeNameLabel: UILabel!
    @IBOutlet weak var purposeDescriptionLabel: UILabel!
    @IBOutlet weak var purposeActiveSwitch: UISwitch!
    @IBOutlet weak var allowLabel: UILabel!
    
    // MARK: - Consent Tool Manager
    
    weak var consentToolManager: CMPConsentToolManager?
    
    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure texts
        self.title = consentToolManager?.configuration.consentManagementScreenPurposeSectionHeaderText
        
        self.purposeNameLabel.text = purpose?.name
        self.purposeDescriptionLabel.text = purpose?.purposeDescription
        self.purposeDescriptionLabel.sizeToFit()
        self.allowLabel.text = consentToolManager?.configuration.consentManagementPurposeDetailAllowText
        if let consentToolManager = self.consentToolManager, let purpose = self.purpose {
            self.purposeActiveSwitch.isOn = consentToolManager.isPurposeAllowed(purpose)
        }

        self.view.backgroundColor = UIColor.groupTableViewBackground
        
    }
    
    @IBAction func purposeActiveSwitchValueChanged(_ sender: UISwitch) {
        if let purpose = self.purpose {
            consentToolManager?.changePurposeConsent(purpose, consent: sender.isOn)
        }
    }
    

}
