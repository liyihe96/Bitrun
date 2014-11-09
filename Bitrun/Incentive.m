//
//  Incentive.m
//  Bitrun
//
//  Created by Yihe Li on 11/9/14.
//  Copyright (c) 2014 Yihe Li. All rights reserved.
//

#import "Incentive.h"
#import "Utility.h"

@implementation Incentive

- (instancetype)initWithDictionary:(NSDictionary *)dic
{
    if (self = [super init]) {
        NSLog(@"%@, %@ ",[dic objectForKey:@"create_date"], [dic objectForKey:@"expire_date"]);
        
        _createDate = [Utility dateFromiso8601String: [dic objectForKey:@"create_date"]];
        _expireDate = [Utility dateFromiso8601String: [dic objectForKey:@"expire_date"]];
        _goal = [dic objectForKey:@"goal"];
        _amount = [dic objectForKey:@"amount"];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@,%@,%@,%@",self.createDate,self.expireDate,self.goal,self.amount];
}
- (instancetype)initWithGoal:(NSNumber *)goal
{
    if (self = [super init]) {
        NSLog(@"setGOAL");
        _goal = goal;
        _createDate = nil;
        _expireDate = nil;
        _amount = nil;
    }
    return self;
}

@end
