//
//  DKTabBarItem.m
//  iQuickChecks
//
//  Created by macuser on 08.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DKTabBarItem.h"


@implementation DKTabBarItem

@synthesize controller;

- (void) dealloc {
	self.controller = nil;
}

@end
