//
//  MotionActivityQuery.m
//  Bitrun
//
//  Created by Yihe Li on 11/8/14.
//  Copyright (c) 2014 Yihe Li. All rights reserved.
//

#import "MotionActivityQuery.h"

@implementation MotionActivityQuery

- (instancetype)initWithDateRangeStartingFrom:(NSDate *)startDate to:(NSDate *)endDate isToday:(BOOL)today
{
    if ((self = [super init]) != nil) {
        _startDate = startDate;
        _endDate = endDate;
        _isToday = isToday;
        return self;
    }
    return nil;
}

- (NSString *)description
{
    if (_isToday) {
        return @"Today";
    } else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSString *format = [NSDateFormatter dateFormatFromTemplate:@"EdMMM" options:0
                                                            locale:[NSLocale currentLocale]];
        [formatter setDateFormat:format];
        return [formatter stringFromDate:_startDate];
    }
}

+ (MotionActivityQuery *)queryStartingFromDate:(NSDate *)date offsetByDay:(NSInteger)offset
{
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *timeComponents = [currentCalendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    timeComponents.hour = 0;
    timeComponents.day = timeComponents.day + offset;
    
    NSDate *queryStart = [currentCalendar dateFromComponents:timeComponents];
    
    timeComponents.day = timeComponents.day + 1;
    NSDate *queryEnd = [currentCalendar dateFromComponents:timeComponents];
    
    return [[MotionActivityQuery alloc] initWithDateRangeStartingFrom:queryStart to:queryEnd isToday:(offset == 0)];
}

@end
