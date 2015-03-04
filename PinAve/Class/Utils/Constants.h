//
//  Constants.h
//  BabyName
//
//  Created by RamotionMac on 6/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#define kNavigationBarHeightPhone 44
#define kNavigationBarHeightPad 88

#define kNavigationBarHeight (iPhone ? kNavigationBarHeightPhone : kNavigationBarHeightPad)

#define kResizableNavigationBarTag 1000

#define kShadowOffset (iPhone ? 0.5 : 1)

#define NotiDicToHere   @"DirectToHere"
#define NotiDicFromHere @"DirectFromHere"


enum SEARCH_MODE {
    CATEGORY_MODE,
    MYPIN_MODE,
    SEARCH_MODE,
    NOTIFY_MODE,
};

enum SEARCH_TIME {
    NOW = 0,
    TODAY,
    THISWEEK,
    THISMONTH,
};