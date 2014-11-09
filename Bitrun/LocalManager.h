//
//  LocalManager.h
//  Bitrun
//
//  Created by Yihe Li on 11/9/14.
//  Copyright (c) 2014 Yihe Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Incentive.h"

@interface LocalManager : NSObject

- (void)addIncentive:(Incentive *)incentive;
- (void)addProgress:(NSNumber *)progress;
- (Incentive *)getIncentive;
- (NSNumber *)getTotalProgress;
- (void)newProgress:(NSNumber *)progress;
- (double)getProgreeRatio;

@end
