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
@property (nonatomic, strong) NSTimer *pomodoroTimer;
@property (nonatomic, strong) NSTimer *networkTimer;
@end

@implementation PCAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    self.sessions = [NSArray array];
    //TODO - get name remainingTime and group from preferences instead
    self.currentUserSession = [[PCSession alloc]initWithUserName:@"Peter" status:PCSessionPomodoroStatusActive remainingTimeInSeconds:kDefaultPomodoTime group:@"JBMobile"];
    [self.pauseButton setHidden:YES];
    [self displayRemainingTime];
    
}

#pragma mark - Timer logic
- (void)startTimers {
    self.pomodoroTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updatePomodoriTimer) userInfo:nil repeats:YES];
    self.networkTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(sendUserSessionToServer) userInfo:nil repeats:YES];
}

- (void)invalidateTimers {
    [self.pomodoroTimer invalidate];
    self.pomodoroTimer = nil;
    [self.networkTimer invalidate];
    self.networkTimer = nil;
}

#pragma mark - Methods to be called by timers
- (void)updatePomodoriTimer {
    [self.currentUserSession updateRemainingTime];
    [self displayRemainingTime];
    if([self.currentUserSession sessionHasEnded]){
        self.currentUserSession.status = PCSessionPomodoroStatusDone;
        [self sendUserSessionToServer];
        [self invalidateTimers];
        //TODO post notification that session has ended
    }
}

- (void)sendUserSessionToServer {
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

#pragma mark - Presentation methods
- (void)displayRemainingTime {
    self.timerLabel.title = [self.currentUserSession remainingTimeAsPresentationString];
}

#pragma mark - Button mehods

- (IBAction)startButtonTapped:(id)sender {
    [self.startButton setHidden:YES];
    [self.pauseButton setHidden:NO];
    [self startTimers];
}

- (IBAction)pauseButtonTapped:(id)sender {
    [self.startButton setHidden:NO];
    [self.pauseButton setHidden:YES];
    [self invalidateTimers];
    self.currentUserSession.status = PCSessionPomodoroStatusPaused;
    [self sendUserSessionToServer];
}

- (IBAction)resetButtonTapped:(id)sender {
    [self.startButton setHidden:NO];
    [self.pauseButton setHidden:YES];
    [self invalidateTimers];
    self.currentUserSession.remainingTimeInSeconds = kDefaultPomodoTime;
    self.currentUserSession.status = PCSessionPomodoroStatusDone;
    [self sendUserSessionToServer];
    [self displayRemainingTime];
}
@end
