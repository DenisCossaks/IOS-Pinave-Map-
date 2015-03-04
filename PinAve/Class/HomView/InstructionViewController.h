//
//  InstructionViewController.h
//  BabyName
//
//  Created by Gold Luo on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "CustomPageControl.h"


@interface InstructionViewController : UIViewController <UIAlertViewDelegate, UIScrollViewDelegate>
{

    int count;
    CustomPageControl *pageControl;
    
	UIScrollView*	m_scrollView;

    int m_nCurPage;
    
}

@property (nonatomic, assign) BOOL m_bFirst;

-(id) initWithValue:(BOOL) bFirst;


- (IBAction)clickNext:(id)sender;

@end
