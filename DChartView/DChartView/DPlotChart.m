//
//  DPlotChart.m
//  PocketStock
//
//  Created by I-VERVE7 on 20/03/13.
//  Copyright (c) 2013 I-VERVE7. All rights reserved.
//

#define IS_IPAD                 (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?YES:NO

#define COLOR_WITH_RGB(r,g,b)   [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f]

#define kChartHeight            300.0f
#define kChartWidth             290.0f

#define kLeftMargin             25.0f
#define kTopMargin              10.0f

#define kMargins                30.0f

#define kChartLinesWidth        0.5f

#define kChartLineColor         [UIColor lightGrayColor].CGColor
#define kMarkerLineColor        [UIColor whiteColor].CGColor
#define kPointColor             [UIColor redColor].CGColor
#define kTextColor              [UIColor whiteColor].CGColor

#define kStatesticFont          [UIFont fontWithName:@"Arial" size:10]

#define kPoint                  @"Point"
#define kClose                  @"Close"
#define kDate                   @"Date"
#define kHigh                   @"High"
#define kLow                    @"Low"
#define kOpen                   @"Open"
#define kVolume                 @"Volume"

#define kDateFormat             @"yyyy-MM-dd"

#pragma mark - Implementation Begin
#import "DPlotChart.h"

@implementation DPlotChart

@synthesize pointArray, dataPoints, dictDispPoint;
@synthesize chartWidth, chartHeight;
@synthesize lineWidth, lineColor;
@synthesize prevPoint, curPoint, currentLoc;
@synthesize min, max;
@synthesize xAxisCount;
@synthesize chartTitle;

#pragma mark - Initialization/LifeCycle Method
- (id)initWithFrame:(CGRect)frame
{
    
    [UIColor colorWithRed:5.0f/255.0f green:5.0f/255.0f blue:5.0f/255.0f alpha:1.0f];
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        @try {
            [self setAutoresizingMask: UIViewAutoresizingFlexibleWidth];
            [self setAutoresizesSubviews:YES];
            
            self.min = 0;
            self.max = 50;
            
            self.lineColor = COLOR_WITH_RGB(155, 155, 0);
            self.lineWidth = 2.0f;
            
            self.backgroundColor = COLOR_WITH_RGB(0, 0, 0);
            
//            self.chartHeight = kChartHeight;
//            self.chartWidth = kChartWidth;
            self.chartHeight = frame.size.height;
            self.chartWidth = frame.size.width;
            
            isMovement = NO;
            
            self.pointArray = [[NSMutableOrderedSet alloc] initWithCapacity:0];
            self.dictDispPoint = [[NSMutableOrderedSet alloc] initWithCapacity:0];
            
            dataFont =  [UIFont fontWithName:@"Arial" size:12];
            
            [self.layer setBorderColor:[UIColor darkGrayColor].CGColor];
            [self.layer setBorderWidth:self.lineWidth];
            
            self.layer.shadowColor = [UIColor lightGrayColor].CGColor;
            self.layer.shadowOffset = CGSizeMake(3, 3);
            self.layer.shadowRadius = 1;
            self.layer.shadowOpacity = 1;
            
            [self setNeedsDisplay];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",[exception debugDescription]);
        }
        @finally {
        }
    }
    return self;
}

#pragma mark - Chart Creation Method
- (void)createChartWith:(NSOrderedSet *)data
{
    [self.dictDispPoint removeAllObjects];
    
    if(self.frame.size.width < 300 || self.frame.size.height < 200)
    {
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, 300, 200)];
    }
    
    self.chartHeight = self.frame.size.height - (kLeftMargin*2);
    self.chartWidth = (self.frame.size.width - kMargins);
    
    NSMutableOrderedSet *orderSet = [[NSMutableOrderedSet alloc] initWithCapacity:0];
    
    // Arrange Data in Reverse Order
    [data enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger ind, BOOL *stop){
        
        [orderSet addObject:obj]; //[NSNumber numberWithFloat:[[obj valueForKey:@"Close"] floatValue]]];
    }];
    
//    NSLog(@"Part : %f, %d",self.chartWidth/[orderSet count],[orderSet count]);
    // Arrange Data in Forward Order
//    [data enumerateObjectsUsingBlock:^(id obj, NSUInteger ind, BOOL *stop){
//        
//        [orderSet addObject:[NSNumber numberWithFloat:[[obj valueForKey:@"Close"] floatValue]]];
//    }];
    
    // Find Min & Max of Chart
    self.max = [[[orderSet valueForKey:kClose] valueForKeyPath:@"@max.floatValue"] floatValue];
    self.min = [[[orderSet valueForKey:kClose] valueForKeyPath:@"@min.floatValue"] floatValue];

    // Enhance Upper & Lower Limit for Flexible Display
    self.max += 50;
    self.min -= 50;
    
//    NSLog(@"(Min-Max) %.2f %.2f",self.min,self.max);
    
    // Calculate Deploying Points for Chart according to Values
    float xGapBetweenTwoPoints = self.chartWidth/[orderSet count];
    float x , y;
    x = kLeftMargin;
    y = kTopMargin;
    
    // Empty Previous Points
    if([self.pointArray count] > 0)
        [self.pointArray removeAllObjects];
            
    for(NSDictionary *dictionary in orderSet)
    {
        float closeValue = [[dictionary valueForKey:kClose] floatValue];
        
        float diff = (self.max-closeValue);
        float range = (self.max-self.min);
        y = ((self.chartHeight+kTopMargin)*diff)/range;
        
        CGPoint point = CGPointMake(x,y);
        
//        NSLog(@"%@",NSStringFromCGPoint(point));
        NSDictionary *dictPoint = [NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithCGPoint:point], kPoint,
                                   [dictionary valueForKey:kClose], kClose,
                                   [dictionary valueForKey:kDate], kDate,
                                   [dictionary valueForKey:kLow], kLow,
                                   [dictionary valueForKey:kHigh], kHigh, nil];
        
        [self.dictDispPoint addObject:dictPoint];
        x += xGapBetweenTwoPoints;
    }

    [self setNeedsDisplay];
//    NSLog(@"%@",self.dictDispPoint);
    
}

//UIImage* ImageByPunchingPathOutOfImage(UIImage *image, UIBezierPath *path) {
//    UIGraphicsBeginImageContextWithOptions([image size], YES, [image scale]);
//    
//    [image drawAtPoint:CGPointZero];
//    
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    CGContextSetBlendMode(ctx, kCGBlendModeDestinationOut);
//    [path fill];
//    
//    
//    UIImage *final = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return final;
//}

#pragma mark - getMonthName
- (NSString *)getMonthNameByNumber:(int)monthNumber
{
    switch (monthNumber) {
        case 1:
            return @"Jan";
            break;
        case 2:
            return @"Feb";
            break;
        case 3:
            return @"Mar";
            break;
        case 4:
            return @"Apr";
            break;
        case 5:
            return @"May";
            break;
        case 6:
            return @"Jun";
            break;
        case 7:
            return @"Jul";
            break;
        case 8:
            return @"Aug";
            break;
        case 9:
            return @"Sep";
            break;
        case 10:
            return @"Oct";
            break;
        case 11:
            return @"Nov";
            break;
        case 12:
            return @"Dec";
            break;

        default:
            return @"";
            break;
    }
}

#pragma mark - Drawing
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    @try
    {
        if([self.dictDispPoint count] > 0)
        {
            // Create Current Context To Draw
            CGContextRef context = UIGraphicsGetCurrentContext();        
            
    //        *** Draw X-Axis Lines with Data ***                
            // Content For X Axis
            for(int i=kLeftMargin;i<self.chartWidth;i+=(self.chartWidth/5))
            {
                // Draw Line
                CGContextSetLineWidth(context, 0.5f);
                CGContextSetFillColorWithColor(context, kChartLineColor);
                CGContextSetStrokeColorWithColor(context, kChartLineColor);
                
                // Vertical Line
                CGContextMoveToPoint(context, i, 0);
                CGContextAddLineToPoint(context, i, kTopMargin+self.chartHeight+5);
                
                CGContextStrokePath(context);

                // Draw content Data
                CGContextSetFillColorWithColor(context, kMarkerLineColor);
                CGContextSetStrokeColorWithColor(context, kMarkerLineColor);
                CGContextSetTextDrawingMode(context, kCGTextFillStroke);
//                CGContextSaveGState(context);
//                CGContextRestoreGState(context);
                
                float xGapBetweenTwoPoints = self.chartWidth/[self.dictDispPoint count];
                int pointSlot = (i-kLeftMargin)/xGapBetweenTwoPoints;
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:kDateFormat];
                NSDate *dateFromString = [dateFormatter dateFromString:[[self.dictDispPoint objectAtIndex:pointSlot] valueForKey:kDate]];
            
                NSCalendar* calendar = [NSCalendar currentCalendar];
                NSDateComponents* components = [calendar components:NSMonthCalendarUnit|NSDayCalendarUnit fromDate:dateFromString];
                                          
                [[NSString stringWithFormat:@"%d-%@",[components day],[self getMonthNameByNumber:[components month]]] drawAtPoint:CGPointMake(i-10, kTopMargin + self.chartHeight + 10) withFont:kStatesticFont];
                CGContextStrokePath(context);
            }
            
            // Draw Last Date
            CGContextSetFillColorWithColor(context, kMarkerLineColor);
            CGContextSetStrokeColorWithColor(context, kMarkerLineColor);
            CGContextSetTextDrawingMode(context, kCGTextFillStroke);
            
            // Set Chart Title if set
            if([chartTitle length] > 0)
                [[NSString stringWithFormat:@"%@",self.chartTitle] drawAtPoint:CGPointMake(50, 5) withFont:dataFont];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:kDateFormat];
            NSDate *dateFromString = [dateFormatter dateFromString:[[self.dictDispPoint lastObject] valueForKey:kDate]];
            
            NSCalendar* calendar = [NSCalendar currentCalendar];
            NSDateComponents* components = [calendar components:NSMonthCalendarUnit|NSDayCalendarUnit fromDate:dateFromString];
            
            [[NSString stringWithFormat:@"%d-%@",[components day],[self getMonthNameByNumber:[components month]]] drawAtPoint:CGPointMake(kTopMargin + self.chartWidth-10, kTopMargin + self.chartHeight + 10) withFont:kStatesticFont];
        
            CGContextStrokePath(context);
            
    //        *** Draw Y-Axis Lines with Data ***        
            // Content For Y-Axis
            for(int i=self.chartHeight+kTopMargin;i>=kTopMargin;i-=(self.chartHeight/5))
            {
                // Draw Line
                CGContextSetLineWidth(context, 0.5f);
                CGContextSetFillColorWithColor(context, kChartLineColor);
                CGContextSetStrokeColorWithColor(context, kChartLineColor);
                CGContextSetTextDrawingMode(context, kCGTextFillStroke);
                CGContextSaveGState(context);
                CGContextRestoreGState(context);
                
                // Vertical Line
                CGContextMoveToPoint(context, kLeftMargin, i+2);
                CGContextAddLineToPoint(context, self.chartWidth+kLeftMargin, i+2);
                
                CGContextStrokePath(context);
                
                // Draw content Data
                CGContextSetFillColorWithColor(context, kMarkerLineColor);
                CGContextSetStrokeColorWithColor(context, kMarkerLineColor);
                CGContextSetTextDrawingMode(context, kCGTextFillStroke);
                
                if(i == self.chartHeight+kTopMargin)
                    [[NSString stringWithFormat:@"%.0f",self.max-i] drawAtPoint:CGPointMake(0, i-12) withFont:kStatesticFont];
                else
                    [[NSString stringWithFormat:@"%.0f",self.max-i] drawAtPoint:CGPointMake(0, i-5) withFont:kStatesticFont];
                CGContextStrokePath(context);
            }
            
    //        *** Put Points on Chart ***
            if([self.dictDispPoint count] > 0)
            {
                // Define Point
                [self.dictDispPoint enumerateObjectsUsingBlock:^(id obj, NSUInteger ind, BOOL *stop){
                    if(ind != 0)
                    {
                        self.prevPoint = [[[self.dictDispPoint objectAtIndex:ind-1] valueForKey:kPoint] CGPointValue];
                        self.curPoint = [[[self.dictDispPoint objectAtIndex:ind] valueForKey:kPoint] CGPointValue];
                    }
                    else
                    {
                        self.prevPoint = [[[self.dictDispPoint objectAtIndex:ind] valueForKey:kPoint] CGPointValue];
                        self.curPoint = self.prevPoint;
                    }
                    // Set Line Color & Width
                    CGContextSetLineWidth(context, self.lineWidth);
                    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
                    
                    // Add Point & Draw
                    CGContextMoveToPoint(context, self.prevPoint.x, self.prevPoint.y);
                    CGContextAddLineToPoint(context, self.curPoint.x, self.curPoint.y);
                    CGContextStrokePath(context);

                    // Set Line Color & Width
                    CGContextSetLineWidth(context, self.lineWidth-1);
                    CGContextSetStrokeColorWithColor(context, COLOR_WITH_RGB(185, 185, 0).CGColor);

                    // Fill Point
                    CGContextMoveToPoint(context, self.curPoint.x, self.curPoint.y);
                    CGContextAddLineToPoint(context, self.curPoint.x, kTopMargin+self.chartHeight);
                    CGContextStrokePath(context);
                }];
            }
        
            //      *** Draw X & Y Axis ***
            
            // Set Line Color & Width
            CGContextSetLineWidth(context, self.lineWidth);
            CGContextSetStrokeColorWithColor(context, kMarkerLineColor);
            
            // Y - Axis
            CGContextMoveToPoint(context, kLeftMargin, 0);
            CGContextAddLineToPoint(context, kLeftMargin,self.chartHeight+kTopMargin+10);
            
            // X - Axis
            CGContextMoveToPoint(context, 0, kTopMargin + self.chartHeight);
            CGContextAddLineToPoint(context, kTopMargin + self.chartWidth + 20, kTopMargin + self.chartHeight);
            
            // Draw Axis
            CGContextStrokePath(context);

            
            // Create Chart Background and Lines
            
            // Set Line Color & Width
            CGContextSetLineWidth(context, kChartLinesWidth);
            CGContextSetStrokeColorWithColor(context, kChartLineColor);
            
    //        *** Add Horizontal & Vertical Lines ***
            
            // Show Mini Popup of Current Value
            if(isMovement)
            {
                float xGapBetweenTwoPoints = self.chartWidth/[self.dictDispPoint count];
                int pointSlot = currentLoc.x/xGapBetweenTwoPoints;
                
                if(pointSlot >= 0 && pointSlot < [self.dictDispPoint count])
                {
                    NSDictionary *dict = [self.dictDispPoint objectAtIndex:pointSlot];

                    // Calculate Point to draw Circle
                    CGPoint point = CGPointMake([[dict valueForKey:kPoint] CGPointValue].x,[[dict valueForKey:kPoint] CGPointValue].y);
                    
                    // Display current Touch point with a circle
                    CGRect myOval = {point.x-4, point.y-4, 8, 8};
                    CGContextSetFillColorWithColor(context, kPointColor);
                    CGContextAddEllipseInRect(context, myOval);
                    CGContextFillPath(context);
                    
                    // Draw current Value for point on Screen
                    CGContextSetFillColorWithColor(context, kTextColor);
                    CGContextSetStrokeColorWithColor(context, kTextColor);
                    CGContextSetTextDrawingMode(context, kCGTextFillStroke);
                    CGContextSaveGState(context);
                    
                    CGPoint drawPoint = CGPointZero;
                    
                    if(currentLoc.x >(self.chartWidth/2) && currentLoc.y < 75)
                        drawPoint = CGPointMake(currentLoc.x-120, currentLoc.y+75);
                    else if(currentLoc.x >(self.chartWidth/2))
                        drawPoint = CGPointMake(currentLoc.x-150, currentLoc.y-75);
                    else if(currentLoc.y < 50)
                        drawPoint = CGPointMake(currentLoc.x +150, currentLoc.y+50);
                    else
                        drawPoint = CGPointMake(currentLoc.x+50, currentLoc.y-100);
                    
                    [[NSString stringWithFormat:@"Dt.   %@",[dict valueForKey:kDate]] drawAtPoint:drawPoint withFont:dataFont];
                    [[NSString stringWithFormat:@"Cur. %@",[dict valueForKey:kClose]] drawAtPoint:CGPointMake(drawPoint.x, drawPoint.y + 15) withFont:dataFont];
                    [[NSString stringWithFormat:@"H-L   %@ - %@",[dict valueForKey:kHigh], [dict valueForKey:kLow]] drawAtPoint:CGPointMake(drawPoint.x, drawPoint.y + 30) withFont:dataFont];

                    CGContextRestoreGState(context);
                    
                    // Line at current Point
                    // Set Stroke Color
                    CGContextSetLineWidth(context, self.lineWidth);
                    CGContextSetFillColorWithColor(context, kMarkerLineColor);
                    CGContextSetStrokeColorWithColor(context, kMarkerLineColor);
                    
                    // Vertical Line
    //                CGContextMoveToPoint(context, 0, currentLoc.y);
    //                CGContextAddLineToPoint(context, self.frame.size.width, currentLoc.y);
                    
                    // Horizontal
                    CGContextMoveToPoint(context, point.x, 0);
                    CGContextAddLineToPoint(context, point.x, self.frame.size.height);
                    
                    CGContextStrokePath(context);
                }
            }
        }
        else
        {
//            *** Draw Loading Label ***
            // Create Current Context To Draw
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            //      *** Draw X & Y Axis ***
            // Draw current Value for point on Screen
            CGContextSetFillColorWithColor(context, kTextColor);
            CGContextSetStrokeColorWithColor(context, kTextColor);
            CGContextSetTextDrawingMode(context, kCGTextFillStroke);
            CGContextSaveGState(context);
            
            // Get Center of Chart
            [[NSString stringWithFormat:@"Loading..."] drawAtPoint:CGPointMake(self.center.x-45, self.center.y-25) withFont:dataFont];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception debugDescription]);
    }
    @finally {
    }
}

#pragma mark - Handle Touch Events
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    currentLoc = [touch locationInView:self];
    currentLoc.x -= kLeftMargin;
    isMovement = YES;
    [self setNeedsDisplay];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    currentLoc = [touch locationInView:self];
    currentLoc.x -= kLeftMargin;
    [self setNeedsDisplay];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    currentLoc = [touch locationInView:self];
    currentLoc.x -= kLeftMargin;
    
    isMovement = NO;
    [self setNeedsDisplay];
}


@end
