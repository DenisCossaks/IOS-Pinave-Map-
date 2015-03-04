//
//  SendMessageController.m
//  PinAve
//
//  Created by Optiplex790 on 9/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SendMessageController.h"
#import <QuartzCore/QuartzCore.h>


@interface SendMessageController ()

@end

@implementation SendMessageController

@synthesize pinInfo;


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
    
    tvMessage.layer.cornerRadius = 5.0;

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

-(void) viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    
    NSLog(@"pinInfo = %@", self.pinInfo);
    
    NSString * name = [self.pinInfo objectForKey:@"author"];
    
    if ([name rangeOfString:@"null"].location != NSNotFound) {
        name = @"";
    }
    lbName.text = name;
    
    tvMessage.text = [NSString stringWithFormat:@"Hello %@\n", lbName.text];
    
    [tvMessage becomeFirstResponder];
}


-(IBAction) onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction) onSend:(id)sender
{
    NSString * message = tvMessage.text;
    
    NSString * sId = [self.pinInfo objectForKey:@"id"];
    NSString * user_id = [self.pinInfo objectForKey:@"user_id"];

    if (sId == nil || sId.length < 1 || [sId isEqualToString:@"(null)"]) {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Pin id is fail!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    if (user_id == nil || user_id.length < 1 || [user_id isEqualToString:@"(null)"]) {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"User id is fail!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    if (message.length < 1) {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please input message" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    
    
    [[SHKActivityIndicator currentIndicator] displayActivity:@"Loading..." : self];
 
    NSString * _auth_code = [[NSUserDefaults standardUserDefaults] objectForKey:@"loginCode"];
    

    NSString *url = [[SERVER_URL stringByAppendingFormat:@"request/mail/%@", _auth_code] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"url = %@", url);
    
    IAMultipartRequestGenerator *request = [[IAMultipartRequestGenerator alloc] initWithUrl:url andRequestMethod:@"POST"];
    
    
    [request setString:sId forField:@"pin"];
    NSLog(@"pin = %@", sId);
    
    [request setString:user_id forField:@"recepient"];
    NSLog(@"recepient = %@", user_id);
    
    [request setString:message forField:@"message"];
    NSLog(@"message = %@", message);
    
    
    [request setDelegate:self];
    [request startRequest];
    
    [tvMessage resignFirstResponder];
//    tvMessage.text = @"";
}



#pragma mark
#pragma mark IAMultipartRequestGenerator delegate methods

-(void)requestDidFailWithError:(NSError *)error 
{
    NSLog(@"IAMultipartRequestGenerator request failed");

    [[SHKActivityIndicator currentIndicator] hide];
    
}


-(void)requestDidFinishWithResponse:(NSData *)responseData 
{
    NSString *response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"IAMultipartRequestGenerator finished: %@", response);
    
    [[SHKActivityIndicator currentIndicator] hide];

    if ([response rangeOfString:@"message"].location != NSNotFound && [response rangeOfString:@"OK"].location != NSNotFound) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                         message:@"Your message has been sent. Please expect a response by email" 
                                                        delegate:self
                                               cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Fail!" delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];

    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self onBack:nil];
    }
}


@end
