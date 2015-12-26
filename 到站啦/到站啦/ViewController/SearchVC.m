//
//  SearchVC.m
//  到站啦
//
//  Created by zy on 15/12/25.
//  Copyright © 2015年 zy. All rights reserved.
//

#import "SearchVC.h"
#import "AppDelegate.h"
#import "BusStationsCell.h"
#import "MapVC.h"

@interface SearchVC ()<UITextFieldDelegate,UITableViewDelegate, UITableViewDataSource>

- (IBAction)searchBus:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UITextField *startSta;
@property (strong, nonatomic) IBOutlet UITextField *endSta;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *stations;
@property (nonatomic, strong) NSMutableSet *set;
@property (nonatomic, strong) CLLocation *cllocation;
@property (nonatomic, assign) BOOL flag;

@property (nonatomic, strong) NSString *line;

@end

@implementation SearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"BusStationsCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell1"];
    self.startSta.delegate = self;
    self.endSta.delegate = self;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"地图" style:(UIBarButtonItemStyleDone) target:self action:@selector(click)];
}

-(void)click{
    MapVC *vc = [[MapVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(NSMutableSet *)set{
    if (!_set) {
        _set = [NSMutableSet set];
    }
    return _set;
}

#pragma mark --- UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([textField isEqual:_startSta]) {
        [_endSta becomeFirstResponder];
    }else{
        [_endSta resignFirstResponder];
        [self searchBus:nil];
    }
    return YES;
}

#pragma mark --- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        _stations = [NSArray arrayWithObjects:@"1 . 株洲路广中路",@"2 . 广中路平型关路",@"3 . 广中西路共和新路>>>>>1号线", @"4 . 广中西路万荣路",@"5 . 广中西路运城路",@"6 . 广中西路沪太路",@"7 . 龙潭",@"8 . 沪太路余庆桥",@"9 . 沪太路汶水路（长途客运北站）",@"10 . 场联路乾溪路",@"11 . 场联路环镇北路",@"12 . 环镇北路场联路",@"13 . 乾溪新村",@"14 . 环镇北路南陈路",@"15 . 南陈路上大路",@"16 . 南陈路四号桥",@"17 . 锦秋路南陈路>>>>>7号线",@"18 . 锦秋路（上海大学）>>>>>7号线",@"19 . 祁连山路锦秋路",@"20 . 祁华路祁连山路",@"21 . 祁华路（葑润华庭）",nil];
        [self getRandomNumber];
        [self.tableView reloadData];
    }
}
#pragma mark --- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0) {
        if (_line) {
            return 1;
        }else{
            return 0;
        }
    }else{
        if (_stations.count) {
            return _stations.count;
        }else{
            return 0;
        }
    }
}

-(void) getRandomNumber {
    if (_stations.count) {
        NSLog(@"###############%lu", (unsigned long)_stations.count);
        while (_set.count < _stations.count/6) {
            int a = arc4random()%(_stations.count);
            NSString *str = [NSString stringWithFormat:@"%d", a];
            NSLog(@"%@", str);
            [self.set addObject:str];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //    cell.selectionStyle = 0;
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell1" forIndexPath:indexPath];
        cell.textLabel.text = _line;
        return cell;
    }else{
        NSString *str = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
        if ([self.set containsObject:str]) {
            BusStationsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
            cell.selectedTextColor = [UIColor redColor];
            cell.busImg.image = [UIImage imageNamed:@"bus"];
            cell.stationTitle.text = self.stations[indexPath.row];
            return cell;
        }else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell1" forIndexPath:indexPath];
            cell.textLabel.text = self.stations[indexPath.row];
            return cell;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_stations.count) {
        return 2;
    }else{
        return 1;
    }
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"公交线路";
    }else{
        if (_stations.count) {
            return @"公交站";
        }else{
            return nil;
        }
    }
}

-(void) getBus{
    self.line = @"767路【株洲路广中路祁华路(葑润华庭)】";
    [self.tableView reloadData];
}

- (IBAction)searchBus:(UIButton *)sender {
    if (![_endSta.text isEqualToString:@""] && ![_startSta.text isEqualToString:@""]) {
        [self getBus];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"始发站/终点站不能为空" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
@end
