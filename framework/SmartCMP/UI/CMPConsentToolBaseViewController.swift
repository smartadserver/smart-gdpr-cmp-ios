//
//  CMPConsentToolBaseViewController.swift
//  SmartCMP
//
//  Created by Loïc GIRON DIT METAZ on 23/05/2018.
//  Copyright © 2018 Smart AdServer.
//
//  This software is distributed under the Creative Commons Legal Code, Attribution 3.0 Unported license.
//  Check the LICENSE file for more information.
//

import Foundation

/**
 Base consent tool view controller used for the global configuration of all preferences view controllers.
 */
internal class CMPConsentToolBaseViewController: UITableViewController {
    
    /// Bar style.
    let barStyle = UIBarStyle.default
    
    /// Status bar style.
    let statusBarStyle = UIStatusBarStyle.default
    
    /// Navigation bar color.
    let navigationBarTintColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
    
    /// Title label color.
    let titleTintColor = UIColor.black
    
    /// Navigation bar button color.
    let navigationButtonTintColor = UIColor(red: 14.0/255, green: 122.0/255, blue: 254.0/255, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting the navigation bar to 'default' colors
        navigationController?.navigationBar.barStyle = barStyle
        navigationController?.navigationBar.barTintColor = navigationBarTintColor
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: titleTintColor]
        navigationController?.navigationBar.tintColor = navigationButtonTintColor
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
}
