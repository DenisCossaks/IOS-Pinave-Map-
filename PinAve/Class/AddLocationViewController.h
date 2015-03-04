//
//  AddLocationViewController.h
//  PinAve
//
//  Created by Gold Luo on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddLocationViewDelegate

- (void) changeLocation ;

@end

@interface AddLocationViewController : UIViewController
{
    IBOutlet UISearchBar *searchFld;
    IBOutlet UITableView * table;
    
    NSMutableArray * arrayLocations;
}

@property(nonatomic, strong) id<AddLocationViewDelegate> delegate;

@end
