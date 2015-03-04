//  UIImageView+Cached.h
//
//  Created by Lane Roathe
//  Copyright 2009 Ideas From the Deep, llc. All rights reserved.

#import "UIImageView+Cached.h"

#pragma mark -
#pragma mark --- Threaded & Cached image loading ---

@implementation UIImageView (Cached)

// max # of images we will cache before flushing cache and starting over
#define MAX_CACHED_IMAGES 50

// method to return a static cache reference (ie, no need for an init method)
- (NSMutableDictionary *)cache
{
	static NSMutableDictionary *_cache = nil;
	
	if( !_cache )
		_cache = [NSMutableDictionary dictionaryWithCapacity:MAX_CACHED_IMAGES];

	assert(_cache);
	return _cache;
}

// Loads an image from a URL, caching it for later loads
// This can be called directly, or via one of the threaded accessors
- (void)cacheFromURL:(NSURL *)url
{
    @autoreleasepool {
        UIImage *newImage = [[self cache] objectForKey:url.description];
        if (!newImage) {
			NSError *err = nil;
			
			newImage = [UIImage imageWithData: [NSData dataWithContentsOfURL:url options:NSDataWritingAtomic error:&err]];
			if ( newImage ) {
				// check to see if we should flush existing cached items before adding this new item
				if( [[self cache] count] >= MAX_CACHED_IMAGES )
					[[self cache] removeAllObjects];
                
				[[self cache] setValue:newImage forKey:url.description];
			} else {
				NSLog( @"UIImageView:LoadImage Failed: %@", err );
            }
        }
        
        if ( newImage ) {
            [self performSelectorOnMainThread:@selector(setImage:) withObject:newImage waitUntilDone:NO];
        }
    }
}

// Methods to load and cache an image from a URL on a separate thread
- (void)loadFromURL:(NSURL *)url
{
	[self performSelectorInBackground:@selector(cacheFromURL:) withObject:url]; 
}

-(void)loadFromURL:(NSURL *)url afterDelay:(float)delay
{
	[self performSelector:@selector(loadFromURL:) withObject:url afterDelay:delay];
}

@end