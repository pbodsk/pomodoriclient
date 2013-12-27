//
//  PCSession.m
//  PomodoriClient
//
//  Created by Peter Bødskov on 16/12/13.
//  Copyright (c) 2013 Peter Bødskov. All rights reserved.
//

#import "PCSession.h"

@implementation PCSession

- (instancetype)initWithUserName:(NSString *)userName status:(PCSessionPomodoroStatus)status remainingTimeInSeconds:(NSInteger)remainingTimeInSeconds group:(NSString *)group {
    self = [super init];
    if (self) {
        self.userName = userName;
        self.status = status;
        self.remainingTimeInSeconds = remainingTimeInSeconds;
        self.group = group;
    }
    return self;
    
}

+ (instancetype)newFromJSON:(NSDictionary *)json {
    PCSession *returnValue = [PCSession new];
    returnValue.userName = [json valueForKey:@"username"];
    returnValue.group = [json valueForKey:@"group"];
    
    NSString *remainingTimeString = [json valueForKey:@"remainingtime"];
    NSArray *timeComponents = [remainingTimeString componentsSeparatedByString:@":"];
    NSString *remainingMinutesString = [timeComponents objectAtIndex:0];
    NSString *remainingSecondsString = [timeComponents objectAtIndex:1];
    NSInteger remainingMinutes = remainingMinutesString.integerValue;
    NSInteger remainingSeconds = remainingSecondsString.integerValue;
    returnValue.remainingTimeInSeconds = (remainingMinutes * 60) + remainingSeconds;
    
    NSString *statusString = [json valueForKey:@"status"];
    if([statusString isEqualToString:@"active"]) {
        returnValue.status = PCSessionPomodoroStatusActive;
    }
    if([statusString isEqualToString:@"paused"]) {
        returnValue.status = PCSessionPomodoroStatusPaused;
    }
    if([statusString isEqualToString:@"done"]) {
        returnValue.status = PCSessionPomodoroStatusDone;
    }

    return returnValue;
}

- (NSDictionary *)postDataAsDictionary {
    NSString *statusString;
    switch (self.status) {
        case PCSessionPomodoroStatusPaused:
            statusString = @"paused";
            break;
        case PCSessionPomodoroStatusDone:
            statusString = @"done";
            break;
        default:
            statusString = @"active";
            break;
    }
    NSString *remainingTimeString = [self remainingTimeAsPresentationString];
    return @{@"username": self.userName, @"remainingtime" : remainingTimeString, @"status" : statusString, @"group" : self.group};
}

- (NSString *)remainingTimeAsPresentationString {
    NSInteger minutes = self.remainingTimeInSeconds / 60;
    NSInteger seconds = self.remainingTimeInSeconds - (minutes * 60);
    return [NSString stringWithFormat:@"%02li:%02li", (long)minutes, (long)seconds];    
}

- (void)updateRemainingTime {
    if(self.remainingTimeInSeconds > 0){
        self.remainingTimeInSeconds -= 1;
    }
}

- (BOOL)sessionHasEnded {
    return self.remainingTimeInSeconds <= 0;
}

- (NSString *)stringFromStatus {
    NSString *returnString;
    if(self.status == PCSessionPomodoroStatusActive){
        returnString = @"Active";
    }
    
    if(self.status == PCSessionPomodoroStatusPaused){
        returnString = @"Paused";
    }
    
    if(self.status == PCSessionPomodoroStatusDone){
        returnString = @"Done";
    }
    return returnString;
}

@end
