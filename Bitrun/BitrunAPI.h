//
//  BitrunAPI.h
//  Bitrun
//
//  Created by Yihe Li on 11/8/14.
//  Copyright (c) 2014 Yihe Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import <SIOSocket/SIOSocket.h>

#define baseUrl @"http://requestb.in/puypi6pu"

@interface BitrunAPI : NSObject
+ (BitrunAPI *)sharedInstance;
- (void)emit:(NSString *)event args:(SIOParameterArray *)args;
+ (NSDictionary *)argsAppendByAccessToken:(NSDictionary *)args;
+ (NSString *)iso8601StringFromDate:(NSDate *)date;
- (void)getRequest:(NSString*)url success:(void(^)(AFHTTPRequestOperation *, id))success;
@end
