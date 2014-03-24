//
//  RSAppDelegate.m
//  SQLiteEncryptSample
//
//  Created by R0CKSTAR on 3/24/14.
//  Copyright (c) 2014 P.D.Q. All rights reserved.
//

#import "RSAppDelegate.h"

#import <FMDatabase.h>

static NSString *const kSecretKey = @"R0CKSTAR";

@implementation RSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#pragma mark - Open an unencrypted db
    
    NSString *unencryptedDBPath = [[[NSBundle mainBundle] URLForResource:@"UnencryptedDB" withExtension:@"sqlite"] path];
    FMDatabase *unencryptedDB = [FMDatabase databaseWithPath:unencryptedDBPath];
    if ([unencryptedDB open]) {
        FMResultSet *resultSet = [unencryptedDB executeQuery:@"select * from user"];
        NSLog(@"Read from unencrypted db>>>>>");
        while ([resultSet next]) {
            for (int i = 0; i < [resultSet columnCount]; i++) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpointer-sign"
                NSString *text = [NSString stringWithUTF8String:[resultSet UTF8StringForColumnIndex:i]];
#pragma clang diagnostic pop
                NSLog(@"%@", text);
            }
        }
        NSLog(@"<<<<<Read from unencrypted db");
        [unencryptedDB close];
    }
    
#pragma mark - Export encrypted db (attach->export->detach)
    
    NSString *encryptedDBPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"EncryptedDB.sqlite"];
    const char* sql = [[NSString stringWithFormat:@"ATTACH DATABASE '%@' AS encrypted KEY '%@';", encryptedDBPath, kSecretKey] UTF8String];
    sqlite3 *unencryptedDB0;
    if (sqlite3_open([unencryptedDBPath UTF8String], &unencryptedDB0) == SQLITE_OK) {
        sqlite3_exec(unencryptedDB0, sql, NULL, NULL, NULL);
        sqlite3_exec(unencryptedDB0, "SELECT sqlcipher_export('encrypted');", NULL, NULL, NULL);
        sqlite3_exec(unencryptedDB0, "DETACH DATABASE encrypted;", NULL, NULL, NULL);
    }
    sqlite3_close(unencryptedDB0);
    // TODO: Once exported, copy the encrypted one from simulator or device, then use the encrypted version
    
#pragma mark - Open an encrypted db
    
    FMDatabase *encryptedDB = [FMDatabase databaseWithPath:encryptedDBPath];
    if ([encryptedDB open]) {
        [encryptedDB setKey:kSecretKey];
        FMResultSet *resultSet = [encryptedDB executeQuery:@"select * from user"];
        NSLog(@"Read from encrypted db>>>>>");
        while ([resultSet next]) {
            for (int i = 0; i < [resultSet columnCount]; i++) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpointer-sign"
                NSString *text = [NSString stringWithUTF8String:[resultSet UTF8StringForColumnIndex:i]];
#pragma clang diagnostic pop
                NSLog(@"%@", text);
            }
        }
        NSLog(@"<<<<<Read from encrypted db");
        [encryptedDB close];
    }
    
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
