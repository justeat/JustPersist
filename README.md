![JustPersist Banner](./img/just_persist_banner.png)

# JustPersist

[![Build Status](https://travis-ci.org/justeat/JustPersist.svg?branch=master)](https://travis-ci.org/justeat/JustPersist)
[![Version](https://img.shields.io/cocoapods/v/JustPersist.svg?style=flat)](http://cocoapods.org/pods/JustPersist)
[![License](https://img.shields.io/cocoapods/l/JustPersist.svg?style=flat)](http://cocoapods.org/pods/JustPersist)
[![Platform](https://img.shields.io/cocoapods/p/JustPersist.svg?style=flat)](http://cocoapods.org/pods/JustPersist)

JustPersist is the easiest and safest way to do persistence on iOS with Core Data support out of the box. It also allows you to migrate to any other persistence framework with minimal effort.

- [Just Eat Tech blog](https://tech.just-eat.com/2017/03/02/how-to-abstract-your-persistence-layer-and-migrate-to-another-one-on-ios-with-justpersist/)

# Overview

At Just Eat, we persist a variety of data in the iOS app. In 2014 we decided to use [MagicalRecord](https://github.com/magicalpanda/MagicalRecord) as a wrapper on top of Core Data but over time the numerous [problems](https://github.com/magicalpanda/MagicalRecord/issues) and fundamental thread-safety issues, arose. In 2017, MagicalRecord is not supported anymore and new solutions look more appealing. We decided to adopt [Skopelos](http://github.com/albertodebortoli/Skopelos): a much younger and lightweight Core Data stack, with a simpler design, developed by [Alberto De Bortoli](http://twitter.com/albertodebo), one of our engineers. The design of the persistence layer interface gets inspiration from Skopelos as well, and we invite the reader to take a look at [its documentation](https://github.com/albertodebortoli/Skopelos/blob/master/README.md).

The main problem in adopting a new persistence solution is migrating to it. It is rarely easy, especially if the legacy codebase doesn't hide the adopted framework (in our case MagicalRecord) but rather spread it around in view controllers, managers, helper classes, categories and sometimes views. Ultimately, in the case of Core Data, there is a single persistent store and this is enough to make impossible to move access across "one at a time". There can only be one active persistence solution at a time.

We believe this is a very common problem, especially in the mobile world. We created JustPersist for this precise reason and to ease the migration process.

At the end of the day, JustPersist is two things:

- A persistence layer with a clear and simple interface to do transactional readings and writings (Skopelos-style)
- A solution to migrate from one persistence layer to another with (we believe) the minimum possible effort

JustPersist aims to be the easiest and safest way for persistence on iOS. It supports Core Data out of the box and can be extended to transparently support other frameworks. Since moving from MagicalRecord to Skopelos, we provide available wrappers for these two frameworks. 

The tone of JustPersist is very much Core Data-oriented but it enables you to migrate to any other persistence framework if a custom data store (wrapper) is implemented (in-memory, key-value store, even [Realm](https://realm.io/) if you are brave enough).

JustPersist is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "JustPersist/Skopelos"
# or
pod "JustPersist/MagicalRecord"
```

Using only `pod JustPersist` will add the core pod with no subspecs and you'll have to implement your own wrapper to use the it. If you intend to extend JustPersist to support other frameworks, we suggest creating a subspec.


# Usage of the persistence layer

To perform operation you need a data store, which you can setup like this (or see [related paragraph](#common-way-of-setting-up-a-data-store) paragraph):

```swift
let dataStore = SkopelosDataStore(sqliteStack: <modelURL>)
// or
let dataStore = MagicalRecordDataStore()
```

Before using the data store for the first time, you must call `setup()` on it, and possibly `tearDown()` when you are completely done with it.

We suggest setting up the stack at app startup time, in the `applicationDidFinishLaunchingWithOptions` method in the AppDelegate and to tear it down at the end of the life cycle of your entire app, when resetting the state of the app (if you provide support to do so) or in the `tearDown` method of your unit tests suite.

To hide the underlying persistence framework used, JustPersist provides things that conform to `DataStoreItem` and `MutableDataStoreItem`, rather than the CoreData specific `NSManagedObject`. These protocols provide access to properties using `objectForKey` and `setObject:forKey:` methods.

In the case of Core Data, JustPersist provides an extension to `NSManagedObject` to make it conforming to `MutableDataStoreItem`.


## Readings and writings

The separation between readings and writings is the foundation of JustPersist.
Reading are always synchronous by design:

```swift
dataStore.read { (accessor) in
  ...
}
```

While writings can be both synchronous or asynchronous:

```swift
dataStore.writeSync { (accessor) in
  ...
}

dataStore.writeAsync { (accessor) in
  ...
}
```

The accessor provided by the blocks can be a read one (`DataStoreReadAccessor`) or a read/write one (`DataStoreReadWriteAccessor`). Read accessors allow you to do read operations such as:

```swift
func items(forRequest request: DataStoreRequest) -> [DataStoreItem]
func firstItem(forRequest request: DataStoreRequest) -> DataStoreItem?
func countItems(forRequest request: DataStoreRequest) -> Int
```

While the read/write ones allow you to perform a complete set of CRUD operations:

```swift
func mutableItems(forRequest request: DataStoreRequest) -> [MutableDataStoreItem]
func firstMutableItem(forRequest request: DataStoreRequest) -> MutableDataStoreItem?
func createItem(ofMutableType itemType: MutableDataStoreItem.Type) -> MutableDataStoreItem?
func insert(_ item: MutableDataStoreItem) -> Bool
func delete(item: MutableDataStoreItem) -> Bool
func deleteAllItems(ofMutableType itemType: MutableDataStoreItem.Type) -> Bool
func mutableVersion(ofItem item: DataStoreItem) -> MutableDataStoreItem?
```

To perform an operation you might need a `DataStoreRequest` which can be customized with itemType, an NSPredicate, an array of NSSortDescriptor, offset and limit. Think of it as the corresponding Core Data's `NSFetchRequest`.


Here are some complete examples:

```swift
dataStore.read { (accessor) in
  let request = DataStoreRequest(itemType: Restaurant.self)
  let count = accessor.countItems(forRequest: request)
}

dataStore.read { (accessor) in
  let request = DataStoreRequest(itemType: Restaurant.self)
  request.setFilter(whereAttribute: "name", equalsValue: <some_name>)
  guard let restaurant = accessor.firstItem(forRequest: request) as? Restaurant else { return }
  ...
}

dataStore.writeSync { (accessor) in
  let restaurant = accessor.createItem(ofMutableType: Restaurant.self) as! Restaurant
  restaurant.name = <some_name>
  ...
  let wasDeleted = accessor.delete(item: restaurant)
}
```

In write blocks there is no need to make any call to a save method. Since it would be the obvious thing to do at the end of a transactional block, JustPersist does it for you. Read blocks are not meant to modify the store and you wouldn't even have the API available to do so (unless `DataStoreItem` objects are casted to `NSManagedObject` in the case of CoreData to allow the setting of properties), therefore a save will not be performed under the hood. 


## Common way of setting up a data store

We recommend to use dependency injection to pass the data store around but sometimes it might be hard. If you wish to access your data store via a singleton, here is how your app could create a shared instance for the DataStoreClient (e.g. `DataStoreClient.swift`) using Skopelos.

```swift
@objc
class DataStoreClient: NSObject {

static let shared: DataStore = {
  return DataStoreClient.sqliteStack()
}()

static let inMemoryShared: DataStore = {
  return DataStoreClient.inMemoryStack()
}()

class func sqliteStack() -> DataStore {
  let modelURL = Bundle.main.url(forResource: "<schema_filename>", withExtension: "momd")! // want to crash if schema is missing
  return SkopelosDataStore(sqliteStack: modelURL, securityApplicationGroupIdentifier: <security_application_group_identifier_id_any>) { error in
    print("Core Data error reported via SkopelosDataStore (sqliteStack): \(error.localizedDescription)")
  }
}

class func inMemoryStack() -> DataStore {
  let modelURL = Bundle.main.url(forResource: "<schema_filename>", withExtension: "momd")! // want to crash if schema is missing
  return SkopelosDataStore(inMemoryStack: modelURL) { error in
    print("Core Data error reported via SkopelosDataStore (inMemoryStack): \(error.localizedDescription)"")
  }
}
```

For unit tests, you might want to use the `inMemoryShared` for better performance.


## Child data store

A child data store is useful in situations where you might have the need to rollback all the changes performed in a specific section of the app or in a part of the user journey. Think of it as a scratch/disposable context in the [Core Data stack](http://martiancraft.com/blog/2015/03/core-data-stack/) by Marcus Zarra.

At Just Eat we use a child data store for the addition of complex products to the basket. The user might make many updates to the product and it is easier to perform the final save operation when the user confirms the addition rather than dealing with multiple CRUD operations on the main data store.

A child data store behaves just like a normal data store, with the only exception that, to save the changes back to the main data store, developers must explicitly merge the data stores. Here is a complete example: 

```swift
let childDataStore = dataStore.makeChildDataStore()
childDataStore.setup()
...
dataStore.merge(childDataStore)
childDataStore.tearDown()
```

## Thread-safety notes

Read and sync write blocks are always performed on the main thread, no matter which thread calls them.
Async write blocks are always performed on a background thread.

Sync writings return only when the changes are persisted (in the case of Core Data, usually to the `NSManagedObjectContext` with main concurrency type). 

Async writings return immediately and leave the job of saving to the source of truth to JustPersist (whether it be the context or a persistent store). They are eventual consistent, meaning that the next reading could potentially not have the data available.

Forcing a transactional programming model for readings and writings helps developers to avoid thread-safety issues which in Core Data can be caught setting the `-com.apple.CoreData.ConcurrencyDebug 1` flag in your scheme (which we recommend enabling).


# How to migrate to a different persistence layer

Examples in this sections are in Objective-C as 1. they deal with the legacy code for the nature of the example and 2. to show that JustPersist works just fine with Objective-C too.

Here we'll outline the steps we made to migrate away from MagicalRecord to Skopelos using JustPersist. We believe that a lot of apps still use MagicalRecord, so this may apply to your case too. If your need is to move from and to other 2 frameworks, you need to implement the corresponding data stores to wrap them.

You should start by implementing your `DataStoreClient` (you could follow the steps in the [related paragraph](#common-way-of-setting-up-a-data-store)) and allocating the data store for the current persistence layer used by your app in the `sqliteStack` method and possibly in the `inMemoryStack` one too. In our case, since we want to move away from MagicalRecord, the data store used would be `MagicalRecordDataStore`.

Standard CRUD interactions with MagicalRecord are like so:

```objective-c
NSManagedObjectContext *mainContext = [NSManagedObjectContext MR_defaultContext];
NSManagedObjectContext *childContext = [NSManagedObjectContext MR_contextWithParent:mainContext];
    
// writing (Create)
[childContext performBlockAndWait:^{
    Restaurant *restaurant = [Restaurant MR_createEntityInContext:localContext];
    [childContext MR_saveToPersistentStoreAndWait];
}];

// reading (Read)
[childContext performBlockAndWait:^{
    Restaurant *restaurant = [Restaurant MR_findFirstInContext:childContext];
}];

// writing (Update)
[childContext performBlockAndWait:^{
    Restaurant *restaurant = [Restaurant MR_findFirstInContext:childContext];
    restaurant.name = <some_name>
    [childContext MR_saveToPersistentStoreAndWait];
}];

// writing (Delete)
[childContext performBlockAndWait:^{
    [Restaurant MR_truncateAllInContext:localContext];
    [childContext MR_saveToPersistentStoreAndWait];
}];
```

All of them should be converted one by one to JustPersist:

```objective-c

DataStore *dataStore = [DataStoreClient shared];

// writing (Create)
[dataStore writeSync:^(id<JEDataStoreReadWriteAccessor> accessor) {
    Restaurant *restaurant = (Restaurant *)[accessor createItemOfMutableType:Restaurant.class];
}];

// reading (Read)
[dataStore read:^(id<JEDataStoreReadAccessor> accessor) {
    JEDataStoreRequest *request = [[JEDataStoreRequest alloc] initWithItemType:Restaurant.class];
    Restaurant *restaurant = (Restaurant *)[accessor firstItemForRequest:request];
}];

// writing (Update)
[dataStore writeSync:^(id<JEDataStoreReadWriteAccessor> accessor) {
    JEDataStoreRequest *request = [[JEDataStoreRequest alloc] initWithItemType:Restaurant.class];
    Restaurant *restaurant = (Restaurant *)[accessor firstItemForRequest:request];
    restaurant.name = <some_name>
}];

// writing (Delete)
[dataStore writeSync:^(id<JEDataStoreReadWriteAccessor> accessor) {
    [accessor deleteAllItemsOfMutableType:Restaurant.class];
}];
```

You should make sure you don't perform any UI work within the blocks even if the `read` and `writeSync` ones are executed on the main thread. Actually, you should aim for doing only the necessary work related to interact with the persistence layer, which often might be copying values out of objects to have them accessible outside the block (in Objective-C via the `__block` keyword). Developers should not hold references to model objects to pass them around threads (transactional blocks help ensure such rule).

By having moved all the direct interactions from MagicalRecord to JustPersist, you should be now able to remove all the various `@import MagicalRecord` and `#import <MagicalRecord/MagicalRecord.h>` from the entire codebase.

Once At this point, your `DataStoreClient` can be modified to allocate the target data store in the `sqliteStack` and `inMemoryStack` methods. In our case, the `SkopelosDataStore`.


# Conclusion

JustPersist aims to be the easiest and safest way to do persistence on iOS. It supports Core Data out of the box and can be extended to transparently support other frameworks.

You can use JustPersist to migrate from one persistence layer to another with minimal effort. Since we moved from MagicalRecord to Skopelos, we provide available wrappers for these two frameworks.

At its core, JustPersist is a persistence layer with a clear and simple interface to do transactional readings and writings, taking inspirations from Skopelos where readings and writings are separated by design.

We hope this library will ease the process of setting up a persistence stack, avoiding the common headache of Core Data and potential threading pitfalls.


- Just Eat iOS team
