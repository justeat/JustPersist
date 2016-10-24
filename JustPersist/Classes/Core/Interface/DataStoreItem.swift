//
//  DataStoreItem.swift
//  JustPersist
//
//  Created by Keith Moon on 29/07/2016.
//  Copyright © 2016 JUST EAT. All rights reserved.
//

@objc(JEDataStoreItem)
public protocol DataStoreItem {
    
    /// Key used by the dataStore to identify items of this type
    static var itemTypeKey: String { get }
    
    /// Something that can be used to uniquely identify this item in the data store
    var uniqueToken: AnyObject { get }
    
    /**
     Way to access the item's properties
     
     - parameter key: The key for the property required
     
     - returns: The value for the given key
     */
    func value(forKeyPath keyPath: String) -> Any?
}

@objc(JEMutableDataStoreItem)
public protocol MutableDataStoreItem: DataStoreItem {
    
    /**
     Way to change the item's properties
     
     - parameter value: The new value to set
     - parameter key:   The key of the property to change
     */
    func setValue(_ value: Any?, forKeyPath keyPath: String)
}
