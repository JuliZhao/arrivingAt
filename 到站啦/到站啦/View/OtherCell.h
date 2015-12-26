//
//  OtherCell.h
//  happyChat
//
//  Created by zy on 15/12/4.
//  Copyright © 2015年 zy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OtherCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *contentLab;
@property (strong, nonatomic) IBOutlet UIImageView *imgView;
@property (nonatomic, strong) AVIMMessage *message;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *myContentHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *myContentWidth;

@end
