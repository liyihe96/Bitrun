//
//  ViewController.m
//  Bitrun
//
//  Created by Yihe Li on 11/8/14.
//  Copyright (c) 2014 Yihe Li. All rights reserved.
//

#import "ViewController.h"
#import "AAPLActivityDataManager.h"
#import "AppDelegate.h"
#import "CoinbaseOAuth.h"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *stepCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
//@property (nonatomic, strong) NSNumber *currentSteps;
@property (nonatomic, strong) NSString *currentStatus;

@end

@implementation ViewController
{
    AAPLActivityDataManager *_dataManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView) name:UIApplicationWillEnterForegroundNotification object:nil];
}

#pragma mark -CoinBase OAuth

- (IBAction)loginCoinBase:(UIButton *)sender {
    [CoinbaseOAuth startOAuthAuthenticationWithClientId:kCoinBaseClientID
                                                  scope:@"user balance"
                                            redirectUri:@"self.bitrun.coinbase-oauth://coinbase-oauth" // Same as entered into Create Application
                                                   meta:nil];
}

- (void)authenticationComplete:(NSDictionary *)response {
    
    NSLog(@"--------RESPONSE");
    // Tokens successfully received!
    NSString *accessToken = [response objectForKey:@"access_token"];
    NSString *refreshToken = [response objectForKey:@"refresh_token"];
    NSNumber *expiresIn = [response objectForKey:@"expires_in"];
    // In your app, you will probably want to save these three values at this point.
//    self.refreshToken = refreshToken;
    
    // Now that we are authenticated, load some data
//    Coinbase *apiClient = [Coinbase coinbaseWithOAuthAccessToken:accessToken];
//    [apiClient doGet:@"account/balance" parameters:nil success:^(NSDictionary *result) {
//        self.balanceLabel.text = [[result objectForKey:@"amount"] stringByAppendingFormat:@" %@", [result objectForKey:@"currency"]];
//    } failure:^(NSError *error) {
//        NSLog(@"Could not load: %@", error);
//    }];
//    [apiClient doGet:@"users" parameters:nil success:^(NSDictionary *result) {
//        self.emailLabel.text = [[[[result objectForKey:@"users"] objectAtIndex:0] objectForKey:@"user"] objectForKey:@"email"];
//    } failure:^(NSError *error) {
//        NSLog(@"Could not load: %@", error);
//    }];
    NSLog(@"%@", accessToken);

    [[NSUserDefaults standardUserDefaults] setValue:accessToken forKey:@"CoinBaseAccessToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)refreshView
{
    if (!_dataManager) {
        _dataManager = [[AAPLActivityDataManager alloc] init];
    }
    [_dataManager stopStepUpdates];
    [_dataManager stopMotionUpdates];

    [_dataManager startStepUpdates:^(NSNumber *stepCount) {
        NSLog(@"%@", stepCount);
        self.stepCountLabel.text =  [stepCount stringValue];
    }];
    [_dataManager startMotionUpdates:^(AAPLActivityType type) {
        NSLog(@"update");
        self.statusLabel.text = [AAPLActivityDataManager  activityTypeToString:type];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self refreshView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
