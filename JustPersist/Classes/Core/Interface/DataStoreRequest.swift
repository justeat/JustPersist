//
//  DataStoreRequest.swift
//  JustPersist
//
//  Created by Keith Moon on 21/08/2016.
//  Copyright © 2016 JUST EAT. All rights reserved.
//

import Foundation

@objcMembers
open class DataStoreRequest: NSObject {
    
    public let itemType: DataStoreItem.Type
    open var predicate: NSPredicate?
    open var sortDescriptors: [NSSortDescriptor]?
    open var offset: Int?
    open var limit: Int?
    
    public init(itemType: DataStoreItem.Type) {
        self.itemType = itemType
    }
    
    open func setFilter(whereAttribute attribute: String, equalsValue value: Any) {
        predicate = NSPredicate(format: "%K == %@", argumentArray: [attribute, value])
    }
    
    open func setSort(byKey sortKey: String, ascending: Bool) {
        sortDescriptors = [NSSortDescriptor(key: sortKey, ascending: ascending)]
    }
}
