//
//  SearchViewController.h
//  Pin Ave
//
//  Created by Gold-iron on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "JsonReader.h"
#import "AdvancedSearchView.h"
#import "SubCategoryList.h"
#import "PinDetailController.h"

@interface SearchViewController : UIViewController <JsonReaderDelegate, AdvancedSearchDelegate, SubCategoryListDelegate, PinDetailControllerDelegate, UIGestureRecognizerDelegate, MKMapViewDelegate>
{
    
// top bar    
    
    IBOutlet UIView   * m_viewTopBar;
    IBOutlet UIView *  m_viewBtn;
    IBOutlet UIButton   * m_btnMap;
    IBOutlet UIButton   * m_btnList;
    IBOutlet UIView     * viewLogo;
    BOOL    m_bList;

    IBOutlet UIView  * m_viewMain;
    
    IBOutlet UIView  * m_viewSubSearchBar;
    IBOutlet UIView  * m_viewSubDark;
    IBOutlet UISearchBar *searchFld;
    
    
    
    IBOutlet UIView *  m_viewMap;
    IBOutlet MKMapView *m_mapView;
    IBOutlet UIView *  viewUserLocation;
    IBOutlet UILabel * lbUserLocation;

    IBOutlet UIView *  m_viewList;
    IBOutlet UITableView * tvListCategory;
    IBOutlet UILabel    * lbLocation;
    
    ////////////////
    
    BOOL m_bIsMyLocation;
    
    
    BOOL isShowMe;
    
    NSString * str_Search_country;
    NSString * str_Search_city;

    
    BOOL    m_bAdvanced;
    AdvancedSearchView * viewSubOption;

    BOOL    m_bShowSearchBar;
    
    
    // Top bar Gesture
    SubCategoryList * m_viewSubCategoryList;
 
    
    int m_nSearchTime;
    
    int     currPage;
    BOOL    isLoading;
    NSMutableArray * m_arrPinsAroundUser;
    
    MKCoordinateRegion m_prevRegion; // map scroll
    
    BOOL m_bGoDetail;
}


+ (SearchViewController*) getInstance;

@property(nonatomic, assign) NSString *m_userLocation;
@property(nonatomic, assign) BOOL m_bUpdated;
@property(nonatomic, assign) int  m_nSearchMode;
@property(nonatomic, assign) int  m_nPinSize;
@property(nonatomic, strong) NSMutableArray * arrSelectedCategory;

-(id) initWithValue:(NSMutableArray*) _selAry pinSize:(int) _pinSize userlocation:(NSString*) _locatioin update:(BOOL) _bUpdate searchMode:(int) nSearch;
-(id) initWithMap:(NSMutableArray*) _selAry pinSize:(int) _pinSize userlocation:(NSString*) _locatioin update:(BOOL) _bUpdate searchMode:(int) nSearch;


#pragma mark -------- Search ------

-(void) refreshMap;

- (void) addUserLocation;

- (void) searchPins :(NSString*) _search;
- (void) showPinsForSearch:(id) result;


- (IBAction)onBack:(id)sender;
- (IBAction)onToggle:(id)sender;
- (IBAction)onClickUserLocation:(id)sender;
- (IBAction)onShowSearchBar:(id)sender;
- (IBAction)onSearchOption:(id)sender;


- (NSMutableDictionary*) changePinInfo : (CLLocationDegrees) latitude : (CLLocationDegrees) longitude;

    
@end
