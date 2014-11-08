//
//  ActivityDataManager.h
//  Bitrun
//
//  Created by Yihe Li on 11/8/14.
//  Copyright (c) 2014 Yihe Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMMotionActivity;

typedef void (^stepUpdateHandler)(NSNumber *stepCount);
typedef void (^motionUpdateHandler)();

@interface ActivityDataManager:NSObject 
+ (BOOL)checkAvailability;
- (void)checkAuthorization:(void (^)(BOOL authorized))authorizationCheckCompletedHandler;

@property (readonly, nonatomic) NSTimeInterval walkingDuration;
@property (readonly, nonatomic) NSNumber *stepCounts;

// Live update functionality
- (void)startStepUpdates:(stepUpdateHandler)handler;
- (void)stopStepUpdates;

- (void)startMotionUpdates:(motionUpdateHandler)handler;
- (void)stopMotionUpdates;

@end

