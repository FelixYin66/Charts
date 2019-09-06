//
//  BarChartViewController.m
//  ChartsDemo
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

#import "BarChartViewController.h"
#import "ChartsDemo_iOS-Swift.h"
#import "DayAxisValueFormatter.h"

@interface BarChartViewController () <ChartViewDelegate>

@property (nonatomic, strong) IBOutlet BarChartView *chartView;
@property (nonatomic, strong) IBOutlet UISlider *sliderX;
@property (nonatomic, strong) IBOutlet UISlider *sliderY;
@property (nonatomic, strong) IBOutlet UITextField *sliderTextX;
@property (nonatomic, strong) IBOutlet UITextField *sliderTextY;
@property(nonatomic,assign) NSInteger count;
@property(nonatomic,assign) double barSpaceScale;
@property(nonatomic,assign) double barWidthScale;
@property(nonatomic,assign) double barWidth;
@property(nonatomic,assign) double chartsViewLeftSpace;
@property(nonatomic,assign) double chartsViewRightSpace;

@end

@implementation BarChartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.count = 3;
    self.barSpaceScale = 5;
    self.barWidthScale = 1;
    self.barWidth = 15;
    self.chartsViewLeftSpace = 40;
    self.chartsViewRightSpace = 40;
    self.title = @"Bar Chart";
    //213
    self.options = @[
                     @{@"key": @"toggleValues", @"label": @"Toggle Values"},
                     @{@"key": @"toggleIcons", @"label": @"Toggle Icons"},
                     @{@"key": @"toggleHighlight", @"label": @"Toggle Highlight"},
                     @{@"key": @"animateX", @"label": @"Animate X"},
                     @{@"key": @"animateY", @"label": @"Animate Y"},
                     @{@"key": @"animateXY", @"label": @"Animate XY"},
                     @{@"key": @"saveToGallery", @"label": @"Save to Camera Roll"},
                     @{@"key": @"togglePinchZoom", @"label": @"Toggle PinchZoom"},
                     @{@"key": @"toggleAutoScaleMinMax", @"label": @"Toggle auto scale min/max"},
                     @{@"key": @"toggleData", @"label": @"Toggle Data"},
                     @{@"key": @"toggleBarBorders", @"label": @"Show Bar Borders"},
                     ];
    
    [self setupBarLineChartView:_chartView];
    
    _chartView.delegate = self;
    
    _chartView.drawBarShadowEnabled = NO;
    _chartView.drawValueAboveBarEnabled = NO;
    
    ChartXAxis *xAxis = _chartView.xAxis;
    xAxis.drawAxisLineEnabled = NO;
    xAxis.drawGridLinesEnabled = YES;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.labelFont = [UIFont systemFontOfSize:10.f];
    xAxis.drawGridLinesEnabled = YES;
//    xAxis.labelCount = self.count;
    DayAxisValueFormatter *formatter = [[DayAxisValueFormatter alloc] initForChart:_chartView];
//    formatter.barSpace = self.barSpace;
    xAxis.valueFormatter = formatter;
    
//    NSNumberFormatter *leftAxisFormatter = [[NSNumberFormatter alloc] init];
//    leftAxisFormatter.minimumFractionDigits = 0;
//    leftAxisFormatter.maximumFractionDigits = 1;
//    leftAxisFormatter.negativeSuffix = @" $";
//    leftAxisFormatter.positiveSuffix = @" $";
//
//    ChartYAxis *leftAxis = _chartView.leftAxis;
//    leftAxis.labelFont = [UIFont systemFontOfSize:10.f];
//    leftAxis.labelCount = 8;
//    leftAxis.valueFormatter = [[ChartDefaultAxisValueFormatter alloc] initWithFormatter:leftAxisFormatter];
//
//    leftAxis.labelPosition = YAxisLabelPositionOutsideChart;
//    leftAxis.spaceTop = 0.15;
//    leftAxis.axisMinimum = 0.0; // this replaces startAtZero = YES
    
    _chartView.leftAxis.enabled = NO;
    _chartView.rightAxis.enabled = NO;
    _chartView.leftAxis.axisMinimum = 0;
//    ChartYAxis *rightAxis = _chartView.rightAxis;
//    rightAxis.enabled = YES;
//    rightAxis.drawGridLinesEnabled = NO;
//    rightAxis.labelFont = [UIFont systemFontOfSize:10.f];
//    rightAxis.labelCount = 8;
//    rightAxis.valueFormatter = leftAxis.valueFormatter;
//    rightAxis.spaceTop = 0.15;
//    rightAxis.axisMinimum = 0.0; // this replaces startAtZero = YES
    
    ChartLegend *l = _chartView.legend;
    l.enabled = NO;
//    l.horizontalAlignment = ChartLegendHorizontalAlignmentLeft;
//    l.verticalAlignment = ChartLegendVerticalAlignmentBottom;
//    l.orientation = ChartLegendOrientationHorizontal;
//    l.drawInside = NO;
//    l.form = ChartLegendFormSquare;
//    l.formSize = 9.0;
//    l.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.f];
//    l.xEntrySpace = 4.0;
    
//    XYMarkerView *marker = [[XYMarkerView alloc]
//                                  initWithColor: [UIColor colorWithWhite:180/255. alpha:1.0]
//                                  font: [UIFont systemFontOfSize:12.0]
//                                  textColor: UIColor.whiteColor
//                                  insets: UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0)
//                                  xAxisValueFormatter: _chartView.xAxis.valueFormatter];
//    marker.chartView = _chartView;
//    marker.minimumSize = CGSizeMake(80.f, 40.f);
//    _chartView.marker = marker;
    
    _sliderX.value = 12.0;
    _sliderY.value = 50.0;
    [self slidersValueChanged:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateChartData
{
    if (self.shouldHideData)
    {
        _chartView.data = nil;
        return;
    }
    
    [self setDataCount:_sliderX.value + 1 range:_sliderY.value];
}

- (void)setDataCount:(int)count range:(double)range
{
    double start = 1.0;
    count = self.count;
    //指定bar的实际宽度，是以点来计算
    CGFloat barWidth = self.barWidth;
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    NSInteger spacePercent = self.barSpaceScale;
    NSInteger barWidthPercent = self.barWidthScale;
    double leftSpace = self.chartsViewLeftSpace; //左边边距
    double rightSpace = self.chartsViewRightSpace; //右边边距
    double xAxisLeftSpaceScale = (barWidth*0.5+leftSpace - 10)/barWidth;
    double xAxisRightSpaceScale = (barWidth*0.5+rightSpace - 10)/barWidth;
    _chartView.xAxis.spaceMin = xAxisLeftSpaceScale; //xAxis左边间隙比例
    _chartView.xAxis.spaceMax = xAxisRightSpaceScale; //xAxis右边间隙比例
    NSLog(@" === %@",@(xAxisLeftSpaceScale));
    double xAxisLeftAndRightSpace = 20; //框架固定space 20
    CGFloat totalWidth = CGRectGetWidth(self.chartView.frame) - xAxisLeftAndRightSpace;
    double visibleCount = totalWidth/barWidth;
    double averageWidth = 0;
    //35.5  23.6 23.6
    if (self.count > 0 && self.count < visibleCount) {
        double spaceCount = self.barSpaceScale*(self.count-1)+xAxisLeftSpaceScale+xAxisRightSpaceScale;
        averageWidth = (spaceCount > visibleCount) ? 0 : (totalWidth/spaceCount);
    }
    //当charts中bar的宽度大于指定的bar的宽度是需要缩放scale比例，从而达到指定bar宽度
    CGFloat scale = barWidth/averageWidth;
    for (int i = start; i < start + count; i++)
    {
        double mult = (range + 1);
        double val = (double) (arc4random_uniform(mult));
        if (val < 1) {
            val = 10;
        }
        if (arc4random_uniform(100) < 25) {
            [yVals addObject:[[BarChartDataEntry alloc] initWithX:i*spacePercent y:val icon: [UIImage imageNamed:@"icon"]]];
        } else {
            [yVals addObject:[[BarChartDataEntry alloc] initWithX:i*spacePercent y:val]];
        }
    }
    
    BarChartDataSet *set1 = nil;
    if (_chartView.data.dataSetCount > 0)
    {
        set1 = (BarChartDataSet *)_chartView.data.dataSets[0];
        [set1 replaceEntries: yVals];
        [_chartView.data notifyDataChanged];
        [_chartView notifyDataSetChanged];
    }
    else
    {
        
//        @[@[[UIColor colorWithRed:0/255.0 green:36/255.0 blue:83/255.0 alpha:1],[UIColor colorWithRed:0/255.0 green:45/255.0 blue:114/255.0 alpha:1]]];
//        _chartView.highlightGradientColors = @[@[[UIColor colorWithRed:30/255.0 green:129/255.0 blue:253/255.0 alpha:1],[UIColor colorWithRed:109/255.0 green:221/255.0 blue:255/255.0 alpha:1]]];\
        
        _chartView.backgroundColor = [UIColor colorWithRed:1/255.0 green:22/255.0 blue:55/255.0 alpha:1];
        if(yVals.count > 0){
//            [UIColor colorWithRed:0/255.0 green:45/255.0 blue:114/255.0 alpha:1]
            set1 = [[BarChartDataSet alloc] initWithEntries:yVals label:@"The year 2017"];
//            [set1 setColor:[UIColor colorWithRed:0/255.0 green:45/255.0 blue:114/255.0 alpha:1]];
//                    [set1 setColors:ChartColorTemplates.material];
            [set1 setColor:nil];
            set1.barGradientColors = @[@[[UIColor colorWithRed:0/255.0 green:36/255.0 blue:83/255.0 alpha:1],[UIColor colorWithRed:0/255.0 green:45/255.0 blue:114/255.0 alpha:1]]]; //默认状态渐变色
//            set1.highlightColor = nil;//[UIColor redColor]; //单色
            set1.highlightGradientColors = @[@[[UIColor colorWithRed:30/255.0 green:129/255.0 blue:253/255.0 alpha:1],[UIColor colorWithRed:109/255.0 green:221/255.0 blue:255/255.0 alpha:1]]]; //高亮渐变色
            set1.drawIconsEnabled = NO;
            set1.drawValuesEnabled = NO;
            set1.barNeedRedius = YES;
            
            NSMutableArray *dataSets = [[NSMutableArray alloc] init];
            [dataSets addObject:set1];
            
            BarChartData *data = [[BarChartData alloc] initWithDataSets:dataSets];
            [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10.f]];
            _chartView.fitBars = NO;
            data.barWidth = barWidthPercent;
            
            _chartView.data = data;
        }else{
            _chartView.data = nil;
        }
        _chartView.scaleXEnabled = NO;
        _chartView.scaleYEnabled = NO;
        _chartView.xAxis.granularityEnabled = YES;
        _chartView.xAxis.granularity = self.barSpaceScale;
        [_chartView setVisibleXRangeMaximum:visibleCount];
        if (scale != 0) {
            //防止在visiblecount 大于实际count
           [_chartView.viewPortHandler setMaximumScaleX:scale];
        }
        
        //设置默认选中
        id hh = [_chartView.highlighter getHighlightWithX:39.9999 y:1];
        [_chartView highlightValue:hh];
    }
}

- (void)optionTapped:(NSString *)key
{
    [super handleOption:key forChartView:_chartView];
}

#pragma mark - Actions

- (IBAction)slidersValueChanged:(id)sender
{
    _sliderTextX.text = [@((int)_sliderX.value + 2) stringValue];
    _sliderTextY.text = [@((int)_sliderY.value) stringValue];
    
    [self updateChartData];
}

#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry highlight:(ChartHighlight * __nonnull)highlight
{
    NSLog(@"chartValueSelected");
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    NSLog(@"chartValueNothingSelected");
}

@end
