//
//  KLChartView.h
//  Maice
//
//  Created by kl on 16/8/15.
//  Copyright © 2016年 kl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KLChartView : UIView

//边距
@property (nonatomic, assign) UIEdgeInsets edgeInsets;
//坐标系虚线的颜色
@property (nonatomic, strong) UIColor *coordinateColor;
//坐标轴上坐标点的颜色
@property (nonatomic, strong) UIColor *coordinatesColor;
//数据
@property (nonatomic, strong) NSArray *dataArr;
//线的颜色
@property (nonatomic, strong) NSArray *colorArr;

//图表起止时间
@property (nonatomic, copy  ) NSString *startTime;
@property (nonatomic, copy  ) NSString *endTime;

//显示的折线名称
@property (nonatomic, strong) NSArray *chartName;

//初始化数据
- (void)initializeTheDefault;
//画图
- (void)setChartView;
//画线
- (void)drawLine;
//添加tap事件
- (void)addTapGestureRecognizer;
//添加pan事件
- (void)addPanGestureRecognizer;

@end
