//
//  DKTabBarViewController.m
//  iQuickChecks
//
//  Created by macuser on 08.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DKTabBarViewController.h"
#import "DKTabBarItem.h"


@implementation DKTabBarViewController

@synthesize tabBarItems;
@synthesize tabBarContainer;
@synthesize tabBarBGImageView;
@synthesize selectedViewController;


// -------------------------------------------------------------------------------

#pragma mark -
#pragma mark Memory Managment Methods

- (void) dealloc {
	self.tabBarItems       = nil;
	self.tabBarBGImageView = nil;
}

// -------------------------------------------------------------------------------

- (void) didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

// -------------------------------------------------------------------------------

#pragma mark -
#pragma mark Load Methods

#define kItemHeight 56
#define kItemWidth 64
#define kTabBarHeight 56

- (void) viewDidLoad {
    [super viewDidLoad];
	
	self.view.backgroundColor = [UIColor clearColor];
	
	CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
	tabBarContainer = [[UIView alloc] 
		initWithFrame:CGRectMake(0, appFrame.size.height - kTabBarHeight, appFrame.size.width, kTabBarHeight)];
	[self.view addSubview:tabBarContainer];
	
    CGFloat margin = (iPhone ? 0 : 10);
    
	tabBarItemsContainer = [[UIView alloc] 
		initWithFrame:CGRectMake(0, 0, (kItemWidth + margin) * [self.tabBarItems count], kTabBarHeight)];
	tabBarItemsContainer.backgroundColor = [UIColor clearColor];
	
	tabBarBGImageView.frame = CGRectMake(0, 0, appFrame.size.width, kTabBarHeight);
	[tabBarContainer addSubview:tabBarBGImageView];
    
	for (int i = 0; i < [self.tabBarItems count]; i++) {
		DKTabBarItem *item = [self.tabBarItems objectAtIndex:i];
		item.frame = CGRectMake(kItemWidth * i + margin * i, kTabBarHeight - kItemHeight, kItemWidth, kItemHeight);
		if (item.controller != nil) {
			[item addTarget:self action:@selector(tabBarItemHandler:) forControlEvents:UIControlEventTouchUpInside];
		}
		[tabBarItemsContainer addSubview:item];
	}
	
	[tabBarContainer addSubview:tabBarItemsContainer];
	tabBarItemsContainer.center = CGPointMake(appFrame.size.width / 2, tabBarItemsContainer.center.y);
}

// -------------------------------------------------------------------------------

- (void) viewDidUnload {
    [super viewDidUnload];
	
	self.tabBarBGImageView = nil;
}

// -------------------------------------------------------------------------------

- (void) setSelectedItemWithIndex:(NSInteger) index 
{    
	CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
	DKTabBarItem *selectedItem = [tabBarItems objectAtIndex:index];
	
	for (int i = 0; i < [self.tabBarItems count]; i++)
    {
		DKTabBarItem *item = [self.tabBarItems objectAtIndex:i];
		if ([item isEqual:selectedItem]) continue;
		if (item.selected)
        {
//			[item.controller viewWillDisappear:NO];
//			[item.controller.view removeFromSuperview];
		}
		item.selected = NO;
	}
	selectedItem.selected  = YES;
	selectedViewController = selectedItem.controller;
	selectedItem.controller.view.frame = CGRectMake(0, 0, appFrame.size.width, appFrame.size.height);
    
	[selectedItem.controller viewWillAppear:NO];
	
	[self.view addSubview:selectedItem.controller.view];
	[self.view bringSubviewToFront:tabBarContainer];
}

// -------------------------------------------------------------------------------

#pragma mark -
#pragma mark Action Methods

- (IBAction) tabBarItemHandler:(id) sender {
	for ( DKTabBarItem* item in tabBarItems )
    {
        if ( item.selected )
        {
            [(UINavigationController*)item.controller popToRootViewControllerAnimated: NO];
            break;
        }
    }
	DKTabBarItem *theItem = (DKTabBarItem *) sender;
	if (theItem.selected) return;

	NSInteger index = [tabBarItems indexOfObject:theItem];
	[self setSelectedItemWithIndex:index];
}

// -------------------------------------------------------------------------------

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
    
/*    
    if (iPhone)
    {
        return YES;
    }
    else
    {
        return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
    }
*/ 
}

/*
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    for (int i = 0; i < [self.tabBarItems count]; i++) 
    {
        DKTabBarItem *item = [self.tabBarItems objectAtIndex:i];
        if (item.selected) 
        {
            [item.controller willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
        }
    }
}
*/
@end
