//
//  CMPVendorList.swift
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
 Representation of a vendor list.
 */
@objc
public class CMPVendorList: NSObject, Codable {
    
    /// The vendor list version.
    @objc
    public let vendorListVersion: Int
    
    /// The date of the last vendor list update.
    @objc
    public let lastUpdated: Date
    
    /// A list of purposes.
    @objc
    public let purposes: [CMPPurpose]
    
    /// A list of features.
    @objc
    public let features: [CMPFeature]
    
    /// A list of vendors.
    @objc
    public let vendors: [CMPVendor]
    
    /// The list of activated vendors (ie not deleted).
    @objc
    public var activatedVendors: [CMPVendor] {
        return vendors.filter { $0.isActivated }
    }
    
    /// The maximum vendor id used in the vendor list.
    @objc
    public var maxVendorId: Int {
        return vendors.map({ $0.id }).reduce(0) { (acc, value) in value > acc ? value : acc }
    }
    
    /// The count of vendors in this vendor list.
    @objc
    public var vendorCount: Int {
        return vendors.count
    }
    
    /// The count of activated vendors (ie not deleted) in this vendor list.
    @objc
    public var activatedVendorCount: Int {
        return activatedVendors.count
    }
    
    /**
     Initialize a list of vendors using direct parameters.
     
     - Parameters:
        - vendorListVersion: The vendor list version.
        - lastUpdated: The date of the last vendor list update.
        - purposes: A list of purposes.
        - vendors: A list of vendors.
     */
    @objc
    public init(vendorListVersion: Int, lastUpdated: Date, purposes: [CMPPurpose], features: [CMPFeature], vendors: [CMPVendor]) {
        self.vendorListVersion = vendorListVersion
        self.lastUpdated = lastUpdated
        self.purposes = purposes
        self.features = features
        self.vendors = vendors
    }
    
    /**
     Initialize a list of vendors from a vendor list JSON (if valid).
     
     - Parameter jsonData: The data representation of the vendor list JSON.
     */
    @objc
    public convenience init?(jsonData: Data) {
        self.init(jsonData: jsonData, localizedJsonData: nil)
    }
    
    /**
     Initialize a list of vendors from a vendor list JSON (if valid).
     
     - Parameters:
        - jsonData: The data representation of the vendor list JSON.
        - localizedJsonData: The data representation of the localized vendor list JSON if any.
     */
    @objc
    public convenience init?(jsonData: Data, localizedJsonData: Data?) {
        
        // The localized JSON will be used to translate purposes and features if possible, but it is not mandatory. If
        // some keys are missing in this JSON, or if it's completely invalid, this will not stop the parser.
        let (localizedPurposesJson, localizedFeaturesJson): ([Any]?, [Any]?) = {
            if let localizedJsonData = localizedJsonData {
                let localizedJson = (try? JSONSerialization.jsonObject(with: localizedJsonData)) as? [String: Any]
                return (localizedJson?[JsonKey.Purposes.PURPOSES] as? [Any], localizedJson?[JsonKey.Features.FEATURES] as? [Any])
            } else {
                return (nil, nil)
            }
        }()
        
        guard let jsonData = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
            let json = jsonData,
            let vendorListVersion = json[JsonKey.VENDOR_LIST_VERSION] as? Int,
            let lastUpdatedString = json[JsonKey.LAST_UPDATED] as? String,
            let lastUpdated = CMPVendorList.date(from: lastUpdatedString),
            let purposesJSON = json[JsonKey.Purposes.PURPOSES] as? [Any],
            let featuresJSON = json[JsonKey.Features.FEATURES] as? [Any],
            let vendorsJSON = json[JsonKey.Vendors.VENDORS] as? [Any],
            let purposes = CMPVendorList.parsePurposes(json: purposesJSON, localizedJson: localizedPurposesJson),
            let features = CMPVendorList.parseFeatures(json: featuresJSON, localizedJson: localizedFeaturesJson),
            let vendors = CMPVendorList.parseVendors(json: vendorsJSON) else {
                
            return nil // The JSON lacks requires keys and is considered invalid
        }
        
        self.init(vendorListVersion: vendorListVersion, lastUpdated: lastUpdated, purposes: purposes, features: features, vendors: vendors)
    }
    
    /**
     Retrieve a purpose by id.
     
     - Parameter id: The id of the purpose that needs to be retrieved.
     - Returns: A purpose corresponding to the id if found, nil otherwise.
     */
    @objc
    public func purpose(forId id: Int) -> CMPPurpose? {
        return purposes.filter { $0.id == id }.first
    }
    
    /**
     Retrieve a feature by id.
     
     - Parameter id: The id of the feature that needs to be retrieved.
     - Returns: A feature corresponding to the id if found, nil otherwise.
     */
    @objc
    public func feature(forId id: Int) -> CMPFeature? {
        return features.filter { $0.id == id }.first
    }
    
    /**
     Retrieve a vendor by id.
     
     - Parameter id: The id of the vendor that needs to be retrieved.
     - Returns: A vendor corresponding to the id if found, nil otherwise.
     */
    @objc
    public func vendor(forId id: Int) -> CMPVendor? {
        return vendors.filter { $0.id == id }.first
    }
    
    /**
     Retrieve a purpose name by id.
     
     - Parameter id: The id of the purpose name that needs to be retrieved.
     - Returns: A purpose name corresponding to the id if found, nil otherwise.
     */
    @objc
    public func purposeName(forId id: Int) -> String? {
        return purpose(forId: id)?.name
    }
    
    /**
     Retrieve a feature name by id.
     
     - Parameter id: The id of the feature name that needs to be retrieved.
     - Returns: A feature name corresponding to the id if found, nil otherwise.
     */
    @objc
    public func featureName(forId id: Int) -> String? {
        return feature(forId: id)?.name
    }
    
    /**
     Retrieve a vendor name by id.
     
     - Parameter id: The id of the vendor name that needs to be retrieved.
     - Returns: A vendor name corresponding to the id if found, nil otherwise.
     */
    @objc
    public func vendorName(forId id: Int) -> String? {
        return vendor(forId: id)?.name
    }
    
    /**
     Parse a date from a json string.
     
     - Parameter string: The JSON string that needs to be parsed as a date (the date needs to be in ISO 8601 format).
     - Returns: The date if the string can be parsed, false otherwise.
     */
    private static func date(from string: String) -> Date? {
        let formatterMilliseconds = DateFormatter()
        formatterMilliseconds.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatterMilliseconds.timeZone = TimeZone(abbreviation: "UTC")
        
        let formatterSeconds = DateFormatter()
        formatterSeconds.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatterSeconds.timeZone = TimeZone(abbreviation: "UTC")
        
        return formatterMilliseconds.date(from: string) ?? formatterSeconds.date(from: string)
    }
    
    /**
     Parse a collection of purposes.
     
     - Parameters:
        - json: A collection of purposes in JSON format.
        - localizedJson: A collection of translation for the purposes, if any.
     - Returns: A collection of purposes, or nil if the JSON is invalid.
     */
    private static func parsePurposes(json: [Any], localizedJson: [Any]?) -> [CMPPurpose]? {
        let result: [CMPPurpose] = json.compactMap { jsonElement in
            switch parseJsonElement(jsonElement) {
            case .some((let id, let name, let description)):
                let (localizedName, localizedDescription) = nameAndDescription(fromLocalizedJson: localizedJson, forId: id)
                return CMPPurpose(id: id, name: localizedName ?? name, description: localizedDescription ?? description)
            default:
                return nil
            }
        }
        
        return result.count == json.count ? result : nil
    }
    
    /**
     Parse a collection of features.
     
     - Parameters:
        - json: A collection of features in JSON format.
        - localizedJson: A collection of translation for the features, if any.
     - Returns: A collection of features, or nil if the JSON is invalid.
     */
    private static func parseFeatures(json: [Any], localizedJson: [Any]?) -> [CMPFeature]? {
        let result: [CMPFeature] = json.compactMap { jsonElement in
            switch parseJsonElement(jsonElement) {
            case .some((let id, let name, let description)):
                let (localizedName, localizedDescription) = nameAndDescription(fromLocalizedJson: localizedJson, forId: id)
                return CMPFeature(id: id, name: localizedName ?? name, description: localizedDescription ?? description)
            default:
                return nil
            }
        }
        
        return result.count == json.count ? result : nil
    }
    
    /**
     Parse a JSON element corresponding to a purpose or a feature if possible.
     
     - Parameter jsonElement: The JSON element to be parsed.
     - Returns: A tuple containing the resulting parsing if successful, nil otherwise.
     */
    private static func parseJsonElement(_ jsonElement: Any) -> (Int, String, String)? {
        guard let element = jsonElement as? [String: Any],
            let id = element[JsonKey.Purposes.ID] as? Int,
            let name = element[JsonKey.Purposes.NAME] as? String,
            let description = element[JsonKey.Purposes.DESCRIPTION] as? String else {
                return nil  // The JSON lacks requires keys and is considered invalid
        }
        
        return (id, name, description)
    }
    
    /**
     Retrieve the name and the description of a localized element from the localized JSON and for a given ID.
     
     - Parameters:
        - localizedJson: An optional localized JSON of purposes or features (if nil, this method will return nil for both name & description).
        - id: The element ID that must be retrieved.
     - Returns: A tuple containing a name
     */
    private static func nameAndDescription(fromLocalizedJson localizedJson: [Any]?, forId id: Int) -> (String?, String?) {
        // Getting name & description for the first element with the right ID
        let nameAndDescription = localizedJson?.compactMap { jsonElement -> (String?, String?)? in
            if let element = jsonElement as? [String: Any], let elementId = element[JsonKey.Purposes.ID] as? Int, elementId == id {
                // Found a JSON element with the right ID: the name and the description can be extracted if possible
                return (element[JsonKey.Purposes.NAME] as? String, element[JsonKey.Purposes.DESCRIPTION] as? String)
            }
            return nil
        }.first
        
        // Returning the name & description tuple or an empty tuple if the element search failed
        return nameAndDescription ?? (nil, nil)
    }
    
    /**
     Parse a collection of vendors.
     
     - Parameter json: A collection of purposes in JSON format.
     - Returns: A collection of vendors, or nil if the JSON is invalid.
     */
    private static func parseVendors(json: [Any]) -> [CMPVendor]? {
        let result: [CMPVendor] = json.compactMap { jsonElement in
            guard let element = jsonElement as? [String: Any],
                let id = element[JsonKey.Vendors.ID] as? Int,
                let name = element[JsonKey.Vendors.NAME] as? String,
                let purposes = element[JsonKey.Vendors.PURPOSE_IDS] as? [Int],
                let legitimatePurposes = element[JsonKey.Vendors.LEGITIMATE_PURPOSE_IDS] as? [Int],
                let features = element[JsonKey.Vendors.FEATURE_IDS] as? [Int] else {
                    
                    return nil  // The JSON lacks requires keys and is considered invalid
            }
            
            let deletedDate: Date? = {
                if let deletedDateString = element[JsonKey.Vendors.DELETED_DATE] as? String  {
                    return date(from: deletedDateString)
                } else {
                    return nil
                }
            }()
            
            let policyURL: URL? = {
                if let policyURLString = element[JsonKey.Vendors.POLICY_URL] as? String,
                    let policyURL = URL(string: policyURLString),
                    let policyURLScheme = policyURL.scheme,
                    policyURLScheme.lowercased() == "http" || policyURLScheme.lowercased() == "https" {
                    
                    // A policy url is only considered as valid if it has an HTTP or HTTPS scheme
                    return policyURL
                } else {
                    return nil
                }
            }()
            
            return CMPVendor(id: id,
                             name: name,
                             purposes: purposes,
                             legitimatePurposes: legitimatePurposes,
                             features: features,
                             policyURL: policyURL,
                             deletedDate: deletedDate)
        }
        
        return result.count == json.count ? result : nil
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        if let object = object as? CMPVendorList {
            return self == object
        } else {
            return false
        }
    }
    
    public static func == (lhs: CMPVendorList, rhs: CMPVendorList) -> Bool {
        return lhs.vendorListVersion == rhs.vendorListVersion
            && lhs.lastUpdated == rhs.lastUpdated
            && lhs.purposes == rhs.purposes
            && lhs.features == rhs.features
            && lhs.vendors == rhs.vendors
    }
    
}
