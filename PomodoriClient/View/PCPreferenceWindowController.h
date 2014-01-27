//
//  PCPreferenceWindowController.h
//  PomodoriClient
//
//  Created by Peter Bødskov on 02/01/14.
//  Copyright (c) 2014 Peter Bødskov. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString * const PCUserNamePrefKey;
extern NSString * const PCPomodoroLengthPrefKey;
extern NSString * const PCGroupNamePrefKey;
extern NSString * const PCSendToServerPrefKey;
extern NSString * const PC_SETTINGS_WAS_UPDATED_NOTIFICATION;

@interface PCPreferenceWindowController : NSWindowController
@property (strong) IBOutlet NSTextFieldCell *userNameTextField;
@property (strong) IBOutlet NSTextFieldCell *pomodoroLengthTextField;
@property (strong) IBOutlet NSStepper *pomodoroLengthStepper;
@property (strong) IBOutlet NSTextFieldCell *groupTextField;
@property (strong) IBOutlet NSButton *sendToServerSwitch;

- (IBAction)stepperAction:(id)sender;
- (IBAction)checkboxTapped:(id)sender;

@end
