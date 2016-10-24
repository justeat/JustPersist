//
//  DataStoreRequest+ObjC.swift
//  JustPersist
//
//  Created by Alberto De Bortoli on 05/10/2016.
//  Copyright © 2016 JUST EAT. All rights reserved.
//

import Foundation

public extension DataStoreRequest {
    
    var limitNumber: NSNumber? {
        get {
            if let limit = limit {
                return NSNumber(value: limit as Int)
            }
            return nil
        }
        set {
            limit = newValue?.intValue
        }
    }
    
    var offsetNumber: NSNumber? {
        get {
            if let offset = offset {
                return NSNumber(value: offset as Int)
            }
            return nil
        }
        set {
            offset = newValue?.intValue
        }
    }
    
}
