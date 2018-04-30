//
//  CMPVendor.swift
//  SmartCMP
//
//  Created by Loïc GIRON DIT METAZ on 24/04/2018.
//  Copyright © 2018 Smart AdServer.
//
//  This software is distributed under the Creative Commons Legal Code, Attribution 3.0 Unported license.
//  Check the LICENSE file for more information.
//

import Foundation

/**
 Representation of a vendor.
 */
public class CMPVendor : Equatable, Codable {
    
    /// The id of the vendor.
    public let id: Int
    
    /// The name of the vendor.
    public let name: String
    
    /// The list of purposes related to this vendor.
    public let purposes: [Int]
    
    /// The list of legitimate (aka non-consentable) purposes related to this vendor.
    public let legitimatePurposes: [Int]
    
    /// The list of features related to this vendor.
    public let features: [Int]
    
    /// The privacy policy's URL for this vendor.
    public let policyURL: URL
    
    /// A date of deletion of this vendor has been marked as deleted, nil otherwise.
    public let deletedDate: Date?
    
    /// true if the vendor is activated (ie not deleted), false otherwise.
    public var isActivated: Bool {
        return deletedDate == nil
    }
    
    /**
     Initialize a new instance of CMPVendor.
     
     - Parameters:
        - id: The id of the vendor.
        - name: The name of the vendor.
        - purposes: The list of purposes related to this vendor.
        - legitimatePurposes: The list of legitimate (aka non-consentable) purposes related to this vendor.
        - features: The list of features related to this vendor.
        - policyURL: The privacy policy's URL for this vendor.
     */
    public convenience init(id: Int, name: String, purposes: [Int], legitimatePurposes: [Int], features: [Int], policyURL: URL) {
        self.init(id: id, name: name, purposes: purposes, legitimatePurposes: legitimatePurposes, features: features, policyURL: policyURL, deletedDate: nil)
    }
    
    /**
     Initialize a new instance of CMPVendor.
     
     - Parameters:
        - id: The id of the vendor.
        - name: The name of the vendor.
        - purposes: The list of purposes related to this vendor.
        - legitimatePurposes: The list of legitimate (aka non-consentable) purposes related to this vendor.
        - features: The list of features related to this vendor.
        - policyURL: The privacy policy's URL for this vendor.
        - deletedDate: A date of deletion of this vendor has been marked as deleted, nil otherwise.
     */
    public init(id: Int, name: String, purposes: [Int], legitimatePurposes: [Int], features: [Int], policyURL: URL, deletedDate: Date?) {
        self.id = id
        self.name = name
        self.purposes = purposes
        self.legitimatePurposes = legitimatePurposes
        self.features = features
        self.policyURL = policyURL
        self.deletedDate = deletedDate
    }
    
    public static func == (lhs: CMPVendor, rhs: CMPVendor) -> Bool {
        return lhs.id == rhs.id
            && lhs.name == rhs.name
            && lhs.purposes == rhs.purposes
            && lhs.legitimatePurposes == rhs.legitimatePurposes
            && lhs.features == rhs.features
            && lhs.policyURL == rhs.policyURL
            && lhs.deletedDate == rhs.deletedDate
    }
    
}
