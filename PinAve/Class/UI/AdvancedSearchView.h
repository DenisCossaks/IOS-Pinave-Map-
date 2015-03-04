//
//  AdvancedSearchView.h
//  PinAve
//
//  Created by Gold Luo on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AdvancedSearchView;
@protocol AdvancedSearchDelegate

- (void) setWithCategory;

@end

@interface AdvancedSearchView : UIView
{
    IBOutlet UISegmentedControl * scDate;
    IBOutlet UILabel            * lbRadius;
    IBOutlet UILabel            * lbUnit;
    IBOutlet UISlider           * pvRadius;
}

@property (nonatomic, strong) id<AdvancedSearchDelegate> delegate;

- (void) setInterface;

- (IBAction)onChangedDate:(UISegmentedControl*)sender;
- (IBAction)onChangedRadius:(UISlider*)sender;
- (IBAction)onClickCategory:(id)sender;

@end
