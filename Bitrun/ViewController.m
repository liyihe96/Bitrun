//
//  ViewController.m
//  DNApp
//
//  Created by Meng To on 2014-04-23.
//  Copyright (c) 2014 Meng To. All rights reserved.
//

#import "ViewController.h"
#import "CoinbaseOAuth.h"
#import "AppDelegate.h"
#import "JGProgressHUD.h"
#import "BitrunAPI.h"
#import "Utility.h"

@interface ViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *dialogView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
- (IBAction)loginButtonDidPress:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIImageView *emailImageView;
@property (weak, nonatomic) IBOutlet UIImageView *passwordImageView;
@property (strong, nonatomic) NSDictionary *data;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (nonatomic, strong) JGProgressHUD *HUD;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Change status bar
    [self setNeedsStatusBarAppearanceUpdate];
    
    // Set delegates
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    
    // Add listener for textfield did change
    [self.emailTextField addTarget:self
                            action:@selector(textFieldDidChange:)
                  forControlEvents:UIControlEventEditingChanged];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)textFieldDidChange:(UITextField *)textField {
    if(textField.text.length > 20) {
        self.emailImageView.hidden = YES;
    }
    else {
        self.emailImageView.hidden = NO;
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    // Highlight email text field
    if(textField.frame.origin.y == 103) {
        [self.emailTextField setBackground:[UIImage imageNamed:@"input-outline-active"]];
        self.emailImageView.image = [UIImage imageNamed:@"icon-mail-active"];
    }
    else {
        [self.emailTextField setBackground:[UIImage imageNamed:@"input-outline"]];
        self.emailImageView.image = [UIImage imageNamed:@"icon-mail"];
    }
    
    // Higlight password text field
    if(textField.frame.origin.y == 157) {
        [self.passwordTextField setBackground:[UIImage imageNamed:@"input-outline-active"]];
        self.passwordImageView.image = [UIImage imageNamed:@"icon-password-active"];
    }
    else {
        [self.passwordTextField setBackground:[UIImage imageNamed:@"input-outline"]];
        self.passwordImageView.image = [UIImage imageNamed:@"icon-password"];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    // Reset highlighting
    [self.emailTextField setBackground:[UIImage imageNamed:@"input-outline"]];
    self.emailImageView.image = [UIImage imageNamed:@"icon-mail"];
    [self.passwordTextField setBackground:[UIImage imageNamed:@"input-outline"]];
    self.passwordImageView.image = [UIImage imageNamed:@"icon-password"];
}

-(void)doErrorMessage {
    // animateWithDuration
    [UIView animateWithDuration:0.1 animations:^{
        self.loginButton.transform = CGAffineTransformMakeTranslation(10, 0);
    } completion:^(BOOL finished) {
        // Step 2
        [UIView animateWithDuration:0.1 animations:^{
            self.loginButton.transform = CGAffineTransformMakeTranslation(-10, 0);
        } completion:^(BOOL finished) {
            // Step 3
            [UIView animateWithDuration:0.1 animations:^{
                self.loginButton.transform = CGAffineTransformMakeTranslation(0, 0);
            }];
        }];
    }];
    
    // animateWithDuration with Damping
    [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:0 animations:^{
        // Change the size of the dialogView
        // Make sure it's running once
        if(self.dialogView.frame.origin.y == 144) {
            [self.dialogView setFrame:CGRectMake(self.dialogView.frame.origin.x, self.dialogView.frame.origin.y-60, self.dialogView.frame.size.width, 320)];
        }
    } completion:^(BOOL finished) { }];
}

- (IBAction)loginButtonDidPress:(id)sender {

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
@end
