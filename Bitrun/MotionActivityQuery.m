//
//  MotionActivityQuery.m
//  Bitrun
//
//  Created by Yihe Li on 11/8/14.
//  Copyright (c) 2014 Yihe Li. All rights reserved.
//

#import "MotionActivityQuery.h"

@implementation MotionActivityQuery

- (instancetype) initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate isToday:(BOOL)isToday
{
    if (self = [super init]) {
        _startDate = startDate;
        _endDate = endDate;
        _isToday = isToday ;
    }
    return self;
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

+ (MotionActivityQuery *)queryStartingFromDate:(NSDate *)startDate offsetByDay:(NSInteger)offset
{
    NSCalendar *calender = [NSCalendar  currentCalendar];
    NSDateComponents *dateComponents = [calender components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:startDate];
    dateComponents.hour = 0;
    dateComponents.day += offset;
    NSDate *queryStart = [calender dateFromComponents:dateComponents];
    dateComponents.day += 1;
    NSDate *queryEnd = [calender dateFromComponents:dateComponents];
    return [[MotionActivityQuery alloc] initWithStartDate:queryStart endDate:queryEnd isToday:offset == 0];
}
@end
