//
//  LocationUtils.h
//  zpp
//
//  Created by Chuck on 2017/4/23.
//  Copyright © 2017年 myncic.com. All rights reserved.  定位
//

#import <Foundation/Foundation.h>
#import "MainViewController.h"
#import <AMapLocationKit/AMapLocationKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>

@interface LocationUtils : NSObject<AMapLocationManagerDelegate,AMapSearchDelegate>{
    
    AMapLocationManager *locationManager;
    AMapSearchAPI *_mapSearcher;//搜索类
    
    //定位

    
    NSInteger locationTime;
    BOOL noAlert;//没有错误弹出
}

-(id)initLocation;
-(id)initLocationWithNoAlert;
-(void)startLocation;

@property (assign, nonatomic) BOOL handleLocationCity;//手动定位当前城市
@property (strong, nonatomic) NSString *check_city;
@property (assign, nonatomic) double my_lat;
@property (assign, nonatomic) double my_lon;
@property (strong, nonatomic) NSString *my_position;
@property (strong, nonatomic) NSString *locationProvince;

@property (assign, nonatomic) NSInteger cityCode;
@property (assign, nonatomic) NSInteger ad_code;

@property (strong, nonatomic) NSString *error_string;
@property (assign, nonatomic) BOOL goback_city;//回到城市提示

typedef void (^LocationBlock)(double lat,double lon,NSString*position,NSString *city,BOOL refresh);
@property (nonatomic,strong)LocationBlock callBackBlock;

@end
