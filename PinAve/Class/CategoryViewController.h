//
//  CategoryViewController.h
//  PinAve
//
//  Created by Gold Luo on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

#import "JsonReader.h"
#import "AdvancedSearchView.h"
#import "AddLocationViewController.h"


typedef enum _LOADING_TYPE {
    LOADING_NONE = 0,
    LOADING_FIRST,
    LOADING_COUNT,
}LOADING_TYPE;

@interface CategoryViewController : UIViewController<EGORefreshTableHeaderDelegate, AdvancedSearchDelegate, JsonReaderDelegate, AddLocationViewDelegate, UIGestureRecognizerDelegate>
{
    IBOutlet UILabel * lbLocation;
    
    IBOutlet UIView *  viewListSearch;
    IBOutlet UIView *  viewSubDark;
    IBOutlet UITableView * tvCategory;
    IBOutlet UISearchBar * searchFld;
    
    AdvancedSearchView * viewSubOption;
    BOOL    m_bAdvanced;
    
    NSMutableArray * arrPinCount;
    
    int     nJSON_STATE;
    
    LOADING_TYPE m_nLoadingType;
    
    BOOL    m_bLoadingDone;
    
    int m_nLoadingCount;
    
}

- (IBAction)onMenu:(id)sender;
- (IBAction)onLocation:(id)sender;
- (IBAction)onAdvancedSearch:(id)sender;


@end
