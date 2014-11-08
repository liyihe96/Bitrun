//
//  ViewController.m
//  Bitrun
//
//  Created by Yihe Li on 11/8/14.
//  Copyright (c) 2014 Yihe Li. All rights reserved.
//

#import "ViewController.h"
#import "AAPLActivityDataManager.h"

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
