//
//  ChildDataStoreTests.swift
//  JustPersist
//
//  Created by Keith Moon on 12/10/2016.
//  Copyright © 2016 JUST EAT. All rights reserved.
//

import XCTest
@testable import JustPersist
@testable import JustPersist_Example

class ChildDataStoreTests: XCTestCase {
    
    func testWritesInMagicalRecordChildDataStoreAreInParentAfterMerge() {
        
        let dataStore = MagicalRecordDataStore.inMemoryStack() { error in }
        dataStore.setup()
        
        let childDataStore = dataStore.makeChildDataStore()
        childDataStore.setup()
        
        testWritesInChildDataStoreAreInParentAfterMerge(dataStore, childDataStore: childDataStore)
        
        dataStore.tearDown()
        childDataStore.tearDown()
    }
    
    func testWritesInSkopelosChildDataStoreAreInParentAfterMerge() {
        
        var dataStore: DataStore!
        
        if let modelURL = Bundle(for: type(of: self)).url(forResource: "TestModel", withExtension: "momd") {
            dataStore = SkopelosDataStore(inMemoryStack: modelURL) { error in }
        }
        
        dataStore.setup()
        
        let childDataStore = dataStore.makeChildDataStore()
        childDataStore.setup()
        
        testWritesInChildDataStoreAreInParentAfterMerge(dataStore, childDataStore: childDataStore)
        
        dataStore.tearDown()
        childDataStore.tearDown()
    }
    
    fileprivate func testWritesInChildDataStoreAreInParentAfterMerge(_ dataStore: DataStore, childDataStore: ChildDataStore) {
        
        // 0 Orders in parent DataStore
        dataStore.read { accessor in
            
            let request = DataStoreRequest(itemType: TestEntity.self)
            let count = accessor.countItems(forRequest: request)
            XCTAssertEqual(count, 0)
        }
        
        // 0 Orders in child DataStore
        childDataStore.read { accessor in
            
            let request = DataStoreRequest(itemType: TestEntity.self)
            let count = accessor.countItems(forRequest: request)
            XCTAssertEqual(count, 0)
        }
        
        // Add one order to child data store
        childDataStore.writeSync { accessor in
            _ = accessor.createItem(ofMutableType: TestEntity.self)
            //_ = try! accessor.create() as TestEntity // this swift magic is not fully supported apparently, yet
        }
        
        // Still 0 Orders in parent DataStore
        dataStore.read { accessor in
            
            let request = DataStoreRequest(itemType: TestEntity.self)
            let count = accessor.countItems(forRequest: request)
            XCTAssertEqual(count, 0)
        }
        
        // But 1 Order in child DataStore
        childDataStore.read { accessor in
            
            let request = DataStoreRequest(itemType: TestEntity.self)
            let count = accessor.countItems(forRequest: request)
            XCTAssertEqual(count, 1)
        }
        
        // Merge child Data Store into Parent
        dataStore.merge(childDataStore)
        
        // Now 1 Order in parent DataStore
        dataStore.read { accessor in
            
            let request = DataStoreRequest(itemType: TestEntity.self)
            let count = accessor.countItems(forRequest: request)
            XCTAssertEqual(count, 1)
        }
        
        // And 1 Order in child DataStore
        childDataStore.read { accessor in
            
            let request = DataStoreRequest(itemType: TestEntity.self)
            let count = accessor.countItems(forRequest: request)
            XCTAssertEqual(count, 1)
        }
        
    }
}
