//
//  ContactsTVC.m
//  happyChat
//
//  Created by zy on 15/12/3.
//  Copyright © 2015年 zy. All rights reserved.
//

#import "ContactsTVC.h"
#import "ChatDetailVC.h"
#import "LoginVC.h"

@interface ContactsTVC ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *userImgView;
@property (strong, nonatomic) IBOutlet UILabel *userNameLab;

@property (strong, nonatomic) NSMutableArray *array;
@property (nonatomic, strong) NSMutableDictionary *headImgDic;

@end

@implementation ContactsTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"friendCell"];
    [self getImg];
     self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"登陆" style:(UIBarButtonItemStyleDone) target:self action:@selector(login)];
}

-(void) getImg{
    AVQuery *fileQuery = [AVFile query];
    [fileQuery orderByDescending:@"craetedAt"];
    [fileQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (AVObject *obj in objects) {
                AVFile *object = [AVFile fileWithAVObject:obj];
//                AVFile *file = [AVFile fileWithURL:object.url];
                [object getThumbnail:YES width:100 height:100 withBlock:^(UIImage *image, NSError *error) {
                    if (image) {
                        if (!self.headImgDic[object.name]) {
                            [self.headImgDic setObject:image forKey:object.name];
                        }
                    }
                }];
            }
            [self.tableView reloadData];
        }
    }];
}

-(void) getMyself{
    AVQuery *fileQuery = [AVFile query];
    [fileQuery orderByDescending:@"craetedAt"];
    [fileQuery whereKey:@"name" equalTo:[NSString stringWithFormat:@"%@.png", [AVUser currentUser].objectId]];
    AVFile *object = [AVFile fileWithAVObject:[fileQuery getFirstObject]];
    [object getThumbnail:YES width:100 height:100 withBlock:^(UIImage *image, NSError *error) {
        if (image) {
            _userImgView.image = image;
        }
    }];
//    if (object.url) {
//            [self.userImgView sd_setImageWithURL:[NSURL URLWithString:object.url]];
//        }
}

-(NSMutableDictionary *)headImgDic{
    if (!_headImgDic) {
        _headImgDic = [NSMutableDictionary dictionary];
    }
    return _headImgDic;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([AVUser currentUser]) {
        self.userNameLab.text = [AVUser currentUser].username;
        [self addTap];
        [self getMyself];
        [self.navigationItem.rightBarButtonItem setTitle:@"注销"];
        [self getData];
    }else {
       [self.navigationItem.rightBarButtonItem setTitle:@"登陆"];
        [self rebuildUI];
    }
}

-(void) rebuildUI{
    if (_array.count) {
        [_array removeAllObjects];
    }
    [self.tableView reloadData];
    self.userImgView.image = [UIImage imageNamed:@"用户"];
    self.userNameLab.text = @"未知";
    NSLog(@"%d", self.userImgView.userInteractionEnabled);
    self.userImgView.userInteractionEnabled = NO;
    self.userNameLab.userInteractionEnabled = NO;
}

-(void) login {
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"登陆"]) {
        LoginVC *vc = [[LoginVC alloc]init];;
        [self.navigationController pushViewController:vc animated:YES];
    }else {
        [AVUser logOut];
        [self.navigationItem.rightBarButtonItem setTitle:@"登陆"];
        [self rebuildUI];
    }
}

-(void) addTap{
    self.userNameLab.userInteractionEnabled = YES;
    self.userImgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    [self.userImgView addGestureRecognizer:tap1];
    [self.userNameLab addGestureRecognizer:tap3];
}

-(void)tap:(UITapGestureRecognizer *)sender{
//    ChangeSelfView *change = [[ChangeSelfView alloc]init];
//    [self.navigationController pushViewController:change animated:YES];
    NSLog(@"点击了头像");
    UIImagePickerController *pic = [[UIImagePickerController alloc]init];
    
    pic.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pic.allowsEditing = YES;
    pic.delegate = self;
    
    [self presentViewController:pic animated:YES completion:nil];
}

// 协议方法选择结束之后执行
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *img = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    self.userImgView.image = img;
    [self dismissViewControllerAnimated:YES completion:nil];
    //储存图像
    if (img != nil) {
        UIImage *image = img;
        NSData *imageData = UIImagePNGRepresentation(image);
        NSString *str = [NSString stringWithFormat:@"%@.png", [AVUser currentUser].objectId];
        AVFile *file = [AVFile fileWithName:str data:imageData];
        [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            // 成功或失败处理...
            if (succeeded) {
                NSLog(@"数据处理成功");
            }else {
                NSLog(@"处理失败:%@",error);
                NSString *string = [NSString stringWithFormat:@"%@", error];
                //创建alert
                UIAlertController *saveAlert = [UIAlertController alertControllerWithTitle:@"处理失败：" message:string preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleCancel) handler:nil];
                [saveAlert addAction:cancelAction];
                // 添加视图
                [self presentViewController:saveAlert animated:YES completion:nil];
            }
        }];
    }
    NSLog(@"%@",img);
}


-(NSMutableArray *) array{
    if (!_array) {
        _array = [NSMutableArray array];
    }
    return _array;
}

-(void) getData {
    if (_array.count) {
        [_array removeAllObjects];
    }
    AVQuery *query = [AVUser query];
    if ([AVUser currentUser]) {
        [query whereKey:@"objectId" notContainedIn:@[[AVUser currentUser].objectId]];
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (AVUser *user in objects) {
                [self.array addObject:user];
                NSLog(@"用户");
            }
            [self.tableView reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --- Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell" forIndexPath:indexPath];
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.cornerRadius = 10;
    AVUser *user = self.array[indexPath.row];
    cell.textLabel.text = user.username;
    NSString *key = [NSString stringWithFormat:@"%@.png", user.objectId];
    if (_headImgDic[key]) {
        NSLog(@"%@", _headImgDic[key]);
//        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:_headImgDic[key]]];
        cell.imageView.image = _headImgDic[key];
    }else{
        cell.imageView.image = [UIImage imageNamed:@"用户"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark --- UITableViewDelegate

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 60;
//}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatDetailVC *chat = [[ChatDetailVC alloc]init];
    chat.otherChater = self.array[indexPath.row];
    NSString *my = [NSString stringWithFormat:@"%@.png", [AVUser currentUser].objectId];
    if (_headImgDic[my]) {
        chat.myImg = _headImgDic[my];
    }
    NSString *her = [NSString stringWithFormat:@"%@.png", [self.array[indexPath.row] objectId]];
    if (_headImgDic[her]) {
        chat.herImg = _headImgDic[her];
    }
    [self.navigationController pushViewController:chat animated:YES];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
