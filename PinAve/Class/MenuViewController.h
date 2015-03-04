//
//  MenuViewController.h
//  NEP
//
//  Created by Gold Luo on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
@interface MenuCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *iconImg;
@property (strong, nonatomic) IBOutlet UILabel *titleLbl;
@property (strong, nonatomic) IBOutlet UIImageView *selectedImg;

@end
*/


@interface MenuViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *menuTbl;
//@property (strong, nonatomic) IBOutlet MenuCell *creatingCell;

@property (strong, nonatomic) NSArray * categoryAry;


-(IBAction)onBack:(id)sender;


@end
