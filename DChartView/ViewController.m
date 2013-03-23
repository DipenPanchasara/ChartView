//
//  ViewController.m
//  DChartView
//
//  Created by I-VERVE7 on 22/03/13.
//  Copyright (c) 2013 D. All rights reserved.
//

#define kQuery              @"query"
#define kResults            @"results"
#define kQuote              @"quote"
#define kCount              @"count"

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //  Test Data
    NSString *sampleFile = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"DATA.json"];
    NSString *jsonString = [NSString stringWithContentsOfFile:sampleFile encoding:NSUTF8StringEncoding error:nil];
    NSOrderedSet *arrHistoricData = [NSOrderedSet orderedSetWithArray:[[[[jsonString JSONValue] objectForKey:kQuery] objectForKey:kResults] objectForKey:kQuote]];
    
    DPlotChart *plotChart = [[DPlotChart alloc] initWithFrame:CGRectMake(10, 70, 250, 300)];
    [plotChart createChartWith:arrHistoricData];
    [self.view addSubview:plotChart];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
