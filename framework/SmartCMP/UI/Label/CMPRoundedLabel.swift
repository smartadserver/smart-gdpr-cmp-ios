//
//  CMPRoundedLabel.swift
//  SmartCMP
//
//  Created by Julien Gomez on 30/04/2018.
//  Copyright © 2018 Smart AdServer.
//
//  This software is distributed under the Creative Commons Legal Code, Attribution 3.0 Unported license.
//  Check the LICENSE file for more information.
//

import UIKit

/**
 UILabel subclass that displays its background with rounded corners.
 */
internal class CMPRoundedLabel: UILabel {

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }

}
