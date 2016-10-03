//
//  ChartModel.h
//  Maice
//
//  Created by kl on 16/8/16.
//  Copyright © 2016年 kl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChartModel : NSObject

@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *value;

- (instancetype)initWithTime:(NSString *)time andValue:(NSString *)value;
+ (instancetype)chartModelWithTime:(NSString *)time andValue:(NSString *)value;

@end
