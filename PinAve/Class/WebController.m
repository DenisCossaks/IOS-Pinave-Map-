//
//  WebController.m
//  GrouplyDeals
//
//  Created by champion on 11. 8. 3..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WebController.h"
#import <QuartzCore/QuartzCore.h>


@implementation WebController

@synthesize m_urlPost;


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	m_viwLoading.layer.cornerRadius = 10;
}

- (void) viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;

  	[m_viwWeb loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.m_urlPost]]];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	if ([webView isEqual:m_viwWeb]) {
		if (m_viwLoading.superview == nil) {
			[self.view addSubview:m_viwLoading];
		}
		
		[m_actLoading startAnimating];
	}
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	if ([webView isEqual:m_viwWeb]) {
		[m_actLoading stopAnimating];
		[m_viwLoading removeFromSuperview];
	}
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	if ([webView isEqual:m_viwWeb]) {
		[m_actLoading stopAnimating];
		[m_viwLoading removeFromSuperview];
		
		NSLog(@"webview load fail (%@)", [error localizedDescription]);
	}
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (IBAction) onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[m_viwWeb stopLoading];
	m_viwWeb.delegate = nil;
	m_viwWeb = nil;

}


@end
