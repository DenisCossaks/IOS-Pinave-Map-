//
//  NotificationsController.m
//  NEP
//
//  Created by Dandong3 Sam on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NotificationsController.h"
#import "Utils.h"
#import "Notification.h"

#import "DistanceDetailController.h"
#import "DateDetailController.h"
#import "WithCategoryController.h"
#import "EveryDayController.h"


@interface NotificationsController ()

@property (strong, nonatomic) NSArray *sectionAry;

@end


static NSString *kSectionName   = @"sectionNameKey";
static NSString *kRowData       = @"rowDataKey";

@implementation NotificationsController

@synthesize sectionAry;
@synthesize listCategory;


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

    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"Notifications";
//    UIViewController *homeCtlr = [self.navigationController.viewControllers objectAtIndex:0];
//    self.navigationItem.leftBarButtonItem = homeCtlr.navigationItem.leftBarButtonItem;
    
    
    
    NSMutableArray *sections = [NSMutableArray array];
    
    [sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Distance", kSectionName, [NSArray arrayWithObjects:@"", nil], kRowData, nil]];
    
    [sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Date / time", kSectionName, [NSArray arrayWithObjects:@"", nil], kRowData, nil]];
    [sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Notify me for", kSectionName, [NSArray arrayWithObjects:@"", nil], kRowData, nil]];
    [sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Scan every", kSectionName, [NSArray arrayWithObjects:@"", nil], kRowData, nil]];
    
    self.sectionAry = [NSArray arrayWithArray:sections];


    if (!iPad) {
        scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(30, 50, 260, 50)];
    } else {
        scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(70, 70, 680, 80)];
    }
    
    
    labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 260, 40)];
    labelTitle.backgroundColor = [UIColor clearColor];
    labelTitle.textColor = [UIColor blackColor];
    labelTitle.font = [UIFont boldSystemFontOfSize:20];
    if (iPad) {
        labelTitle.frame = CGRectMake(60, 5, 680, 60);
        labelTitle.font = [UIFont boldSystemFontOfSize:40];
    }

    labelContent = [[UILabel alloc] initWithFrame:CGRectMake(30, 40, 280, 20)];
    labelContent.backgroundColor = [UIColor clearColor];
    labelContent.textColor = [UIColor blackColor];
    labelContent.font = [UIFont systemFontOfSize:15];
    if (iPad) {
        labelContent.frame = CGRectMake(80, 60, 680, 30);
        labelContent.font = [UIFont systemFontOfSize:30];
    }

}

- (UILabel*) getTitleLab
{
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 260, 40)];
    lab.backgroundColor = [UIColor clearColor];
    lab.textColor = [UIColor blackColor];
    lab.font = [UIFont boldSystemFontOfSize:20];
    if (iPad) {
        lab.frame = CGRectMake(60, 5, 680, 60);
        lab.font = [UIFont boldSystemFontOfSize:40];
    }
    
    return lab;
}

- (UILabel*) getContentLab
{
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(30, 40, 280, 20)];
    lab.backgroundColor = [UIColor clearColor];
    lab.textColor = [UIColor blackColor];
    lab.font = [UIFont systemFontOfSize:15];
    if (iPad) {
        lab.frame = CGRectMake(80, 60, 680, 30);
        lab.font = [UIFont systemFontOfSize:30];
    }    
    
    return lab;
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

- (void)viewWillAppear:(BOOL)animated{
    
    arrSelectedCategory = [[NSMutableArray alloc] initWithCapacity:10];
    arrSelectedCategory = [Notification getCategory];
    
    for (UIView *view in scroll.subviews)
    {
        [view removeFromSuperview];
    }
    [scroll removeFromSuperview];
    
    [table reloadData];
    
}

#pragma ---- UITableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sectionAry count];
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[self.sectionAry objectAtIndex:section] objectForKey:kSectionName];
}*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows = [[[self.sectionAry objectAtIndex:section] objectForKey:kRowData] count];
    
    return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0  || indexPath.section == 1 || indexPath.section == 3) {
        if (iPad) {
            return 100.0f;
        } else {
            return 60.0f;
        }
    }
    else if (indexPath.section == 2) {
        if (iPad) {
            return 150.0f;
        } else {
            return 100.0f;
        }
    }
    
    return 44.0f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NotiCell";
    UILabel *contentLab = nil;
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        //// For Title
        
        UILabel *titleLab = [self getTitleLab];
        [cell.contentView addSubview:titleLab];
        titleLab.text = [[self.sectionAry objectAtIndex:indexPath.section] objectForKey:kSectionName];
        
        //// For Distance

        if(indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 3)
        {
            contentLab = [self getContentLab];
            [cell.contentView addSubview:contentLab];
            
            contentLab.tag = 4000 + indexPath.section;
        }
    
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (iPad && indexPath.section != 2) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    

    if (indexPath.section == 2 && indexPath.row == 0) {
        int x = 0, y = 0;
        int width = 50, height = 50;
        int count = 0, offset = 10;
        
        if (iPad) {
            width = 80, height = 80; offset = 25;
        }
        for (NSMutableDictionary * pinInfo in arrSelectedCategory ) {
           
            int pos = x + (width+offset) * count ;
            
            BOOL isSelected = [[pinInfo objectForKey:@"selected"] boolValue];
            if (isSelected) {
                
                count ++ ;
                
                NSString * name = [pinInfo objectForKey:@"category_id"];
            
                UIImage *pinImg;
                
                
                for (NSMutableDictionary * category in listCategory ) {
                    NSString * category_name = [category objectForKey:@"category_id"];
                    
                    if ([category_name isEqualToString:name]) {
                        pinImg = [Share getCategoryImageName:[category objectForKey:@"name"]]; //[category objectForKey:@"iconData"];
                        
                        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(pos, y, width, height)];
//                        imageView.backgroundColor = [UIColor redColor];
                        imageView.image = pinImg;
                        
                        [scroll addSubview:imageView];

                        
                        break;
                    }
                    
                }
                
            }

        }
        
        [scroll setContentSize:CGSizeMake(x + (width + offset) * count, height)];
        
        [cell addSubview:scroll];
    }
    else 
    {
       
        if(contentLab == nil)
        {
            contentLab = (UILabel*)[cell.contentView viewWithTag:4000 + indexPath.section];
        }

        if (indexPath.section == 0 && indexPath.row == 0) {
            contentLab.text = [NSString stringWithFormat:@"%d Mile", [Notification getDistance]];
        }
        if (indexPath.section == 1 && indexPath.row == 0) {
            contentLab.text = [Notification getDate];
        }
        if (indexPath.section == 3 && indexPath.row == 0) {
            contentLab.text = [NSString stringWithFormat:@"%d Minute", [Notification getMinute]];
        }
//        
//        [cell addSubview:labelContent];
    }
    
    
    return cell;
}

#pragma ---- UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch ([indexPath section]) {
        case 0:
            switch ([indexPath row]) {
                case 0:{
                    if (!iPad) {
                        DistanceDetailController * vc = [[DistanceDetailController alloc] init];
                        [self.navigationController pushViewController:vc animated:YES];
                    } else {
                        
                        UIViewController* popContent = [[UIViewController alloc] init];
                        popContent.view.frame = CGRectMake(0, 0, scDistance.frame.size.width, scDistance.frame.size.height);
                        
                        [popContent.view addSubview: scDistance];
                        popContent.contentSizeForViewInPopover = CGSizeMake(scDistance.frame.size.width, scDistance.frame.size.height);
                        
                        popoverController = [[UIPopoverController alloc] initWithContentViewController: popContent];
                        
                        [popoverController presentPopoverFromRect:CGRectMake(45, 33, 675, 95) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

                    }
                    break;
                }
            }
            break;
            
        case 1:
            switch ([indexPath row]) {
                case 0:{

                    if (!iPad) {
                        DateDetailController * vc = [[DateDetailController alloc] init];
                        [self.navigationController pushViewController:vc animated:YES];
                    } else {
                        UIViewController* popContent = [[UIViewController alloc] init];
                        popContent.view.frame = CGRectMake(0, 0, datePicker.frame.size.width, datePicker.frame.size.height);
                        
                        [popContent.view addSubview: datePicker];
                        popContent.contentSizeForViewInPopover = CGSizeMake(datePicker.frame.size.width, datePicker.frame.size.height);
                        
                        popoverController = [[UIPopoverController alloc] initWithContentViewController: popContent];
                        
                        [popoverController presentPopoverFromRect:CGRectMake(45, 153, 675, 95) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

                    }
                    
                    break;
                }
            }
            break;
            
        case 2:
            switch ([indexPath row]) {
                case 0:{
                    WithCategoryController * vc;
                    if (iPad) {
                        vc = [[WithCategoryController alloc] initWithNibName:@"WithCategoryController-ipad" bundle:nil];
                    } else {
                        vc = [[WithCategoryController alloc] initWithNibName:@"WithCategoryController" bundle:nil];
                    }
                    [self.navigationController pushViewController:vc animated:YES];

                    break;
                }
            }
            break;

        case 3:
            switch ([indexPath row]) {
                case 0:{
                    if (!iPad) {
                        EveryDayController * vc = [[EveryDayController alloc] init];
                        [self.navigationController pushViewController:vc animated:YES];
                    }
                    else {
                        UIViewController* popContent = [[UIViewController alloc] init];
                        popContent.view.frame = CGRectMake(0, 0, scMinute.frame.size.width, scMinute.frame.size.height);
                        
                        [popContent.view addSubview: scMinute];
                        popContent.contentSizeForViewInPopover = CGSizeMake(scMinute.frame.size.width, scMinute.frame.size.height);
                        
                        popoverController = [[UIPopoverController alloc] initWithContentViewController: popContent];
                        
                        [popoverController presentPopoverFromRect:CGRectMake(45, 447, 675, 95) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

                    }
                    break;
                }
            }
            break;
            
    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark ----------- IPad --------------
- (IBAction) changeDistance : (UISegmentedControl*) sender {
    int selected = sender.selectedSegmentIndex;
    
    if (selected == 0) {
        [Notification setDistance:1];
    } else if (selected == 1) {
        [Notification setDistance:2];
    } else if (selected == 2) {
        [Notification setDistance:5];
    } else if (selected == 3) {
        [Notification setDistance:10];
    }
    
    [table reloadData];
}
- (IBAction) changeDate: (UIDatePicker* ) sender{
    NSDate * curDate = sender.date;
    
    [Notification setDate:[Utils getDateString:curDate :DATE_FULL]];
    
    [table reloadData];
}
- (IBAction) changeMinute:(UISegmentedControl*) sender{
    int selected = sender.selectedSegmentIndex;

    if (selected == 0) {
        [Notification setMinute:1];
    } else if (selected == 1) {
        [Notification setMinute:3];
    } else if (selected == 2) {
        [Notification setMinute:5];
    } else if (selected == 3) {
        [Notification setMinute:10];
    } else if (selected == 4) {
        [Notification setMinute:15];
    } else if (selected == 5) {
        [Notification setMinute:30];
    } else if (selected == 6) {
        [Notification setMinute:60];
    }
    
    [table reloadData];

}


@end
