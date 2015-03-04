//
//  Utils.h
//  NEP
//
//  Created by Dandong3 Sam on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface Share : NSObject

@property (nonatomic, strong) NSMutableArray * arrayCategory;
@property (nonatomic, strong) NSArray * arrayMyPin;
@property (nonatomic, strong) NSMutableDictionary * dicUserInfo;
@property (nonatomic, strong) NSArray * allUsers;

@property (nonatomic, strong) NSMutableArray * allAvenueUsers;
@property (nonatomic, strong) NSMutableArray * allAvenuePins;
@property (nonatomic, strong) NSDictionary * userChatInfo;


+ (Share*) getInstance;

- (void) initVal;

- (NSString*) getCategoryTitle:(int) _categoryId;
+ (UIImage*) getCategoryImageName:(NSString*) category_name;
+ (UIImage*) getCategoryImageWithID:(NSString*) _categoryID;

- (BOOL) getFirstApp;
- (void) setFirstApp;



enum _MODE {
    MODE_SEARCH,
    MODE_NOTIFY,
};

+ (NSString*) generateKey:(NSString*) firstName
                 lastName:(NSString*) lastName
                    email:(NSString*) email
                     fbid:(NSString*) fbID;

@end
