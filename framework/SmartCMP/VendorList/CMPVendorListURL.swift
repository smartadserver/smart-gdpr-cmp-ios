//
//  CMPVendorListURL.swift
//  SmartCMP
//
//  Created by Loïc GIRON DIT METAZ on 07/05/2018.
//  Copyright © 2018 Smart AdServer.
//
//  This software is distributed under the Creative Commons Legal Code, Attribution 3.0 Unported license.
//  Check the LICENSE file for more information.
//

import Foundation

/**
 Represents the URL to a vendor list.
 */
internal class CMPVendorListURL {
    
    /// The actual url of the vendor list.
    let url: URL
    
    /**
     Initialize a CMPVendorListURL object that represents the latest vendor list.
     */
    init() {
        url = URL(string: CMPConstants.VendorList.DefaultEndPoint)!
    }
    
    /**
     Initialize a CMPVendorListURL object that representsthe vendor list for a given version.
     
     - Parameter version:
     */
    init(version: Int) {
        precondition(version >= 0, "Version number must be a positive number!")
        
        let urlString = CMPConstants.VendorList.VersionedEndPoint
            .replacingOccurrences(of: "{version}", with: String(version))
        
        url = URL(string: urlString)!
    }
    
}
