//
//  DateDetailController.m
//  NEP
//
//  Created by Gold Luo on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DateDetailController.h"
#import "Notification.h"

@interface DateDetailController ()

@property (nonatomic, strong) id<DateDetailDelegate> delegate;

@end

@implementation DateDetailController

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
    
    
    NSString * date = [Notification getDate];
    pickerDate.date = [Utils dateFromString:date :DATE_FULL];
    
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


- (void) onUpdate {
    NSDate * curDate = pickerDate.date;
    
//    [delegate setDate:curDate];
    
    [Notification setDate:[Utils getDateString:curDate :DATE_FULL]];
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end
