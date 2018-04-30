//
//  CMPConsentToolVendorsViewController.swift
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
 Consent tool vendors view controller.
 */
internal class CMPConsentToolVendorsViewController: UITableViewController {
    
    // MARK: - UI Elements

    static let VendorCellIdentifier = "vendorCell"
    
    // MARK: - Consent Tool Manager
    
    weak var consentToolManager: CMPConsentToolManager?
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.consentToolManager!.configuration.consentManagementScreenVendorsSectionHeaderText
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.consentToolManager!.activatedVendorCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CMPConsentToolVendorsViewController.VendorCellIdentifier, for: indexPath) as! CMPVendorTableViewCell
        
        // Fill cell with vendor info
        if let consentToolManager = self.consentToolManager, let vendor:CMPVendor = consentToolManager.vendorAtIndex(indexPath.row) {
            cell.vendorNameLabel.text = vendor.name
            cell.vendorActiveSwitch.isOn = consentToolManager.isVendorAllowed(vendor)
            cell.vendorActiveSwitchCallback =  { (switch) -> Void in
                consentToolManager.changeVendorConsent(vendor, consent: cell.vendorIsActive)
            }
        }
        cell.accessoryType = .disclosureIndicator;
        return cell
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vendorController:CMPConsentToolVendorViewController = segue.destination as! CMPConsentToolVendorViewController
        vendorController.consentToolManager = self.consentToolManager
        if let consentToolManager = self.consentToolManager, let selectedRow = self.tableView.indexPathForSelectedRow?.row {
            vendorController.vendor = consentToolManager.vendorAtIndex(selectedRow)
        }
    }

}
