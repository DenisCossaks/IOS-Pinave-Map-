//
//  MyDetailsController.m
//  NEP
//
//  Created by Dandong3 Sam on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyDetailsController.h"
#import "UserSession.h"
#import "Utils.h"

#import "JsonReader.h"

#import "SHKActivityIndicator.h"
#import "Setting.h"
#import "ASIFormDataRequest.h"

#define REGISTER_SCROLLVIEW_CONTENT_WIDTH iPad ? 768 : 320
#define REGISTER_SCROLLVIEW_CONTENT_HEIGHT iPad ? 960 : 534


@interface MyDetailsController ()

@end

@implementation MyDetailsController


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
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"My Details";

    UIBarButtonItem * bi = [[UIBarButtonItem alloc] initWithTitle:@"Update" style:UIBarButtonItemStyleBordered
                                                           target:self action:@selector(onRightButtionPressed:)];
    self.navigationItem.rightBarButtonItem = bi;
    
    
    [self setInterface];
    [self setTimeZoneValue];
    [self setCountryList];

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
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardDidShow:) name: UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardDidHide:) name: UIKeyboardDidHideNotification object:nil];
    
    self.navigationController.navigationBarHidden = YES;
    
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setTabBarHidden:YES animated:NO];
 
    
    curGender = MALE;
    
    [[SHKActivityIndicator currentIndicator] displayActivity:@"Loading..." : self];
    
    [self getRequest];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}
-(void) viewDidAppear:(BOOL)animated
{
    NSLog(@"x = %f, y = %f", viewMain.frame.origin.x, viewMain.frame.origin.y);
    NSLog(@"x = %f, y = %f", viewScroll.frame.origin.x, viewScroll.frame.origin.y);
    
}

#pragma mark ----- 
- (void) setInterface {
    
    tfFirstName.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    tfLastName.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    tfCountry.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    tfCity.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    tfState.autocapitalizationType = UITextAutocapitalizationTypeSentences;
  
    if (![Global isIPhone5]) {
        viewScroll.frame = CGRectMake(0, 0, viewMain.frame.size.width, viewMain.frame.size.height);
    } else {
        viewScroll.frame = CGRectMake(0, 0, viewMain.frame.size.width, viewMain.frame.size.height + 88);
    }
    viewScroll.contentSize = CGSizeMake(REGISTER_SCROLLVIEW_CONTENT_WIDTH,
                                        REGISTER_SCROLLVIEW_CONTENT_HEIGHT);	
//    [viewMain addSubview:viewScroll];


    viewSubDate.frame = CGRectMake(0, self.view.frame.size.height + 88, viewSubDate.frame.size.width, viewSubDate.frame.size.height);
    [self.view addSubview:viewSubDate];
    
    viewSubTimezone.frame = CGRectMake(0, self.view.frame.size.height + 88, viewSubTimezone.frame.size.width, viewSubTimezone.frame.size.height);
    [self.view addSubview:viewSubTimezone];

    viewSubCounty.frame = CGRectMake(0, self.view.frame.size.height + 88, viewSubCounty.frame.size.width, viewSubCounty.frame.size.height);
    [self.view addSubview:viewSubCounty];

}
- (void) getRequest {
//    NSString *urlString = [Utils getUsersUrl];
    
    NSString *auth_code = [[NSUserDefaults standardUserDefaults] objectForKey:@"loginCode"];

    NSString * urlString = [Utils getProfileDetail:auth_code];
    JsonReader *jsonReader = [[JsonReader alloc] initWithUrl:urlString delegate:self];
    [jsonReader read];
}

- (void)didJsonReadFail
{
    [[SHKActivityIndicator currentIndicator] hide];
    
    [[[UIAlertView alloc] initWithTitle:@"" message:@"Oops! We seem to be experiencing a system overload. Please try again in a few minute." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)didJsonRead:(id)result
{
    if (result == nil) {
        [self didJsonReadFail];
        return;
    }

    NSDictionary * message = [result objectForKey:@"message"];
    if (message == nil) {
        [self didJsonReadFail];
        return;
    }
    if (![[message objectForKey:@"myprofile"] isEqualToString:@"OK"]) {
        [self didJsonReadFail];
        return;
    }
    
    NSDictionary * data = [result objectForKey:@"data"];
    NSDictionary * userInfo = [data objectForKey:@"user"];
    
    NSLog(@"user info = %@", userInfo);
    
    tfFirstName.text = [userInfo objectForKey:@"firstname"];
    tfLastName.text = [userInfo objectForKey:@"lastname"];
    tfEmail.text = [userInfo objectForKey:@"email"];;

    NSDictionary * detail = [userInfo objectForKey:@"detail"];
    
    NSString * birthday = [detail objectForKey:@"birthday"];
    NSLog(@"birth = %@", birthday);
    if (birthday == nil || [birthday isKindOfClass:[NSNull class]] || [birthday rangeOfString:@"null"].location != NSNotFound) {
        NSDate *currentDate = [NSDate date];
        
        NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
        [dateComponents setYear:-18];
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDate* defaultBirthday = [calendar dateByAddingComponents:dateComponents toDate:currentDate options:0];
        
        birthday = [Utils getDateString:defaultBirthday :DATE_DATE];
    }
    
    NSArray * arry = [birthday componentsSeparatedByString:@"-"];
    tfBirthday.text = [NSString stringWithFormat:@"%@/%@/%@", [arry objectAtIndex:2], [arry objectAtIndex:1], [arry objectAtIndex:0]];
    
    NSString * strGender = [detail objectForKey:@"gender"];
    if ([strGender isKindOfClass:[NSNull class]]) {
        curGender = MALE;
    }
    else if ([strGender isEqualToString:@"male"]) {
        curGender = MALE;
    } else {
        curGender = FOMALE;
    }
    [self changeGenderButton];
    
    NSString * country = [detail objectForKey:@"country"];
    if (country == nil || [country isKindOfClass:[NSNull class]] || [country rangeOfString:@"null"].location != NSNotFound) {
        country = @"";
    }
    tfCountry.text = country;
    
    NSString * city = [detail objectForKey:@"city"];
    if (city == nil || [city isKindOfClass:[NSNull class]] || [city rangeOfString:@"null"].location != NSNotFound) {
        city = @"";
    }
    tfCity.text = city;
    
    NSString * state = [detail objectForKey:@"state"];
    if (state == nil || [state isKindOfClass:[NSNull class]] || [state rangeOfString:@"null"].location != NSNotFound) {
        state = @"";
    }
    tfState.text = state;
    
    NSString * timezone = [detail objectForKey:@"timezone"];
    if (timezone == nil || [timezone isKindOfClass:[NSNull class]] || [timezone rangeOfString:@"null"].location != NSNotFound) {
        timezone = [Setting getTimezone];
    }
    tfTimezone.text = timezone;
    
    NSString * phone = [detail objectForKey:@"phone"];
    if (phone == nil || [phone isKindOfClass:[NSNull class]] || [phone rangeOfString:@"null"].location != NSNotFound) {
        phone = @"";
    }
    tfPhone.text = phone;
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * password = [defaults objectForKey:@"save_password"];
    tfPassword.text = password;
    tfConfirm.text = password;

    
    [[SHKActivityIndicator currentIndicator] hide];
    
}
/*
- (void)didJsonRead:(id)result
{
    if (result == nil) {
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * userId = [defaults objectForKey:@"loginId"];
    NSString * email = [defaults objectForKey:@"username"];
                    
    
//    NSDictionary *users = [result objectForKey:@"users"];
//    NSArray *all_user = [users allValues];
    NSArray *all_user = [result objectForKey:@"users"];
    
    NSDictionary * userInfo = nil;
    BOOL bExist = NO;
    for (userInfo in all_user) {
        if ([[userInfo objectForKey:@"id"] isEqual : userId] ) {
            bExist = YES;
            break;
        }
    }
    
    if (userInfo == nil && bExist == NO) {
        return;
    }
    
    NSLog(@"user info = %@", userInfo);
    
    tfFirstName.text = [userInfo objectForKey:@"firstname"];
    tfLastName.text = [userInfo objectForKey:@"lastname"];
    
    NSDictionary * detail = [userInfo objectForKey:@"detail"];
    
    NSString * birthday = [detail objectForKey:@"birthday"];
    NSLog(@"birth = %@", birthday);
    if (birthday == nil || [birthday isKindOfClass:[NSNull class]] || [birthday rangeOfString:@"null"].location != NSNotFound) {
        NSDate *currentDate = [NSDate date];
        
        NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
        [dateComponents setYear:-18];
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDate* defaultBirthday = [calendar dateByAddingComponents:dateComponents toDate:currentDate options:0];
        
        birthday = [Utils getDateString:defaultBirthday :DATE_DATE];
    }
    
    NSArray * arry = [birthday componentsSeparatedByString:@"-"];
    tfBirthday.text = [NSString stringWithFormat:@"%@/%@/%@", [arry objectAtIndex:2], [arry objectAtIndex:1], [arry objectAtIndex:0]];

    NSString * strGender = [detail objectForKey:@"gender"];
    if ([strGender isKindOfClass:[NSNull class]]) {
        curGender = MALE;
    }
    else if ([strGender isEqualToString:@"male"]) {
        curGender = MALE;
    } else {
        curGender = FOMALE;
    }
    [self changeGenderButton];
    
    NSString * country = [detail objectForKey:@"country"];
    if (country == nil || [country isKindOfClass:[NSNull class]] || [country rangeOfString:@"null"].location != NSNotFound) {
        country = @"";
    }
    tfCountry.text = country;
    
    NSString * city = [detail objectForKey:@"city"];
    if (city == nil || [city isKindOfClass:[NSNull class]] || [city rangeOfString:@"null"].location != NSNotFound) {
        city = @"";
    }
    tfCity.text = city;
    
    NSString * state = [detail objectForKey:@"state"];
    if (state == nil || [state isKindOfClass:[NSNull class]] || [state rangeOfString:@"null"].location != NSNotFound) {
        state = @"";
    }
    tfState.text = state;
    
    NSString * timezone = [detail objectForKey:@"timezone"];
    if (timezone == nil || [timezone isKindOfClass:[NSNull class]] || [timezone rangeOfString:@"null"].location != NSNotFound) {
        timezone = [Setting getTimezone];
    }
    tfTimezone.text = timezone;
    
    NSString * phone = [detail objectForKey:@"phone"];
    if (phone == nil || [phone isKindOfClass:[NSNull class]] || [phone rangeOfString:@"null"].location != NSNotFound) {
        phone = @"";
    }
    tfPhone.text = phone;
    
    tfEmail.text = email;
    
    
    [[SHKActivityIndicator currentIndicator] hide];

}
*/

-(void) setCountryList{
    NSArray *countryCodes = [NSLocale ISOCountryCodes];
    countriesArray = [NSMutableArray arrayWithCapacity:[countryCodes count]];
    
    for (NSString *countryCode in countryCodes)
    {
        NSString *identifier = [NSLocale localeIdentifierFromComponents: [NSDictionary dictionaryWithObject: countryCode forKey: NSLocaleCountryCode]];
        NSString *country = [[NSLocale currentLocale] displayNameForKey: NSLocaleIdentifier value: identifier];
        
        country = [country stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        [countriesArray addObject: country];
    }
    
    
//    NSDictionary *codeForCountryDictionary = [[NSDictionary alloc] initWithObjects:countryCodes forKeys:countries];
//    NSLog(@"codeForCountryDic = %@", codeForCountryDictionary);
    
//    countriesArray = [[NSMutableArray alloc] init];
//    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier: @"en_US"];
//    
//    NSArray *countryArray = [NSLocale ISOCountryCodes];
//    for (NSString *countryCode in countryArray)
//    {
//        @autoreleasepool {
//            NSString *displayNameString = [locale displayNameForKey:NSLocaleCountryCode value:countryCode];
//            [countriesArray addObject:displayNameString];
//            
//        }
//    }
    
    [countriesArray sortUsingSelector:@selector(compare:)];
    
    NSLog(@"country list = %@", countriesArray);
}

- (void) setTimeZoneValue {
    
    timeZoneDic = nil;
    timeZoneDic = [NSMutableDictionary dictionary];
    
    NSArray *aryTimeZone = [NSTimeZone knownTimeZoneNames];
    for (NSString *strTimeZone in aryTimeZone) {
        NSArray *zoneComp = [strTimeZone componentsSeparatedByString:@"/"];
        NSString *strContinent = [zoneComp objectAtIndex:0];
        NSString *strRegion = @"";
        if ([zoneComp count] > 1) {
            strRegion = [zoneComp objectAtIndex:1];
        }
        NSMutableArray *regionsForCont = [timeZoneDic objectForKey:strContinent];
        if (regionsForCont == nil) {
            regionsForCont = [NSMutableArray array];
            [timeZoneDic setObject:regionsForCont forKey:strContinent];
        }
        [regionsForCont addObject:strRegion];
    }
    
    continentArray = nil;
    continentArray = [[timeZoneDic allKeys] sortedArrayUsingSelector:@selector(localizedCompare:)];
    
    regionArray = nil;
    NSArray *zoneComp = [prevTZ.name componentsSeparatedByString:@"/"];
    NSString *strContinent = [zoneComp objectAtIndex:0];
    for (NSString *knownCont in continentArray) {
        if ([knownCont caseInsensitiveCompare:strContinent] == NSOrderedSame) {
            [pvTimezone selectRow:[continentArray indexOfObject:knownCont] inComponent:0 animated:NO];
            regionArray = [timeZoneDic objectForKey:knownCont];
            break;
        }
    }
    
    
    if (regionArray == nil) {
        regionArray = [timeZoneDic objectForKey:[continentArray objectAtIndex:0]];
    }

}


#pragma mark --------- Event ---------
-(void) onUpdate : (id) sender {
    if (![tfPassword.text isEqualToString:tfConfirm.text]) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Do not indentify password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    if (tfTimezone.text.length < 1) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please choose time zone." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }

    if (tfFirstName.text.length < 1 || tfLastName.text.length < 1) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please input name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    if (tfCountry.text.length < 1) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please input country." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    if (tfCity.text.length < 1) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please input city." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }

    [[SHKActivityIndicator currentIndicator] displayActivity:@"Loading..." : self];

//    NSString *url = [Utils getUpdateDetailUrl];
/*    
    IAMultipartRequestGenerator *request = [[IAMultipartRequestGenerator alloc] initWithUrl:url andRequestMethod:@"POST"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * code = [defaults objectForKey:@"loginCode"];
    [request setString:code forField:@"code"];
    NSLog(@"code = %@", code);
    [request setString:tfFirstName.text forField:@"firstname"];
    NSLog(@"firstname = %@", tfFirstName.text);
    [request setString:tfLastName.text forField:@"lastname"];
    NSLog(@"lastname = %@", tfLastName.text);
    [request setString:tfPassword.text forField:@"password"];
    NSLog(@"password = %@", tfPassword.text);
    [request setString:tfConfirm.text forField:@"confirm_password"];
    NSLog(@"confirm_password = %@", tfConfirm.text);
    [request setString:tfEmail.text forField:@"email"];
    NSLog(@"email = %@", tfEmail.text);
    
    
    NSArray * arry = [tfBirthday.text componentsSeparatedByString:@"/"];
    NSString * birthday = [NSString stringWithFormat:@"%@-%@-%@", [arry objectAtIndex:2], [arry objectAtIndex:1], [arry objectAtIndex:0]];
    
    [request setString:birthday forField:@"birthday"];
    NSLog(@"birthday = %@", birthday);
    
    NSString* sGender = @"";
    if (curGender == MALE) {
        sGender = @"male";
    } else {
        sGender = @"female";
    }
    [request setString:sGender forField:@"gender"];
    NSLog(@"gender = %@", sGender);
    
    [request setString:tfCountry.text forField:@"country"];
    NSLog(@"country = %@", tfCountry.text);
    [request setString:tfState.text forField:@"state"];
    NSLog(@"state = %@", tfState.text);
    [request setString:tfCity.text forField:@"city"];
    NSLog(@"city = %@", tfCity.text);
    [request setString:tfPhone.text forField:@"phone"];
    NSLog(@"phone = %@", tfPhone.text);
    

    [request setString:tfTimezone.text forField:@"timezone"];
    NSLog(@"timezone = %@", tfTimezone.text);
    
    
    [Setting setTimezone:tfTimezone.text];
    
    [request setDelegate:self];
    [request startRequest];
*/
    
    NSString * url = [Utils postProfileDetail];

    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString: url]];
    request.requestMethod = @"POST";

    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * code = [defaults objectForKey:@"loginCode"];
    [request setPostValue:code forKey:@"code"];
    NSLog(@"code = %@", code);
    [request setPostValue:tfFirstName.text forKey:@"firstname"];
    NSLog(@"firstname = %@", tfFirstName.text);
    [request setPostValue:tfLastName.text forKey:@"lastname"];
    NSLog(@"lastname = %@", tfLastName.text);
    [request setPostValue:tfPassword.text forKey:@"password"];
    NSLog(@"password = %@", tfPassword.text);
    [request setPostValue:tfConfirm.text forKey:@"password_confirm"];
    NSLog(@"password_confirm = %@", tfConfirm.text);
    [request setPostValue:tfEmail.text forKey:@"email"];
    NSLog(@"email = %@", tfEmail.text);
    
    
    NSArray * arry = [tfBirthday.text componentsSeparatedByString:@"/"];
    NSString * birthday = [NSString stringWithFormat:@"%@-%@-%@", [arry objectAtIndex:2], [arry objectAtIndex:1], [arry objectAtIndex:0]];
    
    [request setPostValue:birthday forKey:@"birthday"];
    NSLog(@"birthday = %@", birthday);
    
    NSString* sGender = @"";
    if (curGender == MALE) {
        sGender = @"male";
    } else {
        sGender = @"female";
    }
    [request setPostValue:sGender forKey:@"gender"];
    NSLog(@"gender = %@", sGender);
    
    [request setPostValue:tfCountry.text forKey:@"country"];
    NSLog(@"country = %@", tfCountry.text);
    [request setPostValue:tfState.text forKey:@"state"];
    NSLog(@"state = %@", tfState.text);
    [request setPostValue:tfCity.text forKey:@"city"];
    NSLog(@"city = %@", tfCity.text);
    [request setPostValue:tfPhone.text forKey:@"phone"];
    NSLog(@"phone = %@", tfPhone.text);
    
    [request setPostValue:tfTimezone.text forKey:@"timezone"];
    NSLog(@"timezone = %@", tfTimezone.text);
    
    [Setting setTimezone:tfTimezone.text];
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(uploadRequestFinished:)];
    [request setDidFailSelector:@selector(uploadRequestFailed:)];
    
    [request startAsynchronous];

}

- (void) changeGenderButton{
    
    if (curGender == MALE) {
        [btnMale setBackgroundImage:[UIImage imageNamed:@"checked"] forState:UIControlStateNormal];
        [btnFemale setBackgroundImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
    } else {
        [btnMale setBackgroundImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
        [btnFemale setBackgroundImage:[UIImage imageNamed:@"checked"] forState:UIControlStateNormal];
    }
}

- (IBAction) onMale:(id)sender{
    curGender = MALE;
    [self changeGenderButton];
}
- (IBAction) onFemale:(id)sender{
    curGender = FOMALE;
    [self changeGenderButton];
}

#pragma mark
#pragma mark IAMultipartRequestGenerator delegate methods

- (void)uploadRequestFinished:(ASIHTTPRequest *)request{    
    
    [[SHKActivityIndicator currentIndicator] hide];
    
//    if ([response rangeOfString:@"OK"].location != NSNotFound) {
        [[[UIAlertView alloc] initWithTitle:@"Success!" 
                                    message: @"Your profile has been updated."
                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:tfPassword.text forKey:@"save_password"];
        [defaults synchronize];
    
//    }
//    else {
//        [[[UIAlertView alloc] initWithTitle:@"Fail!" 
//                                    message: @"Your profile has not updated successfully"
//                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
//        
//    }
}

- (void)uploadRequestFailed:(ASIHTTPRequest *)request{
    
    [[SHKActivityIndicator currentIndicator] hide];
    
    NSLog(@" Error - Statistics file upload failed: \"%@\"",[[request error] localizedDescription]); 
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"A connection failure occurred" delegate:self 
                                           cancelButtonTitle:@"OK" 
                                           otherButtonTitles:nil, nil];
    [alert show];
}


-(void)requestDidFailWithError:(NSError *)error 
{
    [[SHKActivityIndicator currentIndicator] hide];

    NSLog(@"IAMultipartRequestGenerator request failed");
}


-(void)requestDidFinishWithResponse:(NSData *)responseData 
{
    [[SHKActivityIndicator currentIndicator] hide];

    NSString *response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"IAMultipartRequestGenerator finished: %@", response);
    
    if ([response rangeOfString:@"OK"].location != NSNotFound) {
        [[[UIAlertView alloc] initWithTitle:@"Success!" 
                                   message: @"Your profile has been updated"
                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"Fail!" 
                                    message: @"Your profile has not updated successfully"
                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];

    }
}



#pragma mark =-----------------
-(IBAction) onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction) onTappedGender:(UISegmentedControl *) sender{
    
}

-(IBAction) onChangedBirthday:(id) sender{
    NSDate * getDate = pvDate.date;
    
    NSArray * arry = [[Utils getDateString: getDate : DATE_DATE] componentsSeparatedByString:@"-"];
    NSString * birthday = [NSString stringWithFormat:@"%@/%@/%@", [arry objectAtIndex:2], [arry objectAtIndex:1], [arry objectAtIndex:0]];

    tfBirthday.text = birthday;
}

-(IBAction) onDateDone:(id) sender{
    [self hideDateView];
}
-(IBAction) onTimeZoneDone:(id) sender{
    [self hideTimeView];
}
-(IBAction) onCountryDone:(id) sender{
    [self hideCountryView];
}


- (IBAction)next:(id)sender
{
    UITextField * tf = (UITextField*) sender;
    if ([tf isFirstResponder]) {
        [tf resignFirstResponder];
    }
    
/*    
    if ([tfFirstName isFirstResponder]) {
		[tfLastName becomeFirstResponder];
	}else if ([tfLastName isFirstResponder]){
        [tfBirthday becomeFirstResponder];
    }else if ([tfBirthday isFirstResponder]){
        [tfCountry becomeFirstResponder];
    }else if ([tfCountry isFirstResponder]){
        [tfCity becomeFirstResponder];
    }else if ([tfCity isFirstResponder]){
        [tfState becomeFirstResponder];
    }else if ([tfState isFirstResponder]) {
        [tfState resignFirstResponder];
//		[tfTimezone becomeFirstResponder];
	}else if ([tfTimezone isFirstResponder]) {
		[tfPhone becomeFirstResponder];
	}else if ([tfPhone isFirstResponder]) {
		[tfPassword becomeFirstResponder];
	}else if ([tfPassword isFirstResponder]) {
		[tfConfirm becomeFirstResponder];
	}else if ([tfConfirm isFirstResponder]) {
		[tfEmail becomeFirstResponder];
    }else if ([tfEmail isFirstResponder]){
        
    }
*/ 
}

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
	
	// Resize the scroll view to make room for the keyboard
	CGRect viewFrame = viewMain.bounds;
	originalFrame = viewFrame;
	viewFrame.size.height -= keyboardSize.height;
	viewScroll.frame = viewFrame;
    offset = viewScroll.contentOffset;
    
    
    CGRect textFieldRect;
	if ([tfFirstName isFirstResponder])
		textFieldRect = [tfFirstName frame];
	else if ([tfLastName isFirstResponder])
		textFieldRect = [tfLastName frame];
	else if ([tfBirthday isFirstResponder])
		textFieldRect = [tfBirthday frame];
    else if ([tfCountry isFirstResponder])
		textFieldRect = [tfCountry frame];
    else if ([tfCity isFirstResponder])
		textFieldRect = [tfCity frame];
	else if ([tfState isFirstResponder])
		textFieldRect = [tfState frame];
	else if ([tfTimezone isFirstResponder])
		textFieldRect = [tfTimezone frame];
    else if ([tfPhone isFirstResponder])
		textFieldRect = [tfPhone frame];
    else if ([tfPassword isFirstResponder])
		textFieldRect = [tfPassword frame];
    else if ([tfConfirm isFirstResponder])
		textFieldRect = [tfConfirm frame];
    else if ([tfEmail isFirstResponder])
		textFieldRect = [tfEmail frame];
	
    textFieldRect.origin.y += 10 + 44;
	[viewScroll scrollRectToVisible:textFieldRect animated:YES];
	
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
	
	// Reset the frame scroll view to its original value
	viewScroll.frame = originalFrame;
	
	// Reset the scrollview to previous location
	viewScroll.contentOffset = offset;
	
	// Keyboard is no longer visible
	keyboardVisible = NO;
    
}


#pragma mark ------- Delegate ---------
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    BOOL shouldEdit = YES;
	
	if ([textField isEqual:tfTimezone]) {
        
        [textField resignFirstResponder];
        
		shouldEdit = NO;
        [self hideDateView];
        [self hideCountryView];
		[self showTimeview];

        
        NSString* timezone = tfTimezone.text;
        NSArray *myWords = [timezone componentsSeparatedByString:@"/"];
        
        NSString* a = [myWords objectAtIndex:0];
        NSString* b = [myWords objectAtIndex:1];
        int ii = [continentArray indexOfObject:a];
        regionArray = nil;
        regionArray = [timeZoneDic objectForKey:a];
        int jj = [regionArray indexOfObject:b];

        [pvTimezone selectRow:ii
                  inComponent:0 animated:YES];

        [pvTimezone selectRow:jj
                  inComponent:1 animated:YES];

        [pvTimezone reloadAllComponents];
        
    } else if ([textField isEqual:tfBirthday]) {
        [textField resignFirstResponder];
        
		shouldEdit = NO;
        [self hideTimeView];
        [self hideCountryView];
		[self showDateview];
        
    } else if ([textField isEqual:tfCountry]) {
        
        [textField resignFirstResponder];
        
		shouldEdit = NO;
        [self hideDateView];
        [self hideTimeView];
        [self showCountryView];
        
        
        NSString* country = tfCountry.text;
        
        int jj = [countriesArray indexOfObject:country];
        if (jj == NSNotFound) {
            jj = 0;
        }
        [pvCountry selectRow:jj
                  inComponent:0 animated:YES];
        
        [pvCountry reloadAllComponents];

    } else {
		[self hideTimeView];
        [self hideDateView];
        [self hideCountryView];
	}
	
	return shouldEdit;
}


#pragma mark ---------- View Contry ---------
- (void)hideCountryView
{
    if (!country_visible) {
        return;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3f];
    
    viewSubCounty.frame = CGRectMake(0, self.view.frame.size.height, 320, 260);
    [UIView commitAnimations];
    
    viewScroll.frame = originalFrame;
	
	// Reset the scrollview to previous location
	viewScroll.contentOffset = offset;
    
    country_visible = NO;
}

- (void)showCountryView
{
    
    for (UITextField *textField in viewScroll.subviews) {
        if ([textField isKindOfClass:[UITextField class]]) {
            [textField resignFirstResponder];
        }
    }
    
    
    if (country_visible) {
        return;
    }
    
	
    [viewSubCounty setHidden:NO];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.4f];
    
    viewSubCounty.frame = CGRectMake(0, self.view.frame.size.height-260, 320, 260);
    
    [UIView commitAnimations];
    
    
    // Scroll view
    CGRect viewFrame = self.view.bounds;
	originalFrame = viewFrame;
	viewFrame.size.height -= viewSubCounty.frame.size.height;
	viewScroll.frame = viewFrame;
    
    CGRect textFieldRect = tfCountry.frame;
	
    textFieldRect.origin.y += (10 + 44);
	[viewScroll scrollRectToVisible:textFieldRect animated:YES];
    
    
    country_visible = YES;
    
}

#pragma mark -------- View TIME ZONE 
- (void)hideTimeView
{
    if (!timezone_visible) {
        return;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3f];
    
    if (!iPad) {
        viewSubTimezone.frame = CGRectMake(0, self.view.frame.size.height, 320, 260);
    }
    [UIView commitAnimations];
    
    
    viewScroll.frame = originalFrame;
	
	// Reset the scrollview to previous location
	viewScroll.contentOffset = offset;

    
    timezone_visible = NO;
}

- (void)showTimeview
{
    
    for (UITextField *textField in viewScroll.subviews) {
        if ([textField isKindOfClass:[UITextField class]]) {
            [textField resignFirstResponder];
        }
    }

    if (iPad) {
        
        UIViewController* popContent = [[UIViewController alloc] init];
        popContent.view.frame = CGRectMake(0, 0, pvTimezone.frame.size.width, pvTimezone.frame.size.height);
        
        [popContent.view addSubview: pvTimezone];
        popContent.contentSizeForViewInPopover = CGSizeMake(pvTimezone.frame.size.width, pvTimezone.frame.size.height);
        
        popoverController = [[UIPopoverController alloc] initWithContentViewController: popContent];
        
        [popoverController presentPopoverFromRect:tfTimezone.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
        return;
    }
    
    
    
    if (timezone_visible) {
        return;
    }
    
	
    [viewSubTimezone setHidden:NO];

    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.4f];
    
    if (iPad) {
        viewSubTimezone.frame = CGRectMake(0, 748, 768, 260);
    } else {
        viewSubTimezone.frame = CGRectMake(0, self.view.frame.size.height-260, 320, 260);
    }
    
    [UIView commitAnimations];
    
    
    // Scroll view
    CGRect viewFrame = self.view.bounds;
	originalFrame = viewFrame;
	viewFrame.size.height -= viewSubTimezone.frame.size.height;
	viewScroll.frame = viewFrame;
    
    CGRect textFieldRect = tfTimezone.frame;
	
    textFieldRect.origin.y += (10 + 44);
	[viewScroll scrollRectToVisible:textFieldRect animated:YES];

    
    timezone_visible = YES;

}

#pragma mark -------- View Date  
- (void)hideDateView
{
    if (!date_visible) {
        return;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3f];
    
    if (iPad) {
        viewSubDate.frame = CGRectMake(0, 1024, 768, 260);
    } else {
        viewSubDate.frame = CGRectMake(0, self.view.frame.size.height, 320, 260);
    }
    [UIView commitAnimations];
    
    viewScroll.frame = originalFrame;
	
	// Reset the scrollview to previous location
	viewScroll.contentOffset = offset;

    date_visible = NO;
}

- (void)showDateview
{
    
    for (UITextField *textField in viewScroll.subviews) {
        if ([textField isKindOfClass:[UITextField class]]) {
            [textField resignFirstResponder];
        }
    }
	

    if (tfBirthday.text.length != 0) {
        NSArray * arry = [tfBirthday.text componentsSeparatedByString:@"/"];
        NSString * birthday = [NSString stringWithFormat:@"%@-%@-%@", [arry objectAtIndex:2], [arry objectAtIndex:1], [arry objectAtIndex:0]];

        pvDate.date = [Utils dateFromString: birthday :DATE_DATE];
    }

    if (iPad) {
        
        UIViewController* popContent = [[UIViewController alloc] init];
        popContent.view.frame = CGRectMake(0, 0, pvDate.frame.size.width, pvDate.frame.size.height);
        
        [popContent.view addSubview: pvDate];
        popContent.contentSizeForViewInPopover = CGSizeMake(pvDate.frame.size.width, pvDate.frame.size.height);
        
        popoverController = [[UIPopoverController alloc] initWithContentViewController: popContent];
        
        [popoverController presentPopoverFromRect:tfBirthday.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
        return;
    }

    if (date_visible) {
        return;
    }
    
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.4f];
    
    if (iPad) {
        viewSubDate.frame = CGRectMake(0, 748, 768, 260);
    } else {
        viewSubDate.frame = CGRectMake(0, self.view.frame.size.height-260, 320, 260);
    }
    
    [UIView commitAnimations];
    
    
    // Scroll view
    CGRect viewFrame = self.view.bounds;
	originalFrame = viewFrame;
	viewFrame.size.height -= viewSubTimezone.frame.size.height;
	viewScroll.frame = viewFrame;
    
    CGRect textFieldRect = tfBirthday.frame;
	
    textFieldRect.origin.y += (10 + 44);
	[viewScroll scrollRectToVisible:textFieldRect animated:YES];

    
    date_visible = YES;
    
}

#pragma mark ------------------ Time zone picker ---------- 

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (pickerView == pvTimezone) {
        return 2;
    }
    else if (pickerView == pvCountry) {
        return 1;
    }
    return 0;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == pvTimezone) {
        if (component == 0) {
            return [continentArray count];
        } else {
            return [regionArray count];
        }
    }
    else if (pickerView == pvCountry) {
        return [countriesArray count];
    }
    
    return 0;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (pickerView == pvTimezone) {
        if (component == 0) {
            return 120;
        } else {
            return 180;
        }
    }
    else if (pickerView == pvCountry) {
        return 300;
    }
    
    return 0;
}

-(UIView *)pickerView:(UIPickerView *)zonepickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    static const int kReusableTag = 1;
    if (view.tag != kReusableTag) {
        CGRect frame = CGRectZero;
        frame.size = [zonepickerView rowSizeForComponent:component];
        frame = CGRectInset(frame, 4.0, 4.0);
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont boldSystemFontOfSize:18.0];
        view = label;
        view.tag = kReusableTag;
        view.opaque = NO;
        view.backgroundColor = [UIColor clearColor];
        view.userInteractionEnabled = NO;
    }
    
    UILabel *textLabel = (UILabel*)view;
    
    if (zonepickerView == pvTimezone) {
        if (component == 0) {
            textLabel.text = [continentArray objectAtIndex:row];
        } else {
            textLabel.text = [regionArray objectAtIndex:row];
        }
    }
    else if (zonepickerView == pvCountry)
    {
        textLabel.text = [countriesArray objectAtIndex:row];
    }
    
	return view;
}

NSString *displayContinent;
NSString *displayRegion;
NSString *displayTimeZone;
int      curSel = 0;


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == pvTimezone) {
        if (component == 0) {
            displayContinent = [continentArray objectAtIndex:row];
            regionArray = nil;
            regionArray = [timeZoneDic objectForKey:displayContinent];
            
            [pvTimezone reloadComponent:1];
            
            displayTimeZone = displayContinent;
            if(curSel > [regionArray count])
            {
                displayRegion = [regionArray objectAtIndex:0];
                [pvTimezone selectRow:0 inComponent:1 animated:YES];
                curSel = 0;
            }
            else {
                displayRegion = [regionArray objectAtIndex:curSel];
            }
            displayTimeZone = [displayTimeZone stringByAppendingFormat:@"/%@", displayRegion];
            NSLog(@"TIME ZONE SELECTED - %@",displayTimeZone);
            
            tfTimezone.text = displayTimeZone;
            
        }else if (component == 1)
        {
            displayTimeZone = displayContinent;
            displayRegion = [regionArray objectAtIndex:row];
            curSel = row;
            displayTimeZone = [displayTimeZone stringByAppendingFormat:@"/%@", displayRegion];
            NSLog(@"TIME ZONE SELECTED - %@",displayTimeZone);
            tfTimezone.text = displayTimeZone;
        }
        
    }
    else if (pickerView == pvCountry){
        
         if (component == 0) {
             NSString * country = [countriesArray objectAtIndex:row];
             
             tfCountry.text = country;
         }
    }
        
}

@end
