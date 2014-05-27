//
//  SPAddressBook.h
//  SPAddressBook
//
//  Created by Kevin Jenkins on 5/26/14.
//  Copyright (c) 2014 somethingpointless. All rights reserved.
//

#import <Foundation/Foundation.h>

// This class was completely inspired by alterplay's APAddressBook
// https://github.com/Alterplay/APAddressBook
// I just had different needs -- so viola.

typedef enum SPAddressBookAccess {
    SPAddressBookAccessUnknown = 0,
    SPAddressBookAccessGranted = 1,
    SPAddressBookAccessDenied  = 2
} SPAddressBookAccess;

@interface SPAddressBook : NSObject

+ (SPAddressBookAccess)access;

- (void)loadContacts:(void (^)(NSArray *contacts, NSError *error))callback;
- (void)loadContactsOnQueue:(dispatch_queue_t)queue
                 completion:(void (^)(NSArray *contacts, NSError *error))completionBlock;

@end
