//
//  SubCategoryList.h
//  PinAve
//
//  Created by Gold Luo on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SubCategoryList;
@protocol SubCategoryListDelegate

- (void) selectCategory;

@end

@interface SubCategoryList : UIView
{
    IBOutlet UITableView * m_tableView;
    
    NSMutableArray * arraySeleted;
}


@property (nonatomic, strong) id<SubCategoryListDelegate> delegate;

- (void) setInterface;

- (IBAction) onClose:(id)sender;

@end
