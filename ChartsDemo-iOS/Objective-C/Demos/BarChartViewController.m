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

@end

@implementation BarChartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.count = 7;
    self.title = @"Bar Chart";
    
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
    
    _chartView.maxVisibleCount = 60;
    
    ChartXAxis *xAxis = _chartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.labelFont = [UIFont systemFontOfSize:10.f];
    xAxis.drawGridLinesEnabled = NO;
    xAxis.granularity = 1.0; // only intervals of 1 day
    xAxis.labelCount = self.count;
    xAxis.valueFormatter = [[DayAxisValueFormatter alloc] initForChart:_chartView];
    
    NSNumberFormatter *leftAxisFormatter = [[NSNumberFormatter alloc] init];
    leftAxisFormatter.minimumFractionDigits = 0;
    leftAxisFormatter.maximumFractionDigits = 1;
    leftAxisFormatter.negativeSuffix = @" $";
    leftAxisFormatter.positiveSuffix = @" $";
    
    ChartYAxis *leftAxis = _chartView.leftAxis;
    leftAxis.labelFont = [UIFont systemFontOfSize:10.f];
    leftAxis.labelCount = 8;
    leftAxis.valueFormatter = [[ChartDefaultAxisValueFormatter alloc] initWithFormatter:leftAxisFormatter];
    leftAxis.labelPosition = YAxisLabelPositionOutsideChart;
    leftAxis.spaceTop = 0.15;
    leftAxis.axisMinimum = 0.0; // this replaces startAtZero = YES
    
    _chartView.leftAxis.enabled = NO;
    _chartView.rightAxis.enabled = NO;
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
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    
    NSInteger spacePercent = 2;
    NSInteger barWidthPercent = 1;//0.85;
    
    CGFloat barWidth = 37;
    CGFloat space = 0;//(spacePercent - barWidthPercent)*37;
    CGFloat totalWidth = CGRectGetWidth(self.chartView.frame);
    NSInteger visibleCount = (totalWidth - space)/(barWidth+space);
    NSLog(@"%@",@((totalWidth - space)/(barWidth+space)));
    CGFloat averageWidth = (totalWidth/(visibleCount*2-1));
    CGFloat scale = barWidth/averageWidth;
    if (visibleCount > count) {
        scale = barWidth/((totalWidth - 20)/(count*2-1));
    }
    NSLog(@"averageWidth == %@  totalWidth == %@ scale == %@",@(averageWidth),@(totalWidth),@(scale));
    
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
        set1 = [[BarChartDataSet alloc] initWithEntries:yVals label:@"The year 2017"];
//        [set1 setColors:ChartColorTemplates.material];
        set1.barGradientColors = @[@[[UIColor colorWithRed:46/255.0 green:204/255.0 blue:113/255.0 alpha:1],[UIColor colorWithRed:241/255.0 green:196/255.0 blue:15/255.0 alpha:1]]]; //默认状态渐变色
        //        set1.highlightColor = [UIColor redColor]; //单色
        set1.highlightGradientColors = @[@[[UIColor redColor],[UIColor blackColor]]]; //高亮渐变色
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
        
        [_chartView setVisibleXRangeMaximum:visibleCount];
        if (scale < 1) {
            [_chartView.viewPortHandler setMaximumScaleX:scale];
        }else{
            //            [_chartView.viewPortHandler setMinimumScaleX:scale];
        }
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
