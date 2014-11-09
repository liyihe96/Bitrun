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
@property (nonatomic, strong) LocalManager *localManager;

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
        self.localManager = [[LocalManager alloc] init];
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
//    NSLog(@"----------CAlled");
//    if (self.socketIsConnected)
//    {
//        NSLog(@"-------------SENT");
        [self.socket emit:event args:args];
//    }
}

+ (NSDictionary *)argsAppendByAccessToken:(NSDictionary *)args
{
//    NSLog(@"%@",args);
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:args];
    [dic addEntriesFromDictionary:@{@"coinbase_id":[[NSUserDefaults standardUserDefaults] valueForKey:@"CoinBaseID"] }];
//    NSLog(@"-------dic:%@",dic);
    return dic;
}



- (void)getRequest:(NSString*)url success:(void(^)(AFHTTPRequestOperation *, id))success
{
    [self.httpManager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success){
            success(operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)addIncentive:(Incentive *)incentive
{
    [self.localManager addIncentive: incentive];
}

- (void)addProgress:(NSNumber *)progress
{
    [self.localManager addProgress:progress];
}

- (Incentive *)getIncentive
{
    return [self.localManager getIncentive];
}

- (NSNumber *)getTotalProgress
{
    return [self.localManager getTotalProgress];
}

- (void)newProgress:(NSNumber *)progress
{
    [self.localManager newProgress:progress];
}

- (double)getProgreeRatio
{
    return [self.localManager getProgreeRatio];
}

@end
