//
//  Utility.m
//  Bitrun
//
//  Created by Yihe Li on 11/8/14.
//  Copyright (c) 2014 Yihe Li. All rights reserved.
//

#import "Utility.h"

@implementation Utility

+ (void)insertBlurView:(UIView *)view withStyle:(UIBlurEffectStyle)style
{
    view.backgroundColor = [UIColor clearColor];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:style];
    UIVisualEffectView *blurEffectView =[[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [blurEffectView setFrame:view.bounds];
    [view insertSubview:blurEffectView atIndex:0];
    
}

@end
