//
//  SkopelosDataStore.swift
//  JustPersist
//
//  Created by Alberto De Bortoli on 09/08/2016.
//  Copyright © 2016 JUST EAT. All rights reserved.
//

import Foundation
import CoreData
import Skopelos

@objc(JESkopelosDataStore)
open class SkopelosDataStore: NSObject {
    
    enum ErrorCode: Int {
        case attemptingToMergeIncompatibleChildDataStore
    }
    
    let errorDomain = "com.just-eat.SkopelosDataStore.Error"
    
    fileprivate var skopelos: SkopelosClient!
    fileprivate var modelURL: URL
    fileprivate var securityApplicationGroupIdentifier: String?
    fileprivate var storeType: StoreType
    fileprivate var isSetup = false
    fileprivate var isExecutingWriting = false
    open var errorHandler: DataStoreErrorHandler?
    
    public init(sqliteStack modelURL: URL, securityApplicationGroupIdentifier: String?, errorHandler: DataStoreErrorHandler? = nil) {
        storeType = .sqlite
        self.modelURL = modelURL
        self.securityApplicationGroupIdentifier = securityApplicationGroupIdentifier
        self.errorHandler = errorHandler
        super.init()
    }
    
    public init(inMemoryStack modelURL: URL, errorHandler: DataStoreErrorHandler? = nil) {
        storeType = .inMemory
        self.modelURL = modelURL
        self.errorHandler = errorHandler
        super.init()
    }
}

// MARK: - DataStore

extension SkopelosDataStore: SkopelosClientDelegate {

    func handle(_ error: NSError) -> Void {
        errorHandler?(error)
    }
}

// MARK: - DataStore

extension SkopelosDataStore: DataStore {
    
    public func setup() {
        guard !isSetup else { return }
        switch storeType {
        case .sqlite:
            skopelos = SkopelosClient(sqliteStack: modelURL, securityApplicationGroupIdentifier: securityApplicationGroupIdentifier)
        case .inMemory:
            skopelos = SkopelosClient(inMemoryStack: modelURL)
        }
        skopelos.delegate = self
        isSetup = true
    }
    
    public func tearDown() {
        guard isSetup else { return }
        skopelos.nuke()
        skopelos = nil
        isSetup = false
    }
    
    public func read(_ readBlock: @escaping (DataStoreReadAccessor) -> Void) {
        
        precondition(isSetup, "You must setup the data store before trying to read from it")
        
        _ = skopelos.read { context in
            let readAccessor = CoreDataAccessor(withContext: context)
            
            if let errorHandler = self.errorHandler {
                
                readAccessor.errorHandler = { error in
                    DispatchQueue.main.async {
                        errorHandler(error)
                    }
                }
            }
            readBlock(readAccessor)
        }
    }
    
    public func writeSync(_ writeBlock: @escaping (DataStoreReadWriteAccessor) -> Void) {
        
        precondition(isSetup, "You must setup the data store before trying to write to it")
        
        if isExecutingWriting {
            // stop here
            print("YOLO! Already a writing happening in this data store")
        }
        
        isExecutingWriting = true
        
        _ = skopelos.writeSync { context in
            let writeAccessor = CoreDataAccessor(withContext: context)
            
            if let errorHandler = self.errorHandler {
                
                writeAccessor.errorHandler = { error in
                    DispatchQueue.main.async {
                        errorHandler(error)
                    }
                }
            }
            writeBlock(writeAccessor)
        }
        
        isExecutingWriting = false
    }
    
    public func writeAsync(_ writeBlock: @escaping (DataStoreReadWriteAccessor) -> Void) {
        
        precondition(isSetup, "You must setup the data store before trying to write to it")
        
        if isExecutingWriting {
            // stop here
            print("YOLO! Already a writing happening in this data store")
        }
        
        isExecutingWriting = true
        
        skopelos.writeAsync { context in
            let writeAccessor = CoreDataAccessor(withContext: context)
            
            if let errorHandler = self.errorHandler {
                
                writeAccessor.errorHandler = { error in
                    DispatchQueue.main.async {
                        errorHandler(error)
                    }
                }
            }
            writeBlock(writeAccessor)
        }
        
        isExecutingWriting = false
    }
    
    public func makeChildDataStore() -> ChildDataStore {
        var mainContext: NSManagedObjectContext! = nil
        _ = skopelos.read { context in
            mainContext = context
        }
        return ChildCoreDataStore(parentDataStore: self, parentContext: mainContext, errorHandler: errorHandler)
    }
    
    public func merge(_ childDataStore: ChildDataStore) {
        
        guard let child = childDataStore as? ChildCoreDataStore , child.parent === self else {
            errorHandler?(NSError(domain: errorDomain, code: ErrorCode.attemptingToMergeIncompatibleChildDataStore.rawValue, userInfo: nil))
            return
        }
        
        child.saveToParent()
        writeSync { _ in
            // Doing an empty write to force a save.
        }
    }
}
