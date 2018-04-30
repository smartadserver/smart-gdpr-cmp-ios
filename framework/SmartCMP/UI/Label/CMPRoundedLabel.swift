//
//  CMPRoundedLabel.swift
//  SmartCMP
//
//  Created by Julien Gomez on 30/04/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

import UIKit

class CMPRoundedLabel: UILabel {

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }

}
