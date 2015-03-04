//
//  WithCategoryController.m
//  NEP
//
//  Created by Gold Luo on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WithCategoryController.h"
#import "Notification.h"
#import "FilterSearch.h"

#import "MenuCell.h"
#import "AppDelegate.h"


@interface WithCategoryController ()

@end




@implementation WithCategoryController

@synthesize delegate;
@synthesize categoryList;
@synthesize m_nMode;


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
    
//    UIBarButtonItem * itemUpdate = [[UIBarButtonItem alloc]initWithTitle:@"Update" style:UIBarButtonItemStylePlain target:self action:@selector(onUpdate)];
//    self.navigationItem.rightBarButtonItem=itemUpdate;

    
    self.categoryList = [Share getInstance].arrayCategory;
    
    
    arraySeleted = [[NSMutableArray alloc] initWithCapacity:10];
    
    if (m_nMode == MODE_SEARCH) {
        lbTitle.text = @"Search Categories";
        arraySeleted = [FilterSearch getCategory];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        BOOL bFirst = [[defaults objectForKey:@"Search_default"] boolValue];
        if (bFirst == NO) { // default
            [defaults setBool:YES forKey:@"Search_default"];
            [defaults synchronize];
            
            for (NSMutableDictionary *item in arraySeleted) {
                [item setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
            }
        }

    } else {
        arraySeleted = [Notification getCategory];
        lbTitle.text = @"Notification Categories";        
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        BOOL bFirst = [[defaults objectForKey:@"Notification_default"] boolValue];
        if (bFirst == NO) { // default
            [defaults setBool:YES forKey:@"Notification_default"];
            [defaults synchronize];
            
            for (NSMutableDictionary *item in arraySeleted) {
                [item setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
            }
        }

        
    }

//    NSLog(@"self.categoryList = %@", self.categoryList);
//    NSLog(@"arraySeleted = %@", arraySeleted);
    
    [table reloadData];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setTabBarHidden:YES animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}


- (IBAction) onBack:(id)sender
{
    if (![self isSelectedAnyNoti]) {
        if (m_nMode == MODE_SEARCH) {
            [[[UIAlertView alloc] initWithTitle:@"" message:@"Please select one or more categories for your search." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            return;
        } else {
            [[[UIAlertView alloc] initWithTitle:@"" message:@"Please select pin categories for notifications." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            return;
        }
    }

    if (m_nMode == MODE_SEARCH) {
        [FilterSearch setCategory:arraySeleted];
    } else {
        [Notification setCategory:arraySeleted];
    }
    

    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL) isSelectedAnyNoti {
    for (NSMutableDictionary * itemCategory in arraySeleted) {
        BOOL isSelected = [[itemCategory objectForKey:@"selected"] boolValue];
        if (isSelected == YES) {
            return YES;
        }
    }
    return NO;
}


#pragma mark table view delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arraySeleted count] + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MenuCell";
    
    MenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    
    if (cell == nil) {
        UIViewController    *viewController = [[UIViewController alloc] initWithNibName:@"MenuCell" bundle:nil];
        cell =(MenuCell*) viewController.view;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.titleLbl.textColor = [UIColor blackColor];
    
    
    // Configure the cell...
    if (indexPath.row < [categoryList count]) {
        NSDictionary *categoryItem = [categoryList objectAtIndex:indexPath.row];
        
        NSString * name = [categoryItem objectForKey:@"name"];
        NSString * category_id = [categoryItem objectForKey:@"id"];
        
        cell.titleLbl.text = name;
        UIImage *pinImg = [Share getCategoryImageName:[categoryItem objectForKey:@"name"]]; //[categoryItem objectForKey:@"iconData"];
        
        if ([pinImg isKindOfClass:[UIImage class]]) {
            cell.iconImg.image = pinImg;
        } else {
            cell.iconImg.image = nil;
        }
        
        
        for (NSMutableDictionary* dic in arraySeleted) {
            NSString * _name = [dic objectForKey:@"id"];
            
            if ([category_id isEqualToString:_name]) {
                BOOL isSelected = [[dic objectForKey:@"selected"] boolValue];
                if (isSelected) {
                    cell.selectedImg.image = [UIImage imageNamed:@"selected.png"];
                } else {
                    cell.selectedImg.image = [UIImage imageNamed:@"unselected.png"];
                }
                cell.selectedImg.hidden = NO;
                break;
            }
        }
        
        cell.iconImg.hidden = NO;

    } else {
        if (indexPath.row == [[Share getInstance].arrayCategory count]) {
            cell.titleLbl.text = @"Select ALL";
        } else if (indexPath.row == [[Share getInstance].arrayCategory count] + 1) {
            cell.titleLbl.text = @"Remove ALL";
        }
        cell.selectedImg.hidden = YES;
        //        cell.iconImg = nil;
        cell.iconImg.hidden = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [arraySeleted count]) {
        
        
        NSMutableDictionary *dic = [categoryList objectAtIndex:indexPath.row];
        int  selectedId = [[dic objectForKey:@"id"] intValue];
        
        for (NSMutableDictionary* categoryItem in arraySeleted) {
            if ([[categoryItem objectForKey:@"id"] intValue] == selectedId) {
                BOOL isSelected = [[categoryItem objectForKey:@"selected"] boolValue];
                [categoryItem setObject:[NSNumber numberWithBool:(!isSelected)] forKey:@"selected"];
            }
        }
        
    } else {
        if (indexPath.row == [arraySeleted count]) {
            for (NSMutableDictionary *item in arraySeleted) {
                [item setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
            }
        } else if (indexPath.row == [arraySeleted count] + 1) {
            for (NSMutableDictionary *item in arraySeleted) {
                [item setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
            }
        }
    }

    [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
