//
//  PCSession.h
//  PomodoriClient
//
//  Created by Peter Bødskov on 16/12/13.
//  Copyright (c) 2013 Peter Bødskov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCSession : NSObject

typedef NS_ENUM(NSInteger, UserInformationPomodoroStatus) {
    UserInformationPomodoroStatusActive,
    UserInformationPomodoroStatusPaused,
    UserInformationPomodoroStatusDone
};

@property (nonatomic, strong)   NSString *userName;
@property (nonatomic)           UserInformationPomodoroStatus status;
@property (nonatomic)           NSInteger remainingMinutes;
@property (nonatomic)           NSInteger remainingSeconds;
@property (nonatomic, strong)   NSString *group;

+ (instancetype)newFromJSON:(NSDictionary *)json;

@end
