//
//  ActivityDataManager.m
//  Bitrun
//
//  Created by Yihe Li on 11/8/14.
//  Copyright (c) 2014 Yihe Li. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import "ActivityDataManager.h"

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

- (void)_handleError:(NSError *)error
{
    if (error.code == CMErrorMotionActivityNotAuthorized) {
        dispatch_async(dispatch_get_main_queue(), ^{
//            UIAlertController *alertController = [UIAlertController
//                                                  alertControllerWithTitle:@"This app is not authorized for M7"
//                                                  message:@"No activity or step counting is available"
//                                                  preferredStyle:UIAlertControllerStyleAlert];
//            [self presentViewController:alertController animated:YES completion:nil];
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
        handler();
    }];
}

- (void)stopMotionUpdates;
{
    [_motionActivityMgr stopActivityUpdates];
}



@end
