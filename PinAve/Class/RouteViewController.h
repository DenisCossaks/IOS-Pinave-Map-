//
//  RouteViewController.h
//  PinAve
//
//  Created by Gold Luo on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "GoogleDirectionsParser.h"
#import "PinDetailController.h"
#import "RequestsBase.h"

enum ROUTE_MODE {
    DRIVING = 0,
    BICYCLING,
    WALKING,
    };


@interface RouteViewController : UIViewController<DirectionsParserDelegate, UIGestureRecognizerDelegate, PinDetailControllerDelegate, RequestProtocol>
{
    IBOutlet UIView     * viewEdit;
    IBOutlet UITextField* directStartFld;
    IBOutlet UITextField* directEndFld;
    
    IBOutlet UIButton   * btnEdit;
    IBOutlet MKMapView *  m_mapView;
    
    IBOutlet UIButton   * btnModeDrive;
    IBOutlet UIButton   * btnModeBicycle;
    IBOutlet UIButton   * btnModeWalk;
    
    IBOutlet UILabel    * lbUserLocation;
    IBOutlet UILabel    * lbDistance;
    
    MKPolyline *m_routeLine;
    MKPolylineView *m_routeLineView;
    
    BOOL     m_bShowEdit;
    int      m_nModeRoute;
    
    NSMutableDictionary * pinStart;
    NSMutableDictionary * pinEnd;
   
    BOOL m_bIsMyLocation;
    
    BOOL m_bRefresh;
    
    int     m_nLoadingCount;
    BOOL    m_bIsFirst;
}

@property (nonatomic, strong) RequestsBase* request;


+ (RouteViewController*) getInstance;

- (IBAction)onClickUserLocation:(id)sender;


- (IBAction)next:(id)sender;

- (IBAction)onClickEdit:(id)sender;
- (IBAction)onclickRoute:(id)sender;
- (IBAction)onChangeText:(id)sender;

- (IBAction)onClickModeDrive:(id)sender;
- (IBAction)onClickModeBicycle:(id)sender;
- (IBAction)onClickModeWalk:(id)sender;


- (void) onDirectionToHere :(UIButton*) sender;
//-(void) DirectFromHere : (NSMutableDictionary*) _info;
//-(void) DirectToHere : (NSMutableDictionary * ) _info;

@end
