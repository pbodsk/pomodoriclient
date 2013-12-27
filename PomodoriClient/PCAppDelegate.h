//
//  PCAppDelegate.h
//  PomodoriClient
//
//  Created by Peter Bødskov on 16/12/13.
//  Copyright (c) 2013 Peter Bødskov. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PCAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
- (IBAction)testServerConnection:(id)sender;
@property (weak) IBOutlet NSButton *startButton;
@property (weak) IBOutlet NSButton *pauseButton;
@property (weak) IBOutlet NSButton *resetButton;
@property (weak) IBOutlet NSTextFieldCell *timerLabel;
- (IBAction)startButtonTapped:(id)sender;
- (IBAction)pauseButtonTapped:(id)sender;
- (IBAction)resetButtonTapped:(id)sender;
@end
