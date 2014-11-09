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
#import "LocalManager.h"
#import "Incentive.h"

#define baseUrl @"bitrunapp.herokuapp.com/api/"

@interface BitrunAPI : NSObject
+ (BitrunAPI *)sharedInstance;
- (void)emit:(NSString *)event args:(SIOParameterArray *)args;
+ (NSDictionary *)argsAppendByAccessToken:(NSDictionary *)args;
- (void)getRequest:(NSString*)url success:(void(^)(AFHTTPRequestOperation *, id))success fail:(void(^)(AFHTTPRequestOperation *, NSError *))failure;
- (void)postRequest:(NSString *)url parameters:(NSDictionary *)parameter success:(void(^)(AFHTTPRequestOperation *,id))success;
- (void)addIncentive:(Incentive *)incentive;
- (void)addProgress:(NSNumber *)progress;
- (Incentive *)getIncentive;
- (NSNumber *)getTotalProgress;
- (void)newProgress:(NSNumber *)progress;
- (double)getProgreeRatio;

@end
