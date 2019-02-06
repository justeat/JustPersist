//
//  DataStoreTests.swift
//  JustPersist
//
//  Created by Alberto De Bortoli on 25/10/2016.
//  Copyright © 2016 JUST EAT. All rights reserved.
//

import XCTest
@testable import JustPersist
@testable import JustPersist_Example

struct DataStoreTestsConsts {
    static let UnitTestTimeout = 5.0
}

class DataStoreTests: XCTestCase {
    
    var magicalRecordDataStore: DataStore!
    var skopelosDataStore: DataStore!
    var magicalRecordChildDataStore: ChildDataStore!
    var skopelosChildDataStore: ChildDataStore!
    
    override func setUp() {
        super.setUp()
        
        if let modelURL = Bundle(for: type(of: self)).url(forResource: "TestModel", withExtension: "momd") {
            magicalRecordDataStore = MagicalRecordDataStore.inMemoryStack() { error in }
            skopelosDataStore = SkopelosDataStore(inMemoryStack: modelURL) { error in }
        }
        
        magicalRecordDataStore.setup()
        magicalRecordChildDataStore = magicalRecordDataStore.makeChildDataStore()
        magicalRecordChildDataStore.setup()
        
        skopelosDataStore.setup()
        skopelosChildDataStore = skopelosDataStore.makeChildDataStore()
        skopelosChildDataStore.setup()
    }
    
    override func tearDown() {
        super.tearDown()
        magicalRecordDataStore.tearDown()
        magicalRecordChildDataStore.tearDown()
        skopelosDataStore.tearDown()
        skopelosChildDataStore.tearDown()
    }
    
    // MARK: Magical Record
    // MARK: Readings
    
    func testReadInMagicalRecordDataStoreFromMainThreadIsSyncOnMainThread() {
        testReadCalledFromMainThreadIsSyncOnMainThread(magicalRecordDataStore)
    }
    
    func testReadInMagicalRecordDataStoreFromBkgThreadIsSyncOnMainThread() {
        testReadCalledFromBkgThreadIsSyncOnMainThread(magicalRecordDataStore)
    }
    
    func testReadInMagicalRecordChilDataStoreFromMainThreadIsSyncOnMainThread() {
        testReadCalledFromMainThreadIsSyncOnMainThread(magicalRecordChildDataStore)
    }
    
    func testReadInMagicalRecordChildDataStoreFromBkgThreadIsSyncOnMainThread() {
        testReadCalledFromBkgThreadIsSyncOnMainThread(magicalRecordChildDataStore)
    }
    
    // MARK: Writings Sync
    
    func testWriteSyncInMagicalRecordDataStoreFromMainThreadIsSyncOnMainThread() {
        testWriteSyncCalledFromMainThreadIsSyncOnMainThread(magicalRecordDataStore)
    }
    
    func testWriteSyncInMagicalRecordDataStoreFromBkgThreadIsSyncOnMainThread() {
        testWriteSyncCalledFromBkgThreadIsSyncOnBackgroundThread(magicalRecordDataStore)
    }
    
    func testWriteSyncInMagicalRecordChildDataStoreFromMainThreadIsSyncOnMainThread() {
        testWriteSyncCalledFromMainThreadIsSyncOnMainThread(magicalRecordChildDataStore)
    }
    
    func testWriteSyncInMagicalRecordChildDataStoreFromBkgThreadIsSyncOnMainThread() {
        testWriteSyncCalledFromBkgThreadIsSyncOnBackgroundThread(magicalRecordChildDataStore)
    }
    
    // MARK: Writings Async
    
    func testWriteAsyncInMagicalRecordDataStoreFromMainThreadIsAsyncOnBackgroundThread() {
        testWriteAsyncCalledFromMainThreadIsAsyncOnBackgroundThread(magicalRecordDataStore)
    }
    
    func testWriteAsyncInMagicalRecordDataStoreFromBkgThreadIsAsyncOnBackgroundThread() {
        testWriteAsyncCalledFromBkgThreadIsAsyncOnBackgroundThread(magicalRecordDataStore)
    }
    
    func testWriteAsyncInMagicalRecordChildDataStoreFromMainThreadIsAsyncOnBackgroundThread() {
        testWriteAsyncCalledFromMainThreadIsAsyncOnBackgroundThread(magicalRecordChildDataStore)
    }
    
    func testWriteAsyncInMagicalRecordChildDataStoreFromBkgThreadIsAsyncOnBackgroundThread() {
        testWriteAsyncCalledFromBkgThreadIsAsyncOnBackgroundThread(magicalRecordChildDataStore)
    }
    
    // MARK: Skopelos
    // MARK: Readings
    
    func testReadInSkopelosDataStoreFromMainThreadIsSyncOnMainThread() {
        testReadCalledFromMainThreadIsSyncOnMainThread(skopelosDataStore)
    }
    
    func testReadInSkopelosDataStoreFromBkgThreadIsSyncOnMainThread() {
        testReadCalledFromBkgThreadIsSyncOnMainThread(skopelosDataStore)
    }
    
    func testReadInSkopelosChildDataStoreFromMainThreadIsSyncOnMainThread() {
        testReadCalledFromMainThreadIsSyncOnMainThread(skopelosChildDataStore)
    }
    
    func testReadInSkopelosChildDataStoreFromBkgThreadIsSyncOnMainThread() {
        testReadCalledFromBkgThreadIsSyncOnMainThread(skopelosChildDataStore)
    }
    
    // MARK: Writings Sync
    
    func testWriteSyncInSkopelosDataStoreFromMainThreadIsSyncOnMainThread() {
        testWriteSyncCalledFromMainThreadIsSyncOnMainThread(skopelosDataStore)
    }
    
    func testWriteSyncInSkopelosDataStoreFromBkgThreadIsSyncOnMainThread() {
        testWriteSyncCalledFromBkgThreadIsSyncOnBackgroundThread(skopelosDataStore)
    }
    
    func testWriteSyncInSkopelosChildDataStoreFromMainThreadIsSyncOnMainThread() {
        testWriteSyncCalledFromMainThreadIsSyncOnMainThread(skopelosChildDataStore)
    }
    
    func testWriteSyncInSkopelosChildDataStoreFromBkgThreadIsSyncOnMainThread() {
        testWriteSyncCalledFromBkgThreadIsSyncOnBackgroundThread(skopelosChildDataStore)
    }
    
    // MARK: Writings Async
    
    func testWriteAsyncInSkopelosDataStoreFromMainThreadIsAsyncOnBackgroundThread() {
        testWriteAsyncCalledFromMainThreadIsAsyncOnBackgroundThread(skopelosDataStore)
    }
    
    func testWriteAsyncInSkopelosDataStoreFromBkgThreadIsAsyncOnBackgroundThread() {
        testWriteAsyncCalledFromBkgThreadIsAsyncOnBackgroundThread(skopelosDataStore)
    }
    
    func testWriteAsyncInSkopelosChildDataStoreFromMainThreadIsAsyncOnBackgroundThread() {
        testWriteAsyncCalledFromMainThreadIsAsyncOnBackgroundThread(skopelosChildDataStore)
    }
    
    func testWriteAsyncInSkopelosChildDataStoreFromBkgThreadIsAsyncOnBackgroundThread() {
        testWriteAsyncCalledFromBkgThreadIsAsyncOnBackgroundThread(skopelosChildDataStore)
    }
    
    // MARK: Writings Async - completion block
    func testWriteAsyncInMagicalRecordCallsCompletion() {
        testWriteAsyncCalledFromMainThreadIsAsyncOnBackgroundThread(magicalRecordDataStore)
    }

    func testWriteAsyncInSkopelosCallsCompletion() {
        testWriteAsyncCallsCompletion(skopelosDataStore)
    }
    
    // MARK: Private
    
    fileprivate func testReadCalledFromMainThreadIsSyncOnMainThread(_ dataStore: DataStore) {
        
        var stepSequence: [Int] = []
        
        dataStore.read { accessor in
            
            XCTAssertTrue(Thread.current.isMainThread)
            stepSequence.append(0)
        }
        
        stepSequence.append(1)
        
        XCTAssertEqual(stepSequence[0], 0)
        XCTAssertEqual(stepSequence[1], 1)
    }
    
    fileprivate func testWriteSyncCalledFromMainThreadIsSyncOnMainThread(_ dataStore: DataStore) {
        
        var stepSequence: [Int] = []
        
        dataStore.writeSync { accessor in
            
            XCTAssertTrue(Thread.current.isMainThread)
            stepSequence.append(0)
        }
        
        stepSequence.append(1)
        
        XCTAssertEqual(stepSequence[0], 0)
        XCTAssertEqual(stepSequence[1], 1)
        
    }
    
    fileprivate func testWriteAsyncCalledFromMainThreadIsAsyncOnBackgroundThread(_ dataStore: DataStore) {
        
        let asyncExpectation = expectation(description: "thread safety expectation")
        
        /**
        * stepSuquence logic is commented-out as the execution of the block (ultimately a 'performBlock'/'perform' in CoreData
        * is not guaranteed to happen on a dispatched block and might be executed before the line following the block
        */
        //var stepSequence: [Int] = []
        
        dataStore.writeAsync { accessor in
            
            XCTAssertFalse(Thread.current.isMainThread)
            //stepSequence.append(0)
            asyncExpectation.fulfill()
        }
        
        //stepSequence.append(1)
        self.waitForExpectations(timeout: DataStoreTestsConsts.UnitTestTimeout) { error in }
        
        //XCTAssertEqual(stepSequence[0], 1)
        //XCTAssertEqual(stepSequence[1], 0)
        
    }

    fileprivate func testWriteAsyncCallsCompletion(_ dataStore: DataStore) {
        
        let asyncExpectation = expectation(description: "thread safety expectation")
        let completionExpectation = expectation(description: "completion expectation")
        
        /**
         * stepSuquence logic is commented-out as the execution of the block (ultimately a 'performBlock'/'perform' in CoreData
         * is not guaranteed to happen on a dispatched block and might be executed before the line following the block
         */
        //var stepSequence: [Int] = []
        let writeBlock: (DataStoreReadWriteAccessor) -> Void = { accessor in
            
            XCTAssertFalse(Thread.current.isMainThread)
            //stepSequence.append(0)
            asyncExpectation.fulfill()
        }
        
        dataStore.writeAsync(writeBlock) {
            completionExpectation.fulfill()
        }
        
        //stepSequence.append(1)
        wait(for: [asyncExpectation, completionExpectation], timeout: DataStoreTestsConsts.UnitTestTimeout)
        
        //XCTAssertEqual(stepSequence[0], 1)
        //XCTAssertEqual(stepSequence[1], 0)
        
    }

    fileprivate func testReadCalledFromBkgThreadIsSyncOnMainThread(_ dataStore: DataStore) {
        
        let asyncExpectation = expectation(description: "thread safety expectation")
        var stepSequence: [Int] = []
        
        DispatchQueue(label: "com.JustPersist.DataStoreTests", attributes: []).async {
            
            dataStore.read { accessor in
                
                XCTAssertTrue(Thread.current.isMainThread)
                stepSequence.append(0)
            }
            
            stepSequence.append(1)
            asyncExpectation.fulfill()
        }
        
        self.waitForExpectations(timeout: DataStoreTestsConsts.UnitTestTimeout) { error in }
        
        XCTAssertEqual(stepSequence[0], 0)
        XCTAssertEqual(stepSequence[1], 1)
    }
    
    fileprivate func testWriteSyncCalledFromBkgThreadIsSyncOnBackgroundThread(_ dataStore: DataStore) {
        
        let asyncExpectation = expectation(description: "thread safety expectation")
        var stepSequence: [Int] = []
        
        DispatchQueue(label: "com.JustPersist.DataStoreTests", attributes: []).async {
            
            dataStore.writeSync { accessor in
                
                XCTAssertFalse(Thread.current.isMainThread)
                stepSequence.append(0)
            }
            
            stepSequence.append(1)
            asyncExpectation.fulfill()
        }
        
        self.waitForExpectations(timeout: DataStoreTestsConsts.UnitTestTimeout) { error in }
        
        XCTAssertEqual(stepSequence[0], 0)
        XCTAssertEqual(stepSequence[1], 1)
        
    }
    
    fileprivate func testWriteAsyncCalledFromBkgThreadIsAsyncOnBackgroundThread(_ dataStore: DataStore) {
        
        let asyncExpectation = expectation(description: "thread safety expectation")
        var stepSequence: [Int] = []
        
        DispatchQueue(label: "com.JustPersist.DataStoreTests", attributes: []).async {
            
            dataStore.writeAsync { accessor in
                
                XCTAssertFalse(Thread.current.isMainThread)
                stepSequence.append(0)
                asyncExpectation.fulfill()
            }
            
            stepSequence.append(1)
        }
        
        self.waitForExpectations(timeout: DataStoreTestsConsts.UnitTestTimeout) { error in }
        
        XCTAssertEqual(stepSequence[0], 1)
        XCTAssertEqual(stepSequence[1], 0)
        
    }
}
