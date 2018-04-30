//
//  CMPVendorListManagerDelegate.swift
//  SmartCMP
//
//  Created by Loïc GIRON DIT METAZ on 25/04/2018.
//  Copyright © 2018 Smart AdServer.
//
//  This software is distributed under the Creative Commons Legal Code, Attribution 3.0 Unported license.
//  Check the LICENSE file for more information.
//

import Foundation

/**
 Delegate of CMPVendorListManager.
 */
internal protocol CMPVendorListManagerDelegate {
    
    /**
     Method called when the vendor list manager did fetch a vendor list successfully.
     
     - Parameters:
         - vendorListManager: The vendor list manager that fetched a vendor list.
         - vendorList: The vendor list that has been fetched.
     */
    func vendorListManager(_ vendorListManager: CMPVendorListManager, didFetchVendorList vendorList: CMPVendorList)
    
    /**
     Method called when the vendor list manager did fail to fetch a vendor list.
     
     - Parameters:
         - vendorListManager: The vendor list manager that failed to fetch a vendor list.
         - vendorList: The error that has been triggered when trying to fetch the vendor list.
     */
    func vendorListManager(_ vendorListManager: CMPVendorListManager, didFailWithError error: Error)
    
}
