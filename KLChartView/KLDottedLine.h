//
//  KLDottedLine.h
//  MyChartTest
//
//  Created by kl on 16/7/21.
//  Copyright © 2016年 kl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KLDottedLine : UIView

- (void)drawDashLine:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor;

@end
