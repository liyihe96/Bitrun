//
//  MotionActivityQuery.h
//  Bitrun
//
//  Created by Yihe Li on 11/8/14.
//  Copyright (c) 2014 Yihe Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MotionActivityQuery : NSObject
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;
@property BOOL isToday;

- (NSString *)description;
+ (MotionActivityQuery *)queryStartingFromDate:(NSDate *)date offsetByDay:(NSInteger)offset;

@end
