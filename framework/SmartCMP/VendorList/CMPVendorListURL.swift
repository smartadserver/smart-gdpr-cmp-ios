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
    
    /// The actual localized url of the vendor list if any.
    let localizedUrl: URL?
    
    /**
     Initialize a CMPVendorListURL object that represents the latest vendor list.
     
     - Parameter language: The language of the user if a localized url has to be used.
     */
    init(language: CMPLanguage? = nil) {
        url = URL(string: CMPConstants.VendorList.DefaultEndPoint)!
        
        localizedUrl = {
            if let language = language {
                let urlString = CMPConstants.VendorList.DefaultLocalizedEndPoint
                    .replacingOccurrences(of: "{language}", with: language.string)
                return URL(string: urlString)
            }
            return nil
        }()
    }
    
    /**
     Initialize a CMPVendorListURL object that representsthe vendor list for a given version.
     
     - Parameters:
        - version: The vendor list version that should be fetched.
        - language: The language of the user if a localized url has to be used.
     */
    init(version: Int, language: CMPLanguage? = nil) {
        precondition(version >= 0, "Version number must be a positive number!")
        
        let urlString = CMPConstants.VendorList.VersionedEndPoint
            .replacingOccurrences(of: "{version}", with: String(version))
        url = URL(string: urlString)!
        
        localizedUrl = {
            if let language = language {
                let urlString = CMPConstants.VendorList.VersionedLocalizedEndPoint
                    .replacingOccurrences(of: "{language}", with: language.string)
                    .replacingOccurrences(of: "{version}", with: String(version))
                return URL(string: urlString)
            }
            return nil
        }()
    }
    
}
