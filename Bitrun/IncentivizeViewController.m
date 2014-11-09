//
//  IncentivizeViewController.m
//  Bitrun
//
//  Created by Yihe Li on 11/9/14.
//  Copyright (c) 2014 Yihe Li. All rights reserved.
//

#import "IncentivizeViewController.h"
#import "WebViewController.h"
#import "MainViewController.h"

@interface IncentivizeViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (nonatomic, strong) NSString *repeat;
@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet UITextField *goalTextField;
@property (nonatomic) int cicle;
@property (nonatomic) BOOL ready;

@end

@implementation IncentivizeViewController
{
    NSArray *_pickerData;
    NSArray *_dicData;
    NSArray *_timeInterVal;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _pickerData = @[@"Weekly",@"Every Two Week", @"Monthly", @"Yearly"];
    _dicData = @[@"weekly", @"every_two_weeks",@"monthly",@"yearly"];
    _timeInterVal = @[@7, @14,@30, @365];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    self.repeat = _dicData[1];
    self.cicle = [_timeInterVal[1] intValue];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture)]];
    // Do any additional setup after loading the view.
    

}

- (void)handleGesture
{
    [self.view endEditing:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.pickerView selectRow:1 inComponent:0 animated:YES];
    if (self.ready)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
// The number of columns of data

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _pickerData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _pickerData[row];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = _pickerData[row];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    return attString;
    
}

// Catpure the picker view selection
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // This method is triggered whenever the user makes a change to the picker selection.
    // The parameter named row and component represents what was selected.
    self.repeat = _dicData[row];
    self.cicle = [_timeInterVal[row] intValue];
    
}
- (IBAction)submitTapped:(UIButton *)sender {
    NSString *amount = self.amountTextField.text;
    NSString *goal =  self.goalTextField.text ;
    NSDate *current = [NSDate date];
    NSDate *expire = [current dateByAddingTimeInterval:self.cicle *60*60*24];
    NSDictionary *checkoutDic = @{@"amount":amount,@"repeat":self.repeat, @"goal":goal, @"currency":@"BTC"};
    NSDictionary *incentiveDic = @{@"amount":amount,@"expire_date":[Utility iso8601StringFromDate: expire],@"create_date":[Utility iso8601StringFromDate:current], @"goal":goal};
    [self postCheckout:checkoutDic];
    [self postIncentive:incentiveDic];
}

- (void)postIncentive:(NSDictionary *)dic
{
    NSString *url = [NSString stringWithFormat: @"https://%@incentive/%@",baseUrl,[[NSUserDefaults standardUserDefaults]valueForKey:@"CoinBaseID" ]];
    NSLog(@"%@",url);
    NSLog(@"%@",dic);
    [[BitrunAPI sharedInstance] postRequest:url parameters:dic success:^(AFHTTPRequestOperation *operation, id response) {
        NSLog(@"yo%@",response);
        Incentive *incentive = [[Incentive alloc] initWithDictionary:response];
        NSLog(@"----incentive:%@",incentive);
        [[BitrunAPI sharedInstance] addIncentive:incentive];
        [self getProgress];
//        [self openWeb:[response objectForKey:@"url"]];
//        NSLog(@"%@",[[response objectForKey:@"url"] class]);
    }];

}

- (void)getProgress
{
    NSString *urlString = [NSString stringWithFormat:@"https://%@pedometer/%@",baseUrl,[[NSUserDefaults standardUserDefaults] valueForKey:@"CoinBaseID"]];
    NSLog(@"%@",urlString);
    [[BitrunAPI sharedInstance] getRequest:urlString success:^(AFHTTPRequestOperation * operation, id response) {
        NSLog(@"%@",response);
        NSLog(@"%@",[response class]);
        [[BitrunAPI sharedInstance] addProgress:[response objectForKey:@"total_distance"]];
        self.ready = YES;
        ((MainViewController *)self.presentingViewController).error = NO;
//        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        
//        [self.HUD dismiss];
//        [self performSegueWithIdentifier:@"LoginSucceed" sender:@"no error"];
    }fail:nil];
}

- (void)postCheckout:(NSDictionary *)dic
{
    NSString *url = [NSString stringWithFormat: @"https://%@coinbase/checkout",baseUrl ];
    NSLog(@"%@",url);
    NSLog(@"%@",dic);
    [[BitrunAPI sharedInstance] postRequest:url parameters:dic success:^(AFHTTPRequestOperation *operation, id response) {
        NSLog(@"%@",response);
        [self openWeb:[response objectForKey:@"url"]];
        NSLog(@"%@",[[response objectForKey:@"url"] class]);
    }];
}

- (void)openWeb:(NSString *)urlString
{
    [self performSegueWithIdentifier:@"ShowWeb" sender:urlString];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowWeb"])
    {
        WebViewController *webVC = ((WebViewController *)segue.destinationViewController);
        webVC.urlString = sender;
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
