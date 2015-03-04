//
//  Utils.h
//  NEP
//
//  Created by Dandong3 Sam on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define SERVER_URL          @"http://pinave.com/"
#define CHAT_URL            @"http://blazing-frost-9185.herokuapp.com/"
#define ShowActivePinKey    @"kShowActivePin"
#define ShowActiveFromKey   @"kShowActiveFrom"
#define ShowActiveToKey     @"kShowActiveTo"


enum DATE_OPTION {
    DATE_FULL,
    DATE_DATE,
    DATE_TIME
    };


@interface Utils : NSObject

#pragma mark ------ Pin Information ----------
+ (NSString *)getLoginUrl:(NSString *)email password:(NSString *)password;
+ (NSString *)getLogoutUrl;
+ (NSString *)getMessageUrl;
+ (NSString *)getSentMsgUrl;
+ (NSString *)getWriteUrl:(NSString *)title message:(NSString *)message recepient_id:(NSString *)recepient_id reply:(NSString *)message_id;
+ (NSString *)getCategoryUrl;
+ (NSString *)getUsersUrl;
+ (NSString *)getProfileDetail:(NSString*) authCode;
+ (NSString *)postProfileDetail;

+ (NSString *)getPinForUserUrl:(NSString *)user_id;
+ (NSString *)getPinForUserUrl1:(NSString *)user_id;
+ (NSString *)getPinFromLocation:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude :(CLLocationDegrees) radius;

+ (NSString *)getCountPins;
+ (NSString *)getMyAvenueUsersUrl;


+ (NSString *)getPinForCurrentUser;
+ (NSString *)getPinForUser : (NSMutableArray* ) arrCategory : (float) _radius :(int) curPage : (int) limitPin;
+ (NSString *)getPinForUser : (NSMutableArray* ) arrCategory : (float) _radius;
+ (NSString *)getPinForRealUser : (NSMutableArray* ) arrCategory : (float) _radius;

+ (NSString *)getRegisterUrl;
+ (NSString *)getPlacePinUrl;
+ (NSString *)getUpdateDetailUrl;
+ (NSString *)getSearchUrl:(NSString*) search :(NSString*) country : (NSString*) city : (NSMutableArray*) arrCategory : (int) timeOption;
+ (NSString *)getSearchUrl:(NSString*) search : (NSMutableArray*) arrCategory : (int) timeOption;

+(NSString* ) getAddressURLFromLocation:(CLLocationDegrees)latitude : (CLLocationDegrees)longitude;
+(NSString* ) getSearchURLFromText:(NSString*) searchText;

+(NSString* ) getRatingUrl:(NSString*) pinID;
+(NSString* ) postRatingUrl:(NSString*) userCode : (NSString*) pinID : (int) rate;

+(NSString* ) postAddUserUrl:(NSString*) userCode : (int) userId;
+(NSString* ) postDeleteUserUrl:(NSString*) userCode : (int) userId;
+(NSString* ) postAdd_RemovePinUrl:(NSString*) userCode : (int) pinId;

+(NSString* ) isAvenuePinUrl:(NSString*) userCode : (int) pinId;
+(NSString* ) isAvenueUserUrl:(NSString*) userCode : (int) userId;
+(NSString* ) isReviewedUrl:(NSString*) userCode : (int) pinId;

+(NSString* ) getDeletePinUrl:(NSString*) userCode : (NSString*) pinId;
    
+ (NSString *)getPinAroundRoute:(NSMutableArray *) arrlocation;    


#pragma mark ------------- date ------
+(NSDate*) dateFromString:(NSString*) string : (int) option;
+(NSString*) getDateString:(NSDate*) date : (int) option;



+(NSString*)stringFromFileNamed:(NSString*)name;


#pragma mark ------------ Chat----------
+ (NSString *)getChatSendText;
+ (NSString *) getPublishListURL;
+ (NSString *) getUserURL : (NSString*) _userId;
+ (NSString *)getOnlineUsersUrl :(NSString*) _chatcode;
+ (NSString *)getPrivateChatUrl :(NSString*) otherId : (NSString*) _userChatcode;
+ (NSString *)GetStartPinChat;
+ (NSString *)getOtherChatIdUrl :(NSString*) curChatCode : (NSString*) othPubCode;
+ (NSString *) getReviewURL:(int) pinId;
+ (NSString *) sendReviewUrl;

+(NSString *) getTimeFilter: (NSString *) _strTime;
@end
