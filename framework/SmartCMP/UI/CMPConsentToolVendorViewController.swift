//
//  CMPConsentToolVendorViewController.swift
//  SmartCMP
//
//  Created by Julien Gomez on 30/04/2018.
//  Copyright © 2018 Smart AdServer.
//
//  This software is distributed under the Creative Commons Legal Code, Attribution 3.0 Unported license.
//  Check the LICENSE file for more information.
//

import UIKit
import SafariServices

/**
 Consent tool vendors view controller.
 */
internal class CMPConsentToolVendorViewController: CMPConsentToolBaseViewController {

    /// The vendor displayed by the view controller
    var vendor: CMPVendor?
    
    // MARK: - UI Elements
    
    static let PrivacyPolicySection = 0
    static let PurposeSection = 1
    static let LegitimateInterestPurposeSection = 2
    static let FeatureSection = 3

    static let DefaultCellIdentifier = "defaultCell"
    
    // MARK: - Consent Tool Manager
    
    weak var consentToolManager: CMPConsentToolManager?
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.groupTableViewBackground
        self.title = vendor?.name
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == CMPConsentToolVendorViewController.PrivacyPolicySection {
            return vendor?.policyURL != nil ? 1 : 0
        } else if section == CMPConsentToolVendorViewController.PurposeSection {
            return self.vendor?.purposes.count ?? 0
        } else if section == CMPConsentToolVendorViewController.LegitimateInterestPurposeSection {
            return self.vendor?.legitimatePurposes.count ?? 0
        } else if section == CMPConsentToolVendorViewController.FeatureSection {
            return self.vendor?.features.count ?? 0
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell!
        cell = tableView.dequeueReusableCell(withIdentifier: CMPConsentToolVendorViewController.DefaultCellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: CMPConsentToolVendorViewController.DefaultCellIdentifier)
        }
        
        if indexPath.section == CMPConsentToolVendorViewController.PurposeSection {
            if let purposeId = self.vendor?.purposes[indexPath.row], let consentToolManager = self.consentToolManager {
                cell.textLabel?.text = consentToolManager.purposeName(forId: purposeId)
            }
            cell.selectionStyle = .none
            cell.accessoryType = UITableViewCellAccessoryType.none;

        } else if indexPath.section == CMPConsentToolVendorViewController.LegitimateInterestPurposeSection {
            if let purposeId = self.vendor?.legitimatePurposes[indexPath.row], let consentToolManager = self.consentToolManager {
                cell.textLabel?.text = consentToolManager.purposeName(forId: purposeId)
            }
            cell.selectionStyle = .none
            cell.accessoryType = UITableViewCellAccessoryType.none;
            
        } else if indexPath.section == CMPConsentToolVendorViewController.FeatureSection {
            if let featureId = self.vendor?.features[indexPath.row], let consentToolManager = self.consentToolManager {
                cell.textLabel?.text = consentToolManager.featureName(forId: featureId)
            }
            cell.selectionStyle = .none
            cell.accessoryType = UITableViewCellAccessoryType.none;
            
        } else {
            cell.textLabel?.text = consentToolManager?.configuration.consentManagementVendorDetailViewPolicyText
            cell.selectionStyle = .default
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator;
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case CMPConsentToolVendorViewController.PurposeSection:
            if self.tableView(tableView, numberOfRowsInSection: section) > 0 {
                return consentToolManager?.configuration.consentManagementVendorDetailPurposesText
            }
        case CMPConsentToolVendorViewController.LegitimateInterestPurposeSection:
            if self.tableView(tableView, numberOfRowsInSection: section) > 0 {
                return consentToolManager?.configuration.consentManagementVendorDetailLegitimatePurposesText
            }
        case CMPConsentToolVendorViewController.FeatureSection:
            if self.tableView(tableView, numberOfRowsInSection: section) > 0 {
                return consentToolManager?.configuration.consentManagementVendorDetailFeaturesText
            }
        default:
            return nil
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == CMPConsentToolVendorViewController.PrivacyPolicySection {
            return 0
        }
        if self.tableView(tableView, numberOfRowsInSection: section) > 0 {
            return 32.0
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor.groupTableViewBackground
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.darkGray
        switch section {
        case CMPConsentToolVendorViewController.PrivacyPolicySection:
            header.textLabel?.font = UIFont.systemFont(ofSize: 17.0)
        default:
            header.textLabel?.font = UIFont.systemFont(ofSize: 15.0)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == CMPConsentToolVendorViewController.PrivacyPolicySection {
            if let URL = vendor?.policyURL {
                if #available(iOS 9.0, *) {
                    let svc:SFSafariViewController = SFSafariViewController(url: URL)
                    self.present(svc, animated: true, completion: nil)
                } else {
                    UIApplication.shared.openURL(URL)
                }
            }
        }
    }
    
}
