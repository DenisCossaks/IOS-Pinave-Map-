//
//  SentController.h
//  NEP
//
//  Created by Dandong3 Sam on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JsonReader.h"
#import "EGORefreshTableHeaderView.h"

@interface SentCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *thumbImg;
@property (strong, nonatomic) IBOutlet UILabel *receiverLbl;
@property (strong, nonatomic) IBOutlet UILabel *dateLbl;
@property (strong, nonatomic) IBOutlet UILabel *messageLbl;

@end


@interface SentController : UIViewController <JsonReaderDelegate, EGORefreshTableHeaderDelegate>

@property (strong, nonatomic) NSArray *messageAry;
@property (strong, nonatomic) IBOutlet UISearchBar *searchMsgBar;
@property (strong, nonatomic) IBOutlet UITableView *messageTbl;
@property (strong, nonatomic) IBOutlet SentCell *creatingCell;

@end
