//
//  CMPConsentManagerStateProvider.swift
//  SmartCMP
//
//  Created by Loïc GIRON DIT METAZ on 18/06/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

import Foundation

/**
 Protocol that must be implemented by objects offering a persistent state.
 */
internal protocol CMPConsentManagerStateProvider {
    
    /**
     Save a string in the state provider.
     
     - Parameters:
        - string: The string that needs to be saved.
        - key: The key where the string will be saved.
     */
    func saveString(string: String, key: String)
    
    /**
     Read a string from the state provider.
     
     - Parameters key: The key from where the string will be read.
     - Returns: The string read if any, nil otherwise.
     */
    func readString(key: String) -> String?
    
}
