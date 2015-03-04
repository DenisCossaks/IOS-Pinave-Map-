//
//  SearchViewController.m
//  Pin Ave
//
//  Created by gold-iron  on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchViewController.h"
#import "UserRoundPin.h"
#import "PinAnnotation.h"
#import "SBJsonParser.h"
#import "Setting.h"
#import "PinDetailController.h"
#import "CreatePinViewController.h"
#import "PinInfoCell.h"
#import "AppDelegate.h"
#import "WithCategoryController.h"

#import "UserPins.h"
#import "FilterSearch.h"

#import "UIImageView+Cached.h"
#import "Notification.h"
#import "GeoLocation.h"


static SearchViewController *instance = nil;

@interface NSDictionary (SortingFloat)

- (NSComparisonResult) compareByDistance:(NSDictionary *)other;

@end

//enum _NSComparisonResult {NSOrderedAscending = -1, NSOrderedSame, NSOrderedDescending};

@implementation NSDictionary (SortingFloat)
- (NSComparisonResult) compareByDistance:(NSDictionary *)other
{
//    NSString *nameOwn = [self objectForKey:@"name"];
//    NSString *nameOther = [other objectForKey:@"name"];
//    
//    return [nameOwn compare:nameOther];
    
    float distOwn= [[self objectForKey:@"distance"] floatValue];
    float distOther= [[other objectForKey:@"distance"] floatValue];
    
    if(distOwn < distOther)
        return NSOrderedAscending;
    else if(distOwn == distOther)
        return NSOrderedSame;
    
    return NSOrderedDescending;
}
@end


@implementation SearchViewController

@synthesize m_bUpdated;
@synthesize m_nSearchMode;
@synthesize m_nPinSize;
@synthesize arrSelectedCategory;



+ (SearchViewController*) getInstance {
    if (instance == nil) {
        instance = [[SearchViewController alloc] init];
    }
    
    return instance;
}

-(id) initWithValue:(NSMutableArray*) _selAry pinSize:(int) _pinSize userlocation:(NSString*) _locatioin update:(BOOL) _bUpdate searchMode:(int) nSearch
{
    self = [super init];
    if (self) {
        self.arrSelectedCategory = [NSMutableArray arrayWithArray:_selAry];
        self.m_nPinSize = _pinSize;
        self.m_userLocation = _locatioin;
        self.m_bUpdated = _bUpdate;
        self.m_nSearchMode = nSearch;
        
        m_bList = YES;
    }
    
    return self;
}

-(id) initWithMap:(NSMutableArray*) _selAry pinSize:(int) _pinSize userlocation:(NSString*) _locatioin update:(BOOL) _bUpdate searchMode:(int) nSearch
{
    self = [super init];
    if (self) {
        self.arrSelectedCategory = [NSMutableArray arrayWithArray:_selAry];
        self.m_nPinSize = _pinSize;
        self.m_userLocation = _locatioin;
        self.m_bUpdated = _bUpdate;
        self.m_nSearchMode = nSearch;
        
        m_bList = NO;
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    

    // for Drop a pin
//    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
//    lpgr.minimumPressDuration = 1.0; //user needs to press for 2 seconds
//    [m_mapView addGestureRecognizer:lpgr];

    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleMove:)];
	[panRecognizer setMinimumNumberOfTouches:1];
	[panRecognizer setMaximumNumberOfTouches:1];
    panRecognizer.delegate = self;
	[m_mapView addGestureRecognizer:panRecognizer];

    // For top bar
//    UIPanGestureRecognizer *panRecognizer1 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleMove1:)];
//	[panRecognizer1 setMinimumNumberOfTouches:1];
//	[panRecognizer1 setMaximumNumberOfTouches:1];
//    panRecognizer1.delegate = self;
//	[m_viewTopBar addGestureRecognizer:panRecognizer1];
    UITapGestureRecognizer *panRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMove1:)];
    panRecognizer1.delegate = self;
	[viewLogo addGestureRecognizer:panRecognizer1];

    
    m_bAdvanced = NO;
    m_bShowSearchBar = NO;
    
    m_nSearchTime = TODAY;
    
//    self.arrSelectedCategory = [[NSMutableArray alloc] initWithCapacity:10];
    
    if (m_bList) {
        [self setListView];
    } else {
        [self setMapView];
    }
    
    currPage = 0;
    m_arrPinsAroundUser = [NSMutableArray new];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIDeviceOrientationPortraitUpsideDown);
}

- (void) viewWillAppear:(BOOL)animated {

    self.navigationController.navigationBarHidden = YES;

    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setTabBarHidden:NO animated:YES];


    lbUserLocation.text = self.m_userLocation;
    lbLocation.text = self.m_userLocation;
    
    [self refreshMap];
}

- (void)viewDidDisappear:(BOOL)animated
{
    
}
- (void) viewWillDisappear:(BOOL)animated
{
    if (m_bGoDetail == YES) {
        m_bGoDetail = NO;
        return;
    }
    
    if (!m_bList) { // map
//        NSArray *prevPins = m_mapView.annotations;
//        [m_mapView removeAnnotations:prevPins];
        for (id <MKAnnotation> annotation in m_mapView.annotations)
        {
            if (![annotation isKindOfClass:[MKUserLocation class]])
            {
                [m_mapView removeAnnotation:annotation];
            }
            
        }
        m_mapView.delegate = nil;
    }
}
-(void) refreshMap{

    if (self.m_bUpdated) {
        self.m_bUpdated = NO;

        [[SHKActivityIndicator currentIndicator] displayActivity:@"Loading..." : self];
        
        isLoading = YES;
        
        if (self.m_nSearchMode == CATEGORY_MODE) {
            if ([m_arrPinsAroundUser count] >= self.m_nPinSize)
                return;

            [NSThread detachNewThreadSelector:@selector(showAllPinsForUser) toTarget:self withObject:nil];
            
        } else if (self.m_nSearchMode == MYPIN_MODE){
            
            [NSThread detachNewThreadSelector:@selector(ShowUserPins) toTarget:self withObject:nil];
//            [self ShowUserPins];
        } else if (self.m_nSearchMode == SEARCH_MODE) {
            
        } else if (self.m_nSearchMode == NOTIFY_MODE) {
            
            [NSThread detachNewThreadSelector:@selector(showNotifyPinsForUser) toTarget:self withObject:nil];
        }
        
    }

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

- (void)dealloc
{
    NSArray *prevPins = m_mapView.annotations;
//    for (PinAnnotation *annotation in prevPins) {
//        MKAnnotationView *annotationView = [self.m_mapView viewForAnnotation:annotation];
//        [annotationView removeObserver:self forKeyPath:@"selected" context:@"ANSELECTED"];
//    }
    [m_mapView removeAnnotations:prevPins];
    
}


#pragma mark ------------ 

- (void) setListMap{
    
    [m_arrPinsAroundUser sortUsingSelector:@selector(compareByDistance:)];
    
    if (m_bList) {
        [self setListView];
    } else {
        [self setMapView];
    }
    
    [[SHKActivityIndicator currentIndicator] hide];
    isLoading = NO;

}

- (void)showAllPinsForUser
{
    int _radius = [Setting getRadius];
    int page = currPage ++;
    int limit = 15;
    
    NSString *urlString = [Utils getPinForUser: self.arrSelectedCategory : _radius : page : limit];
    NSString *pinResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    id result = [JSonParser objectWithString:pinResult];

    
    NSDictionary *forCategory = [result objectForKey:@"categories"];
    NSArray *pinForCategory = [forCategory allValues];
    for (NSDictionary *categoryItem in pinForCategory) {
        NSArray *pins = [categoryItem objectForKey:@"pins"];
        
        for (NSMutableDictionary *pinItem in pins) {
            
            NSString* strFull = [pinItem objectForKey:@"full_address"];
            if (strFull == nil || strFull.length < 1) {
                strFull = [NSString stringWithFormat:@"%@ %@ %@", [pinItem objectForKey:@"address"], [pinItem objectForKey:@"city"], [pinItem objectForKey:@"country"]];
                
                [pinItem setObject:strFull forKey:@"full_address"];
            }
            
            
            NSString * lat = [pinItem objectForKey:@"lat"];
            NSString * lng = [pinItem objectForKey:@"lng"];
            
            float fpos_lat, fpos_lng;
            NSScanner *strPos = [NSScanner scannerWithString:lat];
            [strPos scanFloat:&fpos_lat];
            strPos = [NSScanner scannerWithString:lng];
            [strPos scanFloat:&fpos_lng];
            
            CLLocationCoordinate2D userLoc = [UserLocationManager sharedInstance].currentLocation.coordinate;
            float distance = DistanceBetweenCoords(userLoc.latitude, userLoc.longitude, fpos_lat, fpos_lng);
            
            [pinItem setObject:[NSNumber numberWithFloat:distance] forKey:@"distance"];

            
            [m_arrPinsAroundUser addObject:pinItem];
        }
    }
    
    [self setListMap];
}



- (void)showNotifyPinsForUser
{
        int _radius = [Notification getDistance];
        
        NSMutableArray * arrayAll = [Notification getCategory];
        
        NSString *urlString = [Utils getPinForRealUser:arrayAll : _radius];
        [[UserRoundPin pool] start:urlString];
        
        while (![UserRoundPin pool].isGotAllPin) {
            [NSThread sleepForTimeInterval:0.01];
        }
        
        NSMutableArray *allPins = [UserRoundPin pool].allPinListForUser;

        
        if (allPins != nil) {
            for (NSDictionary * dic in allPins) {
                NSMutableDictionary * newDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
                
                NSString * lat = [dic objectForKey:@"lat"];
                NSString * lng = [dic objectForKey:@"lng"];
                
                float fpos_lat, fpos_lng;
                NSScanner *strPos = [NSScanner scannerWithString:lat];
                [strPos scanFloat:&fpos_lat];
                strPos = [NSScanner scannerWithString:lng];
                [strPos scanFloat:&fpos_lng];
                
                CLLocationCoordinate2D userLoc = [UserLocationManager sharedInstance].currentLocation.coordinate;
                float distance = DistanceBetweenCoords(userLoc.latitude, userLoc.longitude, fpos_lat, fpos_lng);
                
                [newDic setObject:[NSNumber numberWithFloat:distance] forKey:@"distance"];
                
                
                [m_arrPinsAroundUser addObject:newDic];
            }
        }
        
        m_bList = NO;
        [self setListMap];
        
}

- (void) ShowUserPins {
        
//        NSArray *prevPins = m_mapView.annotations;
//        [m_mapView removeAnnotations:prevPins];
    for (id <MKAnnotation> annotation in m_mapView.annotations)
    {
        if (![annotation isKindOfClass:[MKUserLocation class]])
        {
            [m_mapView removeAnnotation:annotation];
        }
        
    }
    
        //        [Share getInstance].arrayMyPin = nil;
        
        [[UserPins pool] start];
        
        while (![UserPins pool].isGotAllPin) {
            [NSThread sleepForTimeInterval:0.01];
        }
        
        
        
        NSMutableArray *allPins = [UserPins pool].allPinListForUser;
        
        for (NSDictionary * dic in allPins) {
            NSMutableDictionary * newDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
            
            NSString * lat = [dic objectForKey:@"lat"];
            NSString * lng = [dic objectForKey:@"lng"];
            
            float fpos_lat, fpos_lng;
            NSScanner *strPos = [NSScanner scannerWithString:lat];
            [strPos scanFloat:&fpos_lat];
            strPos = [NSScanner scannerWithString:lng];
            [strPos scanFloat:&fpos_lng];
            
            CLLocationCoordinate2D userLoc = [UserLocationManager sharedInstance].currentLocation.coordinate;
            float distance = DistanceBetweenCoords(userLoc.latitude, userLoc.longitude, fpos_lat, fpos_lng);
            
            [newDic setObject:[NSNumber numberWithFloat:distance] forKey:@"distance"];
            
            
            [m_arrPinsAroundUser addObject:newDic];
        }
        
    [self setListMap];
}


-(void) setListView {
    [m_viewMap removeFromSuperview];
    [m_viewMain addSubview:m_viewList];
    [m_btnList removeFromSuperview];
    [m_viewBtn addSubview:m_btnMap];
    
    lbLocation.text = self.m_userLocation; //[[UserLocationManager sharedInstance] getStandardUserLocationAddress];
    [tvListCategory reloadData];
}
-(void) setMapView {
    [m_viewMap removeFromSuperview];
    [m_viewList removeFromSuperview];
    
    [m_viewMain addSubview:m_viewMap];
    [m_btnMap removeFromSuperview];
    [m_viewBtn addSubview:m_btnList];
    
    
//    NSArray *prevPins = m_mapView.annotations;
//    [m_mapView removeAnnotations:prevPins];
    for (id <MKAnnotation> annotation in m_mapView.annotations)
    {
        if (![annotation isKindOfClass:[MKUserLocation class]])
        {
            [m_mapView removeAnnotation:annotation];
        }
        
    }
    m_mapView.delegate = self;
    
    [self performSelectorOnMainThread:@selector(addAllPinsForUser) withObject:nil waitUntilDone:NO];
}



#pragma mark
#pragma mark ---- Set map 
- (void) addAllPinsForUser
{
    int nCount = 1;
    for (NSMutableDictionary *pinItem in m_arrPinsAroundUser) {
        PinAnnotation *pin = [[PinAnnotation alloc] initWithPinInfo:pinItem];
        pin.pinIndex = nCount;
        [m_mapView addAnnotation:pin];
        
        nCount ++;
    }
    
    [self addUserLocation];
    
    
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
        
        NSLog(@"lat = %f, lng = %f", item.coordinate.latitude, item.coordinate.longitude);
        
        
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
    
    if (m_bIsMyLocation)
	{
        m_bIsMyLocation = NO;
        topLeftCoord = bottomRightCoord = [UserLocationManager sharedInstance].currentLocation.coordinate;
        
//		topLeftCoord.latitude = fmin(topLeftCoord.latitude, [UserLocationManager sharedInstance].latestLocation.coordinate.latitude);
//		topLeftCoord.longitude = fmax(topLeftCoord.longitude, [UserLocationManager sharedInstance].latestLocation.coordinate.longitude);
//		
//		bottomRightCoord.latitude = fmax(bottomRightCoord.latitude, [UserLocationManager sharedInstance].latestLocation.coordinate.latitude);
//		bottomRightCoord.longitude = fmin(bottomRightCoord.longitude, [UserLocationManager sharedInstance].latestLocation.coordinate.longitude);
        
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
    
    
    m_prevRegion = region;
}




#pragma mark ----------------
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (m_bList)
        return;
    
    if (self.m_nSearchMode != CATEGORY_MODE)
        return;

    
    MKCoordinateRegion curRegion = mapView.region;

    if ( (curRegion.span.latitudeDelta > m_prevRegion.span.latitudeDelta
        || curRegion.span.longitudeDelta > m_prevRegion.span.longitudeDelta)
        && (fabsl(curRegion.span.latitudeDelta - m_prevRegion.span.latitudeDelta) > 0.01
        || fabsl(curRegion.span.longitudeDelta - m_prevRegion.span.longitudeDelta) > 0.01)) {

        if (!isLoading) {
            m_bUpdated = YES;
            [self refreshMap];
        }
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
        MKPinAnnotationView *pinView ; //= (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];

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
                    categoryItem = [[NSDictionary alloc] initWithDictionary:item];
                    break;
                }
            }
            
            
            if (categoryItem != nil) {
                UIImage *pinImage = [Share getCategoryImageName:[categoryItem objectForKey:@"name"]];//[categoryItem objectForKey:@"iconData"];
                if (pinImage == nil) {
                    NSLog(@"icon image no set =======");
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
                rightButton.tag = pinAnnotation.pinIndex;
//                rightButton.tag = [m_mapView.annotations indexOfObject:annotation];
                NSLog(@"rightbutton.tag = %d", rightButton.tag);
                
                [rightButton addTarget:self action:@selector(showDetails:) forControlEvents:UIControlEventTouchUpInside];
                annotationView.rightCalloutAccessoryView = rightButton;
                
                [annotationView addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:@"ANSELECTED"];
                
                return annotationView;
                
            } else {
                
                NSString * userName = [pinAnnotation.pinInfo objectForKey:@"pinType"];
                if ([userName isEqualToString:@"user"]) { // user location
                    [annotationView setImage:[UIImage imageNamed:@"userpin"]];

                    return annotationView;
                }
                else { // drop pin
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
            
            
        }
        
        return pinView;
    }
    
    return nil;
}



- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {

	if (oldState == MKAnnotationViewDragStateDragging) {
		PinAnnotation *annotation = (PinAnnotation *)annotationView.annotation;

		NSMutableDictionary * _pinInfo = [self changePinInfo:annotation.coordinate.latitude :annotation.coordinate.longitude];

        annotation.pinInfo = _pinInfo;
        
        annotation.subtitle = [_pinInfo objectForKey:@"full_address"];
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
        if (pin.pinIndex == sender.tag) {
            pinAnnot = pin;
            break;
        }
    }

    m_bGoDetail = YES;

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


#pragma mark ------------- Drop pins ---------
- (NSMutableDictionary*) changePinInfo : (CLLocationDegrees) latitude : (CLLocationDegrees) longitude {
    
    NSMutableDictionary * pinItem = [[NSMutableDictionary alloc] init];
    
    [pinItem setObject:[NSString stringWithFormat:@"%f", latitude] forKey:@"lat"];
    [pinItem setObject:[NSString stringWithFormat:@"%f", longitude] forKey:@"lng"];
    
    
    [pinItem setObject:@"-1" forKey:@"category_id"];
    [pinItem setObject:@"Customize your new pin" forKey:@"title"];

    // get Address from location

    NSDictionary * addressDetail = [GeoLocation getAddressDetail:latitude longitude:longitude];
    if (addressDetail != nil) {
        [pinItem setObject:[addressDetail objectForKey:@"full_address"] forKey:@"full_address"];
        
        [pinItem setObject:[addressDetail objectForKey:@"city"] forKey:@"city"];
        [pinItem setObject:[addressDetail objectForKey:@"state"] forKey:@"state"];
        [pinItem setObject:[addressDetail objectForKey:@"country"] forKey:@"country"];
        [pinItem setObject:[addressDetail objectForKey:@"address"] forKey:@"address"];
    }
    else {
        [pinItem setObject:@"location is fail" forKey:@"full_address"];
    }
    
    return pinItem;
    
}


- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:m_mapView];   
    CLLocationCoordinate2D touchMapCoordinate = [m_mapView convertPoint:touchPoint toCoordinateFromView:m_mapView];
    
    
    NSMutableDictionary * _pinInfo = [self changePinInfo:touchMapCoordinate.latitude :touchMapCoordinate.longitude];
    
    PinAnnotation * annotation = [[PinAnnotation alloc] initWithPinInfo:_pinInfo];

    [m_mapView addAnnotation:annotation];	
        
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
            
//            [itemMyLocation setImage:[UIImage imageNamed:@"btn_myLoc"]];

            UILabel * lbLocationInfo = (UILabel*) [self.view viewWithTag:198];
            if (lbLocationInfo != nil) {
                [lbLocationInfo removeFromSuperview];
                
                m_bIsMyLocation = NO;
            }
        }
        
        return;
    }
    
}

- (void)handleMove1:(UIGestureRecognizer *)gestureRecognizer {
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        return;
    }

    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        [self showSubCategoryList];
        
        return;
    }
}

-(void) showSubCategoryList{
    NSArray * views = [[NSBundle mainBundle] loadNibNamed:@"SubCategoryList" owner:self options:nil];
    m_viewSubCategoryList = (SubCategoryList*) [views objectAtIndex:0];
    m_viewSubCategoryList.delegate = self;
    [m_viewSubCategoryList setInterface];
    m_viewSubCategoryList.frame = CGRectMake(0, -m_viewSubCategoryList.frame.size.height, m_viewSubCategoryList.frame.size.width, self.view.frame.size.height);
    
    [self.view addSubview:m_viewSubCategoryList];
    
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.4f];
    [UIView setAnimationDelegate:self];
//    [UIView setAnimationDidStopSelector:@selector(didStopShowAdvancedView)];
    
    m_viewSubCategoryList.frame = CGRectMake(0, 0, m_viewSubCategoryList.frame.size.width, self.view.frame.size.height-44);
    
    [UIView commitAnimations];
}
-(void) hideSubCategoryList{
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.4f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(didStopHideSubCategoryList)];
    
    m_viewSubCategoryList.frame = CGRectMake(0, -m_viewSubCategoryList.frame.size.height, m_viewSubCategoryList.frame.size.width, m_viewSubCategoryList.frame.size.height);
    
    [UIView commitAnimations];
    
}
-(void) didStopHideSubCategoryList{
    [m_viewSubCategoryList removeFromSuperview];
}

- (void) selectCategory
{
    [self hideSubCategoryList];
    
    [self.arrSelectedCategory removeAllObjects];
    [self.arrSelectedCategory addObjectsFromArray:[FilterSearch getCategory]];
    
    m_bUpdated = YES;
    
    currPage = 0;
    [m_arrPinsAroundUser removeAllObjects];
    
    self.m_nSearchMode = CATEGORY_MODE;
    
    [self refreshMap];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {   
    return YES;
}


#pragma mark ---------- button Events ------
- (IBAction)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onToggle:(id)sender{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:NO];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:m_viewMain cache:YES];

    
    UILabel * lbLocationInfo = (UILabel*) [self.view viewWithTag:198];
    if (lbLocationInfo != nil)
        [lbLocationInfo removeFromSuperview];
    m_bIsMyLocation = NO;
    
    if (!m_bList) {
        [m_viewMap removeFromSuperview];
        m_viewList.frame = CGRectMake(0, 0, m_viewMain.frame.size.width, m_viewMain.frame.size.height - 44);
        [m_viewMain addSubview:m_viewList];

        [self setListView];
    } else {
        [m_viewList removeFromSuperview];
        m_viewMap.frame = CGRectMake(0, 0, m_viewMain.frame.size.width, m_viewMain.frame.size.height - 44);
        [m_viewMain addSubview:m_viewMap];
        
        [self setMapView];
    }
    [UIView commitAnimations];

    
    //////////////////
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:NO];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:m_viewBtn cache:YES];
    
    if (!m_bList) {
        [m_btnList removeFromSuperview];
        [m_viewBtn addSubview:m_btnMap];
    } else {
        [m_btnMap removeFromSuperview];
        [m_viewBtn addSubview:m_btnList];
    }
    [UIView commitAnimations];

    m_bList = !m_bList;

}

- (IBAction)onClickUserLocation:(id)sender{
    
    m_bIsMyLocation = YES;
//    [itemMyLocation setImage:[UIImage imageNamed:@"btn_myLoc_sel"]];
    
//    m_mapView.showsUserLocation = YES;
    
    [self fitToPinsRegion];
    
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

- (void) addUserLocation 
{
    [m_mapView setShowsUserLocation:YES];

/*
    NSMutableDictionary * userPin = [[NSMutableDictionary alloc] init];
    
    [userPin setObject:[NSString stringWithFormat:@"%f", [UserLocationManager sharedInstance].currentLocation.coordinate.latitude] forKey:@"lat"];
    [userPin setObject:[NSString stringWithFormat:@"%f", [UserLocationManager sharedInstance].currentLocation.coordinate.longitude] forKey:@"lng"];

    [userPin setObject:@"user" forKey:@"pinType"];
    
    [userPin setObject:@"-1" forKey:@"category_id"];
    [userPin setObject:@"Current Location" forKey:@"title"];
    
    PinAnnotation * annotation = [[PinAnnotation alloc] initWithPinInfo:userPin];
    annotation.pinIndex = 0;
    
    [m_mapView addAnnotation:annotation];
*/ 
}
    


#pragma mark --------- Search --------

#pragma mark ----------------------
- (void) showSearchBar 
{
    if (m_bShowSearchBar) {
        return;
    }

    m_viewSubSearchBar.frame = CGRectMake(0, -searchFld.frame.size.height, m_viewSubSearchBar.frame.size.width, m_viewSubSearchBar.frame.size.height);
    [m_viewSubDark setHidden:YES];
    [m_viewMap addSubview:m_viewSubSearchBar];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.4f];
    
    m_viewSubSearchBar.frame = CGRectMake(0, 0, m_viewSubSearchBar.frame.size.width, m_viewSubSearchBar.frame.size.height);
    
    viewUserLocation.frame = CGRectMake(viewUserLocation.frame.origin.x, 14 + searchFld.frame.size.height,
                                      viewUserLocation.frame.size.width, viewUserLocation.frame.size.height);
    [UIView commitAnimations];
    
    m_bShowSearchBar = YES;
    
    searchFld.text = @"";
    [searchFld becomeFirstResponder];
    
}
- (void) hideSearchBar
{
    if (!m_bShowSearchBar || m_viewSubSearchBar == nil) {
        return;
    }
    
    [m_viewSubDark setHidden:YES];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.4f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(didStophideSearchBar)];
    
    m_viewSubSearchBar.frame = CGRectMake(0, -m_viewSubSearchBar.frame.size.height, m_viewSubSearchBar.frame.size.width, m_viewSubSearchBar.frame.size.height);
    viewUserLocation.frame = CGRectMake(viewUserLocation.frame.origin.x, 14,
                                        viewUserLocation.frame.size.width, viewUserLocation.frame.size.height);
    
    [UIView commitAnimations];
}

- (void) didStophideSearchBar {
    m_bShowSearchBar = NO;
    
    [m_viewSubSearchBar removeFromSuperview];
}

- (IBAction)onShowSearchBar:(id)sender
{
    if (!m_bShowSearchBar) {
        [self showSearchBar];
    }
    else {
        [self hideSearchBar];
    }
}

#pragma mark ----------------------
- (void) showAdvancedView 
{
    if (m_bAdvanced) {
        return;
    }
    
    NSArray * views = [[NSBundle mainBundle] loadNibNamed:@"AdvancedSearchView" owner:self options:nil];
    viewSubOption = (AdvancedSearchView*) [views objectAtIndex:0];
    viewSubOption.delegate = self;
    [viewSubOption setInterface];
    viewSubOption.frame = CGRectMake(0, -viewSubOption.frame.size.height, viewSubOption.frame.size.width, viewSubOption.frame.size.height);
    [self.view addSubview:viewSubOption];
    
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.4f];
    
    viewSubOption.frame = CGRectMake(0, 0, viewSubOption.frame.size.width, viewSubOption.frame.size.height);
    m_viewMain.frame = CGRectMake(m_viewMain.frame.origin.x, viewSubOption.frame.size.height,
                                      m_viewMain.frame.size.width, m_viewMain.frame.size.height);
    [UIView commitAnimations];
    
    m_bAdvanced = YES;
    
}
- (void) hideAdvacedView
{
    if (!m_bAdvanced || viewSubOption == nil) {
        return;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.4f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(didStophideAdvancedView)];
    
    viewSubOption.frame = CGRectMake(0, -viewSubOption.frame.size.height, viewSubOption.frame.size.width, viewSubOption.frame.size.height);
    m_viewMain.frame = CGRectMake(m_viewMain.frame.origin.x, 44,
                                      m_viewMain.frame.size.width, m_viewMain.frame.size.height);
    [UIView commitAnimations];
}

- (void) didStophideAdvancedView {
    m_bAdvanced = NO;
    
    [viewSubOption removeFromSuperview];
    
}

- (IBAction)onSearchOption:(id)sender
{
    if (m_bAdvanced) 
        [self hideAdvacedView];
    else
        [self showAdvancedView];
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    
    [theSearchBar setShowsCancelButton:YES];
    [m_viewSubDark setHidden:NO];
    
/*
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.4f];
    
    [self showSearchAllView];
    
    [UIView commitAnimations];
*/
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{   
    searchBar.text = nil; 
    [searchBar resignFirstResponder];
    
    searchBar.showsCancelButton = NO;

    [self hideSearchBar];
    [self hideAdvacedView];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar                     // called when keyboard search button pressed
{
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];

    [self hideSearchBar];
    [self hideAdvacedView];

    [self searchPins : searchBar.text];
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
/*    
    FilterViewController * vc;
    
    if (iPad) {
        vc = [[FilterViewController alloc] initWithNibName:@"FilterViewController-ipad" bundle:nil];
    } else {
        vc = [[FilterViewController alloc] initWithNibName:@"FilterViewController" bundle:nil];
    }
    
    vc.delegate = self;
    vc.categoryList = self.categoryAry;
    
    //    [self.navigationController presentModalViewController:vc animated:YES];
    
    [self.navigationController pushViewController:vc animated:YES];
*/
}

- (void) searchPins :(NSString*) _search {

    if ([_search isEqualToString:@""]) {
        return;
    }
    
    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if (![appDelegate isSelectedAnySearch]) {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please select pin categories for search pin." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }

    
    NSMutableArray * arrPinPro = [NSMutableArray array];
    for (NSMutableDictionary * item in [FilterSearch getCategory]) {
        BOOL isSelected = [[item objectForKey:@"selected"] boolValue];

        if (isSelected) {
            [arrPinPro addObject:[item objectForKey:@"id"]];
        }
    }
    
    int timeOption = [FilterSearch getTimeOption];
    NSString *url = [Utils getSearchUrl:_search : arrPinPro : timeOption];
    
    JsonReader *jsonReader = [[JsonReader alloc] initWithUrl:url delegate:self];
    [jsonReader read];
}

- (void)didJsonReadFail
{
    [[[UIAlertView alloc] initWithTitle:@"" message:@"Oops! We seem to be experiencing a system overload. Please try again in a few minute." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}
- (void)didJsonRead:(id)result
{
    [self showPinsForSearch:result];
}

-(void) showPinsForSearch:(id) result{
//    NSArray *prevPins = m_mapView.annotations;
//    [m_mapView removeAnnotations:prevPins];
    for (id <MKAnnotation> annotation in m_mapView.annotations)
    {
        if (![annotation isKindOfClass:[MKUserLocation class]])
        {
            [m_mapView removeAnnotation:annotation];
        }
        
    }
    
    if (result == nil) {
        [self addUserLocation];
        [self fitToPinsRegion];

        [[[UIAlertView alloc] initWithTitle:nil message:@"There is no pins." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
//    NSLog(@"search result = %@", result);
    
    [[SHKActivityIndicator currentIndicator] displayActivity:@"Loading..." : self];
    
    
    NSDictionary *forCategory = [result objectForKey:@"categories"];
    NSArray *pinForCategory = [forCategory allValues];
    
    for (NSDictionary *categoryItem in pinForCategory) {
        NSArray *pins = [categoryItem objectForKey:@"pins"];
        
//        NSLog(@"Pins = %@", pins);
/*
        for (NSDictionary *pinItem in pins) {
            NSMutableDictionary *pinArchive = [NSMutableDictionary dictionaryWithDictionary:pinItem];
            
            NSString* strFull = [pinArchive objectForKey:@"full_address"];
            if (strFull == nil || strFull.length < 1) {
                strFull = [NSString stringWithFormat:@"%@ %@ %@", [pinArchive objectForKey:@"address"], [pinArchive objectForKey:@"city"], [pinArchive objectForKey:@"country"]];
                
                [pinArchive setObject:strFull forKey:@"full_address"];
            }

            [arrSearchPins addObject:pinArchive];
        }
*/
        [m_arrPinsAroundUser removeAllObjects];
        for (NSDictionary * dic in pins) {
            NSMutableDictionary * newDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
            
            NSString * lat = [dic objectForKey:@"lat"];
            NSString * lng = [dic objectForKey:@"lng"];
            
            float fpos_lat, fpos_lng;
            NSScanner *strPos = [NSScanner scannerWithString:lat];
            [strPos scanFloat:&fpos_lat];
            strPos = [NSScanner scannerWithString:lng];
            [strPos scanFloat:&fpos_lng];
            
            CLLocationCoordinate2D userLoc = [UserLocationManager sharedInstance].currentLocation.coordinate;
            float distance = DistanceBetweenCoords(userLoc.latitude, userLoc.longitude, fpos_lat, fpos_lng);
            
            [newDic setObject:[NSNumber numberWithFloat:distance] forKey:@"distance"];
            
            
            [m_arrPinsAroundUser addObject:newDic];
        }

    }
    
//    NSLog(@"arrSearchPins= %@", arrSearchPins);
    
    if (m_bList) {
        [self setListView];
    } else {
        [self setMapView];
    }

/*
    int nCount = 1;
    for (NSMutableDictionary *pinItem in m_arrPinsAroundUser) {
        PinAnnotation *pin = [[PinAnnotation alloc] initWithPinInfo:pinItem];
        pin.pinIndex = nCount;
        [m_mapView addAnnotation:pin];
        
        nCount ++;
    }
    
    [self addUserLocation];
    
    [self fitToPinsRegion];
*/
    
    [[SHKActivityIndicator currentIndicator] hide];

}

- (void) setFilter:(NSString *)_country :(NSString *)_city {
    str_Search_city = _city;
    str_Search_country = _country;
    
}




#pragma mark --------- SettingView Delegate ----------
- (void) closeForUpdate{
    m_bUpdated = YES;
}



#pragma mark ---------- PinDetail Delegate -----------
-(void) closeDeletePin{
    m_bUpdated = YES;
}
/*
- (void) closeDirectFromHere:(NSMutableDictionary *)_info {
    [self DirectFromHere:_info];
}

- (void) closeDirectToHere:(NSMutableDictionary *)_info {
    [self DirectToHere:_info];
}
*/


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark ---------------
#pragma mark --- List View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int size = [m_arrPinsAroundUser count];
//    if (size != 0) {
//        return size + 1;
//    }
    return size;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PinInfoCellIdentifier";
    
    PinInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil) {
        UIViewController    *viewController = [[UIViewController alloc] initWithNibName:@"PinInfoCell" bundle:nil];
        cell =(PinInfoCell*) viewController.view;
    }

    if (indexPath.row < [m_arrPinsAroundUser count]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        cell.pinImg.hidden = NO;
        cell.pinTitle.hidden = NO;
        cell.pinAddress.hidden = NO;
        cell.pinDistance.hidden = NO;

        NSMutableDictionary * pinInfo = [m_arrPinsAroundUser objectAtIndex:indexPath.row];
        
        NSString *imageUrl = [pinInfo objectForKey:@"image"];
        [cell.pinImg loadFromURL:[NSURL URLWithString:imageUrl]];
        cell.pinImg.contentMode = UIViewContentModeScaleAspectFit;
        [cell.pinImg setClipsToBounds:YES];
        //    cell.strImgName = imageUrl;
        //    [NSThread detachNewThreadSelector:@selector(getListImage:) toTarget:self withObject:cell];
        
        cell.pinTitle.text = [pinInfo objectForKey:@"title"];
        cell.pinAddress.text = [pinInfo objectForKey:@"address"];
        
        //    NSLog(@"pin Info = %@", pinInfo);
        
        float distance = [[pinInfo objectForKey:@"distance"] floatValue];
        
        if ([Setting getUnit] == 1) { //mile
            distance = distance * 1.609344;
            cell.pinDistance.text = [NSString stringWithFormat:@"Distance : %.1f Mile", distance];
        } else {
            cell.pinDistance.text = [NSString stringWithFormat:@"Distance : %.1f KM", distance];
        }
        
        //
        NSString * category_id = [pinInfo objectForKey:@"category_id"];
        [cell.categoryImg setImage:[Share getCategoryImageWithID:category_id]];
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;

        cell.pinImg.hidden = YES;
        cell.pinTitle.hidden = YES;
        cell.pinAddress.hidden = YES;
        cell.pinDistance.hidden = YES;
        
        cell.textLabel.text = @"Loading More...";
        cell.textLabel.textAlignment = UITextAlignmentCenter;
    }
    return cell;
}

- (void) getListImage:(PinInfoCell *)cell
{
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:cell.strImgName]];
    UIImage *iconImg = [UIImage imageWithData:imageData];
    if (iconImg) {
        [cell.pinImg setImage:iconImg];
    }        
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 118.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [m_arrPinsAroundUser count]){
        NSMutableDictionary * pinInfo = [m_arrPinsAroundUser objectAtIndex:indexPath.row];
        
        PinDetailController *detailCtlr;
        
        if (iPad) {
            detailCtlr = [[PinDetailController alloc] initWithNibName:@"PinDetailController-ipad" bundle:nil];
        } else {
            detailCtlr = [[PinDetailController alloc] initWithNibName:@"PinDetailController" bundle:nil];
        }
        
        detailCtlr.delegate = self;
        detailCtlr.pinInfo = pinInfo;
        [self.navigationController pushViewController:detailCtlr animated:YES];
    }
    else {
        m_bUpdated = YES;
        [self refreshMap];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSLog(@"row = %d", indexPath.row);
    
    if (!isLoading && indexPath.row == [m_arrPinsAroundUser count]) {
        NSLog(@"load more");
        
        m_bUpdated = YES;
        [self refreshMap];
    }
}
 */

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"row = %d", indexPath.row);
    
    if (!isLoading && indexPath.row >= [m_arrPinsAroundUser count] - 1 && [m_arrPinsAroundUser count] < self.m_nPinSize) {
        NSLog(@"load more");
        
        m_bUpdated = YES;
        [self refreshMap];
    }
}


- (void) setWithCategory 
{
    WithCategoryController * vc;
    
    if (iPad) {
        vc = [[WithCategoryController alloc] initWithNibName:@"WithCategoryController-ipad" bundle:nil];
    } else {
        vc = [[WithCategoryController alloc] initWithNibName:@"WithCategoryController" bundle:nil];
    }
    vc.m_nMode = MODE_SEARCH;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
