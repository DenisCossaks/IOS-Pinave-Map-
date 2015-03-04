//
//  EveryDayController.m
//  NEP
//
//  Created by Gold Luo on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EveryDayController.h"
#import "Notification.h"



@interface EveryDayController ()

@property (nonatomic, strong) id<EveryDayDelegate> delegate;

@end

@implementation EveryDayController

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

    arrayDays = [[NSArray alloc] initWithObjects:@"1", @"3", @"5", @"10", @"15", @"30", @"60", nil];
    
    int nMinute = [Notification getMinute];
    int selected  = [arrayDays indexOfObject:[NSString stringWithFormat:@"%d", nMinute]];
    nSelect = selected;
    
//    [picker selectedRowInComponent:selected];
    [picker selectRow:selected inComponent:0 animated:YES];
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


-(void) onUpdate {
    NSString * sMinute = [arrayDays objectAtIndex:nSelect];
    
//    [delegate setEveryDay:[sMinute intValue]];
    
    [Notification setMinute:[sMinute intValue]];
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark --- Picker delegate 
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [arrayDays count];
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 300;
}

-(UIView *)pickerView:(UIPickerView *)zonepickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    static const int kReusableTag = 1;
    if (view.tag != kReusableTag) {
        CGRect frame = CGRectZero;
        frame.size = [zonepickerView rowSizeForComponent:component];
        frame = CGRectInset(frame, 4.0, 4.0);
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont boldSystemFontOfSize:18.0];
        view = label;
        view.tag = kReusableTag;
        view.opaque = NO;
        view.backgroundColor = [UIColor clearColor];
        view.userInteractionEnabled = NO;
    }
    
    UILabel *textLabel = (UILabel*)view;
    
    textLabel.text = [arrayDays objectAtIndex:row];
    
	return view;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    if (component == 0) {
    
        nSelect = row;
        
    }
}

@end
