//
//  PinAnnotation.h
//  NEP
//
//  Created by Dandong3 Sam on 4/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface PinAnnotation : MKPointAnnotation
{
	CLLocationCoordinate2D coordinate_;
	NSString *title_;
	NSString *subtitle_;
    
    NSMutableDictionary *_pinInfo;
}

// Re-declare MKAnnotation's readonly property 'coordinate' to readwrite. 
@property (nonatomic, readwrite, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;

@property (nonatomic, retain) NSMutableDictionary *pinInfo;
@property (nonatomic, assign) int   pinIndex;


- (id)initWithPinInfo:(NSMutableDictionary *)pinDic;

@end
