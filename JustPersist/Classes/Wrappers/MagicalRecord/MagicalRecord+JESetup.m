//
//  MagicalRecord+JESetup.m
//  JustPersist
//
//  Created by Alberto De Bortoli on 09/12/2015.
//  Copyright © 2015 JUST EAT. All rights reserved.
//

#import "MagicalRecord+JESetup.h"

@implementation MagicalRecord (JESetup)

#pragma mark - Setup

+ (NSURL *)persistentStoreURLInSharedLocationWithSqliteStoreNamed:(NSString *)storeFileName
                               securityApplicationGroupIdentifier:(NSString *)appGroupId
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *directory = [fileManager containerURLForSecurityApplicationGroupIdentifier:appGroupId];
    NSURL *pathToStore = [directory URLByAppendingPathComponent:storeFileName];
    return pathToStore;
}

+ (void)setupCoreDataStackInSharedLocationWithAutoMigratingSqliteStoreNamed:(NSString *)storeFileName
                                         securityApplicationGroupIdentifier:(NSString *)appGroupId
{
    NSURL *pathToStore = [self persistentStoreURLInSharedLocationWithSqliteStoreNamed:storeFileName securityApplicationGroupIdentifier:appGroupId];
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreAtURL:pathToStore];
}

#pragma mark - Tear down

+ (void)tearDownCoreDataStackInSharedLocationWithSqliteStoreNamed:(NSString *)storeFileName
                               securityApplicationGroupIdentifier:(NSString *)appGroupId
{
    NSURL *fileURL = [self persistentStoreURLInSharedLocationWithSqliteStoreNamed:storeFileName securityApplicationGroupIdentifier:appGroupId];
    
    [MagicalRecord cleanUp];
    
    NSURL *pathToStore = [fileURL URLByDeletingPathExtension];
    
    NSError *error = nil;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    for (NSString *extension in [self _storeExtensions])
    {
        NSString *filePath = [pathToStore URLByAppendingPathExtension:extension].path;
        if ([fileManager fileExistsAtPath:filePath])
        {
            [fileManager removeItemAtPath:filePath error:&error];
            if (error)
            {
                error = nil;
            }
        }
    }
}

+ (NSArray <NSString *> *)_storeExtensions
{
    return @[@"sqlite", @"sqlite-shm", @"sqlite-wal"];
}

@end
