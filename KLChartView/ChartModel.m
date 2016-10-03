//
//  ChartModel.m
//  Maice
//
//  Created by kl on 16/8/16.
//  Copyright © 2016年 kl. All rights reserved.
//

#import "ChartModel.h"

@implementation ChartModel

- (instancetype)initWithTime:(NSString *)time andValue:(NSString *)value {
    if (self = [super init]) {
        self.time = time;
        self.value = value;
    }
    return self;
}
+ (instancetype)chartModelWithTime:(NSString *)time andValue:(NSString *)value {
    return [[self alloc]initWithTime:time andValue:value];
}

@end
