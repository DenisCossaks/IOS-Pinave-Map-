//
//  CreatePinViewController.m
//  NEP
//
//  Created by Gold Luo on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CreatePinViewController.h"
#import "IAMultipartRequestGenerator.h"
#import "AppDelegate.h"
#import "Setting.h"

#import "ASIFormDataRequest.h"

#import <CoreLocation/CoreLocation.h>

#define TAG_ALERT_ACTIVE_OK     1908
#define TAG_ALERT_ACTIVE_FAIL   1909


@interface CreatePinViewController ()

@end


@implementation CreatePinViewController

@synthesize pinInfo;

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
    
//    self.navigationItem.title = @"Create Pin";
    tfTitle.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    tfTitle.layer.cornerRadius = 5;
    tfTitle.layer.borderColor = [[UIColor blackColor] CGColor];
    tfTitle.layer.borderWidth = 1;
    
    tvDiscription.layer.cornerRadius = 5;
    tvDiscription.layer.borderColor = [[UIColor blackColor] CGColor];
    tvDiscription.layer.borderWidth = 1;

    
    UITapGestureRecognizer * lgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onUploadImage:)];
    lgr.delegate = self; 
    lgr.numberOfTapsRequired = 1;
    imgUpdate.userInteractionEnabled = YES;
    [imgUpdate addGestureRecognizer:lgr];
    
    lbFullAddress.text = [self.pinInfo objectForKey:@"full_address"];
    lbFullAddress.numberOfLines = 0;
    [lbFullAddress sizeToFit];
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    m_strAddress = [self.pinInfo objectForKey:@"address"];
    m_strCity = [self.pinInfo objectForKey:@"city"];
    m_strState = [self.pinInfo objectForKey:@"state"];
    m_strCountry = [self.pinInfo objectForKey:@"country"];

    m_nSimple = -1;
    
    m_nCategoryId = -1;
    m_nDays = 1;
    
    NSDate * cur_Date = [NSDate date];
    m_strStartDate = [NSString stringWithFormat:@"%@ %@", [Utils getDateString:cur_Date :DATE_DATE], @"00:00"];
    
    NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
    [dateComponents setDay:m_nDays - 1];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDate* end_date = [calendar dateByAddingComponents:dateComponents toDate:cur_Date options:0];
    m_strEndDate = [NSString stringWithFormat:@"%@ %@", [Utils getDateString:end_date :DATE_DATE], @"23:59"];
    
    m_strFrequency = @"One-Time Event";
    m_nRepet = 1;
    m_nEvery = 1;
    
    
    // place pin on small map
    PinAnnotation *pin = [[PinAnnotation alloc] initWithPinInfo: [[NSMutableDictionary alloc] initWithDictionary:self.pinInfo]];
    [m_mapPin addAnnotation:pin];
    
    [self performSelectorOnMainThread:@selector(fitToPinsRegion) withObject:nil waitUntilDone:NO];
    
}


#pragma ------------ map ---------
- (void)fitToPinsRegion
{
    if ([m_mapPin.annotations count] == 0) {
        return;
    }
    
    MKCoordinateRegion region;
    region.center =  CLLocationCoordinate2DMake([[self.pinInfo objectForKey:@"lat"] doubleValue], [[self.pinInfo objectForKey:@"lng"] doubleValue]);
    region.span.latitudeDelta = 0.005;
    region.span.longitudeDelta = 0.005;
    region = [m_mapPin regionThatFits:region];
    [m_mapPin setRegion:region animated:YES];
    
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
        
        static NSString *AnnotationIdentifier = @"AnnotationIdentifier";
//        MKPinAnnotationView *pinView; // = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
        
        
        MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                                              reuseIdentifier:AnnotationIdentifier];
        annotationView.canShowCallout = NO;
        annotationView.pinColor = MKPinAnnotationColorPurple;
        
        return annotationView;
    }
    
    return nil;
}

#pragma -------------------
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    UIView * viewTitle = (UIView*)[self.navigationController.navigationBar viewWithTag:290];
    if (viewTitle != nil) {
        [viewTitle removeFromSuperview];
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setTabBarHidden:YES animated:YES];

   
    [m_tableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    
}


#pragma mark ------   Update event --- 
- (void) onActivePin : (id) sender {
    
    if ([tfTitle.text isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:@"Alert!" message:@"Please input title" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }

    if ([tvDiscription.text isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:@"Alert!" message:@"Please input description" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    if (m_nSimple == -1) {
        [[[UIAlertView alloc] initWithTitle:@"Alert!" message:@"Please set schedule" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    if (m_nCategoryId == -1) {
        [[[UIAlertView alloc] initWithTitle:@"Alert!" message:@"Please choose category" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    if (m_strCity == nil || m_strCity.length < 1) {
        [[[UIAlertView alloc] initWithTitle:@"Alert!" message:@"Please input City name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    if (m_strCountry == nil || m_strCountry.length < 1) {
        [[[UIAlertView alloc] initWithTitle:@"Alert!" message:@"Please input Country name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
//    if (imgData == nil) {
//        return;
//    }

    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * userId = [defaults objectForKey:@"loginId"];
    NSString * userCode = [defaults objectForKey:@"loginCode"];
    
    NSString * lat = [self.pinInfo objectForKey:@"lat"];
    NSString * lng = [self.pinInfo objectForKey:@"lng"];
    
    int nCategory = m_nCategoryId;

    
    [[SHKActivityIndicator currentIndicator] displayActivity:@"Loading..." : self];

    ////////////////////////
    
    NSString *url = [Utils getPlacePinUrl];
    
    
/*    
    IAMultipartRequestGenerator *request = [[IAMultipartRequestGenerator alloc] initWithUrl:url andRequestMethod:@"POST"];

    [request setString:userCode forField:@"code"];
    NSLog(@"code = %@", userCode);
    
    [request setString:userId forField:@"user_id"];
    NSLog(@"user_id = %@", userId);
    
    [request setString:tfTitle.text forField:@"title"];
    NSLog(@"title = %@", tfTitle.text);

    
    NSString * _country = m_strCountry;//[NSString stringWithUTF8String:[m_strCountry UTF8String]];
    [request setString:_country forField:@"country"];
    NSLog(@"country = %@", _country);
    
    NSString * _state = m_strState; //[NSString stringWithUTF8String:[m_strState UTF8String]];
    [request setString:_state forField:@"state"];
    NSLog(@"state = %@", _state);
    
   
    NSString* _city = m_strCity; //[NSString stringWithUTF8String:[m_strCity UTF8String]];
    [request setString:_city forField:@"city"];
    NSLog(@"city = %@", _city);
    
    
    NSString* _address = m_strAddress; //[NSString stringWithUTF8String:[m_strAddress UTF8String]];
    [request setString:_address forField:@"address"];
    NSLog(@"address = %@", _address);

    
//    [request setString:tfPhone.text forField:@"phone"];
//    NSLog(@"phone = %@", tfPhone.text);

    [request setString:lat forField:@"lat"];
    NSLog(@"lat = %@", lat);
    [request setString:lng forField:@"lng"];
    NSLog(@"lng = %@", lng);
    
    [request setString:[NSString stringWithFormat:@"%d", nCategory] forField:@"category_id"];
    NSLog(@"category_id = %@", [NSString stringWithFormat:@"%d", nCategory]);
    
    
    [request setString:tvDiscription.text forField:@"description"];
    NSLog(@"description = %@", tvDiscription.text);
    
    NSString * timeZone = [Setting getTimezone];
    [request setString:timeZone forField:@"timezone"];
    NSLog(@"timezone = %@", timeZone);
    
 
    NSDate * start = [Utils dateFromString:m_strStartDate : DATE_FULL];
    NSString * start_date = [Utils getDateString:start : DATE_DATE];
    NSString * start_time = [Utils getDateString:start : DATE_TIME];
    
    NSDate * end = [Utils dateFromString:m_strEndDate : DATE_FULL];
    NSString * end_date = [Utils getDateString:end : DATE_DATE];
    NSString * end_time = [Utils getDateString:end : DATE_TIME];
    
    [request setString:start_date forField:@"start_date"];
    NSLog(@"start_date = %@", start_date);
    [request setString:start_time forField:@"start_time"];
    NSLog(@"start_time = %@", start_time);
    [request setString:end_date forField:@"end_date"];
    NSLog(@"end_date = %@", end_date);
    [request setString:end_time forField:@"end_time"];
    NSLog(@"end_time = %@", end_time);



    [request setString:[NSString stringWithFormat:@"%d", m_nSimple] forField:@"simple"];
    NSLog(@"simple = %d", m_nSimple);

    if (m_nSimple == 1) { //Simple
        
        [request setString:[NSString stringWithFormat:@"%d", m_nDays] forField:@"days_from_now"];
        NSLog(@"days_from_now = %d", m_nDays);

        [request setString:@"one" forField:@"type"];
        NSLog(@"type = one");
    } else {
        
        [request setString:m_strFrequency forField:@"type"];
        NSLog(@"type = %@", m_strFrequency);
        
        [request setString:[NSString stringWithFormat:@"%d", m_nRepet] forField:@"runs"];
        NSLog(@"runs = %d", m_nRepet);

        [request setString:[NSString stringWithFormat:@"%d", m_nEvery] forField:@"x"];
        NSLog(@"x = %d", m_nEvery);
    }
    
    
//    [request setString:[NSString stringWithFormat:@"%d", dtimeslots] forField:@"dtimeslots"];
//    NSLog(@"dtimeslots = %@", [NSString stringWithFormat:@"%d", dtimeslots]);

    if (imgData != nil) {
        [request setData:imgData forField:@"upload"];
    }
    

    [request setDelegate:self];
    [request startRequest];
*/
/*    
    @autoreleasepool {
        NSMutableURLRequest *uploadRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy: NSURLRequestReloadIgnoringLocalCacheData timeoutInterval: 30 ];
        [uploadRequest setHTTPMethod:@"POST"];
        
        //prepare data
        NSMutableData *postData = [NSMutableData data];

        NSString *boundary = [NSString stringWithString:@"-----------------99882746641449"];
        NSString *endItemBoundary = [NSString stringWithFormat:@"\r\n--%@\r\n",boundary];
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data;boundary=%@",boundary];
        [uploadRequest addValue:contentType forHTTPHeaderField:@"Content-Type"];
        [postData appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];

        if (imgData != nil) {
            [postData appendData:[[NSString stringWithString:@"Content-Disposition:form-data;name=\"userfile\";filename=\".jpg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [postData appendData:[[NSString stringWithString:@"Content-Type:application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [postData appendData:[NSData dataWithData:imgData]];
            
            //closing boundary for image
            [postData appendData:[[NSString stringWithFormat:@"%@",endItemBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        }

        //add additional data for textfields here
        [postData appendData:[self generateDataFromText:userCode fieldName:@"code"]];
        //end item boundary
        [postData appendData:[[NSString stringWithFormat:@"%@",endItemBoundary] dataUsingEncoding:NSUTF8StringEncoding]];

        //add additional data for textfields here
        [postData appendData:[self generateDataFromText:userId fieldName:@"user_id"]];
        //end item boundary
        [postData appendData:[[NSString stringWithFormat:@"%@",endItemBoundary] dataUsingEncoding:NSUTF8StringEncoding]];

        //add additional data for textfields here
        [postData appendData:[self generateDataFromText:tfTitle.text fieldName:@"title"]];
        //end item boundary
        [postData appendData:[[NSString stringWithFormat:@"%@",endItemBoundary] dataUsingEncoding:NSUTF8StringEncoding]];

        //add additional data for textfields here
        [postData appendData:[self generateDataFromText:m_strCountry fieldName:@"country"]];
        //end item boundary
        [postData appendData:[[NSString stringWithFormat:@"%@",endItemBoundary] dataUsingEncoding:NSUTF8StringEncoding]];

        //add additional data for textfields here
        [postData appendData:[self generateDataFromText:m_strState fieldName:@"state"]];
        //end item boundary
        [postData appendData:[[NSString stringWithFormat:@"%@",endItemBoundary] dataUsingEncoding:NSUTF8StringEncoding]];

        //add additional data for textfields here
        [postData appendData:[self generateDataFromText:m_strCity fieldName:@"city"]];
        //end item boundary
        [postData appendData:[[NSString stringWithFormat:@"%@",endItemBoundary] dataUsingEncoding:NSUTF8StringEncoding]];

        //add additional data for textfields here
        [postData appendData:[self generateDataFromText:m_strAddress fieldName:@"address"]];
        //end item boundary
        [postData appendData:[[NSString stringWithFormat:@"%@",endItemBoundary] dataUsingEncoding:NSUTF8StringEncoding]];

        
        //add additional data for textfields here
        [postData appendData:[self generateDataFromText:lat fieldName:@"lat"]];
        //end item boundary
        [postData appendData:[[NSString stringWithFormat:@"%@",endItemBoundary] dataUsingEncoding:NSUTF8StringEncoding]];

        //add additional data for textfields here
        [postData appendData:[self generateDataFromText:lng fieldName:@"lng"]];
        //end item boundary
        [postData appendData:[[NSString stringWithFormat:@"%@",endItemBoundary] dataUsingEncoding:NSUTF8StringEncoding]];


        //add additional data for textfields here
        [postData appendData:[self generateDataFromText:[NSString stringWithFormat:@"%d", nCategory] fieldName:@"category_id"]];
        //end item boundary
        [postData appendData:[[NSString stringWithFormat:@"%@",endItemBoundary] dataUsingEncoding:NSUTF8StringEncoding]];

        //add additional data for textfields here
        [postData appendData:[self generateDataFromText:tvDiscription.text fieldName:@"description"]];
        //end item boundary
        [postData appendData:[[NSString stringWithFormat:@"%@",endItemBoundary] dataUsingEncoding:NSUTF8StringEncoding]];

        //add additional data for textfields here
        [postData appendData:[self generateDataFromText:[Setting getTimezone] fieldName:@"timezone"]];
        //end item boundary
        [postData appendData:[[NSString stringWithFormat:@"%@",endItemBoundary] dataUsingEncoding:NSUTF8StringEncoding]];

        
        
        [uploadRequest setHTTPBody: postData];
        
        NSData *_responseData = [NSURLConnection sendSynchronousRequest:uploadRequest returningResponse:nil error:nil];
        
        NSString *_returnString = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
        NSLog(@"result = %@", _returnString);
    }
*/
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString: url]];
    request.requestMethod = @"POST";
    
    [request setPostValue:userCode forKey:@"code"];
    NSLog(@"code = %@", userCode);
    [request setPostValue:userId forKey:@"user_id"];
    NSLog(@"user_id = %@", userId);
    [request setPostValue:tfTitle.text forKey:@"title"];
    NSLog(@"title = %@", tfTitle.text);
    [request setPostValue:tvDiscription.text forKey:@"description"];
    NSLog(@"description = %@", tvDiscription.text);

    [request setPostValue:m_strCountry forKey:@"country"];
    NSLog(@"country = %@", m_strCountry);
    [request setPostValue:m_strState forKey:@"state"];
    NSLog(@"state = %@", m_strState);
    [request setPostValue:m_strCity forKey:@"city"];
    NSLog(@"city = %@", m_strCity);
    [request setPostValue:m_strAddress forKey:@"address"];
    NSLog(@"address = %@", m_strAddress);
    
    [request setPostValue:lat forKey:@"lat"];
    NSLog(@"lat = %@", lat);
    [request setPostValue:lng forKey:@"lng"];
    NSLog(@"lng = %@", lng);
    
    [request setPostValue:[NSString stringWithFormat:@"%d", nCategory] forKey:@"category_id"];
    NSLog(@"category_id = %d", nCategory);
    
    NSString * timeZone = [Setting getTimezone];
    [request setPostValue:timeZone forKey:@"timezone"];
    NSLog(@"timezone = %@", timeZone);
    
    
    if (m_nSimple == 1) { //Simple
        [request setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"simple"];
        NSLog(@"simple = %d", m_nSimple);

        [request setPostValue:[NSString stringWithFormat:@"%d", m_nDays] forKey:@"days_from_now"];
        NSLog(@"days_from_now = %d", m_nDays);
        [request setPostValue:@"one" forKey:@"type"];
        NSLog(@"type = one");
    } else {
        [request setPostValue:[NSString stringWithFormat:@"%d", 0] forKey:@"simple"];
        NSLog(@"simple = %d", m_nSimple);

        NSDate * start = [Utils dateFromString:m_strStartDate : DATE_FULL];
        NSString * start_date = [Utils getDateString:start : DATE_DATE];
        NSString * start_time = [Utils getDateString:start : DATE_TIME];
        
        NSDate * end = [Utils dateFromString:m_strEndDate : DATE_FULL];
        NSString * end_date = [Utils getDateString:end : DATE_DATE];
        NSString * end_time = [Utils getDateString:end : DATE_TIME];

        [request setPostValue:start_date forKey:@"start_date"];
        NSLog(@"start_date = %@", start_date);
        [request setPostValue:start_time forKey:@"start_time"];
        NSLog(@"start_time = %@", start_time);
        [request setPostValue:end_date forKey:@"end_date"];
        NSLog(@"end_date = %@", end_date);
        [request setPostValue:end_time forKey:@"end_time"];
        NSLog(@"end_time = %@", end_time);

        
        
        [request setPostValue:m_strFrequency forKey:@"type"];
        NSLog(@"type = %@", m_strFrequency);
        [request setPostValue:[NSString stringWithFormat:@"%d", m_nRepet] forKey:@"runs"];
        NSLog(@"runs = %d", m_nRepet);
        [request setPostValue:[NSString stringWithFormat:@"%d", m_nEvery] forKey:@"x"];
        NSLog(@"x = %d", m_nEvery);
    }
    
    
    if (imgData != nil) {
        [request setData:imgData withFileName:@"aaa" andContentType:@"image/jpeg" forKey:@"upload"];
    }
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(uploadRequestFinished:)];
    [request setDidFailSelector:@selector(uploadRequestFailed:)];
    
    [request startAsynchronous];
    
    
}

- (void)uploadRequestFinished:(ASIHTTPRequest *)request{    
    
    [[SHKActivityIndicator currentIndicator] hide];

    NSString *responseString = [request responseString];
    NSLog(@"Upload response %@", responseString);
    if ([responseString rangeOfString:@"message"].location != NSNotFound && [responseString rangeOfString:@"added"].location != NSNotFound) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Activated!" message:@"We have broadcasted your pin." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alert.tag = TAG_ALERT_ACTIVE_OK;
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"We are currently experiencing issues accessing our server. Please try again later." delegate:self cancelButtonTitle:@"Report this issue"
                          otherButtonTitles:@"Cancel", nil];
        alert.tag = TAG_ALERT_ACTIVE_FAIL;
        [alert show];
    }
}

- (void)uploadRequestFailed:(ASIHTTPRequest *)request{

    [[SHKActivityIndicator currentIndicator] hide];

    NSLog(@" Error - Statistics file upload failed: \"%@\"",[[request error] localizedDescription]); 
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"There seems to be an issue placing pins at present" delegate:self 
                      cancelButtonTitle:@"Shoot programmer" 
                      otherButtonTitles:@"Cancel", nil];
    alert.tag = TAG_ALERT_ACTIVE_FAIL;
    [alert show];
}

- (void) gotoInExplore
{
    [self.navigationController popViewControllerAnimated:NO];
    
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setTabbarIndex:0];
    
    [[SHKActivityIndicator currentIndicator] displayActivity:@"Loading..." : self];
    
    

}

- (void) onReportEmail
{
    if(![MFMailComposeViewController canSendMail]){
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please configure your mail settings to send email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
		return;
	}

    
	MFMailComposeViewController* mc = [[MFMailComposeViewController alloc] init];
	mc.mailComposeDelegate = self;
    
    NSString *subject = @"Facebook on Place pin";
	[mc setSubject:subject];	
    
    NSMutableArray * arrEmails = [[NSMutableArray alloc] initWithCapacity:5];
    NSString * emailAdd = @"feedback@pinave.com";
    [arrEmails addObject:emailAdd];
	[mc setToRecipients:arrEmails];	
    

    NSString* tpl = [Utils stringFromFileNamed:@"email_error.html"];
    NSString *first_name = [[Share getInstance].dicUserInfo objectForKey:@"firstname"];
    NSString *last_name = [[Share getInstance].dicUserInfo objectForKey:@"lastname"];;
    NSString * strCurDate = [Utils getDateString:[NSDate date] :DATE_FULL];
    NSString * strCity = m_strCity;
    NSString * strCountry = m_strCountry;
    
	NSString* body = [NSString stringWithFormat:tpl, first_name, last_name, strCurDate, strCity, strCountry];
	[mc setMessageBody:body isHTML:YES];	
    
	[self presentModalViewController:mc animated:YES];

}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
	switch (result) {
		case MFMailComposeResultSent:	{
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Email sent" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alert.tag = TAG_ALERT_ACTIVE_OK;
            [alert show];
        }
			break;
		default:
			break;
	}
	[self dismissModalViewControllerAnimated:YES];	
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_ALERT_ACTIVE_OK) {
        if (buttonIndex == 0) {
            [self gotoInExplore];
        }
    }
    
    if (alertView.tag == TAG_ALERT_ACTIVE_FAIL) {
        if (buttonIndex == 0) {
            [self onReportEmail];
        }
    }
}




- (NSMutableData *)generateDataFromText:(NSString *)dataText fieldName:(NSString *)fieldName{
	NSString *post = [NSString stringWithFormat:@"-----------------99882746641449\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n", fieldName];
    //NSString *post = [NSString stringWithFormat:@"--AaB03x\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n", fieldName];
    // Get the post header int ASCII format:
    NSData *postHeaderData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    // Generate the mutable data variable:
    NSMutableData *postData = [[NSMutableData alloc] initWithLength:[postHeaderData length] ];
    [postData setData:postHeaderData];
    
	NSData *uploadData = [dataText dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	
    // Add the text:
    [postData appendData: uploadData];
    
    // Add the closing boundry:
    [postData appendData: [@"\r\n" dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
    //[postData appendData: [@"\r\n--AaB03x--" dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
    
    // Return the post data:
    return postData;
}


#pragma mark
#pragma mark IAMultipartRequestGenerator delegate methods

-(void)requestDidFailWithError:(NSError *)error 
{
    NSLog(@"IAMultipartRequestGenerator request failed");
    
    [[SHKActivityIndicator currentIndicator] hide];
    
    [[[UIAlertView alloc] initWithTitle:@"Fail!" message:@"Creating pin is fails" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];

}


-(void)requestDidFinishWithResponse:(NSData *)responseData 
{
    NSString *response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"IAMultipartRequestGenerator finished: %@", response);
    
    [[SHKActivityIndicator currentIndicator] hide];

    [[[UIAlertView alloc] initWithTitle:@"Success!" message:@"Creating pin success" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}


- (IBAction) onCancel:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) onUploadImage :(id) sender{

    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle: nil delegate: (id)self cancelButtonTitle: @"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"Use Camera", @"Choose from Library", nil];
    actionSheet.tag = 100;
    [actionSheet showInView: self.view];
}


#pragma mark -----------    -------

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 100) {
        if ( buttonIndex == 0 )
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ==  false)
            {
                return;
            }
            
            UIImagePickerController* picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.delegate = self;
            [self presentModalViewController: picker animated: YES];
        }
        else if ( buttonIndex == 1 )
        {
            
            if (iPad) {
                if ([popoverController isPopoverVisible]) {
                    [popoverController dismissPopoverAnimated:YES];
                    popoverController = nil;
                } else {
                    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeSavedPhotosAlbum])
                    {
                        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
//                        imagePicker.delegate = self;
                        imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                        imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeSavedPhotosAlbum];
                        
                        popoverController = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
                        
//                        [popoverController presentPopoverFromRect:btnUpdate.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
                        
                    }
                }
            }
            else {
                UIImagePickerController* picker = [[UIImagePickerController alloc] init];
                picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                picker.delegate = self;
                [self presentModalViewController: picker animated: YES];
            }
        }    
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)selectedImage editingInfo:(NSDictionary *)editingInfo 
{
#define MAX_WIDTH 640
#define MAX_HEIGHT 960
    
    int width = selectedImage.size.width;
    int height = selectedImage.size.height;
    NSLog(@"width = %d, height = %d", width, height);

    
    if (width > MAX_WIDTH) {
        selectedImage = [self resizedImage:selectedImage inSize:CGSizeMake(MAX_WIDTH, height * MAX_WIDTH/width)];
    }

    width = selectedImage.size.width;
    height = selectedImage.size.height;

    if (height > MAX_HEIGHT) {
        selectedImage = [self resizedImage:selectedImage inSize:CGSizeMake(width * MAX_HEIGHT/height, MAX_HEIGHT)];
    }

    NSLog(@"width = %d, height = %d", width, height);
    
//    [btnUpdate setImage:selectedImage forState:UIControlStateNormal];
    imgUpdate.image = selectedImage;
    
    imgData = [[NSData alloc] initWithData: UIImageJPEGRepresentation(selectedImage, 1.0)];

    
	if(m_popoverController != nil)
	{
		[m_popoverController dismissPopoverAnimated:YES];
		m_popoverController = nil;
	}
	else
	{
		[self dismissModalViewControllerAnimated:YES];
	}

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	if (iPad)
	{
		if(m_popoverController != nil) {
			[m_popoverController dismissPopoverAnimated:YES];
			m_popoverController = nil;
		}
	}
	else 
		[self dismissModalViewControllerAnimated:YES];
}

-(UIImage*) resizedImage:(UIImage*)inImage inSize:(CGSize) thumbSize
{
    CGFloat vRatio = inImage.size.height / thumbSize.height;
    CGFloat hRatio = inImage.size.width / thumbSize.width;
    CGFloat ratio = fmaxf(vRatio, hRatio);
    CGSize drawingSize = CGSizeMake(hRatio / ratio * thumbSize.width, vRatio/ratio*thumbSize.height);
    
    UIGraphicsBeginImageContext(thumbSize);
    [inImage drawInRect:CGRectMake((thumbSize.width - drawingSize.width) / 2.0, (thumbSize.height - drawingSize.height) / 2.0f, drawingSize.width, drawingSize.height)];

    return UIGraphicsGetImageFromCurrentImageContext();
}


- (IBAction) onNext{
    
}


- (IBAction) onDptDone:(id)sender{
    if ([tvDiscription isFirstResponder]) {
        [tvDiscription resignFirstResponder];
    }
    
    [btnDptDone setHidden:YES];
    [btnDptDone1 setHidden:YES];

}

-(void) onEdit {
    tfAddress.text = m_strAddress;
    tfCity.text = m_strCity;
    tfState.text = m_strState;
    tfCountry.text = m_strCountry;
    
    
    if (iPad) {
        UIViewController* popContent = [[UIViewController alloc] init];
        popContent.view.frame = CGRectMake(0, 0, viewEditAddress.frame.size.width, viewEditAddress.frame.size.height);
        
        [popContent.view addSubview: viewEditAddress];
        popContent.contentSizeForViewInPopover = CGSizeMake(viewEditAddress.frame.size.width, viewEditAddress.frame.size.height);
        
        popoverController = [[UIPopoverController alloc] initWithContentViewController: popContent];
        
//        [popoverController presentPopoverFromBarButtonItem:itemEdit permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
    } else {
        [self.view addSubview:viewEditAddress];
        viewEditAddress.frame = CGRectMake(0, -230, viewEditAddress.frame.size.width, viewEditAddress.frame.size.height);
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];

        viewEditAddress.frame = CGRectMake(0, 0, viewEditAddress.frame.size.width, viewEditAddress.frame.size.height);
        
        [UIView commitAnimations];
    }
    
    
}

- (IBAction) onClickedAddress:(id)sender
{
    [self onEdit];
}

- (IBAction) onEditCancel:(id) sender{
    if (viewEditAddress!= nil) {
        [viewEditAddress removeFromSuperview];
    }
    
}
- (IBAction) onEditSave:(id) sender{
    if (viewEditAddress != nil) {
        if (!iPad) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.3];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(endAnimationEdit)];

            viewEditAddress.frame = CGRectMake(0, -230, viewEditAddress.frame.size.width, viewEditAddress.frame.size.height);
            
            [UIView commitAnimations];
        }
        
        m_strAddress = tfAddress.text;
        m_strCountry = tfCountry.text;
        m_strState = tfState.text;
        m_strCity = tfCity.text;
        
        lbFullAddress.text = [NSString stringWithFormat:@"%@, %@, %@, %@", m_strAddress, m_strCity, m_strState, m_strCountry];
        lbFullAddress.numberOfLines = 0;
        [lbFullAddress sizeToFit];
    }
    
}
- (void) endAnimationEdit{

    [viewEditAddress removeFromSuperview];

}

- (IBAction) onPinSchedule{
/*
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle: nil delegate: self cancelButtonTitle: @"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"Show pin", @"Advanced Schedule", nil];
    actionSheet.tag = 101;
    [actionSheet showInView: self.view];
*/ 
    AdvancedScheduleViewController * vc;
    
    if (iPad) {
        vc = [[AdvancedScheduleViewController alloc] initWithNibName:@"AdvancedScheduleViewController-ipad" bundle:nil];
    } else {
        vc = [[AdvancedScheduleViewController alloc] initWithNibName:@"AdvancedScheduleViewController" bundle:nil];
    }
    
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
    
    [vc setInterface:m_nDays :m_strStartDate :m_strEndDate :m_strFrequency :m_nRepet :m_nEvery];

}


- (IBAction) onSelectCategory{
    SelectCategoryController * vc; 
    
    if (iPad) {
        vc = [[SelectCategoryController alloc] initWithNibName:@"SelectCategoryController-ipad" bundle:nil];
    } else {
        vc = [[SelectCategoryController alloc] initWithNibName:@"SelectCategoryController" bundle:nil];
    }

    vc.nCategoryId = m_nCategoryId;
    vc.delegate = self;

//    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.navigationController pushViewController:vc animated:YES];

}


#pragma -
#pragma mark --------- Table View -------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MenuCell";
    UIImageView * iconCategory;
    UILabel * lbCategory;
    
    UITableViewCell *cell ;//= [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
//        UIImageView * background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_back"]];
//        cell.backgroundView = background;
        
        iconCategory = (UIImageView*)[cell.contentView viewWithTag:9000 + indexPath.row];
        
        if(iconCategory == nil)
        {
            iconCategory = [[UIImageView alloc] initWithFrame:CGRectMake(10, 3, 35, 35)];
            iconCategory.tag = 9000 + indexPath.row;
            [cell.contentView addSubview:iconCategory];
        }
        
        lbCategory  = (UILabel*)[cell.contentView viewWithTag:10000 + indexPath.row];
        
        if(lbCategory == nil)
        {
            lbCategory = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 280, 44)];
            lbCategory.tag = 10000 + indexPath.row;
            lbCategory.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:lbCategory];
        }
        
    }

    if (indexPath.row == 0) {
        if (m_nCategoryId == -1) {
            iconCategory.image = [UIImage imageNamed:@"place_1"];
            lbCategory.text = @"Select Category";
        } else {
            NSDictionary *categoryItem = nil;
            for (NSMutableDictionary * dic in [Share getInstance].arrayCategory) {
                if (m_nCategoryId == [[dic objectForKey:@"id"] intValue]) {
                    categoryItem = dic;
                    break;
                }
            }
            
            if (categoryItem != nil) {
                iconCategory.image = [Share getCategoryImageName:[categoryItem objectForKey:@"name"]]; //[categoryItem objectForKey:@"iconData"];
                lbCategory.text = [categoryItem objectForKey:@"name"];
            }
        }
        
    } else if (indexPath.row == 1){
        iconCategory.image = [UIImage imageNamed:@"place_2"];

        if (m_nSimple == -1) {
            lbCategory.text = @"When?";
/*        } else if (m_nSimple == 1) { //simple
            if (m_nDays == 1) {
                lbCategory.text = [NSString stringWithFormat:@"%d day", m_nDays];    
            } else {
                lbCategory.text = [NSString stringWithFormat:@"%d days", m_nDays];    
            }*/
        } else {
            //initialize today's date and date formatter
            NSDate *start_date = [Utils dateFromString:m_strStartDate :DATE_FULL];
            NSDateFormatter *dateFormat= [[NSDateFormatter alloc] init];
            
            //get today's number
            [dateFormat setDateFormat:@"dd"];
            NSString *todayDay = [dateFormat stringFromDate:start_date];
            
            //get current month's name 
            [dateFormat setDateFormat:@"MMMM"];
            NSString *todayMonth = [dateFormat stringFromDate:start_date];
            
            NSString * str = [NSString stringWithFormat:@"%@ %@ - ++", todayDay, todayMonth];
            lbCategory.text = str;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.row == 0) {
        [self onSelectCategory];
    }
    else if (indexPath.row == 1) {
        [self onPinSchedule];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}




#pragma mark ----- textField delegate -----------
- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView
{
    [btnDptDone setHidden:NO];
    [btnDptDone1 setHidden:NO];
    
    return YES;
}

/*
-(void) keyboardDidShow: (NSNotification *)notif 
{
    if (keyboardVisible) 
	{
		return;
	}
	
	// Get the size of the keyboard.
	NSDictionary* info = [notif userInfo];
	NSValue* aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
	CGSize keyboardSize = [aValue CGRectValue].size;
	
    [self changeScrollview: keyboardSize : nil];
	
	// Keyboard is now visible
	keyboardVisible = YES;
}

-(void) keyboardDidHide: (NSNotification *)notif 
{
	// Is the keyboard already shown
	if (!keyboardVisible) 
	{
		return;
	}
	
    [self resetScrollview];
    
	// Keyboard is no longer visible
	keyboardVisible = NO;
    
}

- (void) changeScrollview : (CGSize) size : (id) control{
    
    // Resize the scroll view to make room for the keyboard
	CGRect viewFrame = self.view.bounds;
	originalFrame = viewFrame;
	viewFrame.size.height -= size.height;
	viewScroll.frame = viewFrame;
    offset = viewScroll.contentOffset;
    
    
    CGRect textFieldRect;
    
    if (control != nil) {
        textFieldRect = [control frame];
    }
    
	if ([tfTitle isFirstResponder])
		textFieldRect = [tfTitle frame];
    else if ([tvDiscription isFirstResponder]){
		textFieldRect = [tvDiscription frame];
        [btnDptDone setHidden:NO];
    }
    
    textFieldRect.origin.y += 10;
	[viewScroll scrollRectToVisible:textFieldRect animated:YES];
}

- (void) resetScrollview {
    // Reset the frame scroll view to its original value
	viewScroll.frame = originalFrame;
	
	// Reset the scrollview to previous location
	viewScroll.contentOffset = offset;
    
    [btnDptDone setHidden:YES];
}
*/


#pragma mark -------- Delegaet --------------

-(void) setCategoryID:(int)_selectId {
    m_nCategoryId = _selectId;
    
    [m_tableView reloadData];
}

-(void) setAdvancedSchedule:(int) _simple : (int) _days : (NSString *)_startDate :(NSString *)_endDate :(NSString *)_frequecy :(int)_repeat :(int)_every {
    m_nSimple = _simple;
    m_nDays = _days;
    m_strStartDate = _startDate;
    m_strEndDate = _endDate;
    m_strFrequency = _frequecy;
    m_nRepet = _repeat;
    m_nEvery = _every;
}

@end
