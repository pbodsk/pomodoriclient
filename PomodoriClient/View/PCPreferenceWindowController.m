//
//  PCPreferenceWindowController.m
//  PomodoriClient
//
//  Created by Peter Bødskov on 02/01/14.
//  Copyright (c) 2014 Peter Bødskov. All rights reserved.
//

#import "PCPreferenceWindowController.h"

@interface PCPreferenceWindowController ()

@end

@implementation PCPreferenceWindowController

- (id)init {
    self = [super initWithWindowNibName:@"PCPreferenceWindowController"];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.pomodoroLengthTextField setIntValue:[self.pomodoroLengthStepper intValue]];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)stepperAction:(id)sender {
    [self.pomodoroLengthTextField setIntValue:[self.pomodoroLengthStepper intValue]];
}

@end
