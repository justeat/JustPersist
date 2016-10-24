//
//  DataStoreRequest+FetchRequest.swift
//  JustPersist
//
//  Created by Keith Moon on 21/08/2016.
//  Copyright © 2016 JUST EAT. All rights reserved.
//

import Foundation
import CoreData

extension DataStoreRequest {
    
    func fetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: itemType.itemTypeKey)
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        if let offset = offset {
            request.fetchOffset = offset
        }
        if let limit = limit {
            request.fetchLimit = limit
        }
        
        return request
    }
    
}
