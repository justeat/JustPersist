//
//  MagicalRecordDataStore.swift
//  JustPersist
//
//  Created by Keith Moon on 27/07/2016.
//  Copyright © 2016 JUST EAT. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MagicalRecord

@objc(JEMagicalRecordDataStore)
open class MagicalRecordDataStore: NSObject {
    
    enum ErrorCode: Int {
        case attemptingToMergeIncompatibleChildDataStore
    }
    
    let errorDomain = "com.just-eat.MagicalRecordDataStore.Error"
    
    fileprivate var setupBlock: () -> Void
    fileprivate var tearDownBlock: () -> Void
    fileprivate var isSetup = false
    
    open static func stack(_ dataModelFileName: NSString, securityApplicationGroupIdentifier: NSString, errorHandler: DataStoreErrorHandler? = nil) -> MagicalRecordDataStore {
        
        return MagicalRecordDataStore(setupBlock: {
            
            MagicalRecord.setShouldDeleteStoreOnModelMismatch(true)
            MagicalRecord.setLoggingLevel(.error)
            let filename = dataModelFileName as String + ".sqlite"
            MagicalRecord.setupCoreDataStackInSharedLocation(withAutoMigratingSqliteStoreNamed: filename, securityApplicationGroupIdentifier: securityApplicationGroupIdentifier as String)
            
            }, tearDownBlock: {
                
                MagicalRecord.tearDownCoreDataStackInSharedLocation(withSqliteStoreNamed: dataModelFileName as String, securityApplicationGroupIdentifier: securityApplicationGroupIdentifier as String)
                
            }, errorHandler: errorHandler)
    }
    
    open static func inMemoryStack(_ errorHandler: DataStoreErrorHandler? = nil) -> MagicalRecordDataStore {
        
        return MagicalRecordDataStore(setupBlock: {
            
            MagicalRecord.setShouldDeleteStoreOnModelMismatch(true)
            MagicalRecord.setLoggingLevel(.error)
            MagicalRecord.setupCoreDataStackWithInMemoryStore()
            
            }, tearDownBlock: {
                
                // don't care for now, but when the tests will use the in memory one
                // it'll be fundamental to tear down the data store between one test and the other
                
            }, errorHandler: errorHandler)
    }
    
    public init(setupBlock: @escaping () -> Void, tearDownBlock: @escaping () -> Void, errorHandler: DataStoreErrorHandler? = nil) {
        self.setupBlock = setupBlock
        self.tearDownBlock = tearDownBlock
        self.errorHandler = errorHandler
        super.init()
    }
    
    open var errorHandler: DataStoreErrorHandler? {
        didSet {
            if isSetup {
                // We don't need to wrap this as main context work will happen on the main queue
                readAccessor.errorHandler = errorHandler
            }
        }
    }
    
    // MARK: Accessors
    
    fileprivate var readAccessor: CoreDataAccessor!
    
    lazy fileprivate var readWriteAccessor: CoreDataAccessor = {
        
        let privateContext = NSManagedObjectContext.mr_context(withParent: NSManagedObjectContext.mr_default())
        privateContext.shouldDeleteInaccessibleFaults = false
        let accessor = CoreDataAccessor(withContext: privateContext)
        
        if let errorHandler = self.errorHandler {
            
            accessor.errorHandler = { error in
                DispatchQueue.main.async {
                    errorHandler(error)
                }
            }
        }
        return accessor
    }()
}

// MARK: - DataStore

extension MagicalRecordDataStore: DataStore {
    
    public func setup() {
        guard !isSetup else { return }
        setupBlock()
        
        let mainContext = NSManagedObjectContext.mr_default()
        let rootContext = NSManagedObjectContext.mr_rootSaving()
        mainContext.shouldDeleteInaccessibleFaults = false
        rootContext.shouldDeleteInaccessibleFaults = false
        
        readAccessor = CoreDataAccessor(withContext: mainContext)
        readAccessor.errorHandler = errorHandler
        isSetup = true
    }
    
    public func tearDown() {
        guard isSetup else { return }
        tearDownBlock()
        readAccessor = nil
        isSetup = false
    }
    
    public func read(_ readBlock: @escaping (DataStoreReadAccessor) -> Void) {
        
        precondition(isSetup, "You must setup the data store before trying to read from it")
        
        let accessor = readAccessor
        accessor?.context.performAndWait { 
            readBlock(accessor!)
        }
    }
    
    public func writeSync(_ writeBlock: @escaping (DataStoreReadWriteAccessor) -> Void) {
        
        precondition(isSetup, "You must setup the data store before trying to write to it")
        
        let accessor = readWriteAccessor
        accessor.context.performAndWait {
            writeBlock(accessor)
            accessor.context.mr_saveToPersistentStoreAndWait() // Saves context and parent contexts all the way up to the persistent store.
        }
    }
    
    public func writeAsync(_ writeBlock: @escaping (DataStoreReadWriteAccessor) -> Void) {
        
        precondition(isSetup, "You must setup the data store before trying to write to it")
        
        let accessor = readWriteAccessor
        accessor.context.perform {
            writeBlock(accessor)
            accessor.context.mr_saveToPersistentStoreAndWait() // Saves context and parent contexts all the way up to the persistent store.
        }
    }
    
    public func makeChildDataStore() -> ChildDataStore {
        return ChildCoreDataStore(parentDataStore: self, parentContext: readAccessor.context, errorHandler: errorHandler)
    }
    
    public func merge(_ childDataStore: ChildDataStore) {
        
        guard let child = childDataStore as? ChildCoreDataStore , child.parent === self else {
            errorHandler?(NSError(domain: errorDomain, code: ErrorCode.attemptingToMergeIncompatibleChildDataStore.rawValue, userInfo: nil))
            return
        }
        
        child.saveToParent()
        readAccessor.context.mr_saveToPersistentStoreAndWait()
    }
}
