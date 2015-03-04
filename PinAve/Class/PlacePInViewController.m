//
//  PlacePInViewController.m
//  PinAve
//
//  Created by Gold Luo on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlacePInViewController.h"
#import "CreatePinViewController.h"

#import "UserRoundPin.h"
#import "SearchViewController.h"
#import "AppDelegate.h"
#import "PinDetailController.h"
#import "Setting.h"


@interface PlacePInViewController ()
{
    BOOL m_bFirstAppear;
}
@end

@implementation PlacePInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    // for Drop a pin
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0; //user needs to press for 2 seconds
    [m_mapView addGestureRecognizer:lpgr];

    m_bFirstAppear = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

- (void) viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setTabBarHidden:NO animated:YES];
    
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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (m_bFirstAppear == YES) {
        m_bFirstAppear = NO;
        [[SHKActivityIndicator currentIndicator] displayActivity:@"Loading..." : self];
        
//        [NSThread detachNewThreadSelector:@selector(showAllPinsForUser) toTarget:self withObject:nil];
        // [self performSelectorOnMainThread:@selector(refreshPins) withObject:nil waitUntilDone:NO];
        [NSThread detachNewThreadSelector:@selector(refreshPins) toTarget:self withObject:nil];

    }
    

}
- (void) addUserLocation 
{
    
    [m_mapView setShowsUserLocation:YES];

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
}

- (void) addDropPin 
{

    NSMutableDictionary * dropPin = [[SearchViewController getInstance] changePinInfo:[UserLocationManager sharedInstance].currentLocation.coordinate.latitude :[UserLocationManager sharedInstance].currentLocation.coordinate.longitude];

    [dropPin setObject:@"droppin" forKey:@"pinType"];
    [dropPin setObject:@"-1" forKey:@"category_id"];
    
    PinAnnotation * annotation = [[PinAnnotation alloc] initWithPinInfo:dropPin];
    
    [m_mapView addAnnotation:annotation];	
    [m_mapView selectAnnotation:annotation animated:YES];
}

#pragma mark ----------------------------------------------------------------------------------
- (void)showAllPinsForUser
{
    @autoreleasepool {
        
        NSString *url = [Utils getPinForCurrentUser];
        [[UserRoundPin pool] start:url];
        
        
        while (![UserRoundPin pool].isGotAllPin) {
            [NSThread sleepForTimeInterval:0.03];
        }
        

        NSArray *prevPins = m_mapView.annotations;
        [m_mapView removeAnnotations:prevPins];
        
//        NSArray *prevPins = m_mapView.annotations;
//        for (PinAnnotation *pinAn in prevPins)
//        {
////            if (![pinAn isKindOfClass:[MKUserLocation class]])
////            {
////                [m_mapView removeAnnotation:pinAn];
////            }
//            
//            if ([pinAn isKindOfClass:[PinAnnotation class]]) 
//            {
//                [m_mapView removeAnnotation:pinAn];
//            }
//        }
        

        [self performSelectorOnMainThread:@selector(refreshPins) withObject:nil waitUntilDone:NO];
        
//        [self performSelectorOnMainThread:@selector(fitToPinsRegion) withObject:nil waitUntilDone:NO];
        
    }
}

- (void) refreshPins
{
    NSMutableArray *allPins = [UserRoundPin pool].allPinListForUser;
    
    if (allPins != nil) {
        for (NSMutableDictionary *pinItem in allPins) {
            PinAnnotation *pin = [[PinAnnotation alloc] initWithPinInfo:pinItem];
            [m_mapView addAnnotation:pin];
        }
    }
    
    [self addUserLocation];
    [self addDropPin];
    
    [[SHKActivityIndicator currentIndicator] hide];    
    
    [self performSelectorOnMainThread:@selector(fitToPinsRegion) withObject:nil waitUntilDone:NO];
    
}

- (void)fitToPinsRegion
{
    if ([m_mapView.annotations count] == 0) {
        return;
    }
    
	PinAnnotation *firstMark = [m_mapView.annotations objectAtIndex:0];
	
	CLLocationCoordinate2D topLeftCoord = firstMark.coordinate;
	CLLocationCoordinate2D bottomRightCoord = firstMark.coordinate;
	
	for (PinAnnotation *item in m_mapView.annotations) {
        if (![item isKindOfClass:[PinAnnotation class]]) {
            continue;
        }

//        if (![[item.pinInfo objectForKey:@"type"] isEqualToString:@"user"]) {
//            continue;
//        }

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
    

    //user Location
	{
		topLeftCoord.latitude = fmin(topLeftCoord.latitude, [UserLocationManager sharedInstance].currentLocation.coordinate.latitude);
		topLeftCoord.longitude = fmax(topLeftCoord.longitude, [UserLocationManager sharedInstance].currentLocation.coordinate.longitude);
		
		bottomRightCoord.latitude = fmax(bottomRightCoord.latitude, [UserLocationManager sharedInstance].currentLocation.coordinate.latitude);
		bottomRightCoord.longitude = fmin(bottomRightCoord.longitude, [UserLocationManager sharedInstance].currentLocation.coordinate.longitude);
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
    
	region = [m_mapView regionThatFits:region];
	[m_mapView setRegion:region animated:YES];
    
}



#pragma mark ------- map -
-(void) mapView:(MKMapView*) mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [UserLocationManager sharedInstance].currentLocation = [[CLLocation alloc] initWithLatitude:userLocation.coordinate.latitude
                                                                                      longitude:userLocation.coordinate.longitude];
    
    
    NSLog(@"user1 = %@", [UserLocationManager sharedInstance].currentLocation);
    
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    
	if (oldState == MKAnnotationViewDragStateDragging) {
		PinAnnotation *annotation = (PinAnnotation *)annotationView.annotation;
        
		NSMutableDictionary * _pinInfo = [[SearchViewController getInstance] changePinInfo:annotation.coordinate.latitude :annotation.coordinate.longitude];
        
        annotation.pinInfo = _pinInfo;
        
        annotation.subtitle = [_pinInfo objectForKey:@"full_address"];
	}
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    // handle our custom annotations
    //
    if ([annotation isKindOfClass:[PinAnnotation class]]) 
    {
        PinAnnotation *pinAnnotation = annotation;
        
        
        static NSString *AnnotationIdentifier = @"AnnotationIdentifier";
        MKPinAnnotationView *pinView;// = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
        
        if (pinView) 
        {
            pinView.annotation = annotation;
            
        } else {
            
            //            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];
            MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                            reuseIdentifier:AnnotationIdentifier];
            
            annotationView.canShowCallout = YES;
            
            
            if ([[pinAnnotation.pinInfo objectForKey:@"category_id"] intValue] == -1 ) {
                
                NSString * userName = [pinAnnotation.pinInfo objectForKey:@"pinType"];
                if ([userName isEqualToString:@"user"]) {
                    annotationView.canShowCallout = NO;
                    [annotationView setImage:[UIImage imageNamed:@"userpin"]];
                    
                    return annotationView;
                }
                else {
                    pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];
                    
                    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                    [rightButton addTarget:self action:@selector(insertDetails:) forControlEvents:UIControlEventTouchUpInside];
                    rightButton.tag = [m_mapView.annotations indexOfObject:annotation];
                    pinView.rightCalloutAccessoryView = rightButton;
                    
                    pinView.canShowCallout = YES;
                    pinView.animatesDrop = YES;
                    pinView.draggable = YES;
                    pinView.pinColor = MKPinAnnotationColorPurple;
                    
                    [pinView setSelected:YES animated:YES];
                    
                }

            } 
            else {
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
                    [rightButton addTarget:self action:@selector(showDetails:) forControlEvents:UIControlEventTouchUpInside];
                    rightButton.tag = [m_mapView.annotations indexOfObject:annotation];
                    annotationView.rightCalloutAccessoryView = rightButton;
                    
                    [annotationView addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:@"ANSELECTED"];
                    
                    return annotationView;
                    
                }
            }
            
        }
        
        return pinView;
    }
    
    return nil;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
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


- (void)insertDetails:(UIButton *)sender
{
    PinAnnotation *pinAnnot = [m_mapView.annotations objectAtIndex:sender.tag];
    
    
    CreatePinViewController *vc;
    if (iPad) {
        vc = [[CreatePinViewController alloc] initWithNibName:@"CreatePinViewController-ipad" bundle:nil];
    } else {
        vc = [[CreatePinViewController alloc] initWithNibName:@"CreatePinViewController" bundle:nil];
    }
    
    vc.pinInfo = pinAnnot.pinInfo;
    //    vc.categoryList = self.categoryAry;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showDetails:(UIButton *)sender
{
    PinAnnotation *pinAnnot = [m_mapView.annotations objectAtIndex:sender.tag];
    
    
    PinDetailController *detailCtlr;
    
    if (iPad) {
        detailCtlr = [[PinDetailController alloc] initWithNibName:@"PinDetailController-ipad" bundle:nil];
    } else {
        detailCtlr = [[PinDetailController alloc] initWithNibName:@"PinDetailController" bundle:nil];
    }
    detailCtlr.pinInfo = pinAnnot.pinInfo;
    [self.navigationController pushViewController:detailCtlr animated:YES];
    
    
}


#pragma mark Gesture----------------------
- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:m_mapView];   
    CLLocationCoordinate2D touchMapCoordinate = [m_mapView convertPoint:touchPoint toCoordinateFromView:m_mapView];
    
    NSMutableDictionary * _pinInfo = [[SearchViewController getInstance] changePinInfo:touchMapCoordinate.latitude :touchMapCoordinate.longitude];
    
    PinAnnotation * annotation = [[PinAnnotation alloc] initWithPinInfo:_pinInfo];
    
    [m_mapView addAnnotation:annotation];
	[m_mapView selectAnnotation:annotation animated:YES];
    
}

@end
