//
//  InstructionViewController.m
//  BabyName
//
//  Created by Gold Luo on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InstructionViewController.h"
#import "AppDelegate.h"


#define MAX_PAGE    5


@implementation InstructionViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id) initWithValue:(BOOL) bFirst
{
    self = [super init];
    if (self) {
        self.m_bFirst = bFirst;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    

}


-(void) viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;

    AppDelegate * app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [app setTabBarHidden:YES animated:NO];
    
    
    count = 0;
    
    if (![Global isIPhone5]) {
        m_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    } else {
        m_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 548)];
    }
    
	m_scrollView.backgroundColor = [UIColor clearColor];
	m_scrollView.clipsToBounds = YES;
	m_scrollView.pagingEnabled = YES;
    m_scrollView.contentSize = CGSizeMake(self.view.frame.size.width * MAX_PAGE, self.view.frame.size.height);
    
	m_scrollView.showsVerticalScrollIndicator = NO;
	m_scrollView.showsHorizontalScrollIndicator = NO;
	m_scrollView.scrollsToTop = NO;
	m_scrollView.delegate = self;
	m_scrollView.tag = 3;
    [self.view insertSubview:m_scrollView atIndex:1];
	
    
    NSString * imgName[MAX_PAGE] = {@"PinAveIntro_1", @"PinAveIntro_2", @"PinAveIntro_3", @"PinAveIntro_4", @"PinAveIntro_5" };
    
    for (int i = 0 ; i < MAX_PAGE; i ++) {
        UIImageView * view;
        NSString * fileName = imgName[i];
        if ([Global isIPhone5]) {
            fileName = [NSString stringWithFormat:@"%@_iPhone5.png", fileName];
        }
        
        view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:fileName]];
        view.frame = CGRectMake(i * self.view.frame.size.width , 0, self.view.frame.size.width, self.view.frame.size.height);
        
        [m_scrollView addSubview:view];
    }
    
    pageControl = [[CustomPageControl alloc] initWithFrame:CGRectMake(110, self.view.frame.size.height - 20, 200, 13)];
    
    [pageControl setNumberOfPages:MAX_PAGE];
    [pageControl setCurrentPage:0];
    pageControl.backgroundColor = [UIColor clearColor];
    [self.view addSubview:pageControl];

}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGFloat pageWidth = m_scrollView.frame.size.width;
    float page = (m_scrollView.contentOffset.x - pageWidth / MAX_PAGE) / pageWidth + 1;

    NSLog(@"page = %f, m_nCur = %d", page, m_nCurPage);
    
    if (page > MAX_PAGE-1+0.8 && m_nCurPage >= MAX_PAGE-1) {
        NSLog(@"remove");
        [self clickNext:nil];
    }
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    CGFloat pageWidth = m_scrollView.frame.size.width;
    int page = floor((m_scrollView.contentOffset.x - pageWidth / MAX_PAGE) / pageWidth) + 1;

    m_nCurPage = page;

    [pageControl setCurrentPage:page];
    
}


- (IBAction)clickNext:(id)sender{
    
    AppDelegate *app = (AppDelegate*) [UIApplication sharedApplication].delegate;
    [app setTabBarHidden:NO animated:NO];
    
    [[Share getInstance] setFirstApp];

    if (self.m_bFirst) {
        [app.viewController gotoHomePage];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


@end
