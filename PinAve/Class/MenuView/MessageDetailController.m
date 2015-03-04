//
//  MessageDetailController.m
//  NEP
//
//  Created by Dandong3 Sam on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MessageDetailController.h"
#import "Utils.h"
#import "SHKActivityIndicator.h"

@interface MessageDetailController ()

@end

@implementation MessageDetailController

@synthesize messageInfo;
@synthesize titleLbl, fromLbl, toLbl, dateLbl, messageViw, frameScrl, replyFld, replyFrame;

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
    
    self.navigationItem.title = @"Message";
    self.titleLbl.text = [self.messageInfo objectForKey:@"title"];
    self.fromLbl.text = [self.messageInfo objectForKey:@"user"];
    self.toLbl.text = [self.messageInfo objectForKey:@"recepient_id"];
    self.dateLbl.text = [self.messageInfo objectForKey:@"currtime"];
    [self.messageViw loadHTMLString:[messageInfo objectForKey:@"message"] baseURL:nil];
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

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"%f", webView.frame.size.height);
    [webView sizeToFit];
    self.frameScrl.contentSize = CGSizeMake(0, CGRectGetMaxY(webView.frame));
    NSLog(@"%f", webView.frame.size.height);
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 animations:^{
        self.frameScrl.frame = CGRectMake(0, 0, 320, 168);
        self.replyFrame.frame = CGRectMake(0, 168, 320, 32);
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 animations:^{
        self.frameScrl.frame = CGRectMake(0, 0, 320, 384);
        self.replyFrame.frame = CGRectMake(0, 384, 320, 32);
    }];
}

- (IBAction)onSend:(id)sender
{
    if ([self.replyFld.text length] == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please enter message..." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    [[SHKActivityIndicator currentIndicator] displayActivity:@"Sending..." : self];
    
    NSString *urlString = [Utils getWriteUrl:[@"Re: " stringByAppendingString:self.titleLbl.text] message:self.replyFld.text recepient_id:[self.messageInfo objectForKey:@"user_id"] reply:[self.messageInfo objectForKey:@"id"]];
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
        [self.replyFld resignFirstResponder];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Fail to sending message. Please retry." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

@end
