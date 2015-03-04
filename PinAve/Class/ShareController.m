//
//  ShareController.m
//  ChrismasBubble
//
//  Created by Kim SongIl on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ShareController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"


@interface ShareController ()
- (void) postFacebook;
- (void) postTwitter;
@end

@implementation ShareController

@synthesize shareMode;

- (void)initWithMode:(int)mode {

    shareMode = mode;

}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    roundBorderView.layer.cornerRadius = 10;
    
    if (shareMode == SHARE_FACEBOOK) {
        laTitle.text = @"FaceBook";
        characterBG.hidden = YES;
        characterLabel.hidden = YES;
    }
    else {
        laTitle.text = @"Twitter";
        characterLabel.text = @"140";
    }
    
    imgShare = [UIImage imageNamed:@"icon512"];
    
    NSString* favoriteNamesText = @"Welcome to PinAve. I found there many useful and interesting stuff: http://pinave.com/user/create?refer=TEdY89CwGtUDTJF0hr";
  
    
    descriptionView.text = favoriteNamesText;
    int length = [favoriteNamesText length];
    characterLabel.text = [NSString stringWithFormat:@"%d", 140 - length];
    

//    [descriptionView becomeFirstResponder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setTabBarHidden:YES animated:YES];
}



#pragma mark - On click methods
- (IBAction)actionCancel:(id)sender {
    
    [descriptionView resignFirstResponder];
    
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)actionShare:(id)sender {
    
    [descriptionView resignFirstResponder];
    
    if ([descriptionView.text length] == 0) {
        
        UIAlertView * alerView = [[UIAlertView alloc] initWithTitle:@"Information" message:@"Message is empty!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alerView show];
       
        return;
    }
    
    if (shareMode == SHARE_FACEBOOK) {
        [self postFacebook];
    }
    else {
        int length = [laTitle.text intValue];
        if (length < 0) {
            UIAlertView * alerView = [[UIAlertView alloc] initWithTitle:@"Information" message:@"Message is very many so that can not post!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alerView show];
            
            return;
        }
        
        [self postTwitter];
    }

}




#pragma mark -----------------------------


- (void) startAnimating {
    [[SHKActivityIndicator currentIndicator] displayActivity:@"Loading..." : self];  
}

- (void) stopAnimating {
    [[SHKActivityIndicator currentIndicator] hide];
}

- (void) messagePostedSuccessfully
{
    [self stopAnimating];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: nil message: @"Thanks for sharing." delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
    [alert show];
    
}

- (void)postFacebook {
//    UIImage *image = imgShare;
//    
//    NSString* favoriteNamesText = descriptionView.text;
//
//	FacebookManager* myFacebook = [FacebookManager sharedInstance];
//	[myFacebook setDelegate: self];
//	if ( [[myFacebook facebook] isSessionValid]) {
//        [[FacebookManager sharedInstance] postMessage: favoriteNamesText andCaption: favoriteNamesText andImage: image];
//    }

    NSString *message = descriptionView.text;
  
    [self startAnimating];
    
    [FBRequestConnection startForPostStatusUpdate:message
                                completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                    
                                    [self messagePostedSuccessfully];
//                                    [self showAlert:message result:result error:error];
                                    
                                }];
    
}
-(void) postTwitter
{
    //    NSAutoreleasePool *autoreleasePool = [[NSAutoreleasePool alloc] init];
    TwitterManager *tmanager = [TwitterManager sharedTwitterManager];
    [tmanager setDelegate:nil];
    [tmanager setDelegate:self];
    
    UIImage *image = imgShare;
    
    NSString* favoriteNamesText = descriptionView.text;
    
    
    if ([[tmanager engine] isAuthorized]) 
    {
        [self startAnimating];
        if (image) {
            [tmanager postImage:image message:favoriteNamesText];
        }
        else {
            [tmanager postMessage:favoriteNamesText];
        }
        
    }
    else 
    {
        twitterMessage = [[NSDictionary alloc] initWithObjectsAndKeys:favoriteNamesText,@"text",image,@"image", nil];
        [tmanager authorizeUserFromController:self];
    }
    //    [autoreleasePool release];
    
}




// ----------------------------------------------------------------------------
#pragma mark TwitterManager Delegate methods
// ----------------------------------------------------------------------------
- (void)twitterManager:(TwitterManager *)manager didAuthenticateUser:(NSString *)username {
    if (twitterMessage) {
        [self startAnimating];
        TwitterManager *tManager = [TwitterManager sharedTwitterManager];
        [tManager setDelegate:nil];
        [tManager setDelegate:self];
        
        //        [tManager postMessage:[twitterMessage objectForKey:@"text"]];
        
        if ([twitterMessage objectForKey:@"image"]) {
            [tManager postImage:[twitterMessage objectForKey:@"image"] message:[twitterMessage objectForKey:@"text"]];
        }
        else {
            [tManager postMessage:[twitterMessage objectForKey:@"text"]];
        }
        
        twitterMessage = nil;
    }
}

- (void)twitterManager:(TwitterManager *)manager failedToAuthenticateWithError:(NSError *)error {
    [self stopAnimating];
    
    if (twitterMessage) {
        twitterMessage = nil;
    }
    
/*    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                     message:@"Posting fail" 
                                                    delegate:nil
                                           cancelButtonTitle:@"YES" 
                                           otherButtonTitles:nil, nil];
    [alert show];
*/ 
    
}

- (void)twitterManager:(TwitterManager *)manager didPostMessage:(NSError *)error {
    [self stopAnimating];
    if (!error) {
        [self  messagePostedSuccessfully];
    }
    else{
        NSLog(@"Error = %@", error);

/*        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:@"Posting fail" 
                                                        delegate:nil
                                               cancelButtonTitle:@"YES" 
                                               otherButtonTitles:nil, nil];
        [alert show];
*/ 
    }
    
}


- (void)twitterManager:(TwitterManager *)manager didPostImage:(NSError *)error {
    [self stopAnimating];
    if (!error) {
        [self messagePostedSuccessfully];
    }
    else{
        NSLog(@"Error = %@", error);

/*        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:@"Posting fail" 
                                                        delegate:nil
                                               cancelButtonTitle:@"YES" 
                                               otherButtonTitles:nil, nil];
        [alert show];
*/ 
    }
}

/*
#pragma mark FacebookManagerDelegate Methods
- (void) facebookLoginSucceeded 
{
    [self startAnimating];
    
    
    UIImage *image = imgShare;
    
	NSString * favoriteNamesText = descriptionView.text;
    
	[[FacebookManager sharedInstance] postMessage: favoriteNamesText andCaption: favoriteNamesText andImage: image];
	
    
}

- (void) facebookLoginFailed {
    NSLog(@"facebook login failed");
    [self stopAnimating];
    
}
*/

- (void) messagePostingFailedWithError:(NSError *)error {
    [self stopAnimating];

/*    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"Posting Fail"
                                                   delegate:nil
                                          cancelButtonTitle:@"YES"
                                          otherButtonTitles:nil, nil];
    [alert show];
*/
    
}




- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	
	if ([text isEqualToString:@"\n"]) {  
		[textView resignFirstResponder];  
		return NO;
	}

    if (shareMode == SHARE_FACEBOOK) {
        return YES;
    }

	int result = NO;
	NSString* string = [[textView text] stringByReplacingCharactersInRange:range withString:text];
	if ([string length] <= 140) {
		result = YES;
	}
	
	int remainCount = 140 - [string length];
	characterLabel.text = [NSString stringWithFormat:@"%d", (remainCount < 0 ) ? 0 : remainCount]; 
	
	return result;
}

@end
