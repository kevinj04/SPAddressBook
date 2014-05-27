//
//  SPViewController.m
//  SPAddressBook
//
//  Created by Kevin Jenkins on 5/26/14.
//  Copyright (c) 2014 somethingpointless. All rights reserved.
//

#import "SPViewController.h"
#import "SPAddressBook.h"

@implementation SPViewController

#pragma mark - Button Handlers
- (IBAction)snapshotButtonTapped:(id)sender {

    SPAddressBook *addressBook = [SPAddressBook new];

    [addressBook snapShotContacts:^(NSData *contactData, NSError *error) {

        if (error) {

            NSLog(@"Error: %@", error.localizedDescription);
            return;
        }

        BOOL success = [contactData writeToFile:self.pathForSnapshot atomically:YES];
        if (success) { [self showSuccess]; }
        else { [self showFailure]; }
    }];
}

- (IBAction)restoreButtonTapped:(id)sender {

    SPAddressBook *addressBook = [SPAddressBook new];

    NSData *restoreData = [NSData dataWithContentsOfFile:self.pathForSnapshot];

    if (!restoreData) { [self showNoData]; }

    [addressBook replaceContactsWithData:restoreData completion:^(NSError *error) {

        dispatch_async(dispatch_get_main_queue(), ^{
            if (error)  { [self showRestoreFailure:error]; }
            else        { [self showRestoreSuccess]; }
        });
    }];
}

#pragma mark - Helper
- (NSString *)pathForSnapshot {

    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) firstObject];
    if (!documentsDirectory) { return nil; }

    return [documentsDirectory stringByAppendingString:@"snapshot"];
}

- (void)showSuccess {

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Your contacts have been stored." delegate:nil cancelButtonTitle:@"Cool!" otherButtonTitles:nil];
    [alert show];
}

- (void)showFailure {

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Your contacts have not been stored." delegate:nil cancelButtonTitle:@"Fudge!" otherButtonTitles:nil];
    [alert show];
}

- (void)showNoData {

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"There was no data to restore." delegate:nil cancelButtonTitle:@"Huh!" otherButtonTitles:nil];
    [alert show];
}

- (void)showRestoreSuccess {

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Your contacts have been restored from the snapshot." delegate:nil cancelButtonTitle:@"Huzzah!" otherButtonTitles:nil];
    [alert show];
}

- (void)showRestoreFailure:(NSError *)error {

    NSString *message = [NSString stringWithFormat:@"There was an issue restoring your data. %@", error.localizedDescription];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:message delegate:nil cancelButtonTitle:@"Fiddlesticks!" otherButtonTitles:nil];
    [alert show];
}

@end
