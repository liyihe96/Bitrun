//
//  Incentive.h
//  Bitrun
//
//  Created by Yihe Li on 11/9/14.
//  Copyright (c) 2014 Yihe Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Incentive : NSObject

@property (nonatomic, copy, readonly) NSDate *createDate, *expireDate;
@property (nonatomic, copy, readonly) NSNumber *amount, *goal;

- (instancetype)initWithDictionary:(NSDictionary *)dic;
- (instancetype)initWithGoal:(NSNumber *)goal;
- (NSString *)description;
@end
