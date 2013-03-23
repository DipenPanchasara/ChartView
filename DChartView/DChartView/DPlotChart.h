//
//  DPlotChart.h
//  PocketStock
//
//  Created by I-VERVE7 on 20/03/13.
//  Copyright (c) 2013 I-VERVE7. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface DPlotChart : UIView
{
    NSMutableOrderedSet *dictDispPoint;
    NSOrderedSet *dataPoints;
    NSMutableOrderedSet *pointArray;
    
    float chartWidth, chartHeight;
    
    float lineWidth;
    UIColor *lineColor;
    UIFont *dataFont;
    
    CGPoint prevPoint, curPoint;
    
    float min, max;
    int xAxisCount;
    
    BOOL isMovement;    // Default NO
    
    CGPoint currentLoc;
    
    // Chart Title
    NSString *chartTitle;
}

@property (nonatomic, retain) NSMutableOrderedSet *dictDispPoint;
@property (nonatomic, retain) NSOrderedSet *dataPoints;
@property (nonatomic, retain) NSMutableOrderedSet *pointArray;

@property (nonatomic, readwrite) float chartWidth, chartHeight;

@property (nonatomic, retain) UIColor *lineColor;
@property (nonatomic, readwrite) float lineWidth;
@property (nonatomic, readwrite) CGPoint prevPoint, curPoint, currentLoc;
@property (nonatomic, readwrite) float min, max;
@property (nonatomic, readwrite) int xAxisCount;

@property (nonatomic, retain) NSString *chartTitle;

- (void)createChartWith:(NSOrderedSet *)data;
#pragma mark - getMonthName
- (NSString *)getMonthNameByNumber:(int)monthNumber;


@end
