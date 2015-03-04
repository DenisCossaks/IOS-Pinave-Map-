//
//  PinSettingViewController.m
//  NEP
//
//  Created by Gold Luo on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PinSettingViewController.h"

#import "Setting.h"
#import "MenuCell.h"

enum RADIUS_VALUE {
    MILE_1 = 1,
    MILE_2 = 2,
    MILE_5 = 5,
    MILE_10 = 10,
    MILE_50 = 50,
    MILE_100 = 100,
    MILE_200 = 200,
    MILE_500 = 500
    };

enum PIN_VALUE {
    PIN_25 = 25,
    PIN_50 = 50,
    PIN_100 = 100,
    PIN_150 = 150,
    PIN_200 = 200
    };


@implementation SettingCell

@synthesize iconImg, titleLbl, selectedImg;

@end



@interface PinSettingViewController ()

@end

@implementation PinSettingViewController

@synthesize delegate;
@synthesize categoryList;

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
    
    [self setInterface];
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

- (void) viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setTabBarHidden:YES animated:YES];

    viewDateFrame.frame = CGRectMake(0, self.view.frame.size.height, 320, 260);
    pickerDateVisible = NO;
    [self.view addSubview:viewDateFrame];

}


#pragma mark -------------- init ---------
- (void) setInterface {
    
    self.categoryList = [Share getInstance].arrayCategory;
    
/*    
    if (iPad){
        scrollView.frame = CGRectMake(0, 44, 768, 960);
        [scrollView setContentSize:CGSizeMake(768, 960)];
    } else {
        scrollView.frame = CGRectMake(0, 44, 320, 436);
        [scrollView setContentSize:CGSizeMake(320, 620)];
    }
    [self.view addSubview:scrollView];
*/    
    
    tfStartDate.text = [Setting getStartDate];
    tfEndDate.text   = [Setting getEndDate];

    int nRadius = [Setting getRadius];
    int nSelect = 0;
    switch (nRadius) {
        case MILE_1:
            nSelect = 0; break;
        case MILE_2:
            nSelect = 1; break;
        case MILE_5:
            nSelect = 2; break;
        case MILE_10:
            nSelect = 3; break;
        case MILE_50:
            nSelect = 4; break;
        case MILE_100:
            nSelect = 5; break;
        case MILE_200:
            nSelect = 6; break;
        case MILE_500:
            nSelect = 7; break;
    }
    slRadius.value = nSelect;
    lbRadius.text = [NSString stringWithFormat:@"%d", nRadius];
    
    if ([Setting getUnit] == 0) {
        lbUnit.text = @"Km";
    } else {
        lbUnit.text = @"Mile";
    }
        
//    scRadius.selectedSegmentIndex = nSelect;
    
    
    int nPins = [Setting getNumberOfPins];
    switch (nPins) {
        case PIN_25:
            nSelect = 0;  break;
        case PIN_50:
            nSelect = 1;  break;
        case PIN_100:
            nSelect = 2;  break;
        case PIN_150:
            nSelect = 3;  break;
        case PIN_200:
            nSelect = 4;  break;
    }
    scPins.selectedSegmentIndex = nSelect;
    
    
//    int nMapMode = [Setting getMapMode];
//    scMapmode.selectedSegmentIndex = nMapMode;
    
//    tfTimezone.text = [Setting getTimezone];
    
    NSMutableArray * _categorys = [Setting getCategory];
    for (int i = 0; i < [_categorys count]; i ++) {
        NSNumber *opt = (NSNumber*)[_categorys objectAtIndex:i];

        NSMutableDictionary *categoryItem = [self.categoryList objectAtIndex:i];
        
        if ([opt intValue] == 0) {
            [categoryItem setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
        } else {
            [categoryItem setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
        }
        
    }

    [tvCategory reloadData];

}

#pragma mark ------- Button Event -------
-(IBAction)onCancel:(id)sender {
//    [self dismissModalViewControllerAnimated: YES];
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)onUpdate:(id)sender {
//    int selected = scRadius.selectedSegmentIndex;
    int selected = slRadius.value;
    
    int nRadius = 1;
    switch (selected) {
        case 0:
            nRadius = MILE_1;  break;
        case 1:
            nRadius = MILE_2;  break;
        case 2:
            nRadius = MILE_5;  break;
        case 3:
            nRadius = MILE_10;  break;
        case 4:
            nRadius = MILE_50;  break;
        case 5:
            nRadius = MILE_100;  break;
        case 6:
            nRadius = MILE_200;  break;
        case 7:
            nRadius = MILE_500;  break;
    }
    
    [Setting setRadius:nRadius];
    
    
    selected = scPins.selectedSegmentIndex;
    
    int nPins = 1;
    switch (selected) {
        case 0:
            nPins = PIN_25;  break;
        case 1:
            nPins = PIN_50;  break;
        case 2:
            nPins = PIN_100;  break;
        case 3:
            nPins = PIN_150;  break;
        case 4:
            nPins = PIN_200;  break;
    }
    
    [Setting setNumberOfPins: nPins];
    
    
    [Setting setMapMode: scMapmode.selectedSegmentIndex];

    [Setting setStartDate: tfStartDate.text];
    [Setting setEndDate: tfEndDate.text];    
//    [Setting setTimezone:tfTimezone.text];
    
    
    //category tick 
    NSMutableArray * _categorys = [[NSMutableArray alloc] initWithCapacity:10];
    for (NSMutableDictionary * categoryItem in self.categoryList) {
        BOOL isSelected = [[categoryItem objectForKey:@"selected"] boolValue];
        
        if (isSelected) {
            [_categorys addObject:[NSNumber numberWithInt:1]];
        } else {
            [_categorys addObject:[NSNumber numberWithInt:0]];
        }
    }
    [Setting setCategory:_categorys];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Success!"
                                message: @"Your profile has been updated."
                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alert.tag = 1000;
    [alert show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1000) {
        [delegate closeForUpdate];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}


-(IBAction)next:(id)sender{

    if ([tfStartDate isFirstResponder]) {
        [tfStartDate resignFirstResponder];
    }
    if ([tfEndDate isFirstResponder]) {
        [tfEndDate resignFirstResponder];
    }
    if ([tfTimezone isFirstResponder]) {
        [tfTimezone resignFirstResponder];
    }

}
-(IBAction)changeRadius:(UISlider *)sender
{
    int value = sender.value;
    
    int nRadius = 1;
    switch (value) {
        case 0:
            nRadius = MILE_1;  break;
        case 1:
            nRadius = MILE_2;  break;
        case 2:
            nRadius = MILE_5;  break;
        case 3:
            nRadius = MILE_10;  break;
        case 4:
            nRadius = MILE_50;  break;
        case 5:
            nRadius = MILE_100;  break;
        case 6:
            nRadius = MILE_200;  break;
        case 7:
            nRadius = MILE_500;  break;
    }
    lbRadius.text = [NSString stringWithFormat:@"%d", nRadius];    
}

/////////////// 

-(IBAction)onDone:(id)sender{
    [self hideDatePicker];
}

-(IBAction)dateChange:(id)sender{
    NSDate * getDate = pickerDate.date;
    
    if (m_nDateType == 1) {
        tfStartDate.text = [Utils getDateString: getDate : DATE_FULL];
    } else {
        tfEndDate.text = [Utils getDateString: getDate : DATE_FULL];
    }

//    [Setting setStartDate:tfStartDate.text];
//    [Setting setEndDate:tfEndDate.text];
}

#pragma mark ----------
int m_nDateType = 0;

- (void)showDatePicker
{
    
    if (pickerDateVisible) {
        return;
    }
    
    
    for (UITextField *textField in self.view.subviews) {
        if ([textField isKindOfClass:[UITextField class]]) {
            [textField resignFirstResponder];
        }
    }

	
    if (iPad) {
        UIViewController* popContent = [[UIViewController alloc] init];
        popContent.view.frame = CGRectMake(0, 0, pickerDate.frame.size.width, pickerDate.frame.size.height);
        
        [popContent.view addSubview: pickerDate];
        popContent.contentSizeForViewInPopover = CGSizeMake(pickerDate.frame.size.width, pickerDate.frame.size.height);
        
        popoverController = [[UIPopoverController alloc] initWithContentViewController: popContent];
        
        if (m_nDateType == 1) {
            [popoverController presentPopoverFromRect:tfStartDate.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        } else {
            [popoverController presentPopoverFromRect:tfEndDate.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        return;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.4f];
    
    viewDateFrame.frame = CGRectMake(0, self.view.frame.size.height-260, 320, 260);
    
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
    
    viewDateFrame.frame = CGRectMake(0, self.view.frame.size.height, 320, 260);
    [UIView commitAnimations];
    
    pickerDateVisible = NO;
}


- (void)showTimezonePicker :(UITextField *) _textField
{
    
    if (pickerTimeZoneVisible) {
        return;
    }
    
    for (UITextField *textField in self.view.subviews) {
        if ([textField isKindOfClass:[UITextField class]]) {
            [textField resignFirstResponder];
        }
    }
	
    
    
    NSArray * views = [[NSBundle mainBundle] loadNibNamed:@"UITimezoneView" owner:self options:nil];
    
    timezonePicker = (UITimezoneView*) [views objectAtIndex:0];
    timezonePicker.textField = _textField;
    [timezonePicker setTimezonePicker];
    
    timezonePicker.delegate = self;
    
    if (iPad) {
        UIViewController* popContent = [[UIViewController alloc] init];
        popContent.view.frame = CGRectMake(0, 0, timezonePicker.frame.size.width, timezonePicker.frame.size.height);
        
        [popContent.view addSubview: timezonePicker];
        popContent.contentSizeForViewInPopover = CGSizeMake(timezonePicker.frame.size.width, timezonePicker.frame.size.height);
        
        popoverController = [[UIPopoverController alloc] initWithContentViewController: popContent];
        
        [popoverController presentPopoverFromRect:tfTimezone.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
        return;
    } 

    timezonePicker.frame = CGRectMake(0, 480, timezonePicker.frame.size.width, timezonePicker.frame.size.height);
    [self.view addSubview:timezonePicker];
    
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.4f];
    
    timezonePicker.frame = CGRectMake(0, 200, timezonePicker.frame.size.width, timezonePicker.frame.size.height);
    
    [UIView commitAnimations];
    
    
    pickerTimeZoneVisible = YES;
}

- (void)hideTimezonePicker
{
    if (!pickerTimeZoneVisible || timezonePicker == nil) {
        return;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.4f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(hiddenTimezoneView)];
    
    if (iPad) {
        timezonePicker.frame = CGRectMake(0, 1024, 768, 260);
    } else {
        timezonePicker.frame = CGRectMake(0, 480, 320, 260);
    }
    [UIView commitAnimations];
    
}

- (void) hiddenTimezoneView{
    pickerTimeZoneVisible = NO;
    [timezonePicker onDone:nil];
    
}
- (void) closeTimezoneView{
    pickerTimeZoneVisible = NO;
}


#pragma mark -------- Text delegate ---------
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    BOOL shouldEdit = YES;
	
	if ([textField isEqual:tfStartDate] || [textField isEqual:tfEndDate]) {
        
        if ([textField isEqual:tfStartDate]) {
            m_nDateType = 1;
        } else {
            m_nDateType = 2;
        }
        
        [textField resignFirstResponder];
        
        
        pickerDate.date = [Utils dateFromString: textField.text : DATE_FULL];
        
		shouldEdit = NO;
		[self showDatePicker];
        [self hideTimezonePicker];
        
    } else if ([textField isEqual:tfTimezone]){
        [textField resignFirstResponder];

        [self hideDatePicker];
        [self showTimezonePicker:textField];
        
        shouldEdit = NO;
	} else {
        [self hideDatePicker];
        [self hideTimezonePicker];
    }
    
	return shouldEdit;
}






-(IBAction)onTappedRadius:(UISegmentedControl*)sender{

}
-(IBAction)onTappedPins:(UISegmentedControl*)sender{
    
}

-(IBAction)onTappedView:(UISegmentedControl*)sender{
    
        
}


#pragma mark ---- Categories table --------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.categoryList count] + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MenuCell";
    
    MenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil) {
        //        [[NSBundle mainBundle] loadNibNamed:@"MenuCell" owner:self options:nil];
        //        cell = creatingCell;
        //        creatingCell = nil;
        
        UIViewController    *viewController = [[UIViewController alloc] initWithNibName:@"MenuCell" bundle:nil];
        cell =(MenuCell*) viewController.view;
    }
    
    
    
    cell.titleLbl.textColor = [UIColor blackColor];
    
    
    // Configure the cell...
    if (indexPath.row < [self.categoryList count])
    {
        NSDictionary *categoryItem = [self.categoryList objectAtIndex:indexPath.row];
        
        cell.titleLbl.text = [categoryItem objectForKey:@"name"];
        if (iPad) {
            cell.titleLbl.font = [UIFont systemFontOfSize:20];
        }
        
        
        UIImage *pinImg = [Share getCategoryImageName:[categoryItem objectForKey:@"name"]];; //[categoryItem objectForKey:@"iconData"];
        
        if ([pinImg isKindOfClass:[UIImage class]]) {
            cell.iconImg.image = pinImg;
        } else {
            cell.iconImg.image = nil;
        }
        BOOL isSelected = [[categoryItem objectForKey:@"selected"] boolValue];
        
        if (iPad) {
            if (isSelected) {
                cell.selectedImg.image = [UIImage imageNamed:@"selected@2x.png"];
            } else {
                cell.selectedImg.image = [UIImage imageNamed:@"unselected@2x.png"];
            }
        } else {
            if (isSelected) {
                cell.selectedImg.image = [UIImage imageNamed:@"selected.png"];
            } else {
                cell.selectedImg.image = [UIImage imageNamed:@"unselected.png"];
            }
        }
        cell.selectedImg.hidden = NO;
    } else {
        if (indexPath.row == [self.categoryList count]) { // Select all
            cell.titleLbl.text = @"Select All";
        } else {
            cell.titleLbl.text = @"Remove All";
        }
        cell.iconImg.image = nil;
        cell.selectedImg.hidden = YES;
    }
    
    return cell;
}

#pragma ---- UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self.categoryList count]) {
        NSMutableDictionary *categoryItem = [self.categoryList objectAtIndex:indexPath.row];
        BOOL isSelected = [[categoryItem objectForKey:@"selected"] boolValue];
        [categoryItem setObject:[NSNumber numberWithBool:(!isSelected)] forKey:@"selected"];
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        if (indexPath.row == [self.categoryList count]) {
            for (NSMutableDictionary *categoryItem in self.categoryList) {
                [categoryItem setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
            }
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        } else if (indexPath.row == [self.categoryList count] + 1) {
            for (NSMutableDictionary *categoryItem in self.categoryList) {
                [categoryItem setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
            }
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        } 
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
