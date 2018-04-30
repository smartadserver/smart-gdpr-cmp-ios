//
//  CMPVendorTableViewCell.swift
//  SmartCMP
//
//  Created by Julien Gomez on 26/04/2018.
//  Copyright © 2018 Smart AdServer.
//
//  This software is distributed under the Creative Commons Legal Code, Attribution 3.0 Unported license.
//  Check the LICENSE file for more information.
//

import UIKit

/**
 Vendor table view cell.
 */
internal class CMPVendorTableViewCell: UITableViewCell {

    var vendorActiveSwitchCallback: ((_ switch: UISwitch) -> Void)?
    var vendorIsActive: Bool =  true
    
    @IBOutlet weak var vendorNameLabel: UILabel!
    @IBOutlet weak var vendorActiveSwitch: UISwitch!
    
    @IBAction func vendorSwitchValueChanged(_ sender: UISwitch) {
        self.vendorIsActive = sender.isOn
        vendorActiveSwitchCallback?(sender)
    }

}
