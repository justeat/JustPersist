//
//  ChildMagicalRecordDataStore.swift
//  JustPersist
//
//  Created by Keith Moon on 11/08/2016.
//  Copyright © 2016 JUST EAT. All rights reserved.
//

import CoreData

@objcMembers
class ChildCoreDataStore: NSObject {
    
    enum ErrorCode: Int {
        case attemptingToMergeIncompatibleChildDataStore
    }
    
    let errorDomain = "com.just-eat.ChildCoreDataStore.Error"
    
    var parent: DataStore
    fileprivate let parentContext: NSManagedObjectContext
    fileprivate var isSetup = false
    var errorHandler: DataStoreErrorHandler?
    
    init(parentDataStore: DataStore, parentContext: NSManagedObjectContext, errorHandler: DataStoreErrorHandler? = nil) {
        self.parent = parentDataStore
        self.parentContext = parentContext
        self.errorHandler = errorHandler
    }
    
    // MARK: Accessors
    
    fileprivate var readAccessor: CoreDataAccessor!
    
    fileprivate func readWriteAccessor() -> CoreDataAccessor {
        
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.parent = readAccessor.context
        
        privateContext.shouldDeleteInaccessibleFaults = false
        let accessor = CoreDataAccessor(withContext: privateContext)
        
        if let errorHandler = errorHandler {
            
            accessor.errorHandler = { error in
                DispatchQueue.main.async {
                    errorHandler(error)
                }
            }
        }
        return accessor
    }
    
    
    func saveToParent() {
        readAccessor.save()
    }
    
}

extension ChildCoreDataStore: ChildDataStore {
    
    func setup() {
        
        let mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mainContext.parent = parentContext
        readAccessor = CoreDataAccessor(withContext: mainContext)
        
        mainContext.shouldDeleteInaccessibleFaults = false
        readAccessor.errorHandler = errorHandler
        isSetup = true
    }
    
    func tearDown() {
        readAccessor = nil
        isSetup = false
    }
    
    func read(_ readBlock: @escaping (DataStoreReadAccessor) -> Void) {
        
        precondition(isSetup, "You must setup the data store before trying to read from it")
        
        let accessor = readAccessor
        accessor?.context.performAndWait {
            readBlock(accessor!)
            // Save intentionally not called. To prevent changes being pushed to parent context.
        }
    }
    
    func writeSync(_ writeBlock: @escaping (DataStoreReadWriteAccessor) -> Void) {
        
        precondition(isSetup, "You must setup the data store before trying to write to it")
        
        let accessor = readWriteAccessor()
        accessor.context.performAndWait {
            writeBlock(accessor)
            accessor.save()
        }
    }
    
    func writeAsync(_ writeBlock: @escaping (DataStoreReadWriteAccessor) -> Void) {
        writeAsync(writeBlock, completion: nil)
    }
    
    func writeAsync(_ writeBlock: @escaping (DataStoreReadWriteAccessor) -> Void, completion: (() -> Void)?) {
        precondition(isSetup, "You must setup the data store before trying to write to it")
        
        let accessor = readWriteAccessor()
        accessor.context.perform {
            writeBlock(accessor)
            accessor.save()
            completion?()
        }
    }
    
    func makeChildDataStore() -> ChildDataStore {
        return ChildCoreDataStore(parentDataStore: self, parentContext: readAccessor.context, errorHandler: errorHandler)
    }
    
    func merge(_ childDataStore: ChildDataStore) {
        
        guard let child = childDataStore as? ChildCoreDataStore , child.parent === self else {
            errorHandler?(NSError(domain: errorDomain, code: ErrorCode.attemptingToMergeIncompatibleChildDataStore.rawValue, userInfo: nil))
            return
        }
        
        child.saveToParent()
    }
}
