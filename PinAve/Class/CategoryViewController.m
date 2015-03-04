//
//  CategoryViewController.m
//  PinAve
//
//  Created by Gold Luo on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CategoryViewController.h"

#import "MenuViewController.h"
#import "HomeViewController.h"
#import "SearchViewController.h"
#import "AppDelegate.h"

#import "UserSession.h"
//#import "SelectCategoryController.h"
#import "WithCategoryController.h"
#import "AddLocationViewController.h"
#import "NotificationsViewController.h"
#import "UserPins.h"
#import "FilterSearch.h"
#import "UsersPool.h"
#import "JSON.h"


@interface NSDictionary (SortingBranches)

- (NSComparisonResult) compareByName:(NSDictionary *)other;

@end

@implementation NSDictionary (SortingBranches)
- (NSComparisonResult) compareByName:(NSDictionary *)other
{
    NSString *nameOwn = [self objectForKey:@"name"];
    NSString *nameOther = [other objectForKey:@"name"];
    
    return [nameOwn compare:nameOther];
}
@end

@interface CategoryViewController ()
{
//    BOOL isLoading;
}

@property (strong, nonatomic) EGORefreshTableHeaderView *refreshHeaderView;

@end


@implementation CategoryViewController

@synthesize refreshHeaderView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reLogIn) name:kRelogin object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reLoading) name:kReloading object:nil];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    lbLocation.text = @"Loading...";

    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
    tapGesture.delegate = self;
    tapGesture.numberOfTapsRequired = 1;
    lbLocation.userInteractionEnabled = YES;
    [lbLocation addGestureRecognizer:tapGesture];

    CGRect tableFrame = tvCategory.frame;
    tableFrame.origin.y = -tableFrame.size.height;
    self.refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:tableFrame];
    self.refreshHeaderView.delegate = self;
    [tvCategory addSubview:self.refreshHeaderView];
    [self.refreshHeaderView refreshLastUpdatedDate];

    m_bAdvanced = NO;
    [viewSubDark setHidden:YES];

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogIn) name:UserDidLoginSuccess object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogOut) name:UserDidLogoutSuccess object:nil];

    m_nLoadingType = LOADING_FIRST;
    
    [self setSearchIconToFavicon];
    
    [tvCategory setContentOffset:CGPointMake(0, 44)];

}

- (void)tapDetected:(UIGestureRecognizer *)sender{

    [self onAddLocation:nil];
}


-(void) viewWillDisappear:(BOOL)animated
{
//    int size = [self.navigationController.viewControllers count];
//    NSLog(@"size = %d", size);
    
    //            for (int i = 0; i < size; i ++) {
    //                UIViewController * childCtrl = [navCtlr.viewControllers objectAtIndex:i];
    //                [childCtrl viewWillDisappear:NO];
    //            }
    

}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;

    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setTabBarHidden:NO animated:YES];

    [tvCategory setContentOffset:CGPointMake(0, 44)];

    if (m_nLoadingType == LOADING_FIRST) {
        
        [self performSelectorOnMainThread:@selector(refresh) withObject:nil waitUntilDone:NO];
//        [self refresh];
        m_nLoadingType = LOADING_COUNT;
    }
    else if (m_nLoadingType == LOADING_COUNT){
        
        [self refreshCount];
    }
    else if (m_nLoadingType == LOADING_NONE) {
        m_nLoadingType = LOADING_COUNT;
    }
}

- (void)setSearchIconToFavicon {
    // Really a UISearchBarTextField, but the header is private.
    UITextField *searchField = nil;
    for (UIView *subview in searchFld.subviews) {
        if ([subview isKindOfClass:[UITextField class]]) {
            searchField = (UITextField *)subview;
            break;
        }
    }
    
    if (searchField) {
//        UIImage *image = [UIImage imageNamed: @"favicon.png"];
//        UIImageView *iView = [[UIImageView alloc] initWithImage:image];
//        searchField.leftView = iView;
//        [iView release];
        UIButton * btnAdvance = [UIButton buttonWithType:UIButtonTypeCustom];
        btnAdvance.frame = CGRectMake(0, 0, 30, 30);
        [btnAdvance setImage:[UIImage imageNamed:@"advanSearch.png"] forState:UIControlStateNormal];
        [btnAdvance addTarget:self action:@selector(onAdvancedSearch:) forControlEvents:UIControlEventTouchUpInside];
        
        searchField.leftView = btnAdvance;
    }
}

#pragma mark ---- button event

- (IBAction)onMenu:(id)sender{
    if (m_bLoadingDone) {
        return;
    }

    NotificationsViewController * vc;
    
    if (iPad) {
        vc = [[NotificationsViewController alloc] initWithNibName:@"NotificationsViewController-ipad" bundle:nil];
    } else {
        vc = [[NotificationsViewController alloc] initWithNibName:@"NotificationsViewController" bundle:nil];
    }
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    vc.modalPresentationStyle = UIModalPresentationFormSheet;
    
    vc.m_bPresent = YES;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentModalViewController:nav animated:YES];
    
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setTabBarHidden:YES animated:YES];
    
    m_nLoadingType = LOADING_NONE;
}
- (IBAction)onAddLocation:(id)sender
{
    if (m_bLoadingDone) {
        return;
    }

    AddLocationViewController * vc;
    if (iPad) {
        vc = [[AddLocationViewController alloc] initWithNibName:@"AddLocationViewController-ipad" bundle:nil];
    } else {
        vc = [[AddLocationViewController alloc] initWithNibName:@"AddLocationViewController" bundle:nil];
    }
    vc.delegate = self;
    [self.navigationController presentModalViewController:vc animated:YES];
    
    m_nLoadingType = LOADING_COUNT;
}

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
  
//    [self.view insertSubview:viewSubOption atIndex:0];
    [self.view addSubview:viewSubOption];
    
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.4f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(didStopShowAdvancedView)];

    viewSubOption.frame = CGRectMake(0, 0, viewSubOption.frame.size.width, viewSubOption.frame.size.height);
    viewListSearch.frame = CGRectMake(viewListSearch.frame.origin.x, 0 + viewSubOption.frame.size.height,
                                      viewListSearch.frame.size.width, viewListSearch.frame.size.height);
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
    viewListSearch.frame = CGRectMake(viewListSearch.frame.origin.x, 68,
                                      viewListSearch.frame.size.width, viewListSearch.frame.size.height);

    [UIView commitAnimations];
}

- (void) didStopShowAdvancedView {
    [self.view bringSubviewToFront:viewSubOption];
}

- (void) didStophideAdvancedView {
    m_bAdvanced = NO;
    
    [viewSubOption removeFromSuperview];
    
}


- (IBAction)onAdvancedSearch:(id)sender 
{
    if (m_bAdvanced) 
        [self hideAdvacedView];
    else
        [self showAdvancedView];
}


#pragma mark -------- Get Categories -------------

-(void) refresh
{
    [[SHKActivityIndicator currentIndicator] displayActivity:@"Loading..." : self];

    
    [self getCategories];

    [self performSelectorOnMainThread:@selector(getUserInfoOnly) withObject:nil waitUntilDone:NO];
}

- (void)getCategories
{
    
    [[Share getInstance].arrayCategory removeAllObjects];
    [Share getInstance].arrayCategory = nil;
    [tvCategory reloadData];
    
//    isLoading = YES;

    nJSON_STATE = 0;
    NSString *urlString = [Utils getCategoryUrl];
    JsonReader *jsonReader = [[JsonReader alloc] initWithUrl:urlString delegate:self];
    [jsonReader read];
}


#pragma mark pinInfoCount
- (void)getPinInfoCount
{
    NSString *urlString = [Utils getCountPins];
    ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [request setDelegate:self];
    [request setRequestMethod:@"GET"];
    [request setDidFinishSelector:@selector(requestPinInfoCountDone:)];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request startAsynchronous];
}

- (void)requestPinInfoCountDone:(ASIFormDataRequest*)request {
    
    NSString *responseString = [request responseString];
    
    [arrPinCount removeAllObjects];

    if (responseString != nil) {
        NSMutableDictionary* categoryResult = [responseString JSONValue];
        
        if (categoryResult != nil) {
            NSDictionary *values = [categoryResult objectForKey:@"categories"];
            arrPinCount = [[NSMutableArray alloc] initWithArray:[values allValues]];
        }
    }

    
    [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:tvCategory];
    [tvCategory reloadData];

    m_nLoadingCount ++;
    if (m_nLoadingCount == 2) {
        [[SHKActivityIndicator currentIndicator] hide];
    }
}

#pragma mark  --- myAvenueInfo
- (void) getMyAvenueInfo{
    
    NSString *urlString = [Utils GetStartPinChat];

    ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [request setDelegate:self];
    [request setRequestMethod:@"GET"];
    [request setDidFinishSelector:@selector(requestMyAvenueDone:)];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request startAsynchronous];
}
- (void)requestMyAvenueDone:(ASIFormDataRequest*)request {
    
    NSString *responseString = [request responseString];
    NSMutableDictionary* categoryResult = [responseString JSONValue];
 
    NSString * retOK = [categoryResult objectForKey:@"message"];
    if ([retOK isEqualToString:@"OK"]) {
        NSDictionary *values = [categoryResult objectForKey:@"user"];
        [Share getInstance].userChatInfo = [[NSDictionary alloc] initWithDictionary:values];
    }

    [tvCategory reloadData];
    [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:tvCategory];

    m_nLoadingCount ++;
    if (m_nLoadingCount == 2) {
        [[SHKActivityIndicator currentIndicator] hide];
    }

}

- (void)requestFailed:(ASIFormDataRequest*)request {

    [[SHKActivityIndicator currentIndicator] hide];

    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Oops! We seem to be experiencing a system overload. Please try again in a few minute." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}



- (void)didJsonReadFail
{
    [[SHKActivityIndicator currentIndicator] hide];

    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Oops! We seem to be experiencing a system overload. Please try again in a few minute." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alert.tag = 1000;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1000) {
        exit(1);
    }
}

- (void)didJsonRead:(id)result
{
    [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:tvCategory];

    NSDictionary *categoryResult = result;
    
    if (nJSON_STATE == 0) {
        NSDictionary *values = [categoryResult objectForKey:@"categories"];
        if (values != nil) {
            [Share getInstance].arrayCategory = [NSMutableArray arrayWithArray:[values allValues]];
            
            [[Share getInstance].arrayCategory sortUsingSelector:@selector(compareByName:)];
            
            [tvCategory reloadData];

//            [NSThread detachNewThreadSelector:@selector(getCategoryImages:) toTarget:self withObject:categoryList];
            
            [self refreshCount];
        }
        
    } else if (nJSON_STATE == 1) {
        [arrPinCount removeAllObjects];
        
        if (categoryResult != nil) {
            NSDictionary *values = [categoryResult objectForKey:@"categories"];
            arrPinCount = [[NSMutableArray alloc] initWithArray:[values allValues]];
        }
        [self getMyAvenueInfo];
        
    } else if (nJSON_STATE == 2) {
        if (categoryResult != nil) {
            NSString * retOK = [categoryResult objectForKey:@"message"];
            if ([retOK isEqualToString:@"OK"]) {
                NSDictionary *values = [categoryResult objectForKey:@"user"];
                [Share getInstance].userChatInfo = [[NSDictionary alloc] initWithDictionary:values];
                
//                NSLog(@"user chatInfo = %@", [Share getInstance].userChatInfo);
            }
        }
        
        nJSON_STATE = -1;
        [self endLoading];
    }
    
}

- (void) refreshCount{
    
    [[SHKActivityIndicator currentIndicator] displayActivity:@"Loading..." :self];
    
    m_nLoadingCount = 0;
    
    lbLocation.text = [[UserLocationManager sharedInstance] getCustomUserLocationAddress];

    [self getPinInfoCount];
    [self getMyAvenueInfo];
}



- (void)getCategoryImages:(NSArray *)resultAry
{
    @autoreleasepool {
        NSMutableArray *categories = [NSMutableArray array];
        
        for (NSDictionary *categoryItem in resultAry) {
            NSMutableDictionary *category = [NSMutableDictionary dictionaryWithDictionary:categoryItem];

/*
            NSString *imageUrl = [[SERVER_URL stringByAppendingPathComponent:[[categoryItem objectForKey:@"icon"] stringByAppendingString:@".png"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
            UIImage *iconImg = [UIImage imageWithData:imageData];
            if (iconImg) {
                [category setObject:iconImg forKey:@"iconData"];
            } else {
                [category setObject:[NSNull null] forKey:@"iconData"];
            }
*/
            NSString * category_name = [categoryItem objectForKey:@"name"];
            UIImage * iconImg = nil;
            
            if ([category_name isEqualToString:@"Accommodation"]) {
                iconImg = [UIImage imageNamed:@"accom.png"];
            } else if ([category_name isEqualToString:@"Cars & Bikes"]) {
                iconImg = [UIImage imageNamed:@"car.png"];
            } else if ([category_name isEqualToString:@"Events & Parties"]) {
                iconImg = [UIImage imageNamed:@"party.png"];
            } else if ([category_name isEqualToString:@"Food & Drinks"]) {
                iconImg = [UIImage imageNamed:@"food.png"];
            } else if ([category_name isEqualToString:@"Garage Sales"]) {
                iconImg = [UIImage imageNamed:@"garage.png"];
            } else if ([category_name isEqualToString:@"Health & Beauty"]) {
                iconImg = [UIImage imageNamed:@"beauty.png"];
            } else if ([category_name isEqualToString:@"Homely Made"]) {
                iconImg = [UIImage imageNamed:@"homely.png"];
            } else if ([category_name isEqualToString:@"Jobs"]) {
                iconImg = [UIImage imageNamed:@"Jobs.png"];
            } else if ([category_name isEqualToString:@"Leisure"]) {
                iconImg = [UIImage imageNamed:@"leisure.png"];
            } else if ([category_name isEqualToString:@"Parking"]) {
                iconImg = [UIImage imageNamed:@"parking.png"];
            } else if ([category_name isEqualToString:@"On Sale!"]) {
                iconImg = [UIImage imageNamed:@"sale.png"];
            } else if ([category_name isEqualToString:@"Wanted"]) {
                iconImg = [UIImage imageNamed:@"wanted.png"];
            } else if ([category_name isEqualToString:@"Daily Deals"]) {
                iconImg = [UIImage imageNamed:@"deals.png"];
            } else if ([category_name isEqualToString:@"I'll Pay for"]) {
                iconImg = [UIImage imageNamed:@"pay.png"];
            }
        
            if (iconImg) {
                [category setObject:iconImg forKey:@"iconData"];
            }
            [categories addObject:category];
        }
        
        
        
        [Share getInstance].arrayCategory = categories;
        
        [[Share getInstance].arrayCategory sortUsingSelector:@selector(compareByName:)];
        
        /*
        [Share getInstance].arrayCategory = [categories sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
            int id1 = [[obj1 objectForKey:@"id"] intValue];
            int id2 = [[obj2 objectForKey:@"id"] intValue];
            if (id1 < id2) {
                return NSOrderedAscending;
            } else if (id1 > id2) {
                return NSOrderedDescending;
            }
            return NSOrderedSame;
        }];*/
        
        [self performSelectorOnMainThread:@selector(getPinInfoCount) withObject:nil waitUntilDone:NO];

    }
}


-(void) endLoading {
    
    lbLocation.text = [[UserLocationManager sharedInstance] getCustomUserLocationAddress];
    [tvCategory reloadData];
    
    [[SHKActivityIndicator currentIndicator] hide];
    
    m_bLoadingDone = YES;

}

-(void) getUserInfoOnly {
    @autoreleasepool {
        while (![UsersPool pool].isGotUsers) {
            [NSThread sleepForTimeInterval:0.1];
        }
    }
}

-(NSString*) getAll_Count
{
    int pinCount = 0;
    for (NSMutableDictionary * dic in arrPinCount) {
        pinCount += [[dic objectForKey:@"pins_count"] intValue];
    }
    
    NSString *result = [NSString stringWithFormat:@"All Categories (%d)", pinCount];
    return result;
}
-(int) getAll_Count_Number
{
    int pinCount = 0;
    for (NSMutableDictionary * dic in arrPinCount) {
        pinCount += [[dic objectForKey:@"pins_count"] intValue];
    }
    
    return pinCount;
}

-(NSString*) getName_Count :(NSMutableDictionary*) _category
{
    NSString * name = [_category objectForKey:@"name"];
    
    int pinCount = 0;
    for (NSMutableDictionary * dic in arrPinCount) {
        NSString* _name = [dic objectForKey:@"name"];
        if ([name isEqualToString:_name]) {
            pinCount = [[dic objectForKey:@"pins_count"] intValue];
            break;
        }
    }
    
    NSString *result = [NSString stringWithFormat:@"%@ (%d)", name, pinCount];
    return result;
    
}
-(int) getName_Count_Number :(NSMutableDictionary*) _category
{
    NSString * name = [_category objectForKey:@"name"];
    
    int pinCount = 0;
    for (NSMutableDictionary * dic in arrPinCount) {
        NSString* _name = [dic objectForKey:@"name"];
        if ([name isEqualToString:_name]) {
            pinCount = [[dic objectForKey:@"pins_count"] intValue];
            break;
        }
    }
    
    return pinCount;
}


#pragma mark --------- table view delegate -------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if ([[Share getInstance].arrayCategory count] == 0) {
        return 0;
    }
    
    return [[Share getInstance].arrayCategory count] + 1 + 1;
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
        
        UIImageView * background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_back"]];
        cell.backgroundView = background;
        
        iconCategory = (UIImageView*)[cell.contentView viewWithTag:9000 + indexPath.row];
        
        if(iconCategory == nil)
        {
            iconCategory = [[UIImageView alloc] initWithFrame:CGRectMake(10, 3, 38, 38)];
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
        lbCategory.text = [self getAll_Count];
        iconCategory.image = [UIImage imageNamed:@"allcategories.png"];
        
        cell.tag = -1;
    } else if (indexPath.row == [[Share getInstance].arrayCategory count] + 1) {
        NSString * myCount = [[Share getInstance].userChatInfo objectForKey:@"pins_count"];
        if ([myCount rangeOfString:@"null"].location != NSNotFound) {
            myCount = @"0";
        }
        lbCategory.text = [NSString stringWithFormat:@"My Pins (%@)", myCount];
        iconCategory.image = [UIImage imageNamed:@"mypins.png"];
        
        cell.tag = -1;
    } else {
        NSMutableDictionary * item = [[Share getInstance].arrayCategory objectAtIndex:indexPath.row - 1];
        
        NSString * category_name = [item objectForKey:@"name"];
        iconCategory.image = [Share getCategoryImageName:category_name];
        
        lbCategory.text = [self getName_Count:item];
        
        cell.tag = [(NSString*)[item objectForKey:@"id"] intValue];
    } 
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray * selCategoryAry = [NSMutableArray new];
    int nPinSize = 0;
    int nSearchMode = CATEGORY_MODE;
    
    if (indexPath.row == [[Share getInstance].arrayCategory count] + 1) {
        nSearchMode = MYPIN_MODE;
        
        NSString * myCount = [[Share getInstance].userChatInfo objectForKey:@"pins_count"];
        if ([myCount rangeOfString:@"null"].location != NSNotFound) {
            nPinSize = 0;
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
            
        } else {
            nPinSize = [myCount intValue];
        }
        
    } else if (indexPath.row == 0) {
        nPinSize = [self getAll_Count_Number];
        if (nPinSize == 0) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        }

        [selCategoryAry removeAllObjects];

        for (NSMutableDictionary * item in [Share getInstance].arrayCategory) {
            NSMutableDictionary * _dicSelect = [[NSMutableDictionary alloc] initWithCapacity:5];
            
            [_dicSelect setObject:[item objectForKey:@"id"] forKey:@"id"];
            [_dicSelect setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];

            [selCategoryAry addObject:_dicSelect];
        }
    } else {
        NSMutableDictionary * itemSelected = [[Share getInstance].arrayCategory objectAtIndex:indexPath.row - 1];

        nPinSize = [self getName_Count_Number: itemSelected];
        if (nPinSize == 0) {

            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        }

        
        NSString * selCategoryID = [itemSelected objectForKey:@"id"];
        
        for (NSMutableDictionary * item in [Share getInstance].arrayCategory) {
            
            NSMutableDictionary * _dicSelect = [[NSMutableDictionary alloc] initWithCapacity:5];
            
            [_dicSelect setObject:[item objectForKey:@"id"] forKey:@"id"];
            
            BOOL isSelected = NO;
            NSString* categoryID = [item objectForKey:@"id"];
            if ([categoryID isEqualToString:selCategoryID]  ) {
                isSelected = YES;
            }
            
            [_dicSelect setObject:[NSNumber numberWithBool:isSelected] forKey:@"selected"];
            
            [selCategoryAry addObject:_dicSelect];
        }
        
    }

    [FilterSearch setCategory:selCategoryAry];
    
    SearchViewController * pController;
    pController = [[SearchViewController alloc] initWithValue:selCategoryAry
                                                      pinSize:nPinSize
                                                 userlocation:lbLocation.text
                                                       update:YES
                                                   searchMode:nSearchMode];
    [self.navigationController pushViewController:pController animated:YES];

    if (nSearchMode == MYPIN_MODE) {
        m_nLoadingType = LOADING_COUNT;
    } else {
        m_nLoadingType = LOADING_NONE;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction) onLocation:(id)sender
{
    int nSearchMode = CATEGORY_MODE;

    int nPinSize = [self getAll_Count_Number];
    if (nPinSize == 0) {
        return;
    }
    
    NSMutableArray * selCategoryAry = [NSMutableArray new];

    [selCategoryAry removeAllObjects];
    
    for (NSMutableDictionary * item in [Share getInstance].arrayCategory) {
        NSMutableDictionary * _dicSelect = [[NSMutableDictionary alloc] initWithCapacity:5];
        
        [_dicSelect setObject:[item objectForKey:@"id"] forKey:@"id"];
        [_dicSelect setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
        
        [selCategoryAry addObject:_dicSelect];
    }

    [FilterSearch setCategory:selCategoryAry];
    
    SearchViewController * pController;
    pController = [[SearchViewController alloc] initWithMap:selCategoryAry
                                                      pinSize:nPinSize
                                                 userlocation:lbLocation.text
                                                       update:YES
                                                   searchMode:nSearchMode];
    [self.navigationController pushViewController:pController animated:YES];
    
    if (nSearchMode == MYPIN_MODE) {
        m_nLoadingType = LOADING_COUNT;
    } else {
        m_nLoadingType = LOADING_NONE;
    }
    

}
#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
//	[self getCategories];
//    [self getPinInfoCount];
    [self refreshCount];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
//	return isLoading; // should return if data source model is reloading
    return NO;
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
	return [NSDate date]; // should return date data source was last changed
}


#pragma mark ---------------- Search Field --------
- (void)searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    
    [theSearchBar setShowsCancelButton:YES animated:YES];
    
    [viewSubDark setHidden:NO];
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{   
    searchBar.text = nil; 
    [searchBar resignFirstResponder];
    
    
    [tvCategory setContentOffset:CGPointMake(0, 44) animated:YES];
    
    [searchBar setShowsCancelButton:NO animated:YES];

    [viewSubDark setHidden:YES];

    [self hideAdvacedView];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar                     // called when keyboard search button pressed
{
    
    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if (![appDelegate isSelectedAnySearch]) {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please select pin categories for search pin." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    
    
    SearchViewController * vc;
    if (iPad) {
        vc = [[SearchViewController alloc] initWithNibName:@"SearchViewController-ipad" bundle:nil];
    } else {
        vc = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
    }
    
    vc.m_bUpdated = NO;
    vc.m_nSearchMode = SEARCH_MODE;
    
    [vc searchPins:searchBar.text];
    
    [self.navigationController pushViewController:vc animated:YES];
    
    
    [searchBar setShowsCancelButton:NO animated:NO];
    searchBar.text = nil; 
    [searchBar resignFirstResponder];
    [viewSubDark setHidden:YES];
    [self hideAdvacedView];

}


#pragma mark --- 
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

- (void) changeLocation
{
    lbLocation.text = [[UserLocationManager sharedInstance] getCustomUserLocationAddress];
}
@end
