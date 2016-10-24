//
//  MagicalRecord+JESetup.h
//  JustPersist
//
//  Created by Alberto De Bortoli on 09/12/2015.
//  Copyright © 2015 JUST EAT. All rights reserved.
//

#import <MagicalRecord/MagicalRecord.h>

@interface MagicalRecord (JESetup)

+ (NSURL *)persistentStoreURLInSharedLocationWithSqliteStoreNamed:(NSString *)storeFileName
                               securityApplicationGroupIdentifier:(NSString *)appGroupId;

+ (void)setupCoreDataStackInSharedLocationWithAutoMigratingSqliteStoreNamed:(NSString *)storeFileName
                                         securityApplicationGroupIdentifier:(NSString *)appGroupId;

+ (void)tearDownCoreDataStackInSharedLocationWithSqliteStoreNamed:(NSString *)storeFileName
                               securityApplicationGroupIdentifier:(NSString *)appGroupId;

@end
