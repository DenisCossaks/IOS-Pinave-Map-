//
//  WithCategoryController.h
//  NEP
//
//  Created by Gold Luo on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class WithCategoryController;
@protocol WithCategoryDelegate

- (void) setCategories : (NSMutableArray *) array;

@end


@interface WithCategoryController : UIViewController
{
    IBOutlet UILabel     * lbTitle;
    IBOutlet UITableView * table;
    
    NSMutableArray * arraySeleted;

}

@property (nonatomic, strong) NSArray * categoryList;
@property (nonatomic, strong) id<WithCategoryDelegate> delegate;
@property (nonatomic, assign) int m_nMode; 



- (IBAction) onBack:(id)sender;

@end
