//
//  AdvancedSearchView.m
//  PinAve
//
//  Created by Gold Luo on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AdvancedSearchView.h"
#import "SelectCategoryController.h"
#import "Setting.h"
#import "FilterSearch.h"

@implementation AdvancedSearchView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void) setInterface 
{
    scDate.selectedSegmentIndex = 1;
    
    int radius = [Setting getRadius];
    lbRadius.text = [NSString stringWithFormat:@"%d", radius];

    switch (radius) {
        case 1:
            pvRadius.value = 0;
            break;
        case 2:
            pvRadius.value = 1;
            break;
        case 5:
            pvRadius.value = 2;
            break;
        case 10:
            pvRadius.value = 3;
            break;
        case 50:
            pvRadius.value = 4;
            break;
        case 100:
            pvRadius.value = 5;
            break;
        case 200:
            pvRadius.value = 6;
            break;
        case 500:
            pvRadius.value = 7;
            break;
    }
    
    int unit = [Setting getUnit];
    if (unit == 0) {
        lbUnit.text = @"Km";
    } else {
        lbUnit.text = @"Mile";
    }
    
    
    int time = [FilterSearch getTimeOption];
    scDate.selectedSegmentIndex = time;
    
}
- (IBAction)onChangedDate:(UISegmentedControl*)sender
{
    int index = sender.selectedSegmentIndex;
    [FilterSearch setTimeOption:index];
}

- (IBAction)onChangedRadius:(UISlider*)sender
{
    int value = sender.value;
    NSLog(@"value = %d", value);
    
    switch (value) {
        case 0:
            [Setting setRadius:1];
            break;
        case 1:
            [Setting setRadius:2];
            break;
        case 2:
            [Setting setRadius:5];
            break;
        case 3:
            [Setting setRadius:10];
            break;
        case 4:
            [Setting setRadius:50];
            break;
        case 5:
            [Setting setRadius:100];
            break;
        case 6:
            [Setting setRadius:200];
            break;
        case 7:
            [Setting setRadius:500];
            break;
    }

    int radius = [Setting getRadius];
    NSLog(@"[Setting getRadius] = %d", radius);

    lbRadius.text = [NSString stringWithFormat:@"%d", radius];
}

- (IBAction)onClickCategory:(id)sender
{
    [delegate setWithCategory];
}

@end
