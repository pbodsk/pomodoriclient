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
#import "PCPreferenceWindowController.h"

//static const NSInteger kDefaultPomodoTime = 30  ;
//static NSString *const kUrlString = @"http://localhost:5000/update";
static NSString *const kUrlFetchString = @"http://limitless-island-2966.herokuapp.com/fetch";
static NSString *const kUrlUpdateString = @"http://limitless-island-2966.herokuapp.com/update";
static NSString *const kUrlRemoveString = @"http://limitless-island-2966.herokuapp.com/remove";

@interface PCAppDelegate()
@property (nonatomic, strong) NSArray *sessions;
@property (nonatomic, strong) PCSession *currentUserSession;
@property (nonatomic, strong) NSTimer *pomodoroTimer;
@property (nonatomic, strong) NSTimer *fetchSessionsTimer;
@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic, strong) PCPreferenceWindowController *preferenceWindowController;
@end

@implementation PCAppDelegate

+ (void)initialize {
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:PCUserNamePrefKey];
    if(! userName){
        NSMutableDictionary *userPreferences = [NSMutableDictionary dictionary];
        [userPreferences setObject:[[NSHost currentHost]name] forKey:PCUserNamePrefKey];
        [userPreferences setObject:@25 forKey:PCPomodoroLengthPrefKey];
        [userPreferences setObject:@"JBMobile" forKey:PCGroupNamePrefKey];
        [[NSUserDefaults standardUserDefaults]registerDefaults:userPreferences];        
    }
}

#pragma mark - Application lifecycle methods
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self.window setReleasedWhenClosed:false];
    self.window.delegate = self;
    [self handleInitialization];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [self handleTermination];
}

- (void)windowWillClose:(NSNotification *)notification {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self handleTermination];
}

- (void)handleTermination {
    [self invalidatePomodoroTimerAndUpdateTimer];
    [self invalidateFetchSessionsTimer];
    [self removeOldUserNameFromServer];
}

- (void)handleInitialization {
    self.sessions = [NSArray array];
    self.usersTable.delegate = self;
    self.usersTable.dataSource = self;
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:PCUserNamePrefKey];
    NSString *groupName = [[NSUserDefaults standardUserDefaults] objectForKey:PCGroupNamePrefKey];
    NSInteger remainingTimeInSeconds = [self remainingTimeInSecondsFromPreferences];
    self.currentUserSession = [[PCSession alloc]initWithUserName:userName status:PCSessionPomodoroStatusActive remainingTimeInSeconds:remainingTimeInSeconds group:groupName];
    [self.startButton setHidden:NO];
    [self.pauseButton setHidden:YES];
    [self displayRemainingTime];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(userSettingsWasUpdated) name:PC_SETTINGS_WAS_UPDATED_NOTIFICATION object:nil];
    [self fetchUserSessions];
    [self startFetchSessionsTimer];
}

#pragma mark - Timer logic
- (void)startFetchSessionsTimer {
    [self invalidateFetchSessionsTimer];
    self.fetchSessionsTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(fetchUserSessions) userInfo:nil repeats:YES];
}

- (void)startTimers {
    //just to be sure
    [self invalidatePomodoroTimerAndUpdateTimer];
    self.pomodoroTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updatePomodoriTimer) userInfo:nil repeats:YES];
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(sendUserSessionToServer) userInfo:nil repeats:YES];
}

- (void)invalidatePomodoroTimerAndUpdateTimer {
    [self invalidatePomodoroTimer];
    [self invalidateUpdateTimer];
}

- (void)invalidateUpdateTimer {
    [self.updateTimer invalidate];
    self.updateTimer = nil;
}

- (void)invalidatePomodoroTimer {
    [self.pomodoroTimer invalidate];
    self.pomodoroTimer = nil;
}

- (void)invalidateFetchSessionsTimer {
    [self.fetchSessionsTimer invalidate];
    self.fetchSessionsTimer = nil;
}

#pragma mark - Methods to be called by timers
- (void)updatePomodoriTimer {
    [self.currentUserSession updateRemainingTime];
    [self displayRemainingTime];
    if([self.currentUserSession sessionHasEnded]){
        self.currentUserSession.status = PCSessionPomodoroStatusDone;
        [self sendUserSessionToServer];
        [self invalidatePomodoroTimerAndUpdateTimer];
        [self postPomodoroDoneNotification];
        [self.pauseButton setHidden:YES];
        [self.startButton setHidden:NO];
        self.currentUserSession.remainingTimeInSeconds = [self remainingTimeInSecondsFromPreferences];
        [self displayRemainingTime];
    }
}

- (void)sendUserSessionToServer {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *postBody = [self.currentUserSession postDataAsDictionary];
    [manager POST:kUrlUpdateString parameters:postBody
          success:^(AFHTTPRequestOperation *operation, id responseObject){
 //             NSLog(@"success");
          }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
 //             NSLog(@"failure, error %@", error);
          }
     ];
}

- (void)fetchUserSessions {
   // NSLog(@"%s", __PRETTY_FUNCTION__);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *group = @{@"group": self.currentUserSession.group};
    [manager GET:kUrlFetchString parameters:group
          success:^(AFHTTPRequestOperation *operation, id responseObject){
     //         NSLog(@"success");
              self.sessions = nil;
              NSMutableArray *newSessions = [NSMutableArray new];
              NSArray *returnArray = (NSArray *)responseObject;
              for (NSUInteger i = 0; i < returnArray.count; i++) {
                  NSDictionary *currentElement = [returnArray objectAtIndex:i];
                  PCSession *currentSession = [PCSession newFromJSON:currentElement];
                  [newSessions addObject:currentSession];
              }
              self.sessions = [NSArray arrayWithArray:newSessions];
              [self.usersTable reloadData];
       //       NSLog(@"number of sessions: %li", (unsigned long)[self.sessions count]);
          }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         //     NSLog(@"failure, error %@", error);
          }
     ];
}

#pragma mark - Presentation methods
- (void)displayRemainingTime {
    self.timerLabel.title = [self.currentUserSession remainingTimeAsPresentationString];
}

#pragma mark - Button methods

- (IBAction)startButtonTapped:(id)sender {
    [self.startButton setHidden:YES];
    [self.pauseButton setHidden:NO];
    self.currentUserSession.status = PCSessionPomodoroStatusActive;
    [self sendUserSessionToServer];
    [self startTimers];
}

- (IBAction)pauseButtonTapped:(id)sender {
    [self.startButton setHidden:NO];
    [self.pauseButton setHidden:YES];
    //TODO only invalidate pomodoroTimer, let networkTimer continue
    [self invalidatePomodoroTimer];
    self.currentUserSession.status = PCSessionPomodoroStatusPaused;
    [self sendUserSessionToServer];
}

- (IBAction)resetButtonTapped:(id)sender {
    [self.startButton setHidden:NO];
    [self.pauseButton setHidden:YES];
    [self.pauseButton setEnabled:YES];
    [self invalidatePomodoroTimerAndUpdateTimer];
    self.currentUserSession.remainingTimeInSeconds = [self remainingTimeInSecondsFromPreferences];
    self.currentUserSession.status = PCSessionPomodoroStatusDone;
    [self sendUserSessionToServer];
    [self displayRemainingTime];
}

#pragma mark - NSTableViewDataSource methods
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.sessions.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    PCSession *sessionForRow = [self.sessions objectAtIndex:row];
    if([tableColumn.identifier isEqualToString:@"userName"]){
        return sessionForRow.userName;
    }
    
    if([tableColumn.identifier isEqualToString:@"remainingTime"]){
        return [sessionForRow remainingTimeAsPresentationString];
    }

    if([tableColumn.identifier isEqualToString:@"status"]){
        return [sessionForRow stringFromStatus];
    }
    return @"";
}

#pragma mark - NSTableViewDelegate methods

#pragma mark - Notifications
- (void)postPomodoroDoneNotification {
    NSUserNotification *pomodoroDoneNotification = [NSUserNotification new];
    pomodoroDoneNotification.title = @"Time's up";
    pomodoroDoneNotification.informativeText = @"Well done, your pomodoro session is done. Time for a quick break";
    pomodoroDoneNotification.soundName = NSUserNotificationDefaultSoundName;
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:pomodoroDoneNotification];
}

#pragma mark - Preference view handling
- (IBAction)showPreferencePanel:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (! self.preferenceWindowController) {
        self.preferenceWindowController = [[PCPreferenceWindowController alloc]init];
    }
    [self.preferenceWindowController showWindow:self];
}

- (IBAction)openNewWindow:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self.window makeKeyAndOrderFront:self];
    [self handleInitialization];
}


#pragma mark - Prefence methods
- (void)userSettingsWasUpdated {
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:PCUserNamePrefKey];
    NSString *groupName = [[NSUserDefaults standardUserDefaults] objectForKey:PCGroupNamePrefKey];
    if(![userName isEqualToString:self.currentUserSession.userName]){
        [self removeOldUserNameFromServer];
    }
    self.currentUserSession.userName = userName;
    self.currentUserSession.group = groupName;
}

- (void)removeOldUserNameFromServer {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *postBody = [self.currentUserSession postDataAsDictionary];
    [manager POST:kUrlRemoveString parameters:postBody
          success:^(AFHTTPRequestOperation *operation, id responseObject){
              NSLog(@"success");
              [self.usersTable reloadData];
          }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"failure, error %@", error);
          }
     ];
}

- (NSInteger) remainingTimeInSecondsFromPreferences {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:PCPomodoroLengthPrefKey] integerValue] * 60;
}

@end
