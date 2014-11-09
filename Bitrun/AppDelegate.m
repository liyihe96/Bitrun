//
//  AppDelegate.m
//  Bitrun
//
//  Created by Yihe Li on 11/8/14.
//  Copyright (c) 2014 Yihe Li. All rights reserved.
//

#import "AppDelegate.h"
#import "Coinbase.h"
#import "CoinbaseOAuth.h"
#import "MainViewController.h"
#import "ViewController.h"

@interface AppDelegate ()
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.openAppDate = [NSDate date];

    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
//    NSLog(@"-------GOT IT");
//    NSLog(@"%@",[url scheme]);
    if ([[url scheme] isEqualToString:@"self.bitrun.coinbase-oauth"]) {
//        NSLog(@"--------EQUAL");
        // This is a redirect from the Coinbase OAuth web page or app.
        [CoinbaseOAuth finishOAuthAuthenticationForUrl:url
                                              clientId:kCoinBaseClientID
                                          clientSecret:kCoinBaseClientSecret
                                               success:^(NSDictionary *result) {
                                                   // Tokens successfully obtained!
                                                   // Do something with them (store them, etc.)
//                                                   NSString *accessToken = [result objectForKey:@"access_token"];
//                                                   NSLog(@"---------accessToken: %@", accessToken);
                                                   ViewController *controller = (ViewController *)self.window.rootViewController;
                                                   [controller authenticationComplete:result];

                                                   // Note that you should also store 'expire_in' and refresh the token using [CoinbaseOAuth getOAuthTokensForRefreshToken] when it expires
                                               } failure:^(NSError *error) {
                                                   [[[UIAlertView alloc] initWithTitle:@"OAuth Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];                                               }];
        return YES;
    }
    return NO;
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
