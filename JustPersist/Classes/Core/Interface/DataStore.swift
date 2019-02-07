//
//  DataStore.swift
//  JustPersist
//
//  Created by Keith Moon on 25/07/2016.
//  Copyright © 2016 JUST EAT. All rights reserved.
//

import Foundation

public typealias DataStoreErrorHandler = (NSError) -> Void

@objc
public protocol DataStore: class {
    
    var errorHandler: DataStoreErrorHandler? { get set }
    
    // MARK: Lifecyle
    
    /**
     Should be called before the data store is used to allow it set up. Implementations should use this method to initialise their storage mechanism.
     */
    func setup()
    
    /**
     Tear down the data store setup. Will require a call to setup() before being used again.
     */
    func tearDown()
    
    // MARK: Accessing Data
    
    /**
     Read from the data store
     
     - parameter readBlock: Block that contains the work that will be done. The block will be passed a ```DataStoreReadAccessor``` which can be used to access information in the data store. It can be assumed that it is safe to perform UI work within this block. 
     */
    func read(_ readBlock: @escaping (DataStoreReadAccessor) -> Void)
    
    /**
     Write to the data store syncronously
     
     - parameter writeBlock: Block that contains the work that will be done. The block will be passed a ```DataStoreReadWriteAccessor``` which can be used to access information in the data store that can then be modified. Once this block has finished running, the accessor will ensure that any changes that took place within the block will be persisted. This call will block the calling thread until the save is completed. It is **not** safe to perform UI work within this block.
     */
    func writeSync(_ writeBlock: @escaping (DataStoreReadWriteAccessor) -> Void)
    
    /**
     Write to the data store asyncronously
     
     - parameter writeBlock: Block that contains the work that will be done. The block will be passed a ```DataStoreReadWriteAccessor``` which can be used to access information in the data store that can then be modified. Once this block has finished running, the accessor will ensure that any changes that took place within the block will be persisted. It is **not** safe to perform UI work within this block.
     */
    func writeAsync(_ writeBlock: @escaping (DataStoreReadWriteAccessor) -> Void)

    /**
     Write to the data store asyncronously
     
     - parameter writeBlock: Block that contains the work that will be done. The block will be passed a ```DataStoreReadWriteAccessor``` which can be used to access information in the data store that can then be modified. Once this block has finished running, the accessor will ensure that any changes that took place within the block will be persisted. It is **not** safe to perform UI work within this block.
     - parameter completion: Block that is executed when the changes are saved.
     */
    func writeAsync(_ writeBlock: @escaping (DataStoreReadWriteAccessor) -> Void, completion: (() -> Void)?)

    // MARK: Child Data Store
    
    /**
     Produces a data store that has access to the data in this data store, but changes made in the child data store are isolated from this parent data store until it is merged.
     
     - returns:
     */
    func makeChildDataStore() -> ChildDataStore
    
    /**
     Merges changes from child data store back into this data store
     
     - parameter childDataStore: The child datastore to merge changes from
     */
    func merge(_ childDataStore: ChildDataStore)
}

@objc
public protocol ChildDataStore: DataStore {
    
    var parent: DataStore { get }
}
