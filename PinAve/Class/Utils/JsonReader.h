//
//  JsonReader.h
//  NEP
//
//  Created by Dandong3 Sam on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JsonReaderDelegate <NSObject>

- (void) didJsonRead:(id)result;
- (void) didJsonReadFail;

@end


@interface JsonReader : NSObject

- (id)initWithUrl:(NSString *)url delegate:(id <JsonReaderDelegate>)readerDelegate;
- (void)read;

@end
