//
//  ChatDetailVC.h
//  happyChat
//
//  Created by zy on 15/12/6.
//  Copyright © 2015年 zy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AVUser;

@interface ChatDetailVC : UIViewController

@property (nonatomic, strong) AVUser *otherChater;
//聊天对话
@property (nonatomic,strong) AVIMConversation * converstaion;

@property (nonatomic, strong) UIImage *myImg;
@property (nonatomic, strong) UIImage *herImg;

@end
