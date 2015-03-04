//
//  SelectCategoryController.m
//  NEP
//
//  Created by Gold Luo on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SelectCategoryController.h"

@interface SelectCategoryController ()

@end

@implementation SelectCategoryController

@synthesize categoryList;
@synthesize delegate;
@synthesize nCategoryId;

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
    
    
    NSMutableArray * arrRemoveSystem = [[NSMutableArray alloc] initWithCapacity:10];
    for (NSMutableDictionary * dic in [Share getInstance].arrayCategory) {
        if ([[dic objectForKey:@"id"] intValue] != 999) {
            [arrRemoveSystem addObject:dic];
        }
    }
    
//    self.categoryList = [Share getInstance].arrayCategory;
    self.categoryList = [[NSMutableArray alloc] initWithArray:arrRemoveSystem];
    
    NSLog(@"categoryList = %@", self.categoryList);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}
- (void) viewWillDisappear:(BOOL)animated 
{
    [delegate setCategoryID:nCategoryId];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}


- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.categoryList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CategoryCell";
    
    UIImageView * imgView;
    UILabel * label;
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        if (iPad) {
            imgView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 3, 54, 54)];
        } else {
            imgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 3, 44, 44)];
        }
        imgView.tag = 123;
        [cell addSubview:imgView];
        
        if (iPad) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 768-100, cell.frame.size.height)];
        } else {
            label = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 320-80, cell.frame.size.height)];
        }
        label.backgroundColor = [UIColor clearColor];
        label.tag = 124;
        [cell addSubview:label];

        
    }
    
    NSDictionary *categoryItem = [self.categoryList objectAtIndex:indexPath.row];
    
//    NSLog(@"categoryItem = %@", categoryItem);
    
    NSString*pinName   = [categoryItem objectForKey:@"name"];
    UIImage *pinImg = [Share getCategoryImageName:[categoryItem objectForKey:@"name"]]; //[categoryItem objectForKey:@"iconData"];
    
    int pinId = [[categoryItem objectForKey:@"id"] intValue];
    
    if (nCategoryId == pinId) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    
    if (imgView == nil) {
        imgView = (UIImageView*) [cell viewWithTag:123];
    }
    [imgView setImage:pinImg];


    if (label == nil) {
        label = (UILabel*) [cell viewWithTag:124];
    }
    label.text = pinName;
                       
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    nCategoryId = [[[self.categoryList objectAtIndex:indexPath.row] objectForKey:@"id"] intValue];
    
//    nCategoryId = indexPath.row;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    [tableView reloadData];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
