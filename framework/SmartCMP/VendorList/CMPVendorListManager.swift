//
//  CMPVendorListManager.swift
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
 Retrieves and parse a vendor list from internet.
 */
internal class CMPVendorListManager {
    
    /// Represents an error happening during vendor list refresh.
    enum RefreshError : Error {
        
        /// The vendor list refresh fails because of a network error.
        case networkError
        
        /// The vendor list refresh fails because the JSON received is invalid.
        case parsingError
        
    }
    
    /// The default polling timer interval.
    ///
    /// This timer is polling every minutes because we want to be able to retry quicly in case of
    /// issues when retrieving the vendor list.
    /// If the refresh is successful, the 'refreshInterval' will be honored by the timer.
    internal static let DEFAULT_TIMER_POLL_INTERVAL: TimeInterval = 60.0
    
    /// The URL of the vendor list.
    let vendorListURL: CMPVendorListURL
    
    /// The interval between each refresh.
    let refreshInterval: TimeInterval
    
    /// The current polling timer interval.
    let pollInterval: TimeInterval
    
    /// The delegate that should be warned when a vendor list is available or in case of errors.
    let delegate: CMPVendorListManagerDelegate
    
    /// The URL session used for network connection.
    ///
    /// This should always use the shared URL session except for unit testing.
    internal let urlSession: CMPURLSession
    
    /// A handler that will be called before any refresh.
    ///
    /// This should only be implemented by unit tests.
    internal var refreshHandler: ((Date?) -> ())?
    
    /// The polling timer.
    private var timer: Timer? = nil
    
    /// The date of the last vendor list successful refresh, or nil if no success yet.
    private var lastRefreshDate: Date? = nil
    
    /**
     Initialize a new instance of CMPVendorListManager.
     
     - Parameters:
         - url: The URL of the vendor list that will be fetched.
         - refreshInterval: The interval between each refresh.
         - delegate: The delegate that should be warned when a vendor list is available or in case of errors.
     */
    public convenience init(url: CMPVendorListURL, refreshInterval: TimeInterval, delegate: CMPVendorListManagerDelegate) {
        self.init(
            url: url,
            refreshInterval: refreshInterval,
            delegate: delegate,
            pollInterval: CMPVendorListManager.DEFAULT_TIMER_POLL_INTERVAL,
            urlSession: CMPURLSession.shared
        )
    }
    
    /**
     Initialize a new instance of CMPVendorListManager.
     
     Note: this initializer should only be used by unit tests.
     
     - Parameters:
         - url: The URL of the vendor list that will be fetched.
         - refreshInterval: The interval between each refresh.
         - delegate: The delegate that should be warned when a vendor list is available or in case of errors.
         - pollInterval: A custom polling timer interval.
         - urlSession: A custom URL session used for network connection.
     */
    public init(url: CMPVendorListURL,
                refreshInterval:TimeInterval,
                delegate: CMPVendorListManagerDelegate,
                pollInterval: TimeInterval,
                urlSession: CMPURLSession) {
        
        self.vendorListURL = url
        self.refreshInterval = refreshInterval
        self.delegate = delegate
        self.pollInterval = pollInterval
        self.urlSession = urlSession
        
    }
    
    /**
     Start the automatic refresh timer.
     
     Note: starting the refresh timer will trigger a refresh immediately no matter when the
     last refresh happen.
     */
    public func startRefreshTimer() {
        if timer == nil {
            // Refresh is called automatically when the refresh timer is started
            refresh()
            
            // Then the timer is started…
            timer = Timer.scheduledTimer(
                timeInterval: pollInterval,
                target: self,
                selector: #selector(timerFired(timer:)),
                userInfo: nil,
                repeats: true
            )
        }
    }
    
    /**
     Stop the automatic refresh timer.
     */
    public func stopRefreshTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    /**
     Called when the polling timer is fired.
     
     - Parameter timer: The timer that has been fired.
     */
    @objc func timerFired(timer: Timer) {
        switch lastRefreshDate {
        case .some(let date) where Date().timeIntervalSince1970 - date.timeIntervalSince1970 > refreshInterval:
            refresh()
        default:
            break
        }
    }
    
    /**
     Refresh the vendor list from network.
     */
    public func refresh() {
        refresh(vendorListURL: vendorListURL)
    }
    
    /**
     Refresh the vendor list from network.
     
     - Parameter vendorListURL: The url of the vendor list that must be fetched.
     */
    public func refresh(vendorListURL: CMPVendorListURL) {
        refreshHandler?(lastRefreshDate) // calling handler when refreshing for unit testing purposes only
        
        urlSession.dataRequest(url: vendorListURL.url) { (data, response, error) in
            if let data = data, error == nil {
                if let vendorList = CMPVendorList(jsonData: data) {
                    self.lastRefreshDate = Date()
                    
                    // Fetching successful
                    self.delegate.vendorListManager(self, didFetchVendorList: vendorList)
                } else {
                    // Parsing error
                    self.delegate.vendorListManager(self, didFailWithError: RefreshError.parsingError)
                }
            } else {
                // Network error
                self.delegate.vendorListManager(self, didFailWithError: RefreshError.networkError)
            }
        }
    }
    
}
