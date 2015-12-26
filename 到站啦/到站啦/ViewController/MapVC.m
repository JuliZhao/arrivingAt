//
//  MapVC.m
//  到站啦
//
//  Created by zy on 15/12/26.
//  Copyright © 2015年 zy. All rights reserved.
//

#import "MapVC.h"
#import "Annotation.h"


@interface MapVC ()<BMKPoiSearchDelegate,MKMapViewDelegate, BMKGeoCodeSearchDelegate>

@property (nonatomic,strong) BMKPoiSearch * search;
@property (nonatomic,strong) UIImageView * imageview;
// 声明地图属性
@property (nonatomic, strong) MKMapView *mapView;
// 声明一个button,在地图上返回用户当前位置
@property (nonatomic, strong) UIButton *userCurrentLocation;

@property (nonatomic, strong) BMKGeoCodeSearch *searcher;

@property (nonatomic, strong) NSMutableArray *array;

@end

@implementation MapVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searcher = [[BMKGeoCodeSearch alloc]init];
    _searcher.delegate = self;
    BMKGeoCodeSearchOption *option1 = [[BMKGeoCodeSearchOption alloc]init];
    option1.city = @"上海";
    option1.address = @"株洲路广中路-公交车站";
    
    [_searcher geoCode: option1];
    
}

-(NSMutableArray *)array{
    if (!_array) {
        _array = [NSMutableArray array];
    }
    return _array;
}

-(void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
    if (error == BMK_SEARCH_NO_ERROR) {
        [self.array addObject:result];
        NSLog(@"%@-----------%f------------%f", result.address, result.location.latitude,result.location.longitude);
        if (_array.count == 1) {
            BMKGeoCodeSearchOption *option2 = [[BMKGeoCodeSearchOption alloc]init];
            option2.city = @"上海";
            option2.address = @"锦秋路（上海大学）-公交车站";
            [_searcher geoCode:option2];
        }
        NSLog(@"%@", self.array);
        if (_array.count == 2) {
            [self goSearch];
        }
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
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误提示" message:str preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self addMap];
}


- (void)addMap{
    // 设置背景颜色
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 地图的初始化
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 64, kWidth, kHeight)];
    // 设置代理
    self.mapView.delegate = self;
//    self.mapView.userLocation.coordinate = CLLocationCoordinate2DMake(39, 116);
//    self.mapView.userLocation.title = @"您当前位置";
    // 设置追踪模式
    self.mapView.userTrackingMode = BMKUserTrackingModeFollow;
    [self.view addSubview:_mapView];
    
    // 设置地图显示的中心位置
    CLLocationDegrees latitude = self.mapView.userLocation.coordinate.latitude;
    CLLocationDegrees longitude = self.mapView.userLocation.coordinate.longitude;
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    [self.mapView setCenterCoordinate:coordinate animated:YES];
    
    // 设置地图显示的跨度
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(latitude, longitude);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    [self.mapView setRegion:region animated:YES];
    
    // 初始化button
    self.userCurrentLocation = [UIButton buttonWithType:UIButtonTypeCustom];
    _userCurrentLocation.frame = CGRectMake(10, self.mapView.frame.size.height - 50, 40, 40);
    [_userCurrentLocation setBackgroundImage:[UIImage imageNamed:@"22"] forState:UIControlStateNormal];
    [_userCurrentLocation addTarget:self action:@selector(backToUserLocation) forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:_userCurrentLocation];
}

- (void)goSearch{
    BMKGeoCodeResult *re = _array.firstObject;
    BMKGeoCodeResult *re1 = _array.lastObject;
    MKPlacemark *mkplack = [[MKPlacemark alloc] initWithCoordinate:re.location addressDictionary:nil];
    MKPlacemark *mkplack1 = [[MKPlacemark alloc]initWithCoordinate:re1.location addressDictionary:nil];
    MKMapItem *sourceItem = [[MKMapItem alloc] initWithPlacemark:mkplack];
    
    MKMapItem *destItem = [[MKMapItem alloc]initWithPlacemark:mkplack1];
    [self findDirectionsForm:sourceItem  to:destItem];
}

- (void)findDirectionsForm:(MKMapItem *)source to:(MKMapItem *)destination{
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = source;
    request.destination = destination;
    request.requestsAlternateRoutes = NO;
    request.transportType = MKDirectionsTransportTypeWalking;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error:%@", error);
        } else {
            MKRoute *route = response.routes[0];
            [self.mapView addOverlay:route.polyline];
        }
    }];
}

// 对路线的设置
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    renderer.strokeColor = [UIColor magentaColor];
    renderer.lineWidth = 3.0;
    return  renderer;
}

#pragma mark - 释放地图内存
//释放地图内存
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    [self.mapView removeFromSuperview];
    [self.view addSubview:_mapView];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.mapView.showsUserLocation = NO;
    self.mapView.delegate = nil;
    [self.mapView removeFromSuperview];
    self.mapView = nil;
    self.searcher.delegate = nil;
}

// uibutton的点击事件，返回用户当前位置
- (void)backToUserLocation{
    CLLocationCoordinate2D center = self.mapView.userLocation.location.coordinate;
    [self.mapView setCenterCoordinate:center animated:YES];
}

// 懒加载
- (BMKPoiSearch *)search{
    if (!_search) {
        _search = [[BMKPoiSearch alloc] init];
    }
    return _search;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
