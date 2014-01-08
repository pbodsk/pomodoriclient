//
//  PCPreferenceWindowController.m
//  PomodoriClient
//
//  Created by Peter Bødskov on 02/01/14.
//  Copyright (c) 2014 Peter Bødskov. All rights reserved.
//

#import "PCPreferenceWindowController.h"

NSString * const PCUserNamePrefKey = @"PCUserNamePrefKey";
NSString * const PCPomodoroLengthPrefKey = @"PCPomodoroLengthPrefKey";
NSString * const PCGroupNamePrefKey = @"PCGroupNamePrefKey";

@interface PCPreferenceWindowController ()
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, assign) NSInteger pomodoroLength;
@property (nonatomic, strong) NSString *groupName;
@end

@implementation PCPreferenceWindowController

- (id)init {
    self = [super initWithWindowNibName:@"PCPreferenceWindowController"];
    if (self) {
        self.userName = [[NSUserDefaults standardUserDefaults]objectForKey:PCUserNamePrefKey];
        self.pomodoroLength = [[[NSUserDefaults standardUserDefaults]objectForKey:PCPomodoroLengthPrefKey] integerValue];
        self.groupName = [[NSUserDefaults standardUserDefaults]objectForKey:PCGroupNamePrefKey];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    self.pomodoroLengthStepper.integerValue = self.pomodoroLength;
    self.userNameTextField.stringValue = self.userName;
    [self.pomodoroLengthTextField setIntegerValue:self.pomodoroLength];
    self.groupTextField.stringValue = self.groupName;
}

- (void)windowWillClose:(NSNotification *)notification {
    self.userName = self.userNameTextField.stringValue;
    self.pomodoroLength = self.pomodoroLengthStepper.integerValue;
    self.groupName = self.groupTextField.stringValue;
    [[NSUserDefaults standardUserDefaults] setObject:self.userName forKey:PCUserNamePrefKey];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:self.pomodoroLength] forKey:PCPomodoroLengthPrefKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.groupName forKey:PCGroupNamePrefKey];
}

- (IBAction)stepperAction:(id)sender {
    [self.pomodoroLengthTextField setIntValue:[self.pomodoroLengthStepper intValue]];
    self.pomodoroLength = self.pomodoroLengthStepper.integerValue;
}



@end
