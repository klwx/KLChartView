//
//  KLChartView.m
//  Maice
//
//  Created by kl on 16/8/15.
//  Copyright © 2016年 kl. All rights reserved.
//

#define MAKE_COLOR(rr, gg, bb) [UIColor colorWithRed:(rr)/255.0f green:(gg)/255.0f blue:(bb)/255.0f alpha:1.0f]
#define MAKE_COLOR_WITH_ALPHA(rr, gg, bb, aa) [UIColor colorWithRed:(rr)/255.0f green:(gg)/255.0f blue:(bb)/255.0f alpha:aa]

#import "KLChartView.h"
#import "KLDottedLine.h"
#import "ChartModel.h"

@interface KLChartView () {
    CGFloat _kWidth;
    CGFloat _kHeight;
    CGFloat _ordinateWidth;
    CGFloat _coordinateWidth;
    CGFloat _coordinateHeight;
    
    CGFloat _startToEndTimeInterval;
    CGFloat _startTimeInterval;
    CGFloat _maxY;
    CGFloat _minY;
    CGFloat _poorY;
    
    //点击或滑动时数据
    NSString *_tapLabelText;
    CGPoint _tapPoint;
    BOOL flag;
}

@property (nonatomic, strong) NSMutableArray *abscissas;
@property (nonatomic, strong) NSMutableArray *ordinates;
@property (nonatomic, strong) NSMutableArray *remindTextArray;
@property (nonatomic, strong) NSMutableArray *pointsArray;

//点击或滑动时视图
@property (nonatomic, strong) KLDottedLine *tapLine;
@property (nonatomic, strong) UILabel *tapLabel;

@end

@implementation KLChartView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)initializeTheDefault {
    _kWidth = self.frame.size.width;
    _kHeight = self.frame.size.height;
    _ordinateWidth = 50;
    _coordinateWidth = _kWidth - _ordinateWidth - self.edgeInsets.left - self.edgeInsets.right;
    _coordinateHeight = _kHeight - 40;
    if (self.coordinateColor == nil) {
        self.coordinateColor = MAKE_COLOR(151, 151, 151);
    }
    if (self.coordinatesColor == nil) {
        self.coordinatesColor = MAKE_COLOR(108, 108, 108);
    }
    self.abscissas = [NSMutableArray array];
    self.ordinates = [NSMutableArray array];
    self.remindTextArray = [NSMutableArray array];
    self.pointsArray = [NSMutableArray array];
    [self setAbscissa];
    [self setOrdinate];
    
    self.tapLine = [KLDottedLine new];
    [self addSubview:self.tapLine];
    
    self.tapLabel = [UILabel new];
    self.tapLabel.font = [UIFont systemFontOfSize:12];
    self.tapLabel.backgroundColor = MAKE_COLOR_WITH_ALPHA(255, 76, 0, 0.5);
    self.tapLabel.numberOfLines = 0;
    self.tapLabel.textColor = [UIColor whiteColor];
    self.tapLabel.layer.cornerRadius = 4;
    self.tapLabel.clipsToBounds = YES;
    [self addSubview:self.tapLabel];
}

- (void)setChartView {
    for (NSInteger i = 0; i < 6; i++) {
        KLDottedLine *horizontal = [[KLDottedLine alloc] initWithFrame:CGRectMake(self.edgeInsets.left + _ordinateWidth, 10 + i*_coordinateHeight/5, _kWidth - _ordinateWidth - self.edgeInsets.left - self.edgeInsets.right, 0.5)];
        horizontal.backgroundColor = [UIColor clearColor];
        [horizontal drawDashLine:horizontal lineLength:5 lineSpacing:4 lineColor:self.coordinateColor];
        [self addSubview:horizontal];
        
        UILabel *ordinateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _ordinateWidth, 18)];
        ordinateLabel.center = CGPointMake(self.edgeInsets.left + _ordinateWidth/2, 10 + i*_coordinateHeight/5);
        ordinateLabel.textColor = self.coordinatesColor;
        ordinateLabel.text = self.ordinates.count - 1 >= i ? self.ordinates[i] : @"";
        ordinateLabel.font = [UIFont systemFontOfSize:13];
        ordinateLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:ordinateLabel];
    }
    
    for (NSInteger i = 0; i < 5; i++) {
        KLDottedLine *vertical = [[KLDottedLine alloc] initWithFrame:CGRectMake(0, 0, _coordinateHeight, 0.5)];
        vertical.center = CGPointMake(self.edgeInsets.left + _ordinateWidth + i*_coordinateWidth/4, _coordinateHeight/2 + 10);
        vertical.backgroundColor = [UIColor clearColor];
        [vertical drawDashLine:vertical lineLength:5 lineSpacing:4 lineColor:self.coordinateColor];
        [self addSubview:vertical];
        vertical.transform = CGAffineTransformMakeRotation(M_PI_2);
        
        UILabel *abscissaLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _ordinateWidth + 20, 18)];
        CGFloat centerX = _ordinateWidth + self.edgeInsets.left + i*_coordinateWidth/4;
        if (self.frame.size.width - centerX < _ordinateWidth/2 + 10) {
            abscissaLabel.center = CGPointMake(self.frame.size.width - 30, _coordinateHeight + 29);
        }else {
            abscissaLabel.center = CGPointMake(_ordinateWidth + self.edgeInsets.left + i*_coordinateWidth/4, _coordinateHeight + 29);
        }
        abscissaLabel.textColor = self.coordinatesColor;
        abscissaLabel.text = self.abscissas.count - 1 >= i ? self.abscissas[i] : @"";
        abscissaLabel.font = [UIFont systemFontOfSize:13];
        abscissaLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:abscissaLabel];
    }
}

- (void)setAbscissa {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *startDate = [formatter dateFromString:self.startTime];
    NSDate *endDate = [formatter dateFromString:self.endTime];
    NSTimeInterval start = [startDate timeIntervalSinceReferenceDate];
    NSTimeInterval end = [endDate timeIntervalSinceReferenceDate];
    _startToEndTimeInterval = end - start;
    _startTimeInterval = start;
    NSMutableArray *time = [NSMutableArray array];
    [time addObject:@(start)];
    for (NSInteger i = 1; i < 4; i++) {
        [time addObject:@(start + (end - start)/4*i)];
    }
    [time addObject:@(end)];
    for (NSInteger i = 0; i < time.count; i++) {
        NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:[[time objectAtIndex:i] floatValue]];
        NSString *dateString = [NSString stringWithFormat:@"%@", date];
        if (dateString.length != 0) {
            NSArray *timeStr = [[[dateString componentsSeparatedByString:@" "] firstObject] componentsSeparatedByString:@"-"];
            NSString *year = [timeStr objectAtIndex:0];
            NSString *month = [timeStr objectAtIndex:1];
            NSString *day = [timeStr objectAtIndex:2];
            
            NSString *string = [NSString stringWithFormat:@"%@/%@/%@", [year substringFromIndex:2], [[month substringToIndex:1] isEqualToString:@"0"] ? [month substringFromIndex:1] : month, [[day substringToIndex:1] isEqualToString:@"0"] ? [day substringFromIndex:1] : day];
            [self.abscissas addObject:string];
        }
    }
}

- (void)setOrdinate {
    CGFloat max = -99.99;
    CGFloat min = -99.99;
    for (NSInteger i = 0; i < self.dataArr.count; i++) {
        NSArray *array = [self.dataArr objectAtIndex:i];
        for (NSInteger j = 0; j < array.count; j++) {
            ChartModel *chart = array[j];
            CGFloat value = [chart.value floatValue];
            if (i == 0 && j == 0) {
                max = value;
                min = value;
            }else {
                if (value > max) {
                    max = value;
                }
                if (value < min) {
                    min = value;
                }
            }
        }
    }
    
    if (min > 0) {
        max = max*1.25;
        min = 0.0;
    }else {
        max = (max - min)*1.25 + min;
    }
    
    _maxY = max;
    _minY = min;
    _poorY = max - min;
    [self.ordinates addObject:[self getStringWithFloat:max]];
    CGFloat count = (max - min)/5;
    for (NSInteger i = 1; i < 5; i++) {
        [self.ordinates addObject:[self getStringWithFloat:max - i*count]];
    }
    [self.ordinates addObject:[self getStringWithFloat:min]];
}

- (NSString *)getStringWithFloat:(CGFloat)value {
    if ([[NSString stringWithFormat:@"%.0f", value] length] < 3) {
        return [NSString stringWithFormat:@"%.2f%%", value];
    }else {
        return [NSString stringWithFormat:@"%.0f%%", value];
    }
}

- (void)drawLine {
    for (NSInteger i = 0; i < self.dataArr.count; i++) {
        NSArray *array = self.dataArr[i];
        UIBezierPath *path = [UIBezierPath bezierPath];
        for (NSInteger i = 0; i < array.count; i++) {
            ChartModel *chart = [array objectAtIndex:i];
            CGPoint point = [self getPointWithChart:chart];
            if (i == 0) {
                [path moveToPoint:point];
            }else {
                [path addLineToPoint:point];
            }
        }
        
        CAShapeLayer *pathLayer = [CAShapeLayer layer];
        pathLayer.frame = CGRectMake(0, 0, _kWidth, _kHeight);
        pathLayer.path = path.CGPath;
        pathLayer.strokeColor = ((UIColor *)[self.colorArr objectAtIndex:i]).CGColor;
        pathLayer.fillColor = nil;
        pathLayer.lineWidth = 1.5;
        pathLayer.lineJoin = kCALineJoinRound;
        [self.layer addSublayer:pathLayer];
    }
}

- (CGPoint)getPointWithChart:(ChartModel *)chart {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yy-MM-dd HH:mm:ss"];
    NSDate *date = [formatter dateFromString:chart.time];
    NSTimeInterval timeInterval = [date timeIntervalSinceReferenceDate];
    CGFloat poor = timeInterval - _startTimeInterval;
    CGFloat x = self.edgeInsets.left + _ordinateWidth + poor/_startToEndTimeInterval*_coordinateWidth;
    CGFloat value = [chart.value floatValue];
    CGFloat y = 10 + (_coordinateHeight - (value - _minY)/_poorY*_coordinateHeight);
    return CGPointMake(x, y);
}

- (void)addTapGestureRecognizer {
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self addGestureRecognizer:gesture];
}

- (void)tapGesture:(UITapGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self];
    [self setSelectedViewWithTapPoint:location];
}

- (void)addPanGestureRecognizer {
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    [self addGestureRecognizer:gesture];
}

- (void)panGesture:(UIPanGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self];
    [self setSelectedViewWithTapPoint:location];
}

- (void)setSelectedViewWithTapPoint:(CGPoint)point {
    if (point.y >= 10 && point.y <= _coordinateHeight) {
        if (point.x >= (self.edgeInsets.left + _ordinateWidth) && point.x <= (_kWidth - self.edgeInsets.right)) {
            NSTimeInterval tapInterval = (point.x - (self.edgeInsets.left + _ordinateWidth))/_coordinateWidth*_startToEndTimeInterval + _startTimeInterval;
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yy-MM-dd"];
            NSDate *tapDate = [NSDate dateWithTimeIntervalSinceReferenceDate:tapInterval];
            
            NSString *tapDateString = [[[NSString stringWithFormat:@"%@", tapDate] componentsSeparatedByString:@" "] firstObject];
            NSArray *selectedChartArray = [self checkTheSelectedChartPointWithTapDateString:tapDateString];
            if (selectedChartArray.count == 2) {
                NSArray *charts = selectedChartArray[0];
                NSArray *names = selectedChartArray[1];
                if (charts.count != 0) {
                    for (NSInteger i = 0; i < charts.count; i++) {
                        ChartModel *chart = charts[i];
                        if (i == 0) {
                            _tapPoint = [self getPointWithChart:chart];
                            NSArray *date = [[[chart.time componentsSeparatedByString:@" "] firstObject] componentsSeparatedByString:@"-"];
                            _tapLabelText = [NSString stringWithFormat:@"%ld年%ld月%ld日", [date[0] integerValue], [date[1] integerValue], [date[2] integerValue]];
                            _tapLabelText = [NSString stringWithFormat:@"%@\n%@：%@", _tapLabelText, _chartName[[names[i] integerValue]], [self getStringWithString:chart.value]];
                        }else {
                            _tapLabelText = [NSString stringWithFormat:@"%@\n%@：%@", _tapLabelText, _chartName[[names[i] integerValue]], [self getStringWithString:chart.value]];
                        }
                    }
                    
                    [self setTapedView];
                }
            }
        }
    }
}

- (void)setTapedView {
    
    if (!flag) {
        self.tapLine.frame = CGRectMake(_tapPoint.x - _coordinateHeight/2, 10 + _coordinateHeight/2 - 0.5, _coordinateHeight, 1);
        
        [self.tapLine drawDashLine:self.tapLine lineLength:5 lineSpacing:4 lineColor:MAKE_COLOR(50, 50, 50)];
        self.tapLine.transform = CGAffineTransformMakeRotation(M_PI_2);
        
        flag = YES;
    }else {
        self.tapLine.frame = CGRectMake(_tapPoint.x, 10, 1, _coordinateHeight);
    }
    
    CGFloat height = [self getTitleHeightWithTitle:_tapLabelText withFont:[UIFont systemFontOfSize:12] withEdge:110];
    if (_coordinateWidth - _tapPoint.x > 120) {
        if (_tapPoint.y < height/2 + 10) {
            self.tapLabel.frame = CGRectMake(_tapPoint.x, 10, 110, height);
        }else if (_tapPoint.y > _coordinateHeight - height/2) {
            self.tapLabel.frame = CGRectMake(_tapPoint.x, _coordinateHeight - height, 110, height);
        }else {
            self.tapLabel.frame = CGRectMake(_tapPoint.x, _tapPoint.y - height/2, 110, height);
        }
        
    }else {
        if (_tapPoint.y < height/2 + 10) {
            self.tapLabel.frame = CGRectMake(_tapPoint.x - 110, 10, 110, height);
        }else if (_tapPoint.y > _coordinateHeight - height/2) {
            self.tapLabel.frame = CGRectMake(_tapPoint.x - 110, _coordinateHeight - height, 110, height);
        }else {
            self.tapLabel.frame = CGRectMake(_tapPoint.x - 110, _tapPoint.y - height/2, 110, height);
        }
    }
    self.tapLabel.text = _tapLabelText;
    [self bringSubviewToFront:self.tapLabel];
    
    
}

- (NSString *)getStringWithString:(NSString *)value {
    if ([[NSString stringWithFormat:@"%.0f", [value floatValue]] length] >= 3) {
        return [NSString stringWithFormat:@"%.0f%%", [value floatValue]];
    }else {
        return [NSString stringWithFormat:@"%.2f%%", [value floatValue]];
    }
}

- (NSArray *)checkTheSelectedChartPointWithTapDateString:(NSString *)tapDateString {
    
    NSMutableArray *array1 = [NSMutableArray array];
    NSMutableArray *array2 = [NSMutableArray array];
    for (NSInteger i = 0; i < _dataArr.count; i++) {
        NSArray *chartArray = [_dataArr objectAtIndex:i];
        for (NSInteger j = 0; j < chartArray.count; j++) {
            ChartModel *chart = [chartArray objectAtIndex:j];
            NSString *chartTimeString = [[chart.time componentsSeparatedByString:@" "] firstObject];
            if ([chartTimeString isEqualToString:tapDateString]) {
                [array1 addObject:chart];
                [array2 addObject:@(i)];
                break;
            }
        }
    }
    
    if (array1.count != 0) {
        return @[array1, array2];
    }else {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yy-MM-dd"];
        
        CGFloat minSpace1 = 0;
        NSInteger tag1 = 0;
        NSInteger tag2 = 0;
        for (NSInteger i = 0; i < _dataArr.count; i++) {
            NSArray *chartArray = [_dataArr objectAtIndex:i];
            
            CGFloat minSpace2 = 0;
            NSInteger flag1 = 0;
            for (NSInteger j = 0; j < chartArray.count; j++) {
                ChartModel *chart = [chartArray objectAtIndex:j];
                NSString *chartTimeString = [[chart.time componentsSeparatedByString:@" "] firstObject];
                
                NSTimeInterval tapInterval = [[formatter dateFromString:tapDateString] timeIntervalSinceReferenceDate];
                NSTimeInterval chartInterval = [[formatter dateFromString:chartTimeString] timeIntervalSinceReferenceDate];
                if (j == 0) {
                    minSpace2 = ABS(tapInterval - chartInterval);
                }else {
                    if (ABS(tapInterval - chartInterval) <= minSpace2) {
                        minSpace2 = ABS(tapInterval - chartInterval);
                    }else {
                        flag1 = j - 1;
                        break;
                    }
                }
            }
            if (i == 0) {
                minSpace1 = minSpace2;
                tag2 = flag1;
            }else {
                if (minSpace2 < minSpace1) {
                    minSpace1 = minSpace2;
                    tag1 = i;
                    tag2 = flag1;
                }
            }
            
        }
        if (_dataArr.count >= tag1 + 1) {
            
            NSArray *array = _dataArr[tag1];
            if (array.count >= tag2 + 1) {
                ChartModel *chart = array[tag2];
                [array1 addObject:chart];
                [array2 addObject:@(tag1)];
                return @[array1, array2];
            }
        }
    }
    return @[];
}

- (CGFloat)getTitleHeightWithTitle:(NSString *)title withFont:(UIFont *)font withEdge:(CGFloat)size {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    CGSize si = [title boundingRectWithSize:CGSizeMake(size, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    return si.height;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
