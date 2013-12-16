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

@end
