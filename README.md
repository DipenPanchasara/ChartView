---
Title: DChartView

Description: simple Line Chart Representation with Data.

Author: Dipen Panchasara

Tags: Objective-c, IOS, iPhone, iPad

---

ChartView
=========
DChartView is customised Linechart for any representation,
its build with coregraphics so no need to worry about load on you application, 
use it withs simple initialization and set your values, thats all...!!

Frameworks
=========
Quartzcore.framework

How to use it
==================

Step 1: Import Header to your ViewController

//#import "DPlotChart.h"

Step 2: Instantiate the object with frame

    DPlotChart *plotChart = [[DPlotChart alloc] initWithFrame:CGRectMake(10, 70, 250, 300)];

Step 3: Pass NSOrdeset Object with Data

    [plotChart createChartWith:arrHistoricData];

Step 4: Add Chart to your view

    [self.view addSubview:plotChart];

Thats all, it will do remaining..

http://stackoverflow.com/users/990070/dipen-panchasara
