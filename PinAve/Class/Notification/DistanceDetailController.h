//
//  DistanceDetailController.h
//  NEP
//
//  Created by Gold Luo on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DistanceDetailController;
@protocol DistanceDetailDelegate

- (void) setDistance:(int) _distance;

@end

@interface DistanceDetailController : UIViewController
{
    IBOutlet UISegmentedControl * segDistance;
}



-(IBAction)onClickSegment:(UISegmentedControl*) sender;

@end
