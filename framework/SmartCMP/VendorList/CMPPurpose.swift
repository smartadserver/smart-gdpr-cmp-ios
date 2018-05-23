//
//  CMPPurpose.swift
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
 Representation of a purpose.
 */
@objc
public class CMPPurpose: NSObject, Codable {
    
    /// The id of the purpose.
    @objc
    public let id: Int
    
    /// The name of the purpose.
    @objc
    public let name: String
    
    /// The description of the purpose.
    @objc
    public let purposeDescription: String
    
    /**
     Initialize a new instance of CMPPurpose.
     
     - Parameters:
        - id: The id of the purpose.
        - name: The name of the purpose.
        - description: The description of the purpose.
     */
    @objc
    public init(id: Int, name: String, description: String) {
        self.id = id
        self.name = name
        self.purposeDescription = description
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        if let object = object as? CMPPurpose {
            return self == object
        } else {
            return false
        }
    }
    
    public static func == (lhs: CMPPurpose, rhs: CMPPurpose) -> Bool {
        return lhs.id == rhs.id
            && lhs.name == rhs.name
            && lhs.purposeDescription == rhs.purposeDescription
    }
    
}
