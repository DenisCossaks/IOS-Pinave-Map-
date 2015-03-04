//
//  UsersPool.h
//  NEP
//
//  Created by Dandong3 Sam on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JsonReader.h"
#import "SBJSON.h"

@interface UsersPool : NSObject <JsonReaderDelegate>

@property (strong, nonatomic) NSArray *userList;
@property (atomic) BOOL isGotUsers;

+ (UsersPool *)pool;

@end
