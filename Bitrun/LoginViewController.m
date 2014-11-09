//
//  LoginViewController.m
//  Bitrun
//
//  Created by Yihe Li on 11/8/14.
//  Copyright (c) 2014 Yihe Li. All rights reserved.
//

#import "LoginViewController.h"
#import "CoinbaseOAuth.h"
#import "AppDelegate.h"
#import "JGProgressHUD.h"
#import "BitrunAPI.h"
#import "Utility.h"

@interface LoginViewController ()
@property (nonatomic, strong) JGProgressHUD *HUD;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)login:(UIButton *)sender
{
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
    self.HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    self.HUD.textLabel.text = @"Loading";
    [self.HUD showInView:self.view];
    
    [[NSUserDefaults standardUserDefaults] setValue:accessToken forKey:@"CoinBaseAccessToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
//    NSDictionary *responseDic;
    __block NSNumber * userId;
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.coinbase.com/v1/users?access_token=%@",accessToken];
    [[BitrunAPI sharedInstance] getRequest:urlString success:^(AFHTTPRequestOperation * operation, id response) {
        NSLog(@"%@",response);
        NSLog(@"%@",[response class]);
        NSLog(@"%@",[response objectForKey:@"users"]);
        userId =[[[[response objectForKey:@"users"] objectAtIndex:0] objectForKey:@"user"] objectForKey:@"id"];
        [[NSUserDefaults standardUserDefaults] setValue:userId forKey:@"CoinBaseID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self getIncentive];
    }];
}

- (void)getIncentive
{
    NSString *urlString = [NSString stringWithFormat:@"https://%@incentive/%@",baseUrl,[[NSUserDefaults standardUserDefaults] valueForKey:@"CoinBaseID"]];
    NSLog(@"%@",urlString);
    [[BitrunAPI sharedInstance] getRequest:urlString success:^(AFHTTPRequestOperation * operation, id response) {
        NSLog(@"%@",response);
        NSLog(@"%@",[response class]);
        [[BitrunAPI sharedInstance] addIncentive:[[Incentive alloc] initWithDictionary:response]];
        [self getProgress];
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
        [self.HUD dismiss];
        [self performSegueWithIdentifier:@"LoginSucceed" sender:self];
    }];
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
