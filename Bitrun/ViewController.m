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
#import <CoreMotion/CoreMotion.h>
#import "BitrunAPI.h"
#import "Utility.h"
#import "PulsingHaloLayer.h"
#import "MultiplePulsingHaloLayer.h"
#import "INTULocationManager.h"
#import <AddressBook/AddressBook.h>

#define kMinRadius 100
#define kMaxRadius 300
#define kMaxNum 40.0


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *stepCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
//@property (nonatomic, strong) NSNumber *currentSteps;
@property (nonatomic, strong) NSString *currentStatus;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (nonatomic, strong) CMPedometerData *pedometerdData;
@property (nonatomic, strong) NSDate *lastDate;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIView *locationView;
@property (weak, nonatomic) IBOutlet UILabel *detailLocationLabel;
@property (nonatomic, weak) PulsingHaloLayer *halo;
@property (nonatomic, strong) NSNumber *calNumber;
@property (nonatomic, strong) NSNumber *maxNumber;
@property (nonatomic, strong) CMPedometerData *lastData;
@property (nonatomic) int counter;
@property (nonatomic) int tot;
@property (nonatomic, weak) MultiplePulsingHaloLayer *mutiHalo;

@end

@implementation ViewController
{
    AAPLActivityDataManager *_dataManager;
}

- (void)setCalNumber:(NSNumber *)calNumber
{
    _calNumber = calNumber;
    self.counter ++;
    self.tot += [calNumber intValue];
    if (self.counter >= 5)
    {
        self.counter = 0;
        [self setupValues:self.tot];
        NSLog(@"tot: %d",self.tot);
        self.tot = 0;
    }
//    if (calNumber > self.maxNumber) {
//        self.maxNumber = calNumber;
//        NSLog(@"--max:%@",self.maxNumber);
//    }
    
}

- (void)setPedometerdData:(CMPedometerData *)pedometerdData
{
    _pedometerdData = pedometerdData;
    NSDate *nowDate = [NSDate date];
    NSDictionary *arg = @{@"distance":@([pedometerdData.distance integerValue]- [self.lastData.distance integerValue]), @"from":[BitrunAPI iso8601StringFromDate:self.lastDate], @"to":[BitrunAPI iso8601StringFromDate: nowDate], @"steps":@([pedometerdData.numberOfSteps integerValue] -[self.lastData.numberOfSteps integerValue])};
    [[BitrunAPI sharedInstance] emit:@"pedometer" args:@[[BitrunAPI argsAppendByAccessToken: arg ]]];
    self.lastDate = nowDate;
    self.lastData = pedometerdData;
}

- (void) ReverseGeocode: (CLLocation *)newLocation {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:newLocation
                   completionHandler:^(NSArray *placemarks,
                                       NSError *error) {
                       if (error) {
                           NSLog(@"Geocode failed with error: %@", error);
                           return;
                       }
                       if (placemarks && placemarks.count > 0) {
                           CLPlacemark *placemark = placemarks[0];
                           NSDictionary *addressDictionary = placemark.addressDictionary;
                           NSString *address = [addressDictionary objectForKey: (NSString *)kABPersonAddressStreetKey];
                           NSString *city = [addressDictionary objectForKey: (NSString *)kABPersonAddressCityKey];
                           NSString *state = [addressDictionary objectForKey: (NSString *)kABPersonAddressStateKey];
                           NSString *zip = [addressDictionary objectForKey: (NSString *)kABPersonAddressZIPKey];
                           self.locationLabel.text = city;
                           self.detailLocationLabel.text = address;//[NSString localizedStringWithFormat: @"%@ %@ %@ %@", address,city, state, zip];
                       }
                   }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.lastDate = ((AppDelegate *)[UIApplication sharedApplication].delegate).openAppDate;
    // Do any additional setup after loading the view, typically from a nib.
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView) name:UIApplicationWillEnterForegroundNotification object:nil];
    _motionManager = [[CMMotionManager alloc] init];
    _motionManager.accelerometerUpdateInterval = 0.5;
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    [locMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyCity
                                       timeout:10.0
                          delayUntilAuthorized:YES  // This parameter is optional, defaults to NO if omitted
                                         block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                             if (status == INTULocationStatusSuccess) {
                                                 // Request succeeded, meaning achievedAccuracy is at least the requested accuracy, and
                                                 // currentLocation contains the device's current location.
                                                 [self ReverseGeocode: currentLocation];
                                             }
                                             else if (status == INTULocationStatusTimedOut) {
                                                 // Wasn't able to locate the user with the requested accuracy within the timeout interval.
                                                 // However, currentLocation contains the best location available (if any) as of right now,
                                                 // and achievedAccuracy has info on the accuracy/recency of the location in currentLocation.
                                             }
                                             else {
                                                 // An error occurred, more info is available by looking at the specific status returned.
                                             }
                                         }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshView];
    [self setNeedsStatusBarAppearanceUpdate];
    [self.locationView setFrame:CGRectMake(8, 533+124, 426, 0)];
//    self.halo = [PulsingHaloLayer layer];
//    self.halo.radius = 300;
//    self.halo.position = CGPointMake(self.view.center.x, self.view.center.y-100);
////    self.halo.animationDuration = 1;
////    self.halo.useTimingFunction =
//    [self.view.layer addSublayer:self.halo];
    
    //you can specify the number of halos by initial method or by instance property "haloLayerNumber"
    MultiplePulsingHaloLayer *multiLayer = [[MultiplePulsingHaloLayer alloc] initWithHaloLayerNum:3 andStartInterval:1];
    self.mutiHalo = multiLayer;
    self.mutiHalo.position = CGPointMake(self.view.center.x, self.view.center.y-130);
    self.mutiHalo.useTimingFunction = NO;
    [self.mutiHalo buildSublayers];
    [self.view.layer addSublayer:self.mutiHalo];
    [self setupValues:0];

}

- (void)setupValues:(int)num
{
    if (num>kMaxNum)
    {
        num = kMaxNum;
    }
    double ratio = num / kMaxNum;
    NSLog(@"ratio:%f",ratio);
    self.mutiHalo.radius = kMinRadius + ratio*(kMaxRadius-kMinRadius);
    
    UIColor *color = [UIColor colorWithRed:ratio green:1-ratio blue:0 alpha:1];
    [self.mutiHalo setHaloLayerColor:color.CGColor];

}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.5 delay:0.4 options:UIViewAnimationOptionCurveLinear animations:^{
        [self.locationView setFrame:CGRectMake(8, 533, 426, 124)];
    } completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        
        [formatter setMaximumFractionDigits:2];
        
        [formatter setMinimumFractionDigits:0];
        NSString *result = [formatter stringFromNumber:distance];
        
        NSLog(@"%@", stepCount);
        self.distanceLabel.text = [NSString stringWithFormat:@"%@m",result];
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
    self.calNumber =  @(acceleration.x * acceleration.x + acceleration.y * acceleration.y + acceleration.z *acceleration.z);
    NSLog(@"cal: %@",self.calNumber);
    
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
