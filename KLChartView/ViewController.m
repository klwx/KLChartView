//
//  ViewController.m
//  KLChartView
//
//  Created by kl on 16/10/3.
//  Copyright © 2016年 kl. All rights reserved.
//

#import "ViewController.h"
#import "KLChartView.h"
#import "ChartModel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor grayColor];
    
    
    KLChartView *chartView = [[KLChartView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 226)];
    
    chartView.startTime = @"2016-01-01 00:00:00";
    chartView.endTime = @"2016-10-03 00:00:00";
    
    chartView.dataArr = [self setChartDataArray];
    chartView.colorArr = @[[UIColor redColor], [UIColor blueColor]];
    chartView.chartName = @[@"line1", @"line2"];
    
    chartView.backgroundColor = [UIColor whiteColor];
    chartView.edgeInsets = UIEdgeInsetsMake(0, 10, 0, 20);
    [chartView initializeTheDefault];
    [chartView setChartView];
    [chartView drawLine];
    [chartView addTapGestureRecognizer];
    [chartView addPanGestureRecognizer];
    [self.view addSubview:chartView];
    
    
}

- (NSArray *)setChartDataArray {
    NSArray *line1 = @[
                       [ChartModel chartModelWithTime:@"2016-01-01 00:00:00" andValue:@"0"],
                       [ChartModel chartModelWithTime:@"2016-02-01 00:00:00" andValue:@"12.55"],
                       [ChartModel chartModelWithTime:@"2016-03-01 00:00:00" andValue:@"8.25"],
                       [ChartModel chartModelWithTime:@"2016-04-01 00:00:00" andValue:@"4.25"],
                       [ChartModel chartModelWithTime:@"2016-05-01 00:00:00" andValue:@"15.55"],
                       [ChartModel chartModelWithTime:@"2016-06-01 00:00:00" andValue:@"-5.05"],
                       [ChartModel chartModelWithTime:@"2016-07-01 00:00:00" andValue:@"-2.55"],
                       [ChartModel chartModelWithTime:@"2016-08-01 00:00:00" andValue:@"0.88"],
                       [ChartModel chartModelWithTime:@"2016-09-01 00:00:00" andValue:@"3.45"],
                       [ChartModel chartModelWithTime:@"2016-10-01 00:00:00" andValue:@"5.55"]
                       ];
    
    NSArray *line2 = @[
                       [ChartModel chartModelWithTime:@"2016-01-01 00:00:00" andValue:@"0"],
                       [ChartModel chartModelWithTime:@"2016-02-01 00:00:00" andValue:@"10.55"],
                       [ChartModel chartModelWithTime:@"2016-03-01 00:00:00" andValue:@"6.25"],
                       [ChartModel chartModelWithTime:@"2016-04-01 00:00:00" andValue:@"6.25"],
                       [ChartModel chartModelWithTime:@"2016-05-01 00:00:00" andValue:@"17.55"],
                       [ChartModel chartModelWithTime:@"2016-06-01 00:00:00" andValue:@"-3.05"],
                       [ChartModel chartModelWithTime:@"2016-07-01 00:00:00" andValue:@"-2.55"],
                       [ChartModel chartModelWithTime:@"2016-08-01 00:00:00" andValue:@"3.88"],
                       [ChartModel chartModelWithTime:@"2016-09-01 00:00:00" andValue:@"2.45"],
                       [ChartModel chartModelWithTime:@"2016-10-01 00:00:00" andValue:@"8.55"]
                       ];
    
    NSMutableArray *data = [NSMutableArray array];
    [data addObject:line1];
    [data addObject:line2];
    return [NSArray arrayWithArray:data];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
