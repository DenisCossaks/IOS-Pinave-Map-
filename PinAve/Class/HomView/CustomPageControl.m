//
//  CustomPageControl.m
//  Cookit
//
//  Created by SIMON Aymeric on 09/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import "CustomPageControl.h"


@implementation CustomPageControl



/** override to update dots */
- (void) setCurrentPage:(int)_currentPage
{

    currentPage = _currentPage;
    
    // update dot views
    
    [self setNeedsDisplay];
    
}

- (void) setNumberOfPages:(int)_numberOfPage
{
    numberOfPages = _numberOfPage;
    
//    [self setNeedsDisplay];
}


- (void) drawRect:(CGRect) iRect {
    UIImage                 *nor, *sel, *image;
    int                     i;
    CGRect                  rect;
    
    const CGFloat           kSpacing = 10.0;
    
    iRect = self.bounds;
    
    
    nor   = [UIImage imageNamed: @"page_sel.png"];
    sel   = [UIImage imageNamed: @"page_nor.png"];
    
    rect.size.height = iRect.size.height;
    rect.size.width  = iRect.size.height; //(iRect.size.width - kSpacing * numberOfPages) / numberOfPages;
    
    rect.origin.x = 0;
    rect.origin.y = 0;
    
    for ( i = 0; i < numberOfPages; ++i ) {
        rect.origin.x = (rect.size.width + kSpacing) * i;
        
        image = i == currentPage ? sel : nor;
        
        [image drawInRect: rect];
    }
}

@end
