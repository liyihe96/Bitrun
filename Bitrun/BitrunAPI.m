//
//  BitrunAPI.m
//  Bitrun
//
//  Created by Yihe Li on 11/8/14.
//  Copyright (c) 2014 Yihe Li. All rights reserved.
//

#import "BitrunAPI.h"

@interface BitrunAPI()
@property (nonatomic, strong) SIOSocket * socket;
@property BOOL socketIsConnected;
@end

@implementation BitrunAPI

- (instancetype)init
{
    if (self = [super init]) {
        [SIOSocket socketWithHost: @"http://localhost:3000" response: ^(SIOSocket *socket)
         {
             self.socket = socket;
         }];
        __weak typeof(self) weakSelf = self;
        self.socket.onConnect = ^()
        {
            weakSelf.socketIsConnected = YES;
        };
    }
    return self;
}

+ (BitrunAPI*)sharedInstance
{
    // 1
    static BitrunAPI *_sharedInstance = nil;
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[BitrunAPI alloc] init];
    });
    return _sharedInstance;
}

- (void)emit:(NSString *)event args:(SIOParameterArray *)args
{
    if (self.socketIsConnected)
    {
        [self.socket emit:event args:args];
    }
}

+ (SIOParameterArray *)argsAppendByAccessToken:(SIOParameterArray *)args
{
    if ([args isKindOfClass:[NSDictionary class]])
    {
        NSMutableDictionary *newArgs = [NSMutableDictionary dictionaryWithDictionary:((NSDictionary *) args)];
        [newArgs addEntriesFromDictionary:@{@"access_token":[[NSUserDefaults  standardUserDefaults] valueForKey:@"CoinBaseAccessToken"]}];
        return [newArgs copy];
    }
    return args;
}

@end
