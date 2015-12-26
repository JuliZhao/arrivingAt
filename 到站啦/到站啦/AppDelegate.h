//
//  AppDelegate.h
//  到站啦
//
//  Created by zy on 15/12/22.
//  Copyright © 2015年 zy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, BMKGeneralDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property(nonatomic, strong) BMKMapManager*mapManager;
@property (nonatomic,strong) CLLocationManager * locationManager;
@property (nonatomic,strong) CLLocation * location;

@end

