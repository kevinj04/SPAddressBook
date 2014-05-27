//
//  SPViewController.h
//  SPAddressBook
//
//  Created by Kevin Jenkins on 5/26/14.
//  Copyright (c) 2014 somethingpointless. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton  *snapshotButton;
@property (strong, nonatomic) IBOutlet UIButton  *restoreButton;

- (IBAction)snapshotButtonTapped:(id)sender;
- (IBAction)restoreButtonTapped:(id)sender;

@end
