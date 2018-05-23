//
//  CMPConsentToolPurposeViewController.swift
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
 Consent tool preferences view controller.
 */
internal class CMPConsentToolPreferencesViewController: CMPConsentToolBaseViewController {
    
    // MARK: - UI Elements
    
    static let PurposeSection = 0
    static let VendorSection = 1
    static let PurposeCellIdentifier = "purposeCell"
    static let VendorsCellIdentifier = "vendorsCell"

    static let PurposeControllerSegue = "purposeControllerSegue"
    static let VendorsControllerSegue = "vendorsControllerSegue"
    
    // MARK: - Consent Tool Manager
    
    weak var consentToolManager: CMPConsentToolManager?
    
    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = consentToolManager?.configuration.consentManagementScreenTitle
        
        // Cancel button
        let btnBack = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        btnBack.setTitle(consentToolManager?.configuration.consentManagementCancelButtonTitle, for: .normal)
        btnBack.titleLabel?.textAlignment = .left
        btnBack.addTarget(self, action: #selector(cancelButtonTapped(sender:)), for: .touchUpInside)
        btnBack.setTitleColor(navigationButtonTintColor, for: .normal)
        btnBack.setTitleColor(navigationButtonTintColor, for: .highlighted)
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = btnBack
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        // Save button
        let btnSave = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        btnSave.setTitle(consentToolManager?.configuration.consentManagementSaveButtonTitle, for: .normal)
        btnSave.titleLabel?.textAlignment = .right
        btnSave.addTarget(self, action: #selector(saveButtonTapped(sender:)), for: .touchUpInside)
        btnSave.setTitleColor(navigationButtonTintColor, for: .normal)
        btnSave.setTitleColor(navigationButtonTintColor, for: .highlighted)
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnSave
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        // Footer
        self.tableView.tableFooterView = UIView()
        self.view.backgroundColor = UIColor.groupTableViewBackground
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

    // MARK: - Actions
    
    @objc func cancelButtonTapped(sender: Any) {
        self.consentToolManager?.reset()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func saveButtonTapped(sender: Any) {
        consentToolManager?.dismissConsentTool(save: true)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == CMPConsentToolPreferencesViewController.PurposeSection {
            return consentToolManager?.purposesCount ?? 1
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == CMPConsentToolPreferencesViewController.PurposeSection {
            let cell = tableView.dequeueReusableCell(withIdentifier: CMPConsentToolPreferencesViewController.PurposeCellIdentifier) as! CMPPreferenceTableViewCell

            if let purpose = consentToolManager?.purposeAtIndex(indexPath.row) {
                cell.nameLabel.text = purpose.name
                cell.statusLabel.text = consentToolManager!.isPurposeAllowed(purpose) ? consentToolManager?.configuration.consentManagementActivatedText : consentToolManager?.configuration.consentManagementDeactivatedText
            }
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator;
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CMPConsentToolPreferencesViewController.VendorsCellIdentifier) as! CMPPreferenceTableViewCell
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator;
            cell.nameLabel.text = consentToolManager?.configuration.consentManagementVendorsControllerAccessText
            if let consentToolManager = self.consentToolManager {
                cell.statusLabel.text = String(consentToolManager.allowedVendorCount) + " / " + String(consentToolManager.activatedVendorCount)
                cell.statusLabel.sizeToFit()
            }
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator;
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case CMPConsentToolPreferencesViewController.PurposeSection:
            return consentToolManager?.configuration.consentManagementScreenPurposesSectionHeaderText
        default:
            return consentToolManager?.configuration.consentManagementScreenVendorsSectionHeaderText
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor.groupTableViewBackground
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.systemFont(ofSize: 15.0)
        header.textLabel?.textColor = UIColor.darkGray
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == CMPConsentToolPreferencesViewController.VendorsControllerSegue {
            let vendorsController:CMPConsentToolVendorsViewController = segue.destination as! CMPConsentToolVendorsViewController
            vendorsController.consentToolManager = self.consentToolManager
        } else if segue.identifier == CMPConsentToolPreferencesViewController.PurposeControllerSegue {
            let purposeController:CMPConsentToolPurposeViewController = segue.destination as! CMPConsentToolPurposeViewController
            purposeController.consentToolManager = self.consentToolManager
            if let selectedRow = self.tableView.indexPathForSelectedRow?.row {
                purposeController.purpose = self.consentToolManager?.purposeAtIndex(selectedRow)
            }
        }
    }
    

}
