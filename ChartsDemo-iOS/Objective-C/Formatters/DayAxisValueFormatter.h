//
//  DayAxisValueFormatter.h
//  ChartsDemo
//  Copyright © 2016 dcg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChartsDemo_iOS-Swift.h"

@interface DayAxisValueFormatter : NSObject <IChartAxisValueFormatter>

@property(nonatomic,assign) double barSpace; //bar与bar中轴线space

- (id)initForChart:(BarLineChartViewBase *)chart;

@end
