//
//  CMPFeature.swift
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
 Representation of a feature.
 */
public class CMPFeature : Equatable, Codable {
    
    /// The id of the feature.
    public let id: Int
    
    /// The name of the feature.
    public let name: String
    
    /// The description of the feature.
    public let description: String
    
    /**
     Initialize a new instance of CMPFeature.
     
     - Parameters:
        - id: The id of the feature.
        - name: The name of the feature.
        - description: The description of the feature.
     */
    public init(id: Int, name: String, description: String) {
        self.id = id
        self.name = name
        self.description = description
    }
    
    public static func == (lhs: CMPFeature, rhs: CMPFeature) -> Bool {
        return lhs.id == rhs.id
            && lhs.name == rhs.name
            && lhs.description == rhs.description
    }
    
}
