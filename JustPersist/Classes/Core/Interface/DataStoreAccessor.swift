//
//  DataStoreAccessor.swift
//  JustPersist
//
//  Created by Keith Moon on 29/07/2016.
//  Copyright © 2016 JUST EAT. All rights reserved.
//

import Foundation

@objc(JEDataStoreAccessor)
public protocol DataStoreAccessor: class {
    
}

@objc(JEDataStoreReadAccessor)
public protocol DataStoreReadAccessor: DataStoreAccessor {
    
    /**
     Items in the data store for a given request
     
     - parameter request: The request to retrieve items with
     
     - returns: Matching items
     */
    func items(forRequest request: DataStoreRequest) -> [DataStoreItem]
    
    /**
     The first item in the data store for a given request
     
     - parameter request: The request to retrieve items with
     
     - returns: First matching item
     */
    func firstItem(forRequest request: DataStoreRequest) -> DataStoreItem?
    
    /**
     Count of the number of items of the given request
     
     - parameter request: The request to use to count items
     
     - returns: Number of items in the data store for the given type
     */
    func countItems(forRequest request: DataStoreRequest) -> Int
    
}

@objc(JEDataStoreReadWriteAccessor)
public protocol DataStoreReadWriteAccessor: DataStoreReadAccessor {
    
    /**
     Mutable items in the data store for a given request
     
     - parameter request: The request to retrieve items with
     
     - returns: Matching mutable items
     */
    func mutableItems(forRequest request: DataStoreRequest) -> [MutableDataStoreItem]
    
    /**
     The first mutable item in the data store for a given request
     
     - parameter request: The request to retrieve items with
     
     - returns: First matching mutable item
     */
    func firstMutableItem(forRequest request: DataStoreRequest) -> MutableDataStoreItem?
    
    // MARK: Creation and Deletion of Items
    
    /**
     Create item of the given mutable type in the data store
     
     - parameter itemType: The mutable item type of the item to create
     
     - returns: The created item
     */
    func createItem(ofMutableType itemType: MutableDataStoreItem.Type) -> MutableDataStoreItem?
    
    /**
     Insert an item into the data store
     
     - parameter item: Item to insert into the data store
     
     - returns: Returns true is successfully inserted, false if there was an issue
     */
    @discardableResult
    func insert(_ item: MutableDataStoreItem) -> Bool
    
    /**
     Delete the given item in the data store
     
     - parameter item: The item to delete
     
     - returns: Returns true is successfully deleted, false if there was an issue
     */
    @discardableResult
    func delete(item: MutableDataStoreItem) -> Bool
    
    /**
     Delete all items of the given mutable type in the data store
     
     - parameter itemType: The mutable type for which all items should be deleted
     
     - returns: Returns true is successfully all items were successfully deleted, false if there was an issue
     */
    @discardableResult
    func deleteAllItems(ofMutableType itemType: MutableDataStoreItem.Type) -> Bool
    
    // MARK: Mutable Version of Immutable Item
    
    /**
     Access the mutable version of a given item
     
     - discussion: If you have an item access from a different accessor, this lets you retrieve a mutable version of that item that is save to use with this accessor.
     
     - parameter item: Item of which the mutable version is required
     
     - returns: Mutable version of the given item
     */
    func mutableVersion(ofItem item: DataStoreItem) -> MutableDataStoreItem?
    
}
