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
#import <CoreMotion/CoreMotion.h>
#import "BitrunAPI.h"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *stepCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
//@property (nonatomic, strong) NSNumber *currentSteps;
@property (nonatomic, strong) NSString *currentStatus;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (nonatomic, strong) CMPedometerData *pedometerdData;
@property (nonatomic, strong) NSDate *lastDate;

@end

@implementation ViewController
{
    AAPLActivityDataManager *_dataManager;
}

- (void)setPedometerdData:(CMPedometerData *)pedometerdData
{
    _pedometerdData = pedometerdData;
    NSDate *nowDate = [NSDate date];
    NSDictionary *arg = @{@"distance":pedometerdData.distance, @"from":[BitrunAPI iso8601StringFromDate:self.lastDate], @"to":[BitrunAPI iso8601StringFromDate: nowDate], @"steps":pedometerdData.numberOfSteps};
    [[BitrunAPI sharedInstance] emit:@"pedometer" args:@[arg]];
    self.lastDate = nowDate;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lastDate = ((AppDelegate *)[UIApplication sharedApplication].delegate).openAppDate;
    // Do any additional setup after loading the view, typically from a nib.
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView) name:UIApplicationWillEnterForegroundNotification object:nil];
    _motionManager = [[CMMotionManager alloc] init];
    _motionManager.accelerometerUpdateInterval = 0.1;
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

    [_dataManager startStepUpdates:^(CMPedometerData *pData) {
        self.pedometerdData = pData;
        NSNumber *stepCount = pData.numberOfSteps;
        NSNumber *distance = pData.distance;
        NSLog(@"%@", stepCount);
        self.distanceLabel.text = [NSString stringWithFormat:@"%@m",distance];
        self.stepCountLabel.text =  [stepCount stringValue];
    }];
    [_dataManager startMotionUpdates:^(AAPLActivityType type) {
        NSLog(@"update");
        self.statusLabel.text = [AAPLActivityDataManager  activityTypeToString:type];
    }];
//    [_motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue]
//                                withHandler:^(CMGyroData *gyroData, NSError *error) {
//                                    [self outputRotationData:gyroData.rotationRate];
//                                }];
    [_motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                         withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                                             [self handleAccelerometerData:accelerometerData.acceleration];
                                         }];

}

- (void)handleAccelerometerData:(CMAcceleration)acceleration
{
//    NSLog(@"x :%f",acceleration.x);
//    NSLog(@"y :%f",acceleration.y);
//    NSLog(@"z :%f",acceleration.z);
    NSLog(@"cal: %f", acceleration.x * acceleration.x + acceleration.y * acceleration.y + acceleration.z *acceleration.z);
    
}

//-(void)outputRotationData:(CMRotationRate)rotation
//{
//    
//    _lblRotationX.text = [NSString stringWithFormat:@"Rotation X: %.2fr/s",rotation.x];
//    if(fabs(rotation.x)> fabs(_maxRotationX))
//    {
//        _maxRotationX = rotation.x;
//        _lblMaxRotationX.text = [NSString stringWithFormat:@"Max Rotation X: %.2f",_maxRotationX];
//    }
//    _lblRotationY.text = [NSString stringWithFormat:@"Rotation Y: %.2fr/s",rotation.y];
//    if(fabs(rotation.y) > fabs(_maxRotationY))
//    {
//        _maxRotationY = rotation.y;
//        _lblMaxRotationY.text = [NSString stringWithFormat:@"Max Rotation Y: %.2f",_maxRotationY];
//    }
//    _lblRotationZ.text = [NSString stringWithFormat:@"Rotation Z: %.2fr/s",rotation.z];
//    if(fabs(rotation.z) > fabs(_maxRotationZ))
//    {
//        _maxRotationZ = rotation.z;
//        _lblMaxRotationZ.text = [NSString stringWithFormat:@"Max Rotation Z: %.2f",_maxRotationZ];
//    }
//}

- (void)viewWillAppear:(BOOL)animated
{
    [self refreshView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
