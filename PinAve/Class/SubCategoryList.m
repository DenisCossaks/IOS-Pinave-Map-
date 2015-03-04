//
//  SubCategoryList.m
//  PinAve
//
//  Created by Gold Luo on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SubCategoryList.h"
#import "MenuCell.h"
#import "FilterSearch.h"


@implementation SubCategoryList

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void) setInterface 
{

    arraySeleted = [[NSMutableArray alloc] initWithCapacity:10];
    
    arraySeleted = [FilterSearch getCategory];
    
    [m_tableView reloadData];

}

- (IBAction) onClose:(id)sender
{
    [FilterSearch setCategory:arraySeleted];

    [delegate selectCategory];
    
//    [self removeFromSuperview];
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
    
    
    cell.titleLbl.textColor = [UIColor blackColor];
    
    
    // Configure the cell...
    if (indexPath.row < [[Share getInstance].arrayCategory count]) {
        NSDictionary *categoryItem = [[Share getInstance].arrayCategory objectAtIndex:indexPath.row];
        
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
        NSMutableDictionary *categoryItem = [arraySeleted objectAtIndex:indexPath.row];
        BOOL isSelected = [[categoryItem objectForKey:@"selected"] boolValue];
        [categoryItem setObject:[NSNumber numberWithBool:(!isSelected)] forKey:@"selected"];
    } else {
        if (indexPath.row == [[Share getInstance].arrayCategory count]) {
            for (NSMutableDictionary *item in arraySeleted) {
                [item setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
            }
        } else if (indexPath.row == [[Share getInstance].arrayCategory count] + 1) {
            for (NSMutableDictionary *item in arraySeleted) {
                [item setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
            }
        }
    }

    [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

