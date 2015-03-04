//
//  AdvancedScheduleViewController.m
//  NEP
//
//  Created by Gold Luo on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AdvancedScheduleViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"


enum DATE_TYPE {
    _START,
    _END
    };

int     m_nDateType;

enum FILTER_MODE {
    SIMPLE,
    ADVANCED,
    };


@interface AdvancedScheduleViewController ()

@end

@implementation AdvancedScheduleViewController

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

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setTabBarHidden:YES animated:YES];

    if (!iPad) {
        viewDatePicker.frame = CGRectMake(0, self.view.frame.size.height, 320, 260);
        [self.view addSubview:viewDatePicker];
    }
    
    if (!iPad) {
        viewMultiPicker.frame = CGRectMake(0, self.view.frame.size.height, 320, 260);
        [self.view addSubview:viewMultiPicker];
    }

}


- (void) setInterface :(int) _days : (NSString*) _startDate : (NSString*) _endDate : (NSString*) _frequence : (int) _repeat : (int) _every{

    lbDays.text = [NSString stringWithFormat:@"%d", _days];
    slDays.value = _days;
    
    
//    viewSchedule.frame = CGRectMake(viewSchedule.frame.origin.x, 480, viewSchedule.frame.size.width, viewSchedule.frame.size.height);
//    [viewSchedule setHidden:YES];
    
    tfStartDate.text = _startDate;
    tfEndDate.text = _endDate;

    tfFrequency.text = _frequence;
    if ([_frequence isEqualToString:@"One-Time Event"]) {
        [viewRepetition setHidden:YES];
        [viewEvery setHidden:YES];
    }
    
    
    tfRepetition.text = [NSString stringWithFormat:@"%d", _repeat];
    slRepetition.value = _repeat;
    
    tfEvery.text = [NSString stringWithFormat:@"%d", _every];
    slEvery.value = _every;
    if ([_frequence isEqualToString:@"One-Time Event"] || [_frequence isEqualToString:@"Daily"]) {
        lbEvery_days.text = @"days";
    } else if ([_frequence isEqualToString:@"Weekly"]){
        lbEvery_days.text = @"weeks";
    } else if ([_frequence isEqualToString:@"Monthly"]){
        lbEvery_days.text = @"months";
    } else if ([_frequence isEqualToString:@"Yearly"]){
        lbEvery_days.text = @"years";
    }
    
    
    // round effect
    viewDate.layer.cornerRadius = 10.0;
    viewFrequency.layer.cornerRadius = 5.0;
    viewRepetition.layer.cornerRadius = 10.0;
    viewEvery.layer.cornerRadius = 10.0;
    
    
    m_bSimple = SIMPLE;
    [viewSimpleDark setHidden:YES];
    [viewAdvanceDark setHidden:NO];

    arrayPicker = [NSMutableArray new];
    arrayPicker = [self getType:[Utils dateFromString:tfStartDate.text :DATE_FULL] :[Utils dateFromString:tfEndDate.text :DATE_FULL]];
    [pkMulti reloadAllComponents];

}


#pragma mark -------------

- (void)showDatePicker
{
    if (iPad) {
        
        UIViewController* popContent = [[UIViewController alloc] init];
        popContent.view.frame = CGRectMake(0, 0, pkDate.frame.size.width, pkDate.frame.size.height);
        
        [popContent.view addSubview: pkDate];
        popContent.contentSizeForViewInPopover = CGSizeMake(pkDate.frame.size.width, pkDate.frame.size.height);
        
        popoverController = [[UIPopoverController alloc] initWithContentViewController: popContent];
        
        if (m_nDateType == _START) {
            [popoverController presentPopoverFromRect:tfStartDate.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        } else {
            [popoverController presentPopoverFromRect:tfEndDate.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }

        return;
    }
    
    
    if (pickerDateVisible) {
        return;
    }
    
    for (UITextField *textField in self.view.subviews) {
        if ([textField isKindOfClass:[UITextField class]]) {
            [textField resignFirstResponder];
        }
    }
	
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.4f];
    
    viewDatePicker.frame = CGRectMake(0, self.view.frame.size.height - 260, 320, 260);
    
    [viewDatePicker setHidden:NO];
    [UIView commitAnimations];
    
    pickerDateVisible = YES;
    
}

- (void)hideDatePicker
{
    if (!pickerDateVisible) {
        return;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3f];
    
    viewDatePicker.frame = CGRectMake(0, self.view.frame.size.height, 320, 260);
    [UIView commitAnimations];
    
    pickerDateVisible = NO;
    
}


- (void)hidePicker
{
    if (!pickerVisible) {
        return;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3f];
    
    viewMultiPicker.frame = CGRectMake(0, self.view.frame.size.height, 320, 260);
    [UIView commitAnimations];
    
    pickerVisible = NO;
    
}


- (void)showPicker
{
    arrayPicker = [self getType:[Utils dateFromString:tfStartDate.text :DATE_FULL] :[Utils dateFromString:tfEndDate.text :DATE_FULL]];
    int index = [arrayPicker indexOfObject:tfFrequency.text];
    [pkMulti selectRow:index inComponent:0 animated:YES];
    [pkMulti reloadAllComponents];

    if (iPad) {
        
        UIViewController* popContent = [[UIViewController alloc] init];
        popContent.view.frame = CGRectMake(0, 0, pkMulti.frame.size.width, pkMulti.frame.size.height);
        
        [popContent.view addSubview: pkMulti];
        popContent.contentSizeForViewInPopover = CGSizeMake(pkMulti.frame.size.width, pkMulti.frame.size.height);
        
        popoverController = [[UIPopoverController alloc] initWithContentViewController: popContent];
        
        [popoverController presentPopoverFromRect:tfFrequency.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
        return;
    }

    
    if (pickerVisible) {
        return;
    }
    
    for (UITextField *textField in self.view.subviews) {
        if ([textField isKindOfClass:[UITextField class]]) {
            [textField resignFirstResponder];
        }
    }
	
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.4f];
    
    viewMultiPicker.frame = CGRectMake(0, self.view.frame.size.height-260, 320, 260);
    
    [viewMultiPicker setHidden:NO];
    [UIView commitAnimations];
    
    pickerVisible = YES;
    
}


#pragma mark - Picker Data ----------
-(NSMutableArray*) getType : (NSDate*) start : (NSDate*) end {
    
    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents * components = [calendar components:NSHourCalendarUnit
                                                fromDate:start
                                                  toDate:end
                                                 options:0];
    
    int hour = components.hour;
    
    
    NSMutableArray * arrayType = [NSMutableArray arrayWithCapacity:10];
    
    
    if (0 < hour && hour < 24 * 365) {
        [arrayType addObject:@"One-Time Event"];
    }
    
    if (0 < hour && hour < 24) {
        [arrayType addObject:@"Daily"];
    }
    
    if (0 < hour && hour < 24 * 7) {
        [arrayType addObject:@"Weekly"];
    }
    
    if (0 < hour && hour < 24 * 30) {
        [arrayType addObject:@"Monthly"];
    }
    
    if (0 < hour && hour < 24 * 365) {
        [arrayType addObject:@"Yearly"];
    }
    
    return arrayType;
}



#pragma mark --- Picker delegate 
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [arrayPicker count];
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
        
    textLabel.text = [arrayPicker objectAtIndex:row];
    
	return view;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    if (component == 0) {
        
        tfFrequency.text = [arrayPicker objectAtIndex:row];
        
        if ([tfFrequency.text isEqualToString:@"One-Time Event"]) {
            [viewRepetition setHidden:YES];
            [viewEvery setHidden:YES];
        } else {
            [viewRepetition setHidden:NO];
            [viewEvery setHidden:NO];
            
            NSString * _frequence = tfFrequency.text;
            if ([_frequence isEqualToString:@"One-Time Event"] || [_frequence isEqualToString:@"Daily"]) {
                lbEvery_days.text = @"days";
            } else if ([_frequence isEqualToString:@"Weekly"]){
                lbEvery_days.text = @"weeks";
            } else if ([_frequence isEqualToString:@"Monthly"]){
                lbEvery_days.text = @"months";
            } else if ([_frequence isEqualToString:@"Yearly"]){
                lbEvery_days.text = @"years";
            }

        }
        
    }
}


#pragma mark ---------------
- (IBAction) chagneSliderDays{
    int value = slDays.value;
    lbDays.text = [NSString stringWithFormat:@"%d", value];
    
    
    NSString* startDate = tfStartDate.text;
    
    
    NSDate * cur_Date = [Utils dateFromString:startDate :DATE_FULL];
    
    NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
    [dateComponents setDay:value -1];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDate* end_date = [calendar dateByAddingComponents:dateComponents toDate:cur_Date options:0];
    NSString * endDate = [NSString stringWithFormat:@"%@ %@", [Utils getDateString:end_date :DATE_DATE], @"23:59"];
    
    tfEndDate.text = endDate;

}
- (IBAction) changeTextRepetition{
    int value = [tfRepetition.text intValue];
    slRepetition.value = value;
}
- (IBAction) changeSliderRepetition{
    int value = slRepetition.value;
    tfRepetition.text = [NSString stringWithFormat:@"%d", value];
}

- (IBAction) changeTextEvery{
    int value = [tfEvery.text intValue];
    slEvery.value = value;
}
- (IBAction) changeSliderEvery{
    int value = slEvery.value;
    tfEvery.text = [NSString stringWithFormat:@"%d", value];
}

- (IBAction) next{
    
}


- (IBAction) onSaveSchedule : (id) sender{
    [self.navigationController popViewControllerAnimated:YES];
    
    int _simple = 1;
    if (m_bSimple == ADVANCED) { //show
        _simple = 0;
    }
    
    NSString * sFrequency = [tfFrequency.text lowercaseString];
    if ([tfFrequency.text isEqualToString:@"One-Time Event"]) {
        sFrequency = @"one";
    }
    
    [delegate setAdvancedSchedule:_simple :slDays.value : tfStartDate.text :tfEndDate.text :sFrequency :[tfRepetition.text intValue] :[tfEvery.text intValue]];
    
}

- (IBAction) onSimple:(id)sender
{
    m_bSimple = SIMPLE;

    [viewSimpleDark setHidden:YES];
    [viewAdvanceDark setHidden:NO];
}
- (IBAction) onAdvanced:(id)sender
{
    m_bSimple = ADVANCED;

    [viewSimpleDark setHidden:NO];
    [viewAdvanceDark setHidden:YES];

/*    
//    int height = viewSchedule.frame.size.height;
    int yPos = viewSchedule.frame.origin.y;

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];

    if (yPos < 480) {
        viewSchedule.frame = CGRectMake(viewSchedule.frame.origin.x, 480, viewSchedule.frame.size.width, viewSchedule.frame.size.height);
    } else {
//        [UIView setAnimationDelegate:self];
//        [UIView setAnimationDidStopSelector:@selector(endAnimation)];
        viewSchedule.frame = CGRectMake(viewSchedule.frame.origin.x, 143, viewSchedule.frame.size.width, viewSchedule.frame.size.height);
    }
    
    [UIView commitAnimations];
*/ 

}

- (void) endAnimation
{
    [viewSchedule setHidden:YES];
}

- (IBAction) changeDate:(id)sender{
    if (m_nDateType == _START) {
        tfStartDate.text = [Utils getDateString:pkDate.date :DATE_FULL];
    }
    else {
        tfEndDate.text = [Utils getDateString:pkDate.date :DATE_FULL];
    }
    
    arrayPicker = [self getType:[Utils dateFromString:tfStartDate.text :DATE_FULL] :[Utils dateFromString:tfEndDate.text :DATE_FULL]];
    [pkMulti reloadAllComponents];

    tfFrequency.text = @"One-Time Event";
    [viewRepetition setHidden:YES];
    [viewEvery setHidden:YES];
    
}
- (IBAction) onDateDone:(id)sender{
    [self hideDatePicker];
}

- (IBAction) onPickerDone:(id)sender{
    [self hidePicker];
}


#pragma mark -------- Text delegate ---------
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    BOOL shouldEdit = NO;
	
	if ([textField isEqual:tfStartDate] || [textField isEqual:tfEndDate]) {
        
        if ([textField isEqual:tfStartDate]) {
            m_nDateType = _START;
        } else {
            m_nDateType = _END;
        }
        
        [textField resignFirstResponder];
        
        
        pkDate.date = [Utils dateFromString: textField.text : DATE_FULL];
        
        if ([textField isEqual:tfStartDate]) {
            pkDate.minimumDate = [NSDate date];
        }
        else if ([textField isEqual:tfEndDate]) {
            pkDate.minimumDate = [Utils dateFromString: tfStartDate.text : DATE_FULL];
        }
        
        
		shouldEdit = NO;
		[self showDatePicker];
        [self hidePicker];
        
    } else if ([textField isEqual:tfFrequency]){
        
        
        [self hideDatePicker];
        [self showPicker];
        
        shouldEdit = NO;
	} else {
        [textField resignFirstResponder];
        
        [self hideDatePicker];
        [self hidePicker];
    }
    
	return shouldEdit;
}

@end
