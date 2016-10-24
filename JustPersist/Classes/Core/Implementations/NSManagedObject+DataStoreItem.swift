//
//  NSManagedObject+DataStoreItem.swift
//  JustPersist
//
//  Created by Keith Moon on 27/07/2016.
//  Copyright © 2016 JUST EAT. All rights reserved.
//

import CoreData

extension NSManagedObject: MutableDataStoreItem {
    
    // In the case of a Core Data implementation, we want itemTypeKey to be the entityName.
    // We can make the assumption that the class name is the same as the entityName.
    // Alternatively we could generate the this in a Mogenerator template and be explicit about
    // it being the entity name.
    public static var itemTypeKey: String {
        return String(describing: self)
    }
    
    public var uniqueToken: AnyObject {
        return objectID
    }
}
