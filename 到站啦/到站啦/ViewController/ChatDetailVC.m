//
//  ChatDetailVC.m
//  happyChat
//
//  Created by zy on 15/12/6.
//  Copyright © 2015年 zy. All rights reserved.
//

#import "ChatDetailVC.h"
#import "MyCell.h"
#import "OtherCell.h"


#define kWidth [UIScreen mainScreen].bounds.size.width

@interface ChatDetailVC ()<UITextFieldDelegate, AVIMClientDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSString *isOnline;

@property (nonatomic, strong) AVIMClient *client;
//用来记录聊天信息
@property (nonatomic,strong) NSMutableArray * messages;

@property (nonatomic, strong) NSString *conversationName;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITextField *messageTF;
- (IBAction)sendMessage:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewBottomConstraint;

@end

@implementation ChatDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = [UIScreen mainScreen].bounds;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.title = self.otherChater.username;
    self.tabBarController.tabBar.hidden = YES;
    self.messageTF.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    // 注册
    [self.tableView registerNib:[UINib nibWithNibName:@"OtherCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"other"];
    [self.tableView registerNib:[UINib nibWithNibName:@"MyCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"my"];
    // 通过通知中心来观察键盘的frame  发送变化后触发keyboardFrameChange事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChange:) name:UIKeyboardDidChangeFrameNotification object:nil];
    [AVIMConversation classForKeyedUnarchiver];
    if (_converstaion) {
        [self getOldMessages];
    }else{
        // 创建聊天
        [self createConversation];
    }
    AVQuery *ison = [AVQuery queryWithClassName:@"isOnLine"];
    self.isOnline = [ison getFirstObject][@"isOn"];
}

-(void) getOldMessages{
    //查询之前的对话
    [self.converstaion queryMessagesWithLimit:10 callback:^(NSArray *objects, NSError *error) {
        for (AVIMMessage *message in objects) {
            [self.messages addObject:message];
            [self selectNewMessage];
        }
//        [self.tableView reloadData];
    }];
}

- (void)keyboardFrameChange:(NSNotification *)notification {
    NSLog(@"%@",notification);
    // 键盘改变后的frame
    CGRect rect = [[notification.userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    // 计算聊天窗口的底部偏移量
    CGFloat height = self.view.frame.size.height - rect.origin.y;
    self.viewBottomConstraint.constant = height + 64;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

-(void) createConversation{
    
    //  创建了一个 client
    self.client = [[AVIMClient alloc] initWithClientId:[AVUser currentUser].objectId];
    
    __block typeof(self) temp = self;
    
    //  用自己的名字作为 ClientId 打开 client
    [self.client openWithClientId:[AVUser currentUser].objectId callback:^(BOOL succeeded, NSError *error) {
        
        temp.client.delegate = temp;
        //TODO: 应该先查看是否之前创建了聊天对话
        
        //聊天对话查询对象
        AVIMConversationQuery *query = [temp.client conversationQuery];
        //查找对话名字是 两个对话人姓名
        [query whereKey:@"name" equalTo:[temp getConversation]];
        [query findConversationsWithCallback:^(NSArray *objects, NSError *error) {
            //如果数据库中没有对话就创建一个
            if (objects.count == 0) {
                //创建回话
                [temp.client createConversationWithName:[temp getConversation] clientIds:@[[AVUser currentUser].objectId, temp.otherChater.objectId] callback:^(AVIMConversation *conversation, NSError *error) {
                    temp.converstaion = conversation;
                }];
            }else{
                //取到最后一个对话
                temp.converstaion = objects.lastObject;
//                //查询之前的对话
//                [temp.converstaion queryMessagesWithLimit:10 callback:^(NSArray *objects, NSError *error) {
//                    for (AVIMMessage *message in objects) {
//                        [temp.messages addObject:message];
//                    }
//                    [temp.tableView reloadData];
//                }];
                [temp getOldMessages];
            }
        }];
        
    }];
}


#pragma mark - AVIMClientDelegate
- (void)conversation:(AVIMConversation *)conversation messageDelivered:(AVIMMessage *)message{
    NSLog(@"%@",message.content);
}
-(void)conversation:(AVIMConversation *)conversation didReceiveTypedMessage:(AVIMTypedMessage *)message{
    //    NSLog(@"%@",message.text);
}
//接受代理方法
-(void)conversation:(AVIMConversation *)conversation didReceiveCommonMessage:(AVIMMessage *)message{
    NSLog(@"_____%d",message.ioType);
    NSLog(@"+++++++%@",message.content);
    [self.messages addObject:message];
    [self selectNewMessage];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
//    self.viewBottomConstraint.constant = 0;
    
    [self sendMessage];
    
    return YES;
}

-(void) sendMessage {
    if (![_messageTF.text isEqualToString:@""]) {
        
        //构造发送的消息
        AVIMMessage *avmessage = [AVIMMessage messageWithContent:_messageTF.text];
        avmessage.clientId = [AVUser currentUser].objectId;
        avmessage.conversationId = self.conversationName;
        
        //发送消息
        [self.converstaion sendMessage:avmessage callback:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"发送消息成功");
                _messageTF.text = nil;
            }
        }];
        
        [self.messages addObject:avmessage];
//        [self.tableView reloadData];
        [self selectNewMessage];
        if ([self.isOnline isEqualToString:@"否"]) {
            AVIMMessage *mes = [AVIMMessage messageWithContent:[self stringAutomic]];
            mes.clientId = self.otherChater.objectId;
            mes.conversationId = self.conversationName;
            [self.messages addObject:mes];
            [self selectNewMessage];
        }
        
    }else{
        _messageTF.placeholder = @"发送消息不能为空";
    }
}

-(NSString *)stringAutomic{
    NSArray *array = @[@"Hello~😊", @"Love U!😘", @"Right!👍", @"Ok!!👌"];
    int a = arc4random_uniform((int)array.count);
    return array[a];
}

-(void) selectNewMessage{
    if (self.messages.count) {
        NSInteger row = self.messages.count - 1;
        NSIndexPath *index = [NSIndexPath indexPathForRow:row inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[index] withRowAnimation:(UITableViewRowAnimationNone)];
        [self.tableView selectRowAtIndexPath:index animated:YES scrollPosition:UITableViewScrollPositionBottom];
    }
}

//根据两个人得用户名来排序来生成一个对话名
- (NSString *)getConversation{
    NSString *myname = [AVUser currentUser].objectId;
    NSString *chaterName = self.otherChater.objectId;
    if ([myname compare:chaterName] == NSOrderedAscending) {
        
        return [NSString stringWithFormat:@"%@%@",chaterName,myname];
    }else{
        return [NSString stringWithFormat:@"%@%@",myname,chaterName];
    }
}


-(NSMutableArray *)messages{
    if (!_messages) {
        _messages = [[NSMutableArray alloc]init];
    }
    return _messages;
}

-(NSString *)getImgHaHa{
    int a = arc4random_uniform((int)6);
    return [NSString stringWithFormat:@"%d", a+1];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AVIMMessage *message = self.messages[indexPath.row];
    if (message.ioType == 2 && [message.clientId isEqualToString:[AVUser currentUser].objectId]) {
        MyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"my" forIndexPath:indexPath];
#warning 
//        cell.message = message;
        cell.myContent.text = message.content;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        // 根据文本内容调整content高度
        cell.contentHeight.constant = [self textHeight:message.content].height;
        cell.contentWidth.constant = [self textHeight:message.content].width;
        if (_myImg) {
            cell.myImg.image = _myImg;
        }
        return cell;
    }else{
        OtherCell *cell = [tableView dequeueReusableCellWithIdentifier:@"other" forIndexPath:indexPath];
//        cell.message =message;
        cell.contentLab.text = message.content;
        cell.myContentWidth.constant = [self textHeight:message.content].width;
        cell.myContentHeight.constant = [self textHeight:message.content].height;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (_herImg) {
            cell.imgView.image = _herImg;
        }
        return cell;
    }
}

#pragma mark --- UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.messageTF resignFirstResponder];
    self.viewBottomConstraint.constant = 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self textHeight:[self.messages[indexPath.row] content]].height > 60 ? [self textHeight:[self.messages[indexPath.row] content]].height+10 : 60 ;
}

#pragma mark --- text自适应高度
// 自定义content高度
- (CGSize)textHeight:(NSString *)string {
    CGRect rect = [string boundingRectWithSize:CGSizeMake(kWidth/2.0, 10000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18.0]} context:nil];
    NSLog(@"%f", rect.size.height);
    
    CGFloat width = rect.size.width <= kWidth/2.0 ? rect.size.width : kWidth/2.0;
    CGFloat height = rect.size.height >= 50 ? rect.size.height + 20 : 50;
    CGSize size = CGSizeMake(width, height);
    
    // 返回计算好的高度
    return size;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)sendMessage:(UIButton *)sender {
    [self sendMessage];
}
@end
