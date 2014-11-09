//
//  LocalManager.m
//  Bitrun
//
//  Created by Yihe Li on 11/9/14.
//  Copyright (c) 2014 Yihe Li. All rights reserved.
//

#import "LocalManager.h"

@implementation LocalManager
{
    Incentive *_incentive;
    NSNumber *_progress;
    NSNumber *_newProgress;
}

- (void)newProgress:(NSNumber *)progress
{
    _newProgress = progress;
}
- (void)addIncentive:(Incentive *)incentive
{
    _incentive = incentive;
}

- (void)addProgress:(NSNumber *)progress
{
    _progress = progress;
}

- (Incentive *)getIncentive
{
    return _incentive;
}

- (NSNumber *)getTotalProgress
{
    return @([_progress doubleValue] + [_newProgress doubleValue]);
}

- (double)getProgreeRatio
{
    return [[self getTotalProgress] doubleValue] / [[self getIncentive].goal doubleValue];
}


@end
