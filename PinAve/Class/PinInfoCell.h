//
//  PinInfoCell.h
//  PinAve
//
//  Created by Gold Luo on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PinInfoCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *pinImg;
@property (strong, nonatomic) IBOutlet UILabel *pinTitle;
@property (strong, nonatomic) IBOutlet UILabel *pinAddress;
@property (strong, nonatomic) IBOutlet UILabel *pinDistance;
@property (nonatomic, assign) NSString * strImgName;
@property (nonatomic, strong) IBOutlet UIImageView * categoryImg;

@end
