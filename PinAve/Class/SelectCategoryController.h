//
//  SelectCategoryController.h
//  NEP
//
//  Created by Gold Luo on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SelectCategoryController;

@protocol SelectCategoryDelegate

- (void) setCategoryID:(int) _selectId;

@end


@interface SelectCategoryController : UIViewController
{
    IBOutlet UITableView * tvCategories;
    
}

@property (strong, nonatomic) NSArray *categoryList;
@property (strong, nonatomic) id<SelectCategoryDelegate> delegate;
@property (nonatomic, assign)     int nCategoryId;


- (IBAction)onBack:(id)sender;

@end
