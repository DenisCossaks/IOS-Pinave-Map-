//
//  RequestsBase.h
//  Soffer Health
//
//  Created by Arthur on 1/31/12.
//  Copyright (c) 2012 Chinasoft.dk. All rights reserved.


//#define SERVER_URL @"http://myappworx.com/soffer/api"
//#define SERVER_MEDIA_DIRECTORY @"http://myappworx.com/media/"
//#define SERVER_ROOT @"http://myappworx.com"

//#define SERVER_URL @"http://soffer-staging.zingnightlife.com/api"
//#define SERVER_MEDIA_DIRECTORY @"http://soffer-staging.zingnightlife.com/media/"
//#define SERVER_ROOT @"http://soffer-staging.zingnightlife.com"

#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

#import <Foundation/Foundation.h>

@class RequestsBase;

/// Enumerates all available requests inherited from @class RequestsBase
typedef enum RequestTag
{
    REQ_STARTUPCODE,
    REQ_LOGIN,
    REQ_GETCONFIG,
    REQ_GETBILLSELECT,
    REQ_GETBILLFROMACTIVITY,
    REQ_OPENBILL,
    REQ_SAVEBILL,
    REQ_ADDDISCOUNT,
    REQ_CLOSEBILL,
    REQ_PRINTRECEIPT,
    REQ_NEXTCOURSE,
    REQ_MARKASVISITED    
} eRequestTag;

@protocol RequestProtocol

@required
/// Must be invoked by the subclasses of the RequestsBase class whenever the request execution is successfully finished
-(void) requestExecutionFinished:(RequestsBase*) req;

/// Must be invoked by the subclasses of the RequestsBase class whenever the request execution is failed
-(void) requestExecutionFailed:(RequestsBase*) req;

@optional
-(void) progressValue:(float) value forRequest:(RequestsBase*) r;

@end

/// Enumeration of the available request types
enum RequestType {
    REQUEST_TYPE_GET_SYNCHRONOUS,
	REQUEST_TYPE_PUT_ASYNCHRONOUS,
	REQUEST_TYPE_POST_ASYNCHRONOUS,
    REQUEST_TYPE_UNKNOWN
};

/// Base class for all types of requests
@interface RequestsBase : NSObject<NSURLConnectionDataDelegate> {
    NSString* requestURL;
    enum RequestType requestType;
    enum RequestTag tag;
    NSObject *userInfo;
    id<RequestProtocol> delegate;
    NSMutableData* webCache;
	NSString* requestHeaderValue;
    NSString* responseString;
    int failureRecoveryAttempts;
	ASIFormDataRequest* httpSynchronousFormDataRequest;
}

@property (nonatomic, retain) NSString* requestURL;
@property (nonatomic, assign) enum RequestType requestType;
@property (nonatomic, assign) enum RequestTag tag;
@property (nonatomic, retain) NSObject *userInfo;
@property (nonatomic, assign) id<RequestProtocol> delegate;
@property (nonatomic, retain) NSString* requestHeaderValue;

@property (nonatomic, retain) NSMutableData* webCache;
@property (nonatomic, retain) ASIFormDataRequest* httpSynchronousFormDataRequest;
@property (nonatomic, retain) NSString* responseString;
@property (nonatomic, retain) NSData*   responseData;

/** 
 The following methods must be implemented by the sub-classses
 */

/// Should parse the given as an argument response
-(void) parseResponse:(NSString*) response;

/**
 The methods described below are used only for synchronous post requests
 */

/// Sets the post value for the given key
-(void) setPostValue:(id<NSObject>) value forKey:(NSString *)key;

/// Sets the file for sending with post method
-(void)setFile:(id<NSObject>)data withFileName:(NSString *)fileName andContentType:(NSString *)contentType forKey:(NSString *)key;

/// Sets the post body for sending with post method
-(void)setPostBody:(NSMutableData*)body;

/**
 Public API
 */

/// Executes the request
-(void) execute;

+(id) requestGETWith:(NSString *)url delegate:(id<RequestProtocol>)delegate;
+(id) requestPOSTWithURL:(NSString *)url delegate:(id<RequestProtocol>)delegate;
@end
