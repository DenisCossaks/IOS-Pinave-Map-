//
//  RequestsBase.m
//  Soffer Health
//
//  Created by Arthur on 1/31/12.
//  Copyright (c) 2012 Chinasoft.dk. All rights reserved.
//

#import "RequestsBase.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "NSString+HTML.h"

@interface RequestsBase (Private)

-(void) executeAsynchronousWithMethod:(NSString*) method;
-(void) executeSynchronousWithMethod:(NSString*) method;

@end

@implementation RequestsBase

@synthesize requestURL;
@synthesize requestType;
@synthesize tag;
@synthesize delegate;
@synthesize requestHeaderValue;

@synthesize webCache;
@synthesize httpSynchronousFormDataRequest;
@synthesize responseString;
@synthesize responseData;
@synthesize userInfo;
-(void) parseResponse:(NSString*) response {
    
}

-(void) execute {
	switch(requestType) {
		case REQUEST_TYPE_GET_SYNCHRONOUS:
			[self executeSynchronousWithMethod:@"GET"];
			break;
		case REQUEST_TYPE_PUT_ASYNCHRONOUS:
			[self executeAsynchronousWithMethod:@"PUT"];
			break;
		case REQUEST_TYPE_POST_ASYNCHRONOUS:
			[self executeAsynchronousWithMethod:@"POST"];
			break;
		default:
			break;
	}
}

+(id) requestGETWith:(NSString *)url delegate:(id<RequestProtocol>)delegate
{
    RequestsBase *requestBase = [[[RequestsBase alloc] init] autorelease];
    requestBase.requestURL = url;
    requestBase.requestType = REQUEST_TYPE_GET_SYNCHRONOUS;
    requestBase.delegate = delegate;
    return requestBase;
}

+(id) requestPOSTWithURL:(NSString *)url delegate:(id<RequestProtocol>)delegate
{
    RequestsBase *requestBase = [[[RequestsBase alloc] init] autorelease];
    requestBase.requestURL = url;
    requestBase.requestType = REQUEST_TYPE_POST_ASYNCHRONOUS;
    requestBase.delegate = delegate;
    return requestBase;
}

-(void) dealloc {
	self.requestHeaderValue = nil;
    [webCache release];
    [requestURL release];
    [requestHeaderValue release];
	[httpSynchronousFormDataRequest release];
    [responseString release];
    [userInfo release];
	[super dealloc];
}

#pragma mark Public API implementation

-(void) setPostValue:(id<NSObject>) value forKey:(NSString *)key {
	[httpSynchronousFormDataRequest setPostValue:value forKey:key];
}

-(void)setFile:(id<NSObject>)data withFileName:(NSString *)fileName andContentType:(NSString *)contentType forKey:(NSString *)key {

	[httpSynchronousFormDataRequest setFile:(NSString *)data withFileName:fileName andContentType:contentType forKey:key];
}

-(void)setPostBody:(NSMutableData*)body {
	[httpSynchronousFormDataRequest setPostBody:body];
}

-(void) setRequestType:(enum RequestType)rt {
	requestType = rt;
    
	if(REQUEST_TYPE_PUT_ASYNCHRONOUS == requestType ||
	   REQUEST_TYPE_POST_ASYNCHRONOUS == requestType) {
		NSURL* url = [NSURL URLWithString:requestURL];
        
		self.httpSynchronousFormDataRequest = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease]  ;
	}
}

#pragma mark Private API implementation

-(void) executeAsynchronousWithMethod:(NSString*) method {
    [httpSynchronousFormDataRequest setRequestMethod:method] ;
    [httpSynchronousFormDataRequest setTimeOutSeconds:120];
    
    //NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (requestHeaderValue)
        [httpSynchronousFormDataRequest addRequestHeader:@"Content-Type" value:requestHeaderValue];
    //[httpSynchronousFormDataRequest addRequestHeader:@"Authorization" value:[userDefault objectForKey:@"Authentication"]];
	
	[httpSynchronousFormDataRequest setDelegate:self];
	[httpSynchronousFormDataRequest setDidFinishSelector:@selector(requestFinished:)];
    [httpSynchronousFormDataRequest setDidFailSelector:@selector(requestFailed:)];	
	
    [httpSynchronousFormDataRequest startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)req {
	self.responseString = [[httpSynchronousFormDataRequest responseString] stringByDecodingHTMLEntities];
    self.responseData = [httpSynchronousFormDataRequest responseData];
	[delegate requestExecutionFinished:self];
}

- (void)requestFailed:(ASIHTTPRequest *)req {

    NSLog(@"%d", httpSynchronousFormDataRequest.responseStatusCode);
	[delegate requestExecutionFailed:self];
}

-(void) executeSynchronousWithMethod:(NSString*) method {
    NSURL* url = [NSURL URLWithString: requestURL];
    NSMutableURLRequest *r = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:120.0];
    //NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    //[r setValue:[userDefault objectForKey:@"Authentication"] forHTTPHeaderField:@"Authorization"];
    [r setHTTPMethod:method];
    [[[NSURLConnection alloc] initWithRequest:r delegate:self] autorelease];
}

#pragma mark NSURLConnectionDataDelegate methods implementation

-(void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)response {
	self.webCache = [NSMutableData data];
    failureRecoveryAttempts = 5;
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[self.webCache appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [delegate requestExecutionFailed:self];
    
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection {
    self.responseString = [[[[NSString alloc] initWithData:webCache encoding:NSUTF8StringEncoding] autorelease] stringByDecodingHTMLEntities];
    [delegate requestExecutionFinished:self];
}

@end
