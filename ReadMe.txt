// This is a simple Line Chart Representation with Data.

// Required Frameworks
Quartzcore.framework

// How to use it
// Eg.
// Import Header to your ViewController
#import "DPlotChart.h"

// Instantiate the object with frame
    DPlotChart *plotChart = [[DPlotChart alloc] initWithFrame:CGRectMake(10, 70, 250, 300)];
// Pass NSOrdeset Object with Data
    [plotChart createChartWith:arrHistoricData];
// Add Chart to your view
    [self.view addSubview:plotChart];

// Thats all it will do remaining..

