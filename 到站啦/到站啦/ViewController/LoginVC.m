//
//  LoginVC.m
//  到站啦
//
//  Created by zy on 15/12/23.
//  Copyright © 2015年 zy. All rights reserved.
//

#import "LoginVC.h"

#define kHeight [UIScreen mainScreen].bounds.size.height
#define Height 304


@interface LoginVC ()<UITextFieldDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (strong, nonatomic) IBOutlet UITextField *userName;
@property (strong, nonatomic) IBOutlet UITextField *userPsw;
@property (strong, nonatomic) IBOutlet UIButton *login;
- (IBAction)loginAction:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *registerBtn;
- (IBAction)registerAction:(UIButton *)sender;


@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = [UIScreen mainScreen].bounds;
    self.userName.delegate = self;
    self.userName.returnKeyType = UIReturnKeyNext;
    self.userPsw.delegate = self;
    self.userPsw.returnKeyType = UIReturnKeyGo;
}

#pragma mark --- UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([textField isEqual:_userName]) {
        [_userPsw becomeFirstResponder];
    }else {
        [_userPsw resignFirstResponder];
        [self loginAction:nil];
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// 点击试图空白处回收键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (IBAction)loginAction:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"登陆"]) {
        [AVUser logInWithUsernameInBackground:_userName.text password:_userPsw.text block:^(AVUser *user, NSError *error) {
            if (user != nil) {
                NSLog(@"登陆成功");
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                NSLog(@"登录失败:%@",error);
                NSString *str = [NSString stringWithFormat:@"详情:%@", error];
                UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"用户名或密码不正确" message:str preferredStyle:(UIAlertControllerStyleAlert)];
                
                UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:nil];
                
                [errorAlert addAction:defaultAction];
                
                [self presentViewController:errorAlert animated:YES completion:nil];
            }
        }];
    }else if([sender.titleLabel.text isEqualToString:@"注册"]) {
        AVUser *user = [AVUser user];
        user.username = _userName.text;
        user.password =  _userPsw.text;
        
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"注册成功");
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                NSLog(@"注册失败:%@",error);
                NSString *str = [NSString stringWithFormat:@"详情:%@", error];
                UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"错误：" message:str preferredStyle:(UIAlertControllerStyleAlert)];
                
                UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:nil];
                
                [errorAlert addAction:defaultAction];
                
                [self presentViewController:errorAlert animated:YES completion:nil];
            }
        }];
    }
}
- (IBAction)registerAction:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"没有账号?快来注册!"]) {
        [_login setTitle:@"注册" forState:(UIControlStateNormal)];
        [_registerBtn setTitle:@"已有账号?点击登陆!" forState:(UIControlStateNormal)];
    }else if([sender.titleLabel.text isEqualToString:@"已有账号?点击登陆!"]){
        [_login setTitle:@"登陆" forState:(UIControlStateNormal)];
        [_registerBtn setTitle:@"没有账号?快来注册!" forState:(UIControlStateNormal)];
    }
}
@end
