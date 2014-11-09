//
//  Utility.h
//  Bitrun
//
//  Created by Yihe Li on 11/8/14.
//  Copyright (c) 2014 Yihe Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Utility : NSObject

+ (void)insertBlurView:(UIView *)view withStyle:(UIBlurEffectStyle)style;
+ (NSString *)iso8601StringFromDate:(NSDate *)date;
+ (NSDate *)dateFromiso8601String:(NSString *)string;
@end
