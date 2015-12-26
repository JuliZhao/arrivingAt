//
//  AppDelegate.m
//  到站啦
//
//  Created by zy on 15/12/22.
//  Copyright © 2015年 zy. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    BOOL ret = [_mapManager start:@"HZK42FVXtlotI0e43MDs9mgj"  generalDelegate:self];
    if (ret) {
        NSLog(@"manager start succeed!");
    }
    self.locationManager = [[CLLocationManager alloc] init];
    [_locationManager requestAlwaysAuthorization];
    [_locationManager requestWhenInUseAuthorization];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    
    [AVOSCloud useAVCloudCN];
    [AVOSCloud setApplicationId:@"6d4rkzcRVWeuQHlePkJtfz8Q-gzGzoHsz"
                      clientKey:@"4EXaKJ6rjOMJKNTxtU5imx2O"];
    
    return YES;
}

#pragma mark - BMKGeneralDelegate
-(void)onGetPermissionState:(int)iError{
    if (iError != 0) {
        NSLog(@"验证失败:%d", iError);
    }else{
        NSLog(@"成功 %d",iError);
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [BMKMapView willBackGround];//当应用即将后台时调用，停止一切调用opengl相关的操作
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [BMKMapView didForeGround];//当应用恢复前台状态时调用，回复地图的渲染和opengl相关的操作
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
