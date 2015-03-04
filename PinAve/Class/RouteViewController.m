//
//  RouteViewController.m
//  PinAve
//
//  Created by Gold Luo on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RouteViewController.h"
#import "AppDelegate.h"
#import "SBJsonParser.h"
#import "Setting.h"
#import "PinDetailController.h"
#import "RequestsBase.h"


#define FIRST_POINT @"Current Location"

#define kPinTitle @"title"
#define kPinLat   @"lat"  
#define kPinLng   @"lng"
#define kPinSet   @"Set"

@interface RouteViewController ()

- (void) addUserLocation;
- (void) setModeButton;
- (void) showPinsAroundRoute: (NSArray*) arrPoint;

@end

static RouteViewController *instance = nil;


@implementation RouteViewController

+ (RouteViewController*) getInstance {
    if (instance == nil) {
        instance = [[RouteViewController alloc] init];
    }
    
    return instance;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyDicFromHere:) name:NotiDicFromHere object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyDicToHere:) name:NotiDicToHere object:nil];

    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleMove:)];
	[panRecognizer setMinimumNumberOfTouches:1];
	[panRecognizer setMaximumNumberOfTouches:1];
    panRecognizer.delegate = self;
	[m_mapView addGestureRecognizer:panRecognizer];

    
    m_bShowEdit = YES;
    m_nModeRoute = DRIVING;
    
//    pinStart = [[NSMutableDictionary alloc] initWithCapacity:1];
//    [pinStart setObject:FIRST_POINT forKey:kPinTitle];
//    [pinStart setObject:[NSNumber numberWithFloat:[UserLocationManager sharedInstance].latestLocation.coordinate.latitude] forKey:kPinLat];
//    [pinStart setObject:[NSNumber numberWithFloat:[UserLocationManager sharedInstance].latestLocation.coordinate.longitude] forKey:kPinLng];
//    
//    pinEnd = [[NSMutableDictionary alloc] initWithCapacity:1];
//    [pinEnd setObject:FIRST_POINT forKey:kPinTitle];
//    [pinEnd setObject:[NSNumber numberWithFloat:0.0] forKey:kPinLat];
//    [pinEnd setObject:[NSNumber numberWithFloat:0.0] forKey:kPinLng];
    
    directStartFld.text = FIRST_POINT;
    directStartFld.textColor = [UIColor blueColor];
    directStartFld.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    
    directEndFld.textColor = [UIColor blackColor];
    directEndFld.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    [directEndFld becomeFirstResponder];
    
    [self clearDistance];
    
    m_bIsFirst = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setTabBarHidden:NO animated:YES];

    if (m_bIsFirst) {
        m_bShowEdit = FALSE;
        [self onClickEdit:nil];
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

-(void) viewDidAppear:(BOOL)animated
{

    [self setModeButton];
    
    // user location
    lbUserLocation.text = [[UserLocationManager sharedInstance] getStandardUserLocationAddress];
    
    switch ([Setting getMapMode]) {
        case 0:
            m_mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            m_mapView.mapType = MKMapTypeSatellite;
            break;
        case 2:
            m_mapView.mapType = MKMapTypeHybrid;
            break;
            
    }
    
    if (!m_bIsFirst) {
        return;
    }

    [self addUserLocation];
    
    
    if (pinStart != nil) {
        NSString * strFull = [pinStart objectForKey:@"full_address"];
        if (strFull == nil || strFull.length < 1) {
            strFull = [NSString stringWithFormat:@"%@ %@ %@", [pinStart objectForKey:@"address"], [pinStart objectForKey:@"city"], [pinStart objectForKey:@"country"]];
        }
        directStartFld.text = strFull;
        directStartFld.textColor = [UIColor blackColor];
    }
    if (pinEnd != nil) {
        NSString * strFull = [pinEnd objectForKey:@"full_address"];
        if (strFull == nil || strFull.length < 1) {
            strFull = [NSString stringWithFormat:@"%@ %@ %@", [pinEnd objectForKey:@"address"], [pinEnd objectForKey:@"city"], [pinEnd objectForKey:@"country"]];
        }
        directEndFld.text = strFull;
        directEndFld.textColor = [UIColor blackColor];
    }
    
    m_bIsMyLocation = YES;
    [self fitToPinsRegionGPS];
    
    m_bIsFirst = NO;
 
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

- (void) setModeButton 
{
    if (m_nModeRoute == DRIVING) {
        [btnModeDrive setSelected:YES];
        [btnModeBicycle setSelected:NO];
        [btnModeWalk setSelected:NO];
    } else if (m_nModeRoute == BICYCLING) {
        [btnModeDrive setSelected:NO];
        [btnModeBicycle setSelected:YES];
        [btnModeWalk setSelected:NO];
    } else {
        [btnModeDrive setSelected:NO];
        [btnModeBicycle setSelected:NO];
        [btnModeWalk setSelected:YES];
    }
    
}

- (IBAction)onClickModeDrive:(id)sender
{
    m_nModeRoute = DRIVING;
    [self setModeButton];
}
- (IBAction)onClickModeBicycle:(id)sender
{
    m_nModeRoute = BICYCLING;
    [self setModeButton];
}
- (IBAction)onClickModeWalk:(id)sender
{
    m_nModeRoute = WALKING;
    [self setModeButton];
}

- (IBAction)onChangeText:(id)sender
{
    NSString * startText = directStartFld.text;
    directStartFld.text = directEndFld.text;
    directEndFld.text = startText;

    NSMutableDictionary * temp = [[NSMutableDictionary alloc]initWithDictionary:pinStart];
    
    pinStart = [NSMutableDictionary dictionaryWithDictionary:pinEnd];
    pinEnd = [NSMutableDictionary dictionaryWithDictionary:temp];
 
    
    if ([directStartFld.text isEqualToString:FIRST_POINT]) {
        directStartFld.textColor = [UIColor blueColor];
    } else {
        directStartFld.textColor = [UIColor blackColor];
    }
        
    if ([directEndFld.text isEqualToString:FIRST_POINT]) {
        directEndFld.textColor = [UIColor blueColor];
    } else {
        directEndFld.textColor = [UIColor blackColor];
    }
                                                          
}

- (IBAction)onClickUserLocation:(id)sender{
    m_bIsMyLocation = YES;
    
    [self fitToPinsRegionGPS];
    
    
    UILabel * lbLocationInfo = (UILabel*) [self.view viewWithTag:198];
    if (lbLocationInfo != nil) {
        [lbLocationInfo removeFromSuperview];
    }
    lbLocationInfo = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44 - 40, self.view.frame.size.width, 40)];
    
    int _setting = [Setting getRadius];
    int _pins    = [Setting getNumberOfPins];
    NSString * unit = ([Setting getUnit] == 0) ? @"Km" : @"Miles";
    NSString * strInfo = [NSString stringWithFormat:@"Radius = %d %@, Pins = %d", _setting, unit, _pins];
    
    lbLocationInfo.text = strInfo;
    lbLocationInfo.textAlignment = UITextAlignmentCenter;
    lbLocationInfo.textColor = [UIColor blackColor];
    lbLocationInfo.font = [UIFont boldSystemFontOfSize:14];
    lbLocationInfo.tag = 198;
    lbLocationInfo.backgroundColor = [UIColor clearColor];
    [self.view addSubview:lbLocationInfo];
}

CGPoint firstPoint;

- (void)handleMove:(UIGestureRecognizer *)gestureRecognizer {
    
    if (!m_bIsMyLocation) {
        return;
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        firstPoint = [gestureRecognizer locationInView:m_mapView];   
        return;
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint movePoint = [gestureRecognizer locationInView:m_mapView];   
        
        double distance = sqrt(pow((movePoint.x - firstPoint.x), 2) + pow((movePoint.y - firstPoint.y), 2));
        
        if (distance >= 100) {
            
            UILabel * lbLocationInfo = (UILabel*) [self.view viewWithTag:198];
            if (lbLocationInfo != nil) {
                [lbLocationInfo removeFromSuperview];
                
                m_bIsMyLocation = NO;
            }
        }
        
        return;
    }
    
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {   
    return YES;
}



- (IBAction)next:(id)sender
{
    if ([directStartFld isFirstResponder]) {
        [directEndFld becomeFirstResponder];
    }
}
- (IBAction)onClickEdit:(id)sender
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    if (m_bShowEdit) {
        viewEdit.frame = CGRectMake(0, 44-viewEdit.frame.size.height, viewEdit.frame.size.width, viewEdit.frame.size.height);
        [btnEdit setTitle:@"Edit" forState:UIControlStateNormal];

        if ([directStartFld isFirstResponder]) {
            [directStartFld resignFirstResponder];
        }
        if ([directEndFld isFirstResponder]) {
            [directEndFld resignFirstResponder];
        }

    }
    else {
        viewEdit.frame = CGRectMake(0, 44, viewEdit.frame.size.width, viewEdit.frame.size.height);
        [btnEdit setTitle:@"Cancel" forState:UIControlStateNormal];
        
        [directEndFld becomeFirstResponder];
    }
    [UIView commitAnimations];
    
    m_bShowEdit = !m_bShowEdit;
    

    if (sender != nil) {
        directStartFld.text = FIRST_POINT;
        directStartFld.textColor = [UIColor blueColor];
        
        directEndFld.text = @"";
        directEndFld.textColor = [UIColor blackColor];
        
        pinStart = nil;
        pinEnd   = nil;
    }

}

- (IBAction)onclickRoute:(id)sender
{
    if ([directEndFld.text length] == 0 || [directStartFld.text length] == 0) {
        return;
    }
    
    [self onClickEdit:nil];

    if ([directStartFld isFirstResponder]) {
        [directStartFld resignFirstResponder];
    }
    if ([directEndFld isFirstResponder]) {
        [directEndFld resignFirstResponder];
    }
    
    [self setRoute];

}

- (void) setRoute{
    NSString* starting    = directStartFld.text;
    NSString* destination = directEndFld.text;
    
    m_nLoadingCount = 0;
    [[SHKActivityIndicator currentIndicator] displayActivity:@"Loading..." : self];
    
    int mode = m_nModeRoute;
    
    GoogleDirectionsParser *directionParser;
    
    CLLocationCoordinate2D startCoord, endCoord;
    
    if ([starting isEqualToString:@"Current Location"]) {
        startCoord = [UserLocationManager sharedInstance].currentLocation.coordinate;
    } else {
        if (pinStart != nil) {
            startCoord.latitude = [[pinStart objectForKey:kPinLat] floatValue];
            startCoord.longitude = [[pinStart objectForKey:kPinLng] floatValue];
        }
        else {
            startCoord = [GeoLocation getCoordinateByAddress:starting];
        }
    }
    
    if ([destination isEqualToString:@"Current Location"]) {
        endCoord = [UserLocationManager sharedInstance].currentLocation.coordinate;
    } else {
        if (pinEnd != nil) {
            endCoord.latitude = [[pinEnd objectForKey:kPinLat] floatValue];
            endCoord.longitude = [[pinEnd objectForKey:kPinLng] floatValue];
        }
        else {
            endCoord = [GeoLocation getCoordinateByAddress:destination];
        }
    }
    
    
    /*
     if ([starting isEqualToString:@"Current Location"]) {
     directionParser = [[GoogleDirectionsParser alloc] initWithDestination:destination : mode];
     }
     else {
     directionParser = [[GoogleDirectionsParser alloc] initWithOriginAndDestination:starting : destination : mode];
     }
     */
    directionParser = [[GoogleDirectionsParser alloc] initWithOriginAndDestination:startCoord.latitude : startCoord.longitude
                                                                                  : endCoord.latitude : endCoord.longitude : mode];
    
    directionParser.delegate = self;
}

- (void)directionsParser:(GoogleDirectionsParser *)directionsParser didFinished:(BOOL)isSuccess
{
	if (isSuccess)
    {
		NSArray *arySteps = [NSArray arrayWithArray:[directionsParser getDirectionSteps]];
        if ([arySteps count] == 0) {
            [[SHKActivityIndicator currentIndicator] hide];
            
            [self clearDistance];
            
            [[[UIAlertView alloc] initWithTitle:nil message:@"There is no route to there." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return;
        }
        
        //        [NSThread detachNewThreadSelector:@selector(showPinsAroundRoute:) toTarget:self withObject:arySteps];
        [self showPinsAroundRoute:arySteps];
        [m_mapView showsUserLocation];
        
        
		CLLocationCoordinate2D *pointArr = malloc(sizeof(CLLocationCoordinate2D) * [arySteps count]);
		for (int idx = 0; idx < [arySteps count]; idx++) {
			pointArr[idx] = [[arySteps objectAtIndex:idx] coordinate];
		}
        
        NSArray *overlays = m_mapView.overlays;
        for (MKPolyline *overlayItem in overlays) {
            if ([overlayItem isKindOfClass:[MKPolyline class]]) {
                [m_mapView removeOverlay:overlayItem];
            }
        }
        m_routeLineView = nil;
		m_routeLine = [MKPolyline polylineWithCoordinates:pointArr count:[arySteps count]];
		if (m_routeLine) {
			[m_mapView addOverlay:m_routeLine];
		}
		free(pointArr);
        
//        NSArray *annotations = m_mapView.annotations;
//        for (MKPointAnnotation *pointItem in annotations) {
//            if (![pointItem isKindOfClass:[PinAnnotation class]]) {
//                [m_mapView removeAnnotation:pointItem];
//            }
//        }
        
        MKPointAnnotation *startPoint = [directionsParser getStartPoint];
        MKPointAnnotation *endPoint = [directionsParser getEndPoint];
        [m_mapView addAnnotation:startPoint];
        [m_mapView addAnnotation:endPoint];
 
        
        
        [self showDistance: [directionsParser getDistance] : [directionsParser getDuration]];
        
        m_bIsMyLocation = NO;
        [self fitToPinsRegionGPS];

        m_nLoadingCount ++;
        if (m_nLoadingCount == 2) {
            [[SHKActivityIndicator currentIndicator] hide];
        }
    
	} else {
        [[SHKActivityIndicator currentIndicator] hide];
        
        [self clearDistance];
        
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Can't get route." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        m_bIsFirst = YES;
    }
    
}

-(void) mapView:(MKMapView*) mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [UserLocationManager sharedInstance].currentLocation = [[CLLocation alloc] initWithLatitude:userLocation.coordinate.latitude
                                                                                      longitude:userLocation.coordinate.longitude];
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    // handle our custom annotations
    //
    if ([annotation isKindOfClass:[PinAnnotation class]]) {
        PinAnnotation *pinAnnotation = annotation;
        
        
        static NSString *AnnotationIdentifier = @"AnnotationIdentifier";
        MKPinAnnotationView *pinView; // = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
        
        if (pinView) {
            pinView.annotation = annotation;
            
        } else {
            
            //            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];
            MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                            reuseIdentifier:AnnotationIdentifier];
            
            annotationView.canShowCallout = YES;
            
            
            NSArray *categoryList = [Share getInstance].arrayCategory;
            
            NSDictionary *categoryItem = nil;
            for (NSDictionary *item in categoryList) {
                if ([[pinAnnotation.pinInfo objectForKey:@"category_id"] isEqualToString:[item objectForKey:@"id"]]) {
                    categoryItem = item;
                    break;
                }
            }
            
            
            if (categoryItem != nil) {
                UIImage *pinImage = [Share getCategoryImageName:[categoryItem objectForKey:@"name"]]; //[categoryItem objectForKey:@"iconData"];
                if (pinImage == nil) {
                    NSLog(@"icon image set =======");
                }
                
                CGRect resizeRect = CGRectMake(0, 0, 32, 32); // pinImage.size;
                CGSize maxSize = CGRectInset(mapView.bounds, 10, 10).size;
                if (resizeRect.size.width > maxSize.width)
                    resizeRect.size = CGSizeMake(maxSize.width, resizeRect.size.height / resizeRect.size.width * maxSize.width);
                if (resizeRect.size.height > maxSize.height)
                    resizeRect.size = CGSizeMake(resizeRect.size.width / resizeRect.size.height * maxSize.height, maxSize.height);
                
                UIGraphicsBeginImageContext(resizeRect.size);
                [pinImage drawInRect:resizeRect];
                UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                [annotationView setImage:resizedImage];
                
                annotationView.opaque = NO;
                
                UIImage *iconImage = [pinAnnotation.pinInfo objectForKey:@"pin_image"];
                if ([iconImage isKindOfClass:[UIImage class]]) {
                    UIImageView *iconView = [[UIImageView alloc] initWithImage:iconImage];
                    iconView.frame = CGRectMake(0, 0, 32, 32);
                    annotationView.leftCalloutAccessoryView = iconView;
                } else {
                    annotationView.leftCalloutAccessoryView = nil;
                }
                
                UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//                [rightButton addTarget:self action:@selector(onDirectionToHere:) forControlEvents:UIControlEventTouchUpInside];
                rightButton.tag = pinAnnotation.pinIndex; //[m_mapView.annotations indexOfObject:annotation];
                [rightButton addTarget:self action:@selector(showDetails:) forControlEvents:UIControlEventTouchUpInside];
                annotationView.rightCalloutAccessoryView = rightButton;
                NSLog(@"rightbutton.tag = %d", rightButton.tag);
                
                [annotationView addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:@"ANSELECTED"];
                
                
                return annotationView;
                
            } else {
                
                NSString * userName = [pinAnnotation.pinInfo objectForKey:@"pinType"];
                if ([userName isEqualToString:@"user"]) {
                    [annotationView setImage:[UIImage imageNamed:@"userpin"]];
                    
                    return annotationView;
                }
                
            }
            
            
        }
        
        return pinView;
    }
    
    return nil;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
	MKOverlayView *overlayView = nil;
	
	if (overlay == m_routeLine) {
		// if we have not yet created an overlay view for this overlay, create it now. 
		if (m_routeLineView == nil) {
			m_routeLineView = [[MKPolylineView alloc] initWithPolyline:m_routeLine];
			m_routeLineView.fillColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.5];
			m_routeLineView.strokeColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.5];
			m_routeLineView.lineWidth = 3;
		}
		
		overlayView = m_routeLineView;
	}
	
	return overlayView;
}

- (void)fitToPinsRegionGPS
{
    if ([m_mapView.annotations count] == 0) {
        MKCoordinateRegion region;
        region.center = [UserLocationManager sharedInstance].currentLocation.coordinate;
        region.span.latitudeDelta = 0.005;
        region.span.longitudeDelta = 0.005;
        region = [m_mapView regionThatFits:region];
        [m_mapView setRegion:region animated:YES];
        m_mapView.showsUserLocation = YES;
        return;
    }
    
	CLLocationCoordinate2D topLeftCoord;
	CLLocationCoordinate2D bottomRightCoord;

    MKPointAnnotation *firstMark = [m_mapView.annotations objectAtIndex:0];
    topLeftCoord = firstMark.coordinate;
    bottomRightCoord = firstMark.coordinate;
	
    BOOL bOtherPineExist = NO;
	for (MKPointAnnotation *item in m_mapView.annotations) {
        if (![item isKindOfClass:[MKPointAnnotation class]]) {
            continue;
        }
        
        bOtherPineExist = YES;
        
		if (item.coordinate.latitude < topLeftCoord.latitude) {
			topLeftCoord.latitude = item.coordinate.latitude;
		}
		
		if (item.coordinate.longitude > topLeftCoord.longitude) {
			topLeftCoord.longitude = item.coordinate.longitude;
		}
		
		if (item.coordinate.latitude > bottomRightCoord.latitude) {
			bottomRightCoord.latitude = item.coordinate.latitude;
		}
		
		if (item.coordinate.longitude < bottomRightCoord.longitude) {
			bottomRightCoord.longitude = item.coordinate.longitude;
		}
	}
	
    if (!bOtherPineExist || m_bIsMyLocation)
	{
        topLeftCoord = bottomRightCoord = [UserLocationManager sharedInstance].currentLocation.coordinate;

//		topLeftCoord.latitude = fmin(topLeftCoord.latitude, [UserLocationManager sharedInstance].currentLocation.coordinate.latitude);
//		topLeftCoord.longitude = fmax(topLeftCoord.longitude, [UserLocationManager sharedInstance].currentLocation.coordinate.longitude);
//		
//		bottomRightCoord.latitude = fmax(bottomRightCoord.latitude, [UserLocationManager sharedInstance].currentLocation.coordinate.latitude);
//		bottomRightCoord.longitude = fmin(bottomRightCoord.longitude, [UserLocationManager sharedInstance].currentLocation.coordinate.longitude);
	}
    
    
	MKCoordinateRegion region;
	
    
    
    
    region.center.latitude = (topLeftCoord.latitude + bottomRightCoord.latitude) / 2.0;
    region.center.longitude = (topLeftCoord.longitude + bottomRightCoord.longitude) / 2.0;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.5; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.5; // Add a little extra space on the sides
    
    if (region.span.latitudeDelta < 0.01) {
        region.span.latitudeDelta = 0.01;
    }
    if (region.span.longitudeDelta < 0.01) {
        region.span.longitudeDelta = 0.01;
    }
    
    if (region.span.latitudeDelta > 90) {
        region.span.latitudeDelta -= 90;
    }
    if (region.span.longitudeDelta > 180) {
        region.span.longitudeDelta -= 180;
    }
    
	region = [m_mapView regionThatFits:region];
	[m_mapView setRegion:region animated:YES];
}

- (void) showPinsAroundRoute: (NSArray*) arrPoint{
    
    @autoreleasepool {
        if (arrPoint == nil) {
            return;
        }
        
        NSArray *prevPins = m_mapView.annotations;
  
        for (MKPointAnnotation *pinAn in prevPins)
        {
            if (![pinAn isKindOfClass:[MKUserLocation class]])
            {
                [m_mapView removeAnnotation:pinAn];
            }
        }
        
//        [m_mapView removeAnnotations:prevPins];

        NSMutableArray * arrLocation = [NSMutableArray new];
        
        for (int i = 0; i < [arrPoint count]; i += 1) {
            CLLocationCoordinate2D location = [[arrPoint objectAtIndex:i] coordinate];
            
            [arrLocation addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithDouble:location.latitude], @"lat",
                                    [NSNumber numberWithDouble:location.longitude], @"lng", nil]];
            
        }    

/*
        NSString * url = [SERVER_URL stringByAppendingFormat:@"request/route_pins"];
        NSLog(@"url = %@", url);
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString: url]];
        request.requestMethod = @"POST";

        
        [request setPostValue:@"" forKey:@"search"];
        NSLog(@"search = %@", @"");
        
        for (NSMutableDictionary * dic in [Share getInstance].arrayCategory) {
            [request setPostValue:[dic objectForKey:@"id"] forKey:@"category[]"];
            NSLog(@"category[] = %@", [dic objectForKey:@"id"]);
        }

        for (NSMutableDictionary * dic in arrLocation) {
            [request setPostValue:[NSString stringWithFormat:@"%@,%@", [dic objectForKey:@"lat"], [dic objectForKey:@"lng"]] forKey:@"latlng[]"];
            NSLog(@"latlng[] = %@", [NSString stringWithFormat:@"%@,%@", [dic objectForKey:@"lat"], [dic objectForKey:@"lng"]]);
        }

        NSString *radius = @"1";
        [request setPostValue:radius forKey:@"radius"];
        NSLog(@"radius = %@", radius);

        [request setDelegate:self];
        [request setDidFinishSelector:@selector(uploadRequestFinished:)];
        [request setDidFailSelector:@selector(uploadRequestFailed:)];
        
        [request startAsynchronous];
*/
        NSString * url = [SERVER_URL stringByAppendingFormat:@"request/route_pins"];
        self.request = [RequestsBase requestPOSTWithURL: url delegate: self];
        
        [self.request setPostValue:@"" forKey:@"search"];
        NSLog(@"search = %@", @"");
        
        int index = 0;
        for (NSMutableDictionary * dic in [Share getInstance].arrayCategory) {
            [self.request setPostValue:[dic objectForKey:@"id"] forKey: [NSString stringWithFormat:@"category[%d]", index]];
            NSLog(@"category[%d] = %@", index, [dic objectForKey:@"id"]);
            index ++;
        }
        
        index = 0;
        int offset = 1; //[arrLocation count] / 10;
        for (int i = 0 ; i < [arrLocation count] ; i += offset) {
            NSMutableDictionary *dic = [arrLocation objectAtIndex:i];
            [self.request setPostValue:[NSString stringWithFormat:@"%@,%@", [dic objectForKey:@"lat"], [dic objectForKey:@"lng"]]
                           forKey:[NSString stringWithFormat:@"latlng[%d]", index]];
            NSLog(@"latlng[%d] = %@", index, [NSString stringWithFormat:@"%@,%@", [dic objectForKey:@"lat"], [dic objectForKey:@"lng"]]);
            index ++;
            
        }
//        for (NSMutableDictionary * dic in arrLocation) {
//            [request setPostValue:[NSString stringWithFormat:@"%@,%@", [dic objectForKey:@"lat"], [dic objectForKey:@"lng"]] forKey:[NSString stringWithFormat:@"latlng[%d]", index]];
//            NSLog(@"latlng[%d] = %@", index, [NSString stringWithFormat:@"%@,%@", [dic objectForKey:@"lat"], [dic objectForKey:@"lng"]]);
//            index ++;
//        }
        
        NSString *radius = @"1";
        [self.request setPostValue:radius forKey:@"radius"];
        [self.request setDelegate:self];
        NSLog(@"radius = %@", radius);

        [self.request execute];
    }
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string 
{
    
    if ([textField.text isEqualToString:@"Current Locatio"] && [string isEqualToString:@"n"]) {
        textField.textColor = [UIColor blueColor];
    } else {
        textField.textColor = [UIColor blackColor];
    }
    
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField isEqual:directStartFld]) {
        if (pinStart != nil) {
            if (![[pinStart objectForKey:@"full_address"] isEqualToString:directStartFld.text]){
                pinStart = nil;
            }
        }
    } 
    if ([textField isEqual:directEndFld]) {
        if (pinEnd != nil) {
            if (![[pinEnd objectForKey:@"full_address"] isEqualToString:directEndFld.text]){
                pinEnd = nil;
            }
        }
    }
    
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //    BOOL isMain = [NSThread isMainThread];
    NSString *action = (__bridge NSString *)context;
	MKPinAnnotationView *annotationView = (MKPinAnnotationView *)object;
    if ([action isEqualToString:@"ANSELECTED"])
    {
        BOOL annotationSelected = [[change valueForKey:@"new"] boolValue];
        if (annotationSelected)
        {
            PinAnnotation *pin = (PinAnnotation *)annotationView.annotation;
            UIImage *iconImage = [pin.pinInfo objectForKey:@"pin_image"];
            if ([iconImage isKindOfClass:[UIImage class]]) {
                [self performSelectorOnMainThread:@selector(addImageToAnnotationView:) withObject:annotationView waitUntilDone:NO];
            } else {
                [NSThread detachNewThreadSelector:@selector(getThumbImage:) toTarget:self withObject:annotationView];
            }
        }
        else
        {
            // Annotation deselected
        }
    }
}


- (void)getThumbImage:(MKAnnotationView *)annotationView
{
    @autoreleasepool {
        PinAnnotation *pin = annotationView.annotation;
        NSMutableDictionary *pinInfo = pin.pinInfo;
        if (pinInfo && ![[pinInfo objectForKey:@"pin_image"] isKindOfClass:[UIImage class]]) {
            NSString *imageUrl = [[pinInfo objectForKey:@"image"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSLog(@"%@", imageUrl);
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
            UIImage *iconImg = [UIImage imageWithData:imageData];
            if (iconImg) {
                [pinInfo setObject:iconImg forKey:@"pin_image"];
                
                [self performSelectorOnMainThread:@selector(addImageToAnnotationView:) withObject:annotationView waitUntilDone:NO];
            } else {
                [pinInfo setObject:[NSNull null] forKey:@"pin_image"];
            }
        }
    }
}

- (void) addImageToAnnotationView:(MKAnnotationView *)annotationView
{
	PinAnnotation *pin = annotationView.annotation;
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    UIImage *iconImg = [pin.pinInfo objectForKey:@"pin_image"];
    if ([iconImg isKindOfClass:[UIImage class]]) {
        imageView.image = iconImg;
    }
	imageView.backgroundColor = [UIColor clearColor];
	annotationView.leftCalloutAccessoryView = imageView;
}

- (void)showDetails:(UIButton *)sender
{
//    PinAnnotation *pinAnnot = [m_mapView.annotations objectAtIndex:sender.tag];
    PinAnnotation *pinAnnot = nil;
    for (PinAnnotation * pin in m_mapView.annotations) {
        if ([pin isKindOfClass:[MKUserLocation class]]) {
            continue;
        }

//        if ([pin isKindOfClass:[MKPointAnnotation class]]) {
//            continue;
//        }
        if (![pin isKindOfClass:[PinAnnotation class]]) {
            continue;
        }
        
        if (pin.pinIndex == sender.tag) {
            pinAnnot = pin;
            break;
        }
    }
    
    PinDetailController *detailCtlr;
    
    if (iPad) {
        detailCtlr = [[PinDetailController alloc] initWithNibName:@"PinDetailController-ipad" bundle:nil];
    } else {
        detailCtlr = [[PinDetailController alloc] initWithNibName:@"PinDetailController" bundle:nil];
    }
    
    detailCtlr.delegate = self;
    detailCtlr.pinInfo = pinAnnot.pinInfo;
    
    [self.navigationController pushViewController:detailCtlr animated:YES];
    
}

- (void) onDirectionToHere :(UIButton*) sender 
{
    int tag = sender.tag;
    
    if (tag > [m_mapView.annotations count]) {
        return;
    }
    
    PinAnnotation *pinAnnot = [m_mapView.annotations objectAtIndex:tag];
    if (pinAnnot != nil) {
        [self DirectToHere:pinAnnot.pinInfo];
    }

}

-(void) DirectFromHere : (NSMutableDictionary*) _info{
    m_bShowEdit = NO;
    [self onClickEdit:nil];
    
    pinStart = [[NSMutableDictionary alloc] initWithDictionary:_info];
    
    NSString * strFull = [_info objectForKey:@"full_address"];
    if (strFull == nil || strFull.length < 1) {
        strFull = [NSString stringWithFormat:@"%@ %@ %@", [_info objectForKey:@"address"], [_info objectForKey:@"city"], [_info objectForKey:@"country"]];

        [pinStart setObject:strFull forKey:@"full_address"];

    }
    directStartFld.text = strFull;
    directStartFld.textColor = [UIColor blackColor];
    [directStartFld becomeFirstResponder];
    
    
    directEndFld.text = FIRST_POINT;
    directEndFld.textColor = [UIColor blueColor];
    pinEnd = nil;
}

-(void) DirectToHere : (NSMutableDictionary * ) _info{
    m_bShowEdit = NO;
    [self onClickEdit:nil];

    directStartFld.text = FIRST_POINT;
    directStartFld.textColor = [UIColor blueColor];
    
    pinStart = nil;
    
    NSLog(@"_info = %@", _info);

    pinEnd = [[NSMutableDictionary alloc] initWithDictionary:_info];

    NSString * strFull = [_info objectForKey:@"full_address"];
    if (strFull == nil || strFull.length < 1) {
        strFull = [NSString stringWithFormat:@"%@ %@ %@", [_info objectForKey:@"address"], [_info objectForKey:@"city"], [_info objectForKey:@"country"]];
        
        [pinEnd setObject:strFull forKey:@"full_address"];
    }
    directEndFld.text = strFull;
    [directEndFld becomeFirstResponder];

}

- (void) addUserLocation 
{
/*    
    NSMutableDictionary * userPin = [[NSMutableDictionary alloc] init];
    
    [userPin setObject:[NSString stringWithFormat:@"%f", [UserLocationManager sharedInstance].latestLocation.coordinate.latitude] forKey:@"lat"];
    [userPin setObject:[NSString stringWithFormat:@"%f", [UserLocationManager sharedInstance].latestLocation.coordinate.longitude] forKey:@"lng"];
    
    [userPin setObject:@"user" forKey:@"pinType"];
    
    [userPin setObject:@"-1" forKey:@"category_id"];
    [userPin setObject:@"Current Location" forKey:@"title"];
    
    PinAnnotation * annotation = [[PinAnnotation alloc] initWithPinInfo:userPin];
    
    [m_mapView addAnnotation:annotation];	
*/
    
    [m_mapView setShowsUserLocation:YES];
    
}


-(void) showDistance: (NSString*) _distance : (NSString*) _duration
{
    // _distance = "1.8 mi" , "2.8 km"
    
    NSArray *array = [_distance componentsSeparatedByString:@" "];
    
    float value = [[array objectAtIndex:0] floatValue];
    NSString * unit = [array objectAtIndex:1];
    
    if ([Setting getUnit] == 0) { //km
        if ([unit isEqualToString:@"km"]) {
            lbDistance.text = [NSString stringWithFormat:@"%@ - %@", _duration, _distance];
        } else {
            value = value * 1.6;
            
            lbDistance.text = [NSString stringWithFormat:@"%@ - %.1f mile", _duration, value];
        }
    } else { //mile
        if ([unit isEqualToString:@"mi"]) {
            lbDistance.text = [NSString stringWithFormat:@"%@ - %.1f mile", _duration, value];
        } else {
            value = value / 1.6;
            
            lbDistance.text = [NSString stringWithFormat:@"%@ - %.1f km", _duration, value];
        }
        
    }
}
-(void) clearDistance{
    lbDistance.text = @"";
}

#pragma mark --------- NOtification ---------
- (void) onNotifyDicFromHere:(NSNotification*)notify
{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] initWithDictionary:notify.userInfo];
    [self DirectFromHere:dic];
}

- (void) onNotifyDicToHere:(NSNotification*)notify
{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] initWithDictionary:notify.userInfo];
    [self DirectToHere:dic];
}

#pragma mark ---------- PinDetail Delegate -----------
-(void) closeDeletePin{
    
    [self setRoute];
}


- (void)uploadRequestFinished:(ASIHTTPRequest *)request{
/*
    NSString *sResponseString = request.responseString;
    NSLog(@"Upload response %@", sResponseString);
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    id result = [JSonParser objectWithString:sResponseString];
    
    NSLog(@"result = %@", result);
    
    NSDictionary *forCategory = [result objectForKey:@"categories"];
    NSArray *pinForCategory = [forCategory allValues];
    
    NSMutableArray * pinItems = [[NSMutableArray alloc] initWithCapacity:10];
    for (NSDictionary *categoryItem in pinForCategory) {
        NSArray *pins = [categoryItem objectForKey:@"pins"];
        for (NSDictionary *pinItem in pins) {
            NSMutableDictionary *pinArchive = [NSMutableDictionary dictionaryWithDictionary:pinItem];
            
            [pinItems addObject:pinArchive];
        }
    }
    
 
    int nCount = 1;
    for (NSMutableDictionary *pinItem in pinItems) {
        //            [pinItem setObject:@"Direction to Here" forKey:@"title"];
        //            [pinItem setObject:@"" forKey:@"full_address"];
        
        NSString* strFull = [NSString stringWithFormat:@"%@ %@ %@", [pinItem objectForKey:@"address"], [pinItem objectForKey:@"city"], [pinItem objectForKey:@"country"]];
        [pinItem setObject:strFull forKey:@"full_address"];
        
        PinAnnotation *pin = [[PinAnnotation alloc] initWithPinInfo:pinItem];
        pin.pinIndex = nCount;
        [m_mapView addAnnotation:pin];
        
        nCount ++;
    }
    
    [self addUserLocation];

    [self fitToPinsRegionGPS];
*/
}

- (void)uploadRequestFailed:(ASIHTTPRequest *)request{
    
    
//    NSLog(@" Error - Statistics file upload failed: \"%@\"",[[request error] localizedDescription]);
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"There seems to be an issue at present" delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark RequestProtocol

-(void) requestExecutionFinished:(RequestsBase*) req
{
    NSString *responseString = req.responseString;
    NSLog(@"Upload response %@", responseString);
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    id result = [JSonParser objectWithString:responseString];
    
    NSLog(@"result = %@", result);
    
    NSDictionary *forCategory = [result objectForKey:@"categories"];
    NSArray *pinForCategory = [forCategory allValues];
    
    NSMutableArray * pinItems = [[NSMutableArray alloc] initWithCapacity:10];
    for (NSDictionary *categoryItem in pinForCategory) {
        NSArray *pins = [categoryItem objectForKey:@"pins"];
        for (NSDictionary *pinItem in pins) {
            NSMutableDictionary *pinArchive = [NSMutableDictionary dictionaryWithDictionary:pinItem];
            
            [pinItems addObject:pinArchive];
        }
    }
    
    int nCount = 1;
    for (NSMutableDictionary *pinItem in pinItems) {
        //            [pinItem setObject:@"Direction to Here" forKey:@"title"];
        //            [pinItem setObject:@"" forKey:@"full_address"];
        
        NSString* strFull = [NSString stringWithFormat:@"%@ %@ %@", [pinItem objectForKey:@"address"], [pinItem objectForKey:@"city"], [pinItem objectForKey:@"country"]];
        [pinItem setObject:strFull forKey:@"full_address"];
        
        PinAnnotation *pin = [[PinAnnotation alloc] initWithPinInfo:pinItem];
        pin.pinIndex = nCount;
        [m_mapView addAnnotation:pin];
        
        nCount ++;
    }
    
    [self addUserLocation];
    
    [self fitToPinsRegionGPS];
    
    m_nLoadingCount ++;
    if (m_nLoadingCount == 2) {
        [[SHKActivityIndicator currentIndicator] hide];
    }
    
}
-(void) requestExecutionFailed:(RequestsBase*) req
{
    [[SHKActivityIndicator currentIndicator] hide];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"There seems to be an issue at present" delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil, nil];
    [alert show];
}

@end
