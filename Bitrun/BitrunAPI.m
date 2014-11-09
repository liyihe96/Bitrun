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
@property (nonatomic, strong) AFHTTPRequestOperationManager *httpManager;
//@property BOOL socketIsConnected;
@end

@implementation BitrunAPI

- (instancetype)init
{
    if (self = [super init]) {
        [SIOSocket socketWithHost: @"http://bitrunapp.herokuapp.com" response: ^(SIOSocket *socket)
         {
             self.socket = socket;
         }];
//        __weak typeof(self) weakSelf = self;
//        self.socket.onConnect = ^()
//        {
//            weakSelf.socketIsConnected = YES;
//        };
        self.httpManager = [AFHTTPRequestOperationManager manager];
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
    NSLog(@"----------CAlled");
//    if (self.socketIsConnected)
//    {
        NSLog(@"-------------SENT");
        [self.socket emit:event args:args];
//    }
}

+ (SIOParameterArray *)argsAppendByAccessToken:(SIOParameterArray *)args
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:args];
    [array addObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"CoinBaseAccessToken"]];
    return array;
}

+ (NSString *)iso8601StringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    
    NSString *iso8601String = [dateFormatter stringFromDate:date];
    return iso8601String;
}

@end
