//
//  PCSession.h
//  PomodoriClient
//
//  Created by Peter Bødskov on 16/12/13.
//  Copyright (c) 2013 Peter Bødskov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCSession : NSObject

typedef NS_ENUM(NSInteger, PCSessionPomodoroStatus) {
    PCSessionPomodoroStatusActive,
    PCSessionPomodoroStatusPaused,
    PCSessionPomodoroStatusDone
};

@property (nonatomic, strong)   NSString *userName;
@property (nonatomic)           PCSessionPomodoroStatus status;
@property (nonatomic)           NSInteger remainingTimeInSeconds;
@property (nonatomic, strong)   NSString *group;

- (instancetype)initWithUserName:(NSString *)userName status:(PCSessionPomodoroStatus)status remainingTimeInSeconds:(NSInteger)remainingTimeInSeconds group:(NSString *)group;
+ (instancetype)newFromJSON:(NSDictionary *)json;
- (NSDictionary *)postDataAsDictionary;
- (NSString *)remainingTimeAsPresentationString;
- (void)updateRemainingTime;
- (BOOL)sessionHasEnded;
- (NSString *)stringFromStatus;
@end
