//
//  AddLocationViewController.m
//  PinAve
//
//  Created by Gold Luo on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddLocationViewController.h"
#import "AppDelegate.h"
#import "SBJSON.h"

@interface AddLocationViewController ()

- (void) addCurrentLocation ;

@end

@implementation AddLocationViewController

@synthesize delegate;

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
    
    
    arrayLocations = [[NSMutableArray alloc] initWithCapacity:10];
    
    // add Current Location 
    [self addCurrentLocation];
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


- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setTabBarHidden:YES animated:YES];
}

- (void) addCurrentLocation
{
//    NSMutableDictionary * curLocation = [[NSMutableDictionary alloc] initWithCapacity:10];
//    [curLocation setObject:[NSString stringWithFormat:@"%f", [UserLocationManager sharedInstance].currentLocation.coordinate.latitude ] forKey:@"lat"];
//    [curLocation setObject:[NSString stringWithFormat:@"%f", [UserLocationManager sharedInstance].currentLocation.coordinate.longitude] forKey:@"lng"];
//    
//    [curLocation setObject:@"Current Location" forKey:@"title"];

    CLLocationCoordinate2D coord = [UserLocationManager sharedInstance].currentLocation.coordinate;

    Address *curLocation = [[Address alloc] initWithCoordinate:coord];
    
    curLocation.fullAddress = @"Current Location";
    
    if ([arrayLocations count] == 0) {
        [arrayLocations addObject:curLocation];
    } else {
        [arrayLocations insertObject:curLocation atIndex:0];
    }
}


#pragma mark --------------- Table view ---------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrayLocations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MenuCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        UIImageView * background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_back"]];
        cell.backgroundView = background;
    }
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
    

    Address * item = [arrayLocations objectAtIndex:indexPath.row];
    
    cell.textLabel.text = item.fullAddress;
    
    if (indexPath.row == 0) {
        cell.textLabel.textColor = [UIColor blueColor];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > [arrayLocations count]) {
        return;
    }
    
    if (indexPath.row == 0) { //current location
        [UserLocationManager sharedInstance].latestLocation = nil;
    }
    else {
        Address * item = [arrayLocations objectAtIndex:indexPath.row];
        
        [UserLocationManager sharedInstance].latestLocation = [[CLLocation alloc] initWithLatitude:item.coordinate.latitude longitude:item.coordinate.longitude];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [delegate changeLocation];
    
    [self dismissModalViewControllerAnimated:YES];

}

#pragma mark ---------------- Search Field --------

- (void) searchAddress :(NSString*) txtSearch
{
    [[SHKActivityIndicator currentIndicator] displayActivity:@"Loading..." : self];
    
    [arrayLocations removeAllObjects];
    
    [self addCurrentLocation];
    
    NSArray * listArry = [GeoLocation getCoordinateListByAddress:txtSearch];
    NSLog(@"search = %@", listArry);
    
    if (listArry != nil) {
        [arrayLocations addObjectsFromArray:listArry];
    }
    
    [table reloadData];
    
    [[SHKActivityIndicator currentIndicator] hide];

}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {

    theSearchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{   
    searchBar.text = nil; 
    if ([searchBar isFirstResponder]) {
        [searchBar resignFirstResponder];
    }
    
    [self dismissModalViewControllerAnimated:YES];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar                     // called when keyboard search button pressed
{
    if ([searchBar isFirstResponder]) {
        [searchBar resignFirstResponder];
    }
    searchBar.showsCancelButton = NO;
    
    [self searchAddress:searchBar.text];
}

/*
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text 
{
    
    [self searchAddress:searchBar.text];
    
    return YES;
    
}
*/
@end
