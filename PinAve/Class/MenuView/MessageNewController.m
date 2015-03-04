//
//  MessageNewController.m
//  NEP
//
//  Created by Dandong3 Sam on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MessageNewController.h"
#import "SHKActivityIndicator.h"
#import "Utils.h"

@interface MessageNewController ()

@end

@implementation MessageNewController

@synthesize toAddressFld, messageTxt;

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
    
    [self.toAddressFld becomeFirstResponder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)onCancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)onSend:(id)sender
{
    if ([self.toAddressFld.text length] == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please enter a person to send." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    if ([self.messageTxt.text length] == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please enter a message to send." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    [[SHKActivityIndicator currentIndicator] displayActivity:@"Sending..." : self];
    
    NSString *urlString = [Utils getWriteUrl:@"New Message" message:self.messageTxt.text recepient_id:self.toAddressFld.text reply:@"0"];
    JsonReader *jsonReader = [[JsonReader alloc] initWithUrl:urlString delegate:self];
    [jsonReader read];
}

- (void)didJsonReadFail
{
    [[[UIAlertView alloc] initWithTitle:@"" message:@"Oops! We seem to be experiencing a system overload. Please try again in a few minute." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}
- (void)didJsonRead:(id)result
{
    NSDictionary *messageResult = result;
    if (messageResult && [@"OK" isEqualToString:[messageResult objectForKey:@"message"]]) {
        [[SHKActivityIndicator currentIndicator] displayCompleted:@"Success!"];
        [self onCancel:nil];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Fail to sending message. Please retry." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

@end
