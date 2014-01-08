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

@interface PCPreferenceWindowController : NSWindowController
@property (strong) IBOutlet NSTextFieldCell *userNameTextField;
@property (strong) IBOutlet NSTextFieldCell *pomodoroLengthTextField;
@property (strong) IBOutlet NSStepper *pomodoroLengthStepper;
@property (strong) IBOutlet NSTextFieldCell *groupTextField;

- (IBAction)stepperAction:(id)sender;

@end
