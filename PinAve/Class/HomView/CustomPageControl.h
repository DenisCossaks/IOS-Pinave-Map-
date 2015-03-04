//
//  CustomPageControl.h
//  Cookit
//
//  Created by SIMON Aymeric on 09/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CustomPageControl : UIView {

    int numberOfPages;
    int currentPage;
}


- (void) setCurrentPage:(int)_currentPage;
- (void) setNumberOfPages:(int)_numberOfPage;

@end
