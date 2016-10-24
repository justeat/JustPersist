//
//  DataStoreAccessor+Generics.swift
//  JustPersist
//
//  Created by Keith Moon on 26/07/2016.
//  Copyright © 2016 JUST EAT. All rights reserved.
//

import Foundation

// MARK: - Enums

/**
 Possible errors from Swiftified Data Store interface
 
 - couldNotCreateItemOfType:    Could not create the item: Type provided
 - couldNotDeleteItem:          Could not delete the item: Item provided
 - couldNotDeleteItemsOfType:   Could not delete all items of given type: Type provided
 - couldNotFetchMutableVersion: Could not fetch mutable version of given item: Original item provided
 */
public enum DataStoreError: Error {
    case couldNotCreateItemOfType(DataStoreItem.Type)
    case couldNotDeleteItem(DataStoreItem)
    case couldNotDeleteItemsOfType(DataStoreItem.Type)
    case couldNotFetchMutableVersion(DataStoreItem)
}

// MARK: - Convenience Generics Interfaces

extension DataStoreReadAccessor {
    
    /**
     Items in the data store for a given request
     
     - parameter request: The request to retrieve items with
     
     - returns: Matching items
     */
    public func items<ItemType: DataStoreItem>(forRequest request: DataStoreRequest) -> [ItemType] {
        return items(forRequest: request) as? [ItemType] ?? []
    }
    
    /**
     The first item in the data store for a given request
     
     - parameter request: The request to retrieve items with
     
     - returns: First matching item
     */
    public func firstItem<ItemType: DataStoreItem>(forRequest request: DataStoreRequest) -> ItemType? {
        guard let item = firstItem(forRequest: request) else {
            return nil
        }
        return item as? ItemType
    }
}

extension DataStoreReadWriteAccessor {
    
    /**
     Mutable items in the data store for a given request
     
     - parameter request: The request to retrieve items with
     
     - returns: Matching mutable items
     */
    public func items<ItemType: MutableDataStoreItem>(forRequest request: DataStoreRequest) -> [ItemType] {
        return items(forRequest: request) as? [ItemType] ?? []
    }
    
    /**
     The first mutable item in the data store for a given request
     
     - parameter request: The request to retrieve items with
     
     - returns: First matching mutable item
     */
    public func firstItem<ItemType: MutableDataStoreItem>(forRequest request: DataStoreRequest) -> ItemType? {
        guard let item = firstItem(forRequest: request) else {
            return nil
        }
        return item as? ItemType
    }
    
    /**
     Create item in the data store of the mutable type determined by the generics constraint
     
     - throws: DataStoreError.couldNotCreateItemOfType if the item could not be created
     
     - returns: The created item
     */
    public func create<ItemType: MutableDataStoreItem>() throws -> ItemType {
        guard let item = createItem(ofMutableType: ItemType.self) as? ItemType else {
            throw DataStoreError.couldNotCreateItemOfType(ItemType)
        }
        return item
    }
    
    /**
     Delete the given item in the data store
     
     - parameter item: The item to delete
     
     - throws: DataStoreError.couldNotDeleteItem if the item could not be deleted
     */
    public func delete(_ item: MutableDataStoreItem) throws {
        if !delete(item: item) {
            throw DataStoreError.couldNotDeleteItem(item)
        }
    }
    
    /**
     Delete all items of the given mutable type in the data store
     
     - parameter itemType: The mutable type for which all items should be deleted
     
     - throws: DataStoreError.couldNotDeleteItemsOfType if the items could not be deleted
     */
    public func deleteAll(_ itemType: MutableDataStoreItem.Type) throws {
        if !deleteAllItems(ofMutableType: itemType.self) {
            throw DataStoreError.couldNotDeleteItemsOfType(itemType)
        }
    }
    
    /**
     Access the mutable version of a given item, where the immutable and mutable types are determined by the generics constraints
     
     - parameter item: Item of which the mutable version is required
     
     - throws: DataStoreError.couldNotFetchMutableVersion is the mutable version could not be retrieved
     
     - returns: Mutable version of the given item
     */
    public func mutableVersion<ItemType: DataStoreItem, MutableItemType: MutableDataStoreItem>(ofItem item: ItemType) throws -> MutableItemType {
        guard let mutableVersion = mutableVersion(ofItem: item) as? MutableItemType else {
            throw DataStoreError.couldNotFetchMutableVersion(item)
        }
        return mutableVersion
    }
}

extension DataStoreItem {
    
    public func get<PropertyType: AnyObject>(forKey key: String) -> PropertyType? {
        return value(forKeyPath: key) as? PropertyType
    }
}

extension MutableDataStoreItem {
    
    public func set<PropertyType: AnyObject>(_ value: PropertyType, forKey key: String) {
        setValue(value, forKeyPath: key)
    }
}
