//
//  SkopelosClient.swift
//  JustPersist
//
//  Created by Alberto De Bortoli on 09/08/2016.
//  Copyright © 2016 JUST EAT. All rights reserved.
//

import Foundation
import CoreData
import Skopelos

@objc
protocol SkopelosClientDelegate: class {
    func handle(_ error: NSError) -> Void
}

@objcMembers
class SkopelosClient: Skopelos {
    
    weak var delegate: SkopelosClientDelegate?
    
    override func handle(error: NSError) {
        DispatchQueue.main.async {
            self.delegate?.handle(error)
        }
    }
}
