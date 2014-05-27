//
//  SPAddressBook.m
//  SPAddressBook
//
//  Created by Kevin Jenkins on 5/26/14.
//  Copyright (c) 2014 somethingpointless. All rights reserved.
//

#import "SPAddressBook.h"
#import <AddressBook/AddressBook.h>

@interface SPAddressBook ()

@property (readonly, nonatomic) ABAddressBookRef addressBook;

@end

@implementation SPAddressBook

#pragma mark - Initialization
- (instancetype)init {

    self = [super init];
    if (self) {

        CFErrorRef *error = NULL;
        _addressBook = ABAddressBookCreateWithOptions(NULL, error);
        if (error) {
            NSLog(@"%@", (__bridge_transfer NSString *)CFErrorCopyFailureReason(*error));
        }
    }
    return self;
}

- (void)dealloc {

    if (_addressBook) { CFRelease(_addressBook); }
}

#pragma mark - Access Determination
+ (SPAddressBookAccess)access {

    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    switch (status) {

        case kABAuthorizationStatusDenied:
        case kABAuthorizationStatusRestricted:
            return SPAddressBookAccessDenied;

        case kABAuthorizationStatusAuthorized:
            return SPAddressBookAccessGranted;

        default:
            return SPAddressBookAccessUnknown;
    }
}

#pragma mark - Contact Loading
- (void)loadContacts:(void (^)(NSArray *contacts, NSError *error))callback {

    [self loadContactsOnQueue:dispatch_get_main_queue() completion:callback];
}

- (void)loadContactsOnQueue:(dispatch_queue_t)queue
                 completion:(void (^)(NSArray *contacts, NSError *error))completionBlock {

    ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef errorRef) {

        NSError *error = (__bridge_transfer NSError *)errorRef;
        NSArray *contacts;

        if (granted) { contacts = [self allContactsFromAddressBook]; }

        dispatch_async(queue, ^{
            if (completionBlock) { completionBlock(contacts, error); }
        });
    });
}

#pragma mark - Helpers
- (NSArray *)allContactsFromAddressBook {

    CFArrayRef peopleArrayRef   = ABAddressBookCopyArrayOfAllPeople(self.addressBook);
    NSUInteger peopleCount      = (NSUInteger)CFArrayGetCount(peopleArrayRef);
    NSMutableArray *contacts    = [NSMutableArray arrayWithCapacity:peopleCount];

    for (NSUInteger index = 1; index < peopleCount; index++) {

        ABRecordRef recordRef = CFArrayGetValueAtIndex(peopleArrayRef, index);
        // create record object here

    }

    return [NSArray arrayWithArray:contacts];
}

@end
