//
//  PCSession.m
//  PomodoriClient
//
//  Created by Peter Bødskov on 16/12/13.
//  Copyright (c) 2013 Peter Bødskov. All rights reserved.
//

#import "PCSession.h"

@implementation PCSession

+ (instancetype)newFromJSON:(NSDictionary *)json {
    PCSession *returnValue = [PCSession new];
    returnValue.userName = [json valueForKey:@"username"];
    returnValue.group = [json valueForKey:@"group"];
    
    NSString *remainingTimeString = [json valueForKey:@"remainingtime"];
    NSArray *timeComponents = [remainingTimeString componentsSeparatedByString:@":"];
    NSString *remainingMinutesString = [timeComponents objectAtIndex:0];
    NSString *remainingSecondsString = [timeComponents objectAtIndex:1];
    returnValue.remainingMinutes = remainingMinutesString.integerValue;
    returnValue.remainingSeconds = remainingSecondsString.integerValue;
    
    NSString *statusString = [json valueForKey:@"status"];
    if([statusString isEqualToString:@"active"]) {
        returnValue.status = UserInformationPomodoroStatusActive;
    }
    if([statusString isEqualToString:@"paused"]) {
        returnValue.status = UserInformationPomodoroStatusPaused;
    }
    if([statusString isEqualToString:@"done"]) {
        returnValue.status = UserInformationPomodoroStatusDone;
    }

    return returnValue;
}

@end
