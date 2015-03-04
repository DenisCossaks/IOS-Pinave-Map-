//
//  JsonReader.m
//  NEP
//
//  Created by Dandong3 Sam on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JsonReader.h"
#import "JSON.h"

@interface JsonReader ()

@property (strong, nonatomic) id <JsonReaderDelegate> delegate;
@property (strong, nonatomic) NSString *parseUrl;
@property (strong, nonatomic) NSMutableData *receivedData;

@end

@implementation JsonReader

@synthesize delegate, parseUrl, receivedData;

- (id)initWithUrl:(NSString *)url delegate:(id <JsonReaderDelegate>)readerDelegate
{
    if ((self = [super init])) {
        self.delegate = readerDelegate;
        self.parseUrl = url;
    }
    
    return self;
}

- (void)read
{
    self.receivedData = [NSMutableData data];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.parseUrl]];
    NSURLConnection *connetion = [NSURLConnection connectionWithRequest:request delegate:self];
    [connetion start];
}

#pragma mark - NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"Connection failed: %@", error);
    
    [self.delegate didJsonReadFail];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSString *responseString = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
	self.receivedData = nil;
    
//    NSLog(@"result = %@", responseString);
	
	SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
	id result = [JSonParser objectWithString:responseString];
	
    [self.delegate didJsonRead:result];
}


//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    exit(0);
//}
@end
