//
//  ActivityDataManager.m
//  Bitrun
//
//  Created by Yihe Li on 11/8/14.
//  Copyright (c) 2014 Yihe Li. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import "ActivityDataManager.h"
#import <UIKit/UIKit.h>

@implementation ActivityDataManager
{
    CMPedometer *_pedometer;
    CMMotionActivityManager *_motionActivityMgr;
}

- (instancetype) init
{
    if (self = [super init]){
        _walkingDuration = 0;
        _stepCounts = 0;
        [self _initMotionActivity];
    }
    return self;
}

- (void)_initMotionActivity
{
    _motionActivityMgr = [[CMMotionActivityManager alloc] init];
    _pedometer = [[CMPedometer alloc] init];
}

+ (BOOL)checkAvailability
{
    static dispatch_once_t sentinel;
    static BOOL available;
    dispatch_once(&sentinel, ^{
        available = YES;
        if ([CMMotionActivityManager isActivityAvailable]  == NO) {
            NSLog(@"Motion Activity is not available!");
            available = NO;
        }
        
        if ([CMPedometer isStepCountingAvailable] == NO) {
            NSLog(@"Step counting is not available!");
            available = NO;
        }
    });
    return available;
}

- (void)_handleError:(NSError *)error
{
    if (error.code == CMErrorMotionActivityNotAuthorized) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"This app is not authorized for M7"
                                                            message:@"No activity or step counting is available" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
            [alert show];
        });
    } else {
        NSLog(@"Error occurred %@", [error description]);
        return;
    }
}

- (void)checkAuthorization:(void (^)(BOOL authorized))authorizationCheckCompletedHandler
{
    NSDate *now = [NSDate date];
    [_pedometer queryPedometerDataFromDate:now toDate:now withHandler:^(CMPedometerData *pedometerData, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            authorizationCheckCompletedHandler(!error || error.code != CMErrorMotionActivityNotAuthorized);
        });
    }];
}

- (void)startStepUpdates:(stepUpdateHandler)handler;
{
    [_pedometer startPedometerUpdatesFromDate:[NSDate date] withHandler:^(CMPedometerData *pedometerData, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(pedometerData.numberOfSteps);
        });
    }];
}

- (void)stopStepUpdates
{
    [_pedometer stopPedometerUpdates];
}

- (void)startMotionUpdates:(motionUpdateHandler)handler
{
    [_motionActivityMgr startActivityUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMMotionActivity *activity) {
        handler([ActivityDataManager activityToType:activity]);
    }];
}

- (void)stopMotionUpdates;
{
    [_motionActivityMgr stopActivityUpdates];
}

#pragma mark Utility functions

+ (ActivityType)activityToType:(CMMotionActivity *)activity
{
    if (activity.walking) {
        return ActivityTypeWalking;
    } else if (activity.running) {
        return ActivityTypeRunning;
    } else if (activity.automotive) {
        return ActivityTypeDriving;
    } else if (activity.stationary) {
        return ActivityTypeStationary;
    } else if (!activity.unknown) {
        return ActivityTypeMoving;
    } else {
        return ActivityTypeNone;
    }
}
+ (NSString *)activityTypeToString:(ActivityType)type
{
    switch (type) {
        case ActivityTypeWalking:
            return @"Walking";
        case ActivityTypeRunning:
            return @"Running";
        case ActivityTypeDriving:
            return @"Automotive";
        case ActivityTypeStationary:
            return @"Not Moving";
        case ActivityTypeMoving:
            return @"Moving";
        default:
            return @"Unclassified";
    }
}




@end
