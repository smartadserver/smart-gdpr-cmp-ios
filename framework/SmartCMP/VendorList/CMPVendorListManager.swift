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
    /// This timer is polling every minutes because we want to be able to retry quickly in case of
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
     
     Note: a successful refresh will update the last refresh date, preventing the auto refresh to happen for some times,
     a failed refresh will invalidate the last refresh date: an auto refresh will be triggered at the next timer fired
     event.
     
     - Parameters
        - vendorListURL: The url of the vendor list that must be fetched.
        - responseHandler: Optional callback that will be used INSTEAD of the delegate if provided.
     */
    public func refresh(vendorListURL: CMPVendorListURL, responseHandler: ((CMPVendorList?, Error?) -> ())? = nil) {
        refreshHandler?(lastRefreshDate) // calling handler when refreshing for unit testing purposes only
        
        fetchVendorList(vendorListURL: vendorListURL) { (vendorListData, vendorListError, localizedVendorListData, localizedVendorListError) in
            if let vendorListData = vendorListData, vendorListError == nil {
                if let vendorList = CMPVendorList(jsonData: vendorListData, localizedJsonData: localizedVendorListData) {
                    self.lastRefreshDate = Date()
                    
                    // Fetching successful
                    self.callRefreshCallback(vendorList: vendorList, error: nil, responseHandler: responseHandler)
                } else {
                    self.lastRefreshDate = nil
                    
                    // Parsing error
                    self.callRefreshCallback(vendorList: nil, error: RefreshError.parsingError, responseHandler: responseHandler)
                }
            } else {
                self.lastRefreshDate = nil
                
                // Network error
                self.callRefreshCallback(vendorList: nil, error: RefreshError.networkError, responseHandler: responseHandler)
            }
        }
    }
    
    /**
     Fetch a vendor list and its localized version if it exists in parallel.
     
     - Parameters:
        - vendorListURL: The vendor list URL.
        - responseHandler: The callback called when the vendor list retrieval is finished. The first two parameters corresponds to
     the main vendor list, the last two corresponds to the localized vendor list if it exists (if not, both Data & Error will be nil).
     */
    private func fetchVendorList(vendorListURL: CMPVendorListURL, responseHandler: @escaping (Data?, Error?, Data?, Error?) -> ()) {
        let dispatchGroup = DispatchGroup()
        
        // Requesting for main vendor list JSON
        var vendorListData: Data? = nil
        var vendorListError: Error? = nil
        fetchVendorList(withDispatchGroup: dispatchGroup, url: vendorListURL.url) { (data, error) in
            vendorListData = data
            vendorListError = error
        }
        
        // Requesting for localized vendor list JSON if necessary
        var localizedVendorListData: Data? = nil
        var localizedVendorListError: Error? = nil
        if let localizedURL = vendorListURL.localizedUrl {
            fetchVendorList(withDispatchGroup: dispatchGroup, url: localizedURL) { (data, error) in
                localizedVendorListData = data
                localizedVendorListError = error
            }
        }
        
        // Waiting for both requests to complete
        dispatchGroup.notify(queue: .main) {
            responseHandler(vendorListData, vendorListError, localizedVendorListData, localizedVendorListError)
        }
    }
    
    /**
     Fetch a vendor list from a raw URL using a dispatch group for synchronization.
     
     - Parameters:
        - dispatchGroup: The dispatch group that is going to be locked during the request.
        - url: The raw URL that need to be fetched
        - responseHandler: The callback that will be called when the request finished.
     */
    private func fetchVendorList(withDispatchGroup dispatchGroup: DispatchGroup, url: URL, responseHandler: @escaping (Data?, Error?) -> ()) {
        dispatchGroup.enter()
        urlSession.dataRequest(url: url) { (data, response, error) in
            responseHandler(data, error)
            dispatchGroup.leave()
        }
    }
    
    /**
     Call the relevant CMPVendorListManager delegate or callback.
     
     Called after a refresh attempt, this method will call a callback if provided when refresh() was invoked, otherwise
     the standard delegate will be called.
     
     - Parameters:
        - vendorList: An optional vendor list.
        - error: An optional error.
        - responseHandler: An optional response handler.
     */
    private func callRefreshCallback(vendorList: CMPVendorList?, error: Error?, responseHandler: ((CMPVendorList?, Error?) -> ())?) {
        if let handler = responseHandler {
            handler(vendorList, error)
        } else {
            if let vendorList = vendorList {
                self.delegate.vendorListManager(self, didFetchVendorList: vendorList)
            } else if let error = error {
                self.delegate.vendorListManager(self, didFailWithError: error)
            }
        }
    }
    
}
