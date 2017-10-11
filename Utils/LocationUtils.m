//
//  LocationUtils.m
//  zpp
//
//  Created by Chuck on 2017/4/23.
//  Copyright © 2017年 myncic.com. All rights reserved.
//

#import "LocationUtils.h"
#import "APPUtils.h"
#import "MainViewController.h"


@implementation LocationUtils
@synthesize check_city;
@synthesize my_lat;
@synthesize my_lon;
@synthesize my_position;

- (id)initLocation{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

-(id)initLocationWithShowAlert{
    self = [super init];
    if (self) {
        
        [self initData];
        showAlert = YES;
    }
    return self;
}

-(void)initData{
    _mapSearcher =  [[AMapSearchAPI alloc] init];
    _mapSearcher.delegate = self;
}

-(void)startLocation{
    
     [APPUtils setMethod:@"LocationUtils -> startLocation"];
    
    if(locationIng){
        return;
    }
    
    locationIng = YES;
    NSLog(@"开始定位");
    
    locationAuth = [LocationUtils getLocationAuth];
    
    if(locationManager==nil){
        locationManager = [[AMapLocationManager alloc] init];
        [locationManager setDelegate:self];
        [locationManager setAllowsBackgroundLocationUpdates:YES];
        [locationManager setPausesLocationUpdatesAutomatically:NO];//设置允许后台定位参数，保持不会被系统挂起
    }
    
    
    //NSLocationWhenInUseUsageDescription表示应用在前台的时候可以搜到更新的位置信息。
    //NSLocationAlwaysUsageDescription表示应用在前台和后台（suspend或terminated)都可以获取到更新的位置数据。
    //需要在plist文件添加NSLocationWhenInUseUsageDescription
    
    
    //高德定位
    [locationManager startUpdatingLocation];
    
}


//权限判断
-(void)amapLocationManager:(AMapLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{

    //切换时候才会调用
    if(status == kCLAuthorizationStatusAuthorizedWhenInUse){
        NSLog(@"可以定位");
    }else{
        NSLog(@"未开启定位权限");
    }
}



//停止定位
-(void)stopLocation
{
    NSLog(@"停止定位");
    
    [locationManager stopUpdatingLocation];
    
}

//高德定位错误
- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error
{
    [self locationFailed];
 
    
}

-(void)locationFailed{
    
    //若定位失败 尝试IP定位  高德  但是需要白名单  弃用
    //http://lbs.amap.com/api/webservice/guide/api/ipconfig/ 使用
    //http://lbs.amap.com/api/webservice/guide/tools/info/  错误码
    //key 需要web类型
    
    
     [APPUtils setMethod:@"LocationUtils -> locationFailed"];
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.myncic.iplocation",DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(concurrentQueue, ^{
        

        //myncic ip定位
        BOOL ipLocationOk = NO;
        NSString *ip= [GetDeviceIp getPubIPAddress];//我的ip
        if(ip!=nil && ip.length>0){
        
            NSString *iplocation = [NSString stringWithFormat:@"http://%@/plugin_1?c=api&a=iptolocation&ip=%@",[AFN_util getIpadd],ip];
            
            NSData *iplocationData = [NSData dataWithContentsOfURL:[NSURL URLWithString:iplocation]];
            if(iplocationData){
                @try {
                    
                    NSDictionary *dataDic = [APPUtils getDicByJson:[APPUtils data2String:iplocationData]];
                    dataDic = [[APPUtils getDicByJson:[dataDic objectForKey:@"data"]] objectForKey:@"content"];
                
                    
                    NSDictionary *address_detail = [dataDic objectForKey:@"address_detail"];
                    
                    _locationProvince = [address_detail objectForKey:@"province"];
                    NSString *locationCity = [address_detail objectForKey:@"city"];
                    
                    
                    address_detail = nil;
                    if(my_lon == 0 && my_lat==0){
                        
                        NSDictionary *point = [dataDic objectForKey:@"point"];
                        
                        my_lon = [[point objectForKey:@"x"]doubleValue];
                        my_lat = [[point objectForKey:@"y"]doubleValue];
                        
                        
                        [APPUtils userDefaultsSet:[NSString stringWithFormat:@"%.6f",my_lon] forKey:@"my_lon"];
                        [APPUtils userDefaultsSet:[NSString stringWithFormat:@"%.6f",my_lat] forKey:@"my_lat"];
                        
                        point = nil;
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                         [self saveLocation:locationCity];
                    });
                   

                    dataDic = nil;
                    
                    ipLocationOk = YES;
                } @catch (NSException *exception) {}
            }
            iplocationData = nil;
            iplocation = nil;
        }

        
        ip = nil;
        
      
        if(!ipLocationOk){
            [APPUtils userDefaultsDelete:@"location_city"];
            [APPUtils userDefaultsDelete:@"location_province"];
             locationIng = NO;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.callBackBlock(-1, -1, nil, nil, NO);
                
                
                [ShowWaiting hideWaiting];
                
                if(_handleLocationCity||showAlert){
                    
                    if(locationAuth){
                        
                        [ToastView showToast:@"定位异常,请重试"];
                        
                        return;
                    }else{
                        if(_error_string==nil){
                            _error_string = @"定位失败,请开启定位权限重试";
                        }
                    }
                    
                    
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                             message:_error_string
                                                                                      preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}];
                    
                    
                    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"去开启" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                        
                        [APPUtils intoSetting];
                    }];
                    
                    [alertController addAction:cancel];
                    [alertController addAction:confirm];
                    
                    
                    [[MainViewController sharedMain] presentViewController:alertController animated:YES completion:nil];
                    cancel = nil;
                    confirm = nil;
                    alertController = nil;
                    
                }
                _handleLocationCity=NO;
            });
        }
    });
    
    
    
    
}



//高德定位数据代理
- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location{
    
     [APPUtils setMethod:@"LocationUtils -> amapLocationManager"];
    
    //取出当前位置的坐标
    [self stopLocation];
    
    if([[APPUtils GetCurrentTimeString]integerValue]-locationTime<3){//3s间隔
        return;
    }
    
    locationTime = [[APPUtils GetCurrentTimeString]integerValue];
    
    if(location.coordinate.latitude>0 && location.coordinate.longitude>0){
        
        
        NSLog(@"定位位置： lat %f,long %f",location.coordinate.latitude,location.coordinate.longitude);
        
        
        my_lon = location.coordinate.longitude;
        my_lat = location.coordinate.latitude;
        
      
        [APPUtils userDefaultsSet:[NSString stringWithFormat:@"%.6f",my_lon] forKey:@"my_lon"];
        [APPUtils userDefaultsSet:[NSString stringWithFormat:@"%.6f",my_lat] forKey:@"my_lat"];
        
        //逆地理编码出地理位置
        AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
        regeo.location = [AMapGeoPoint locationWithLatitude:my_lat longitude:my_lon];
        regeo.requireExtension = YES;
        //发起逆地理编码
        [_mapSearcher AMapReGoecodeSearch:regeo];
        regeo = nil;
        
        
    }else{
        //定位失败
        _handleLocationCity=NO;
        [self locationFailed];
        
    }
    
}


//逆地址错误 （key未验证）
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error{
    
     [self locationFailed];
}


/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    
    [APPUtils setMethod:@"LocationUtils -> onReGeocodeSearchDone"];
    
    if (response.regeocode != nil) {
        
        _locationProvince = response.regeocode.addressComponent.province;
        NSString *locationCity = response.regeocode.addressComponent.city;
        
    
        _cityCode = [response.regeocode.addressComponent.citycode integerValue];
        _ad_code = [response.regeocode.addressComponent.adcode integerValue];
        
        
        
        if(locationCity == nil || locationCity.length == 0){
            //对于直辖市，response.regeocode.addressComponent对象的city属性值为空，province属性中是直辖市名称。
            locationCity = response.regeocode.addressComponent.province;
        }
        
        my_position = response.regeocode.formattedAddress;
        @try {
            my_position = [my_position stringByReplacingOccurrencesOfString:response.regeocode.addressComponent.city withString:@""];
            my_position = [my_position stringByReplacingOccurrencesOfString:response.regeocode.addressComponent.province withString:@""];
            [APPUtils userDefaultsSet :my_position forKey:@"my_position"];
            
            [APPUtils userDefaultsSet :[NSString stringWithFormat:@"%d",(int)[response.regeocode.addressComponent.adcode integerValue]] forKey:@"my_adCode"];
            
        } @catch (NSException *exception) { }
        
        
        [self saveLocation:locationCity];
        
        
        locationCity = nil;
     
    }else {
        
        [self locationFailed];
        [ShowWaiting hideWaiting];
        [ToastView showToast:@"抱歉,无法知道您的位置 T_T"];
      
    }
    
}

//保存定位数据
-(void)saveLocation:(NSString*)locationCity{

    [APPUtils setMethod:@"LocationUtils -> saveLocation"];
    
    if(locationCity!=nil){
        
        locationCity = [locationCity stringByReplacingOccurrencesOfString:@"市" withString:@""];
        
        [APPUtils userDefaultsSet : locationCity forKey:@"location_city"];//定位城市
    }
    
    if(_locationProvince!=nil){
        [APPUtils userDefaultsSet : _locationProvince forKey:@"location_province"];//定位省份
    }

    
    check_city = [APPUtils get_ud_string:@"check_city"];
    
    //切换城市 跑跑用
    if(_goback_city && !_handleLocationCity && check_city!=nil && check_city.length>0 && ![check_city isEqualToString:locationCity]){
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                 message:[NSString stringWithFormat:@"检测到您当前所在城市为%@,是否切换到该地区",locationCity]
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            
        }];
        
        
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"切换城市" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
            check_city = locationCity;
            [APPUtils userDefaultsSet :check_city forKey:@"check_city"];
            
            self.callBackBlock(my_lat, my_lon, my_position,check_city,YES);
            
        }];
        
        [alertController addAction:cancel];
        [alertController addAction:confirm];
        
        
        [[MainViewController sharedMain] presentViewController:alertController animated:YES completion:nil];
        cancel = nil;
        confirm = nil;
        alertController = nil;
        
    }else{
        
        BOOL refresh = YES;
        if(_handleLocationCity){//手动定位城市
            refresh = NO;
            [ShowWaiting hideWaiting];
        }
        _handleLocationCity = NO;
        
        
        if(check_city==nil||check_city.length==0){
            check_city = locationCity;
        }
        [APPUtils userDefaultsSet :check_city forKey:@"check_city"];
        
        self.callBackBlock(my_lat, my_lon, my_position,locationCity,refresh);
        
        
    }
    
    locationIng = NO;
    
}


//获取定位权限
+(BOOL)getLocationAuth{
    NSLog(@"%d",[CLLocationManager authorizationStatus]);
    
    //    [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined 未选择
    
    if ([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways|| [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)) {
        //        NSLog(@"可以定位");
        //定位功能可用
        return YES;
        
    }else{
        //        NSLog(@"未开启定位权限");
        //定位不能用
        return NO;
    }
}
@end
