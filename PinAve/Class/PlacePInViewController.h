//
//  PlacePInViewController.h
//  PinAve
//
//  Created by Gold Luo on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>



@interface PlacePInViewController : UIViewController
{
    IBOutlet MKMapView *  m_mapView;
   
}

- (void)showDetails:(UIButton *)sender;


@end
