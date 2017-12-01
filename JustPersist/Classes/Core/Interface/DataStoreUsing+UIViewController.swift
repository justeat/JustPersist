//
//  DataStoreUsing+UIViewController.swift
//  JustPersist
//
//  Created by Keith Moon on 29/07/2016.
//  Copyright © 2016 JUST EAT. All rights reserved.
//

import Foundation

extension DataStoreUsing where Self: UIViewController {
    
    func passDataStore(alongSegue segue: UIStoryboardSegue) {
        guard var dataStoreRecipiant = segue.destination as? DataStoreUsing else { return }
        dataStoreRecipiant.dataStore = dataStore
    }
}
