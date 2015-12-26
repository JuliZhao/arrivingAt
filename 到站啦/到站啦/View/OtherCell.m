//
//  OtherCell.m
//  happyChat
//
//  Created by zy on 15/12/4.
//  Copyright © 2015年 zy. All rights reserved.
//

#import "OtherCell.h"

@implementation OtherCell

- (void)awakeFromNib {
    self.imgView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//-(void)setMessage:(AVIMMessage *)message{
//    self.message = message;
//    self.contentLab.text = message.content;
//}

@end
