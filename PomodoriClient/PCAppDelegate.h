//
//  PCAppDelegate.h
//  PomodoriClient
//
//  Created by Peter Bødskov on 16/12/13.
//  Copyright (c) 2013 Peter Bødskov. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PCAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate, NSWindowDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSButton *startButton;
@property (weak) IBOutlet NSButton *pauseButton;
@property (weak) IBOutlet NSButton *resetButton;
@property (weak) IBOutlet NSTextFieldCell *timerLabel;
@property (weak) IBOutlet NSTableView *usersTable;

- (IBAction)startButtonTapped:(id)sender;
- (IBAction)pauseButtonTapped:(id)sender;
- (IBAction)resetButtonTapped:(id)sender;
- (IBAction)showPreferencePanel:(id)sender;
- (IBAction)openNewWindow:(id)sender;
@end
