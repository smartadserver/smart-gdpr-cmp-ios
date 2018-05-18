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
            DispatchQueue.main.async {
                self.textView.text = consentString
            }            
        } else {
            DispatchQueue.main.async {
                self.textView.text = nil
            }
        }
    }
    
    // MARK: Show consent tool action
    
    @IBAction func showConsentToolButtonTapped(_ sender: Any) {
        // Showing the consent tool manually
        if !CMPConsentManager.shared.showConsentTool(fromController: self) {
            
            // Note: showing the consent tool might fail for several reasons (check the API documentation for more information).
            // For better user experience, it is advised to display an error if the consent tool can't be opened when it has been
            // requested by the user.
            let alert = UIAlertController(title: "Service unavailable",
                                          message: "Setting your privacy preferences is not possible at the moment, please try again later",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            
        }
    }
    
}


