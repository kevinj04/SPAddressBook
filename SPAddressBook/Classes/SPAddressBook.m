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
- (void)snapShotContacts:(void (^)(NSData *contactData, NSError *error))callback {

    [self snapShotContactsOnQueue:dispatch_get_main_queue() completion:callback];
}

- (void)snapShotContactsOnQueue:(dispatch_queue_t)queue
                     completion:(void (^)(NSData *, NSError *))completionBlock {

    ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef errorRef) {

        NSData *contactData = nil;
        NSError *error      = (__bridge_transfer NSError *)errorRef;

        if (granted) { contactData = [self allContactData]; }

        dispatch_async(queue, ^{
            if (completionBlock) { completionBlock(contactData, error); }
        });
    });
}

- (void)replaceContactsWithData:(NSData *)contactData completion:(void (^)(NSError *error))completionBlock {

    ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error) {

        BOOL success = granted;

        if (granted) {

            success = [self deleteAllContacts];
            success = success && [self loadContactsFromData:contactData];
            success = success && [self save];
        }

        NSError *newError = !success ? [NSError errorWithDomain:@"Replace Error" code:1001 userInfo:@{}] : (__bridge NSError *)error;

        if (completionBlock) {
            completionBlock(newError);
        }
    });
}

#pragma mark - Helpers
- (NSData *)allContactData {

    CFArrayRef peopleArrayRef   = ABAddressBookCopyArrayOfAllPeople(self.addressBook);
    return (__bridge_transfer NSData *)ABPersonCreateVCardRepresentationWithPeople(peopleArrayRef);

}

- (BOOL)deleteAllContacts {

    CFArrayRef peopleArrayRef   = ABAddressBookCopyArrayOfAllPeople(self.addressBook);
    NSUInteger peopleCount      = CFArrayGetCount(peopleArrayRef);

    for (NSUInteger index = 0; index < peopleCount; index++) {

        NSError  *error     = nil;
        ABRecordRef record  = CFArrayGetValueAtIndex(peopleArrayRef, index);

        CFErrorRef cfError = NULL;
        ABAddressBookRemoveRecord(self.addressBook, record, &cfError);


        if (cfError) {
            error = (__bridge NSError *)(cfError);
            NSLog(@"Deletion Error: %@", [error localizedDescription]);
            return NO;
        }
    }

    return YES;
}

- (BOOL)loadContactsFromData:(NSData *)contactData {

    CFArrayRef peopleArrayRef   = ABPersonCreatePeopleInSourceWithVCardRepresentation(NULL, (__bridge CFDataRef)contactData);
    NSUInteger peopleCount      = CFArrayGetCount(peopleArrayRef);

    for (NSUInteger index = 0; index < peopleCount; index++) {

        NSError  *error     = nil;
        CFErrorRef cfError  = NULL;
        ABRecordRef record  = CFArrayGetValueAtIndex(peopleArrayRef, index);

        ABAddressBookAddRecord(self.addressBook, record, &cfError);

        if (cfError) {
            error = (__bridge NSError *)(cfError);
            NSLog(@"Deletion Error: %@", [error localizedDescription]);
            return NO;
        }
    }

    return YES;
}

- (BOOL)save {

    CFErrorRef errorRef = NULL;
    NSError *error      = nil;
    BOOL success        = ABAddressBookSave(self.addressBook, &errorRef);

    if (errorRef) {
        error = (__bridge NSError *)(errorRef);
    }
    return success && !error;
}

@end
