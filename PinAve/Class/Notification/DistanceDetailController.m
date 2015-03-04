//
//  DistanceDetailController.m
//  NEP
//
//  Created by Gold Luo on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DistanceDetailController.h"
#import "Notification.h"


@interface DistanceDetailController ()

@property (nonatomic, strong) id<DistanceDetailDelegate> delegate;

@end

@implementation DistanceDetailController

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem * itemUpdate = [[UIBarButtonItem alloc]initWithTitle:@"Update" style:UIBarButtonItemStylePlain target:self action:@selector(onUpdate)];
    self.navigationItem.rightBarButtonItem=itemUpdate;

    int _distance = [Notification getDistance];
    if (_distance == 1) {
        segDistance.selectedSegmentIndex = 0;
    } else if (_distance == 2) {
        segDistance.selectedSegmentIndex = 1;
    } else if (_distance == 5) {
        segDistance.selectedSegmentIndex = 2;
    } else if (_distance == 10) {
        segDistance.selectedSegmentIndex = 3;
    } 
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}


-(IBAction)onClickSegment:(UISegmentedControl*) sender{

}

- (void) onUpdate {
    int selected = segDistance.selectedSegmentIndex;
    
//    [delegate setDistance:selected];

    if (selected == 0) {
        [Notification setDistance:1];
    } else if (selected == 1) {
        [Notification setDistance:2];
    } else if (selected == 2) {
        [Notification setDistance:5];
    } else if (selected == 3) {
        [Notification setDistance:10];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
