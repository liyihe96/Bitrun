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
//    if (!_incentive)
//    {
//        NSLog(@"----------shit");
//        _incentive = [[Incentive alloc] initWithGoal:0];
//    }
//    NSLog(@"%@",_incentive);
    return _incentive;
}

- (NSNumber *)getTotalProgress
{
    return @([_progress doubleValue] + [_newProgress doubleValue]);
}

- (double)getProgreeRatio
{
    if ([[self getIncentive].goal doubleValue] == 0)
        return 1;
    return [[self getTotalProgress] doubleValue] / [[self getIncentive].goal doubleValue];
}


@end
