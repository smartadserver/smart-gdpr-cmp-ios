//
//  ViewController.swift
//  SmartCMPDemo
//
//  Created by Thomas Geley on 24/04/2018.
//  Copyright © 2018 Smart Adserver.
//
//  This software is distributed under the Creative Commons Legal Code, Attribution 3.0 Unported license.
//  Check the LICENSE file for more information.
//

import UIKit
import SmartCMP

class ViewController: UIViewController {

    static let consentStringKey = "IABConsent_ConsentString"
    
    var storedConsentString: String?
    
    @IBOutlet weak var textView: UITextView!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        ////////////////////////////////////////////////////////
        // How to read GDPR consent string from NSUserDefaults
        ////////////////////////////////////////////////////////
        logRegisteredConsentString()
        // Be notified at each change
        registerConsentStringObserver()
    }
    
    // MARK: Observe and log consent string value
    
    func registerConsentStringObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(logRegisteredConsentString), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    @objc func logRegisteredConsentString() {
        if let consentString = UserDefaults.standard.object(forKey: ViewController.consentStringKey) as? String, storedConsentString != consentString {
            NSLog("Stored consent string changed: \(consentString)")
            storedConsentString = consentString
            self.textView.text = consentString
        } else {
            self.textView.text = nil
        }
    }
    
    // MARK: Show consent tool action
    
    @IBAction func showConsentToolButtonTapped(_ sender: Any) {
        CMPConsentManager.shared.showConsentTool(fromController: self)
    }
    
}


