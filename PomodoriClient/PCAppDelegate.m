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

@interface PCAppDelegate()
@property (nonatomic, strong) NSArray *sessions;

@end

@implementation PCAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    self.sessions = [NSArray array];
}

- (IBAction)testServerConnection:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *url = @"http://localhost:5000/update";
    NSDictionary *postBody = @{@"username": @"Peter", @"remainingtime" : @"24:00", @"status" : @"active", @"group" : @"JBMobile"};
    [manager POST:url parameters:postBody
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
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure, error %@", error);
    }];
}

@end
