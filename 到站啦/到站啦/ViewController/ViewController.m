//
//  ViewController.m
//  到站啦
//
//  Created by zy on 15/12/22.
//  Copyright © 2015年 zy. All rights reserved.
//

#import "ViewController.h"

#import "AppDelegate.h"
#import "BusStationsCell.h"
#import "MapVC.h"



@interface ViewController ()< BMKBusLineSearchDelegate, BMKPoiSearchDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, BMKMapViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *busLab;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) BMKBusLineSearch *searcheBL;
@property (nonatomic, assign) BOOL flag;
@property (nonatomic, strong) BMKPoiSearch *search;
@property (nonatomic, strong) NSMutableArray *busLinesArray;
@property (nonatomic, strong) NSMutableArray *busStationsArray;
@property (nonatomic, strong) CLLocation *cllocation;
@property (nonatomic, strong) NSMutableSet *set;

@property (nonatomic, strong) BMKBusStation *sta;

- (IBAction)searchBus:(UIButton *)sender;

// 放小菊花的view
@property (nonatomic, retain) UIView *backgroundView;
// 系统小菊花
@property (nonatomic, retain) UIActivityIndicatorView *act;
//  系统菊花label
@property (nonatomic, retain) UILabel *actLab;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.busLab.returnKeyType = UIReturnKeySearch;
    // 初始化位置管理器
    AppDelegate * mydelegate = [UIApplication sharedApplication].delegate;
    mydelegate.locationManager.delegate = self;
    self.search.delegate = self;
    self.searcheBL.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"BusStationsCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell1"];
    self.searcheBL.delegate = self;
    _flag = NO;
    
    self.busLab.delegate = self;
    [self createAct];
    [self addToView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"地图" style:(UIBarButtonItemStyleDone) target:self action:@selector(click)];
}

-(void)click{
    MapVC *vc = [[MapVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //不使用时将delegate设置为 nil
    _searcheBL.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)createAct{
    self.backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, -64, kWidth, kHeight)];
    _backgroundView.backgroundColor = [UIColor lightGrayColor];
    _backgroundView.alpha = 0.6;
    self.act = [[UIActivityIndicatorView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _act.center = _backgroundView.center;
    self.actLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 70, 30)];
    _actLab.center = CGPointMake(_act.center.x, _act.center.y + 30);
    _actLab.text = @"加载...";
    _actLab.textColor = [UIColor whiteColor];
    _actLab.font = [UIFont systemFontOfSize:15];
    _actLab.textAlignment = NSTextAlignmentCenter;
    [_backgroundView addSubview:_actLab];
    [_act setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [_backgroundView addSubview:_act];
    [self addToView];
}

-(void)removeAct{
    [_act stopAnimating];
    [_backgroundView removeFromSuperview];
}

-(void) addToView{
    [_act startAnimating];
    [self.view addSubview:_backgroundView];
}

#pragma mark --- lazy load
-(BMKBusLineSearch *) searcheBL {
    if (!_searcheBL) {
        //初始化检索对象
        _searcheBL =[[BMKBusLineSearch alloc]init];
    }
    return _searcheBL;
}

// 懒加载
- (BMKPoiSearch *)search{
    if (!_search) {
        _search = [[BMKPoiSearch alloc] init];
    }
    return _search;
}

-(NSMutableArray *)busLinesArray{
    if (!_busLinesArray) {
        _busLinesArray = [NSMutableArray array];
    }
    return _busLinesArray;
}

-(NSMutableArray *)busStationsArray {
    if (!_busStationsArray) {
        _busStationsArray = [NSMutableArray array];
    }
    return _busStationsArray;
}

-(CLLocation *)cllocation {
    if (!_cllocation) {
        _cllocation = [CLLocation new];
    }
    return _cllocation;
}

-(NSMutableSet *)set{
    if (!_set) {
        _set = [NSMutableSet set];
    }
    return _set;
}

-(BMKBusStation *)sta{
    if (!_sta) {
        _sta = [[BMKBusStation alloc]init];
    }
    return _sta;
}

#pragma mark --- CLLocationManagerDelegate
// 当定位到用户位置时就会调用
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    [self removeAct];
    self.cllocation = locations.lastObject;
    UIView *aView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kWidth, kHeight/3.0)];
    aView.backgroundColor = [UIColor grayColor];
    aView.center = self.view.center;
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kWidth, kHeight/3.0)];
    NSString *str = [NSString stringWithFormat:@"定位成功，可以搜索了!\n您当前的位置:\n经度:%f   纬度:%f",_cllocation.coordinate.longitude, _cllocation.coordinate.latitude];
    lab.text = str;
    lab.numberOfLines = 0;
    lab.textAlignment = NSTextAlignmentCenter;
    lab.textColor = [UIColor redColor];
    [aView addSubview:lab];
    [self.view addSubview:aView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [aView removeFromSuperview];
    });
    if (_flag) {
        NSLog(@"检索成功");
        //检索成功后就停止定位
        [manager stopUpdatingLocation];
    }else{
        NSLog(@"检索失败");
    }
}
#pragma mark --- BMKPoiSearchDelegate
- (void)onGetPoiResult:(BMKPoiSearch*)searcher result:(BMKPoiResult*)poiResult errorCode:(BMKSearchErrorCode)errorCode{
    if (errorCode == BMK_OPEN_NO_ERROR) {
        if (_busLinesArray.count) {
            [_busLinesArray removeAllObjects];
        }
        for (BMKPoiInfo *info in poiResult.poiInfoList) {
            NSLog(@"%@", info);
            if (info.epoitype == 2) {
                [self.busLinesArray addObject:info];
            }
            if (info.epoitype == 1) {
                self.sta = (BMKBusStation *)info;
                NSLog(@"%@", info.name);
            }
        }
        [self removeAct];
        [self.tableView reloadData];
    }else{
        NSLog(@"检索错了");
    }
}

#pragma mark --- BMKBusLineSearchDelegate
//实现PoiSearchDeleage处理回调结果
- (void)onGetBusDetailResult:(BMKBusLineSearch*)searcher result:(BMKBusLineResult*)busLineResult errorCode:(BMKSearchErrorCode)error{
    if (error == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
        NSLog(@"哈哈");
        if (_busStationsArray.count) {
            [_busStationsArray removeAllObjects];
        }
        for (BMKBusStation *station in busLineResult.busStations) {
            [self.busStationsArray addObject:station];
            NSLog(@"%@", station.title);
        }
        [self getRandomNumber];
        [self.tableView reloadData];
    }else {
        NSString *str = nil;
        switch (error) {
            case 1:
                str = @"检索词有岐义";
                break;
            
            case 8:
                str =@"网络连接错误";
                break;
                
            case 3:
                str =@"该城市不支持公交搜索";
                break;
                
            case 4:
                str =@"不支持跨城市公交";
                break;
                
            case 5:
                str =@"没有找到检索结果";
                break;
                
            case 6:
                str =@"起终点太近";
                break;
                
            case 9:
                str =@"网络连接超时";
                break;
                
            default:
                str = @"错误不明确";
                break;
        }
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误" message:str preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
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
        BMKBusLineSearchOption *option = [[BMKBusLineSearchOption alloc]init];
        BMKPoiInfo *info = self.busLinesArray[indexPath.row];
        option.city = info.city;
        option.busLineUid = info.uid;
        [self.searcheBL busLineSearch:option];
    }
}
#pragma mark --- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.busLinesArray.count;
    }else {
        return self.busStationsArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    cell.selectionStyle = 0;
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell1" forIndexPath:indexPath];
        cell.textLabel.text = [self.busLinesArray[indexPath.row] name];
        return cell;
    }else{
        NSString *str = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
        if ([self.set containsObject:str]) {
            BusStationsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
            cell.selectedTextColor = [UIColor redColor];
            cell.busImg.image = [UIImage imageNamed:@"bus"];
            BMKMapPoint point1 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(self.cllocation.coordinate.latitude, self.cllocation.coordinate.longitude));
            BMKBusStation *station = _busStationsArray[indexPath.row];
            BMKMapPoint point2 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(station.location.latitude,station.location.longitude));
            CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
            cell.distanceLab.text = [NSString stringWithFormat:@"距离:%.f", distance];
            cell.stationTitle.text = [self.busStationsArray[indexPath.row] title];
            return cell;
        }else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell1" forIndexPath:indexPath];
            cell.textLabel.text = [self.busStationsArray[indexPath.row] title];
            return cell;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"公交线路";
    }else {
        return @"公交站";
    }
}

#pragma mark --- UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [self searchBus:nil];
    return YES;
}

#pragma mark --- 自定义方法

-(void) getRandomNumber {
    if (_busStationsArray.count) {
        NSLog(@"###############%lu", (unsigned long)_busStationsArray.count);
        while (_set.count < _busStationsArray.count/6) {
            int a = arc4random()%(_busStationsArray.count);
            NSString *str = [NSString stringWithFormat:@"%d", a];
            NSLog(@"%@", str);
            [self.set addObject:str];
        }
    }
}

- (IBAction)searchBus:(UIButton *)sender {
    if (![_busLab.text isEqualToString:@""]) {
        NSLog(@"搜索公交啦");
        BMKNearbySearchOption *option = [[BMKNearbySearchOption alloc] init];
        option.pageCapacity = 30;
        option.location = _cllocation.coordinate;
        option.keyword = _busLab.text;
        _flag = [_search poiSearchNearBy:option];
        [self addToView];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"公交线路不能为空" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end
