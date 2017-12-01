//
//  CoreDataAccessor.swift
//  JustPersist
//
//  Created by Keith Moon on 28/07/2016.
//  Copyright © 2016 JUST EAT. All rights reserved.
//

import CoreData

@objcMembers
class CoreDataAccessor: NSObject {
    
    let errorDomain = "com.just-eat.CoreDataAccessor.Error"
    
    enum ErrorCode: Int {
        case itemIsNotFromAccessorsDataStore
        case itemIsNotCompatibleWithAccessorsDataStore
    }
    
    enum ErrorUserInfoKey: String {
        case relevantItem = "com.just-eat.CoreDataAccessor.Error.relevantItem"
        case relevantItemType = "com.just-eat.CoreDataAccessor.Error.relevantItemType"
    }

    let context: NSManagedObjectContext
    var errorHandler: DataStoreErrorHandler?
    
    init(withContext context: NSManagedObjectContext, errorHandler: DataStoreErrorHandler? = nil) {
        self.context = context
        self.errorHandler = errorHandler
        super.init()
    }
    
    // MARK: Saving Methods
    func save() {
        
        if context.hasChanges {
            do {
                try context.save()
            } catch (let error as NSError) {
                errorHandler?(error)
            }
        }
    }
    
    // MARK: Error Methods
    
    fileprivate func reportError(withCode code: ErrorCode, userInfo: [String: AnyObject]? = nil) {
        let error = NSError(domain: errorDomain, code: code.rawValue, userInfo: userInfo)
        errorHandler?(error)
    }
    
    fileprivate func reportError(withCode code: ErrorCode, andRelevantItem relevantItem: DataStoreItem) {
        reportError(withCode: code, userInfo: [ErrorUserInfoKey.relevantItem.rawValue: relevantItem])
    }
    
    fileprivate func reportError(withCode code: ErrorCode, andRelevantItemType relevantItemType: DataStoreItem.Type) {
        reportError(withCode: code, userInfo: [ErrorUserInfoKey.relevantItemType.rawValue: relevantItemType])
    }
    
    // MARK: Count Returning Methods
    
    fileprivate func fetchItemCount(forRequest request: NSFetchRequest<NSFetchRequestResult>) -> Int {
        
        request.resultType = .countResultType
        
        let count: Int
        
        do {
            count = try context.count(for: request)
        } catch let error as NSError {
            errorHandler?(error)
            count = 0
        }
        
        return count
    }
    
    // MARK: DataStoreItem Returning Methods
    
    fileprivate func fetchItems(forRequest request: NSFetchRequest<NSFetchRequestResult>) -> [MutableDataStoreItem] {
        
        let results: [AnyObject]
        do {
            results = try context.fetch(request)
        } catch (let error as NSError) {
            errorHandler?(error)
            results = []
        }
        
        return results as? [MutableDataStoreItem] ?? []
    }
}

// MARK: - DataStoreReadAccessor

extension CoreDataAccessor: DataStoreReadAccessor {
    
    func items(forRequest request: DataStoreRequest) -> [DataStoreItem] {
        return mutableItems(forRequest: request)
    }
    
    func firstItem(forRequest request: DataStoreRequest) -> DataStoreItem? {
        return firstMutableItem(forRequest: request)
    }
    
    func countItems(forRequest request: DataStoreRequest) -> Int {
        return fetchItemCount(forRequest: request.fetchRequest())
    }
}

extension CoreDataAccessor: DataStoreReadWriteAccessor {
    
    // MARK: DataStoreReadWriteAccessor Implementation
    
    func mutableItems(forRequest request: DataStoreRequest) -> [MutableDataStoreItem] {
        return fetchItems(forRequest: request.fetchRequest())
    }
    
    func firstMutableItem(forRequest request: DataStoreRequest) -> MutableDataStoreItem? {
        
        let fetchRequest = request.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.fetchBatchSize = 1
        
        return fetchItems(forRequest: fetchRequest).first
    }
    
    func createItem(ofMutableType itemType: MutableDataStoreItem.Type) -> MutableDataStoreItem? {
        return NSEntityDescription.insertNewObject(forEntityName: itemType.itemTypeKey, into: context)
    }
    
    func insert(_ item: MutableDataStoreItem) -> Bool {
        
        guard let mo = item as? NSManagedObject else {
            reportError(withCode: ErrorCode.itemIsNotCompatibleWithAccessorsDataStore)
            return false
        }
        
        context.insert(mo)
        return true
    }
    
    func delete(item: MutableDataStoreItem) -> Bool {
        
        guard let mo = item as? NSManagedObject else {
            reportError(withCode: ErrorCode.itemIsNotFromAccessorsDataStore)
            return false
        }
        
        context.delete(mo)
        return true
    }
    
    func deleteAllItems(ofMutableType itemType: MutableDataStoreItem.Type) -> Bool {
        
        let request = DataStoreRequest(itemType: itemType)
        
        let allItems = mutableItems(forRequest: request)
        
        for item in allItems {
            guard delete(item: item) else {
                return false
            }
        }
        
        return true
    }
    
    func mutableVersion(ofItem item: DataStoreItem) -> MutableDataStoreItem? {
        
        guard let object = item as? NSManagedObject, let objectID = item.uniqueToken as? NSManagedObjectID else {
            reportError(withCode: ErrorCode.itemIsNotFromAccessorsDataStore)
            return nil
        }
        
        if !objectID.isTemporaryID {
            return context.object(with: objectID)
        }
        
        do {
            try object.managedObjectContext?.obtainPermanentIDs(for: [object])
            return context.object(with: objectID)
        } catch {
            reportError(withCode: ErrorCode.itemIsNotFromAccessorsDataStore)
            return nil
        }
    }
}
