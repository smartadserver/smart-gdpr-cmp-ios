//
//  CMPConsentString+Utils.swift
//  SmartCMP
//
//  Created by Loïc GIRON DIT METAZ on 26/04/2018.
//  Copyright © 2018 Smart AdServer.
//
//  This software is distributed under the Creative Commons Legal Code, Attribution 3.0 Unported license.
//  Check the LICENSE file for more information.
//

import Foundation

/**
 Utils consent string extension that contains static methods used to initialize new consent
 strings more easily.
 */
@objc
public extension CMPConsentString {
    
    /**
     Return a new consent string with no consent given for any purposes & vendors.
     
     - Parameters:
        - consentScreen: The screen number in the CMP where the consent was given.
        - consentLanguage: The language that the CMP asked for consent in.
        - vendorList: The vendor list corresponding to the consent string.
        - date: The date that will be used as creation date & last updated date (optional, it will use the current date by default).
     - Returns: A new consent string with no consent given.
     */
    @objc
    public static func consentStringWithNoConsent(consentScreen: Int,
                                                  consentLanguage: CMPLanguage,
                                                  vendorList: CMPVendorList,
                                                  date: Date = Date()) -> CMPConsentString {
        
        return CMPConsentString(
            versionConfig: CMPVersionConfig.LATEST,
            created: date,
            lastUpdated: date,
            cmpId: CMPConstants.CMPInfos.ID,
            cmpVersion: CMPConstants.CMPInfos.VERSION,
            consentScreen: consentScreen,
            consentLanguage: consentLanguage,
            allowedPurposes: [],
            allowedVendors: [],
            vendorList: vendorList
        )
        
    }
    
    /**
     Return a new consent string with every consent given for every purposes & vendors.
     
     - Parameters:
        - consentScreen: The screen number in the CMP where the consent was given.
        - consentLanguage: The language that the CMP asked for consent in.
        - vendorList: The vendor list corresponding to the consent string.
        - date: The date that will be used as creation date & last updated date (optional, it will use the current date by default).
     - Returns: A new consent string with every consent given.
     */
    @objc
    public static func consentStringWithFullConsent(consentScreen: Int,
                                                    consentLanguage: CMPLanguage,
                                                    vendorList: CMPVendorList,
                                                    date: Date = Date()) -> CMPConsentString {
        
        return CMPConsentString(
            versionConfig: CMPVersionConfig.LATEST,
            created: date,
            lastUpdated: date,
            cmpId: CMPConstants.CMPInfos.ID,
            cmpVersion: CMPConstants.CMPInfos.VERSION,
            consentScreen: consentScreen,
            consentLanguage: consentLanguage,
            allowedPurposes: IndexSet(vendorList.purposes.map({ $0.id })),
            allowedVendors: IndexSet(vendorList.vendors.map({ $0.id })),
            vendorList: vendorList
        )
        
    }
    
    /**
     Return a new consent string which keeps info from a previous one (generated with a previous vendor list)
     but give consent one new items (purposes & vendors).
     
     - Parameters:
        - updatedVendorList: The updated vendor list.
        - previousVendorList: The previous consent string that has been used to generated the previous consent string.
        - previousConsentString: The previous consent string.
        - consentLanguage: The language that the CMP asked for consent in.
        - lastUpdated: The date that will be used as last updated date (optional, it will use the current date by default).
     - Returns: The new consent string.
     */
    @objc
    public static func consentString(fromUpdatedVendorList updatedVendorList: CMPVendorList,
                                     previousVendorList: CMPVendorList,
                                     previousConsentString: CMPConsentString,
                                     consentLanguage: CMPLanguage,
                                     lastUpdated: Date = Date()) -> CMPConsentString {
        
        let updatedAllowedPurposes = IndexSet((1...updatedVendorList.purposes.count).compactMap { index in
            if index <= previousVendorList.purposes.count {
                return previousConsentString.allowedPurposes.contains(index) ? index : nil
            } else {
                return index
            }
        })
        
        let updatedAllowedVendors = IndexSet((1...updatedVendorList.maxVendorId).compactMap { index in
            if index <= previousVendorList.maxVendorId {
                return previousConsentString.allowedVendors.contains(index) ? index : nil
            } else {
                return index
            }
        })
        
        return CMPConsentString(
            versionConfig: CMPVersionConfig.LATEST,
            created: previousConsentString.created,
            lastUpdated: lastUpdated,
            cmpId: CMPConstants.CMPInfos.ID,
            cmpVersion: CMPConstants.CMPInfos.VERSION,
            consentScreen: previousConsentString.consentScreen,
            consentLanguage: consentLanguage,
            allowedPurposes: updatedAllowedPurposes,
            allowedVendors: updatedAllowedVendors,
            vendorList: updatedVendorList
        )
    }
    
    /**
     Return a new consent string identical to the one provided in parameters, with a consent given for a particular purpose.
     
     Note: this method will update the version config and the last updated date.
     
     - Parameters:
        - purposeId: The purpose id which should be added to the consent list.
        - consentString: The consent string which should be copied.
        - consentLanguage: The language that the CMP asked for consent in.
        - lastUpdated: The date that will be used as last updated date (optional, it will use the current date by default).
     - Returns: A new consent string with a consent given for a particular purpose.
     */
    @objc
    public static func consentStringByAddingConsent(forPurposeId purposeId: Int,
                                                    consentString: CMPConsentString,
                                                    consentLanguage: CMPLanguage,
                                                    lastUpdated: Date = Date()) -> CMPConsentString {
        
        let updatedAllowedPurposes = !consentString.allowedPurposes.contains(purposeId) ?
            IndexSet(consentString.allowedPurposes + [purposeId]) : consentString.allowedPurposes
        
        return CMPConsentString(
            versionConfig: CMPVersionConfig.LATEST,
            created: consentString.created,
            lastUpdated: lastUpdated,
            cmpId: CMPConstants.CMPInfos.ID,
            cmpVersion: CMPConstants.CMPInfos.VERSION,
            consentScreen: consentString.consentScreen,
            consentLanguage: consentLanguage,
            vendorListVersion: consentString.vendorListVersion,
            maxVendorId: consentString.maxVendorId,
            allowedPurposes: updatedAllowedPurposes,
            allowedVendors: consentString.allowedVendors
        )
    }
    
    /**
     Return a new consent string identical to the one provided in parameters, with a consent removed for a particular purpose.
     
     Note: this method will update the version config and the last updated date.
     
     - Parameters:
        - purposeId: The purpose id which should be removed from the consent list.
        - consentString: The consent string which should be copied.
        - consentLanguage: The language that the CMP asked for consent in.
        - lastUpdated: The date that will be used as last updated date (optional, it will use the current date by default).
     - Returns: A new consent string with a consent removed for a particular purpose.
     */
    @objc
    public static func consentStringByRemovingConsent(forPurposeId purposeId: Int,
                                                      consentString: CMPConsentString,
                                                      consentLanguage: CMPLanguage,
                                                      lastUpdated: Date = Date()) -> CMPConsentString {
        
        let updatedAllowedPurposes = consentString.allowedPurposes.filteredIndexSet(includeInteger: { $0 != purposeId })
        
        return CMPConsentString(
            versionConfig: CMPVersionConfig.LATEST,
            created: consentString.created,
            lastUpdated: lastUpdated,
            cmpId: CMPConstants.CMPInfos.ID,
            cmpVersion: CMPConstants.CMPInfos.VERSION,
            consentScreen: consentString.consentScreen,
            consentLanguage: consentLanguage,
            vendorListVersion: consentString.vendorListVersion,
            maxVendorId: consentString.maxVendorId,
            allowedPurposes: updatedAllowedPurposes,
            allowedVendors: consentString.allowedVendors
        )
    }
    
    /**
     Return a new consent string identical to the one provided in parameters, with a consent given for a particular vendor.
     
     Note: this method will update the version config and the last updated date.
     
     - Parameters:
        - vendorId: The vendor id which should be added to the consent list.
        - consentString: The consent string which should be copied.
        - consentLanguage: The language that the CMP asked for consent in.
        - lastUpdated: The date that will be used as last updated date (optional, it will use the current date by default).
     - Returns: A new consent string with a consent given for a particular vendor.
     */
    @objc
    public static func consentStringByAddingConsent(forVendorId vendorId: Int,
                                                    consentString: CMPConsentString,
                                                    consentLanguage: CMPLanguage,
                                                    lastUpdated: Date = Date()) -> CMPConsentString {
        
        let updatedAllowedVendors = !consentString.allowedVendors.contains(vendorId) ?
            IndexSet(consentString.allowedVendors + [vendorId]) : consentString.allowedVendors
        
        return CMPConsentString(
            versionConfig: CMPVersionConfig.LATEST,
            created: consentString.created,
            lastUpdated: lastUpdated,
            cmpId: CMPConstants.CMPInfos.ID,
            cmpVersion: CMPConstants.CMPInfos.VERSION,
            consentScreen: consentString.consentScreen,
            consentLanguage: consentLanguage,
            vendorListVersion: consentString.vendorListVersion,
            maxVendorId: consentString.maxVendorId,
            allowedPurposes: consentString.allowedPurposes,
            allowedVendors: updatedAllowedVendors
        )
    }
    
    /**
     Return a new consent string identical to the one provided in parameters, with a consent removed for a particular vendor.
     
     Note: this method will update the version config and the last updated date.
     
     - Parameters:
        - vendorId: The vendor id which should be removed from the consent list.
        - consentString: The consent string which should be copied.
        - consentLanguage: The language that the CMP asked for consent in.
        - lastUpdated: The date that will be used as last updated date (optional, it will use the current date by default).
     - Returns: A new consent string with a consent removed for a particular vendor.
     */
    @objc
    public static func consentStringByRemovingConsent(forVendorId vendorId: Int,
                                                      consentString: CMPConsentString,
                                                      consentLanguage: CMPLanguage,
                                                      lastUpdated: Date = Date()) -> CMPConsentString {
        
        let updatedAllowedVendors = consentString.allowedVendors.filteredIndexSet(includeInteger: { $0 != vendorId })
        
        return CMPConsentString(
            versionConfig: CMPVersionConfig.LATEST,
            created: consentString.created,
            lastUpdated: lastUpdated,
            cmpId: CMPConstants.CMPInfos.ID,
            cmpVersion: CMPConstants.CMPInfos.VERSION,
            consentScreen: consentString.consentScreen,
            consentLanguage: consentLanguage,
            vendorListVersion: consentString.vendorListVersion,
            maxVendorId: consentString.maxVendorId,
            allowedPurposes: consentString.allowedPurposes,
            allowedVendors: updatedAllowedVendors
        )
    }
    
    /**
     Return a new consent string identical to the one provided in parameters, with all purposes disallowed.
     
     Note: the vendor list provided must match the one used to generate the previous consent string, otherwise
     this method will return nil.
     
     - Parameters:
        - previousConsentString: The previous consent string.
        - consentScreen: The screen number in the CMP where the consent was given.
        - consentLanguage: The language that the CMP asked for consent in.
        - vendorList: The vendor list corresponding to the consent string.
        - lastUpdated: The date that will be used as last updated date (optional, it will use the current date by default).
     - Returns: A new consent string identical to the one provided in parameters with all purposes disallowed if possible, nil otherwise.
     */
    @objc
    public static func consentStringWithNoPurposesConsent(fromConsentString previousConsentString: CMPConsentString,
                                                          consentScreen: Int,
                                                          consentLanguage: CMPLanguage,
                                                          vendorList: CMPVendorList,
                                                          lastUpdated: Date = Date()) -> CMPConsentString? {
        
        guard previousConsentString.vendorListVersion == vendorList.vendorListVersion else {
            return nil
        }
        
        return CMPConsentString(
            versionConfig: CMPVersionConfig.LATEST,
            created: previousConsentString.created,
            lastUpdated: lastUpdated,
            cmpId: CMPConstants.CMPInfos.ID,
            cmpVersion: CMPConstants.CMPInfos.VERSION,
            consentScreen: consentScreen,
            consentLanguage: consentLanguage,
            allowedPurposes: [], // No purpose allowed
            allowedVendors: previousConsentString.allowedVendors,
            vendorList: vendorList
        )
    }
    
    /**
     Return a new consent string identical to the one provided in parameters, with all purposes allowed.
     
     Note: the vendor list provided must match the one used to generate the previous consent string, otherwise
     this method will return nil.
     
     - Parameters:
        - previousConsentString: The previous consent string.
        - consentScreen: The screen number in the CMP where the consent was given.
        - consentLanguage: The language that the CMP asked for consent in.
        - vendorList: The vendor list corresponding to the consent string.
        - lastUpdated: The date that will be used as last updated date (optional, it will use the current date by default).
     - Returns: A new consent string identical to the one provided in parameters with all purposes allowed if possible, nil otherwise.
     */
    @objc
    public static func consentStringWithAllPurposesConsent(fromConsentString previousConsentString: CMPConsentString,
                                                           consentScreen: Int,
                                                           consentLanguage: CMPLanguage,
                                                           vendorList: CMPVendorList,
                                                           lastUpdated: Date = Date()) -> CMPConsentString? {
        
        guard previousConsentString.vendorListVersion == vendorList.vendorListVersion else {
            return nil
        }
        
        let allowedPurposes = IndexSet(vendorList.purposes.map { $0.id })
        
        return CMPConsentString(
            versionConfig: CMPVersionConfig.LATEST,
            created: previousConsentString.created,
            lastUpdated: lastUpdated,
            cmpId: CMPConstants.CMPInfos.ID,
            cmpVersion: CMPConstants.CMPInfos.VERSION,
            consentScreen: consentScreen,
            consentLanguage: consentLanguage,
            allowedPurposes: allowedPurposes,
            allowedVendors: previousConsentString.allowedVendors,
            vendorList: vendorList
        )
    }
    
}
