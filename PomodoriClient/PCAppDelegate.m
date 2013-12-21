//
//  PCAppDelegate.m
//  PomodoriClient
//
//  Created by Peter Bødskov on 16/12/13.
//  Copyright (c) 2013 Peter Bødskov. All rights reserved.
//

#import "PCAppDelegate.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "PCSession.h"

static const NSInteger kDefaultPomodoTime = 25*60;
static NSString *const kUrlString = @"http://localhost:5000/update";

@interface PCAppDelegate()
@property (nonatomic, strong) NSArray *sessions;
@property (nonatomic, strong) PCSession *currentUserSession;
@end

@implementation PCAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    self.sessions = [NSArray array];
    self.currentUserSession = [[PCSession alloc]initWithUserName:@"Peter" status:PCSessionPomodoroStatusActive remainingTimeInSeconds:kDefaultPomodoTime group:@"JBMobile"];
}

- (IBAction)testServerConnection:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *postBody = [self.currentUserSession postDataAsDictionary];
    [manager POST:kUrlString parameters:postBody
    success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSLog(@"success");
        self.sessions = nil;
        NSMutableArray *newSessions = [NSMutableArray new];
        NSArray *returnArray = (NSArray *)responseObject;
        for (NSUInteger i = 0; i < returnArray.count; i++) {
            NSDictionary *currentElement = [returnArray objectAtIndex:i];
            PCSession *currentSession = [PCSession newFromJSON:currentElement];
            [newSessions addObject:currentSession];
        }
        self.sessions = [NSArray arrayWithArray:newSessions];
        NSLog(@"number of sessions: %li", (unsigned long)[self.sessions count]);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure, error %@", error);
    }];
}

@end
