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
internal extension CMPConsentString {
    
    /**
     Return a new consent string with no consent given for any purposes & vendors.
     
     - Parameters:
        - consentScreen: The screen number in the CMP where the consent was given.
        - consentLanguage: The language that the CMP asked for consent in.
        - vendorList: The vendor list corresponding to the consent string.
        - date: The date that will be used as creation date & last updated date (optional, it will use the current date by default).
     - Returns: A new consent string with no consent given.
     */
    static func consentStringWithNoConsent(consentScreen: Int,
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
    static func consentStringWithFullConsent(consentScreen: Int,
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
        - lastUpdated: The date that will be used as last updated date (optional, it will use the current date by default).
     - Returns: The new consent string.
     */
    static func consentString(fromUpdatedVendorList updatedVendorList: CMPVendorList,
                              previousVendorList: CMPVendorList,
                              previousConsentString: CMPConsentString,
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
            cmpId: previousConsentString.cmpId,
            cmpVersion: previousConsentString.cmpVersion,
            consentScreen: previousConsentString.consentScreen,
            consentLanguage: previousConsentString.consentLanguage,
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
        - lastUpdated: The date that will be used as last updated date (optional, it will use the current date by default).
     - Returns: A new consent string with a consent given for a particular purpose.
     */
    static func consentStringByAddingConsent(forPurposeId purposeId: Int,
                                             consentString: CMPConsentString,
                                             lastUpdated: Date = Date()) -> CMPConsentString {
        
        let updatedAllowedPurposes = !consentString.allowedPurposes.contains(purposeId) ?
            IndexSet(consentString.allowedPurposes + [purposeId]) : consentString.allowedPurposes
        
        return CMPConsentString(
            versionConfig: CMPVersionConfig.LATEST,
            created: consentString.created,
            lastUpdated: lastUpdated,
            cmpId: consentString.cmpId,
            cmpVersion: consentString.cmpVersion,
            consentScreen: consentString.consentScreen,
            consentLanguage: consentString.consentLanguage,
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
        - lastUpdated: The date that will be used as last updated date (optional, it will use the current date by default).
     - Returns: A new consent string with a consent removed for a particular purpose.
     */
    static func consentStringByRemovingConsent(forPurposeId purposeId: Int,
                                             consentString: CMPConsentString,
                                             lastUpdated: Date = Date()) -> CMPConsentString {
        
        let updatedAllowedPurposes = consentString.allowedPurposes.filteredIndexSet(includeInteger: { $0 != purposeId })
        
        return CMPConsentString(
            versionConfig: CMPVersionConfig.LATEST,
            created: consentString.created,
            lastUpdated: lastUpdated,
            cmpId: consentString.cmpId,
            cmpVersion: consentString.cmpVersion,
            consentScreen: consentString.consentScreen,
            consentLanguage: consentString.consentLanguage,
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
        - lastUpdated: The date that will be used as last updated date (optional, it will use the current date by default).
     - Returns: A new consent string with a consent given for a particular vendor.
     */
    static func consentStringByAddingConsent(forVendorId vendorId: Int,
                                             consentString: CMPConsentString,
                                             lastUpdated: Date = Date()) -> CMPConsentString {
        
        let updatedAllowedVendors = !consentString.allowedVendors.contains(vendorId) ?
            IndexSet(consentString.allowedVendors + [vendorId]) : consentString.allowedVendors
        
        return CMPConsentString(
            versionConfig: CMPVersionConfig.LATEST,
            created: consentString.created,
            lastUpdated: lastUpdated,
            cmpId: consentString.cmpId,
            cmpVersion: consentString.cmpVersion,
            consentScreen: consentString.consentScreen,
            consentLanguage: consentString.consentLanguage,
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
        - lastUpdated: The date that will be used as last updated date (optional, it will use the current date by default).
     - Returns: A new consent string with a consent removed for a particular vendor.
     */
    static func consentStringByRemovingConsent(forVendorId vendorId: Int,
                                               consentString: CMPConsentString,
                                               lastUpdated: Date = Date()) -> CMPConsentString {
        
        let updatedAllowedVendors = consentString.allowedVendors.filteredIndexSet(includeInteger: { $0 != vendorId })
        
        return CMPConsentString(
            versionConfig: CMPVersionConfig.LATEST,
            created: consentString.created,
            lastUpdated: lastUpdated,
            cmpId: consentString.cmpId,
            cmpVersion: consentString.cmpVersion,
            consentScreen: consentString.consentScreen,
            consentLanguage: consentString.consentLanguage,
            vendorListVersion: consentString.vendorListVersion,
            maxVendorId: consentString.maxVendorId,
            allowedPurposes: consentString.allowedPurposes,
            allowedVendors: updatedAllowedVendors
        )
    }
    
}
