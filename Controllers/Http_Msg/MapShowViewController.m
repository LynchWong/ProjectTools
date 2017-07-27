//
//  MapShowViewController.m
//  zpp
//
//  Created by Chuck on 16/5/10.
//  Copyright © 2016年 myncic.com. All rights reserved.
//

#import "MapShowViewController.h"
#import "APPUtils.h"
@interface MapShowViewController ()

@end

@implementation MapShowViewController


- (id)initWithLocation:(double)showLon showLat:(double)showLat label:(NSString*)label{
    self = [super init];
    if (self) {
        
        paoLon = showLon;
        paoLat = showLat;
        oldLon = 50;
        desLocation = label;
        anno_name = @"起点";
    }
    return self;
}

- (id)initWithOrder:(double)old_Lon lastLon:(double)lastLon lastLat:(double)lastLat label:(NSString*)label annoLon:(double)annoLon annoLat:(double)annoLat annoName:(NSString*)annoName;{
    self = [super init];
    if (self) {
        
        paoLon = lastLon;
        paoLat = lastLat;
        oldLon = old_Lon;
        desLocation = label;
        anno_lat = annoLat;
        anno_lon = annoLon;
        anno_name = annoName;
        if(anno_name == nil){
            anno_name = @"";
        }
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [MainViewController setPosition:@"MapShowViewController"];
    hasOpened=YES;
    [self initController];

}


-(void)initController{
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMapShowOrder:)  name:@"refreshMapShowOrder" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MapShowView_back)  name:@"MapShowView_back" object:nil];//后退
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMapShowView:)  name:@"refreshMapShowView" object:nil];//刷新位置
    
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    
    bodyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    [bodyView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:bodyView];
    
    
    
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    _mapView.delegate = self;
    [bodyView addSubview:_mapView];
    _mapView.alpha = 0;
    _mapView.zoomLevel = 16;//默认缩放
    _mapView.cameraDegree = 40;//摄像机角度
    [_mapView setShowsCompass:NO];//隐藏指南针
    [_mapView setShowsScale:NO];//隐藏比例尺
    [_mapView setShowTraffic:NO];//显示交通
    _mapView.showsBuildings = NO;//是否显示楼块
    _mapView.skyModelEnable = NO;
    _mapView.touchPOIEnabled = NO;
    _mapView.showsIndoorMap = NO;
    _mapView.showsIndoorMapControl=NO;
    
    [_mapView setRotateEnabled:NO];
    
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    infoDictionary = nil;
    
    //返回
    backView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    [backView setFrame:CGRectMake(-10, 25, 60, 35)];
    backView.layer.cornerRadius = 6;
    backView.alpha=0.9;
    [backView.layer setMasksToBounds:YES];
    [bodyView addSubview:backView];
    
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, (backView.height-18)/2, 18, 18)];
    [backImageView setImage:[UIImage imageNamed:@"goBack_white.png"]];
    [backView addSubview:backImageView];
    backImageView = nil;
    
    UIControl *backControl = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, backView.width, backView.height)];
    [backControl addTarget:self action:@selector(beback) forControlEvents:UIControlEventTouchUpInside];
    [backControl addSubview:backImageView];
    [backView addSubview:backControl];
    backControl = nil;
    
    CGFloat locationYAdd = 60;
    if(desLocation!= nil && desLocation.length>0){
        
        
        UIVisualEffectView *bottomView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        [bottomView setFrame:CGRectMake(0, SCREENHEIGHT-45, SCREENWIDTH, 45)];
        [self.view addSubview:bottomView];
        
        
        UILabel *positionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,0, SCREENWIDTH-20, 45)];
        positionLabel.text = desLocation;
       
        positionLabel.textAlignment = NSTextAlignmentLeft;
        positionLabel.numberOfLines = 2;
        positionLabel.textColor = [UIColor whiteColor];
        positionLabel.font = [UIFont fontWithName:textDefaultFont size:12];
        
        [bottomView addSubview:positionLabel];
        
        positionLabel = nil;
        bottomView = nil;
        
        locationYAdd = 100;
    }
    
    
    
    //定位按钮
    UIView *locationView =  [APPUtils getLocationBtn:[anno_name isEqualToString:@"终点"]?[UIImage imageNamed:@"location_myself_red.png"]:[UIImage imageNamed:@"location_myself.png"] x:10 y:SCREENHEIGHT-locationYAdd width:0];
    [bodyView addSubview:locationView];
    
    MyBtnControl *locationControl = (MyBtnControl*)[locationView viewWithTag:123];
    locationControl.clickBackBlock = ^(){
        [self location_Myself];
    };
    locationControl = nil;
    
    
  
    __weak typeof(self) weakSelf = self;
    
    //联系人追踪
    followView =  [APPUtils getLocationBtn:(oldLon == 50)?([anno_name isEqualToString:@"终点"]?[UIImage imageNamed:@"end_anno.png"]:[UIImage imageNamed:@"begin_anno.png"]):([appName isEqualToString:@"找跑跑"]?[UIImage imageNamed:@"paopao_head.png"]:[UIImage imageNamed:@"default_head_boy_60.png"]) x:SCREENWIDTH-locationView.width y:locationView.y width:0] ;
    [bodyView addSubview:followView];
    
    MyBtnControl * followControl = (MyBtnControl*)[followView viewWithTag:123];
    followControl.clickBackBlock = ^(){
      [weakSelf jump2contactLocation];
    };
    followControl = nil;
    
    
    [self addAnno];
    
   
    
    if(oldLon != 50){
        [self refreshLocation];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        
        _mapView.alpha = 1;
    }];
    
}


//跳到联系人位置
-(void)jump2contactLocation{
    
    if(annotationLocation!= nil){
        [_mapView removeAnnotation:annotationLocation];
    }
    [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(paoLat,paoLon) animated:YES];
}


//刷新坐标（跑跑用）
-(void)refreshMapShowOrder:(NSNotification*)notification{
    
    if(hasOpened){
        @try {
            
            NSDictionary *userdic = [notification userInfo];
            anno_name = [userdic objectForKey:@"name"];
            anno_lat = [[userdic objectForKey:@"lat"] doubleValue];
            anno_lon = [[userdic objectForKey:@"lon"] doubleValue];
            
            [self addAnno];
            [self refreshLocation];
            
        } @catch (NSException *exception) {
            
        }
        
        
    }
    
    
}


//添加起终点
-(void)addAnno{
    
    if(annotationBegin != nil){
        [_mapView removeAnnotation:annotationBegin];
    }
    
    if(annotationEnd != nil){
        [_mapView removeAnnotation:annotationEnd];
    }
    
    if(oldLon == 50){//oldLon == 50 消息位置发送的显示
        
        if(oldLon == 50){
            
            CLLocationCoordinate2D coor;
            coor.latitude = paoLat;
            coor.longitude = paoLon;
            annotationBegin = [[MAPointAnnotation alloc] init];
            annotationBegin.coordinate = coor;
            annotationBegin.title = anno_name;
            [_mapView addAnnotation:annotationBegin];
            
            [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(paoLat,paoLon) animated:NO];
            
            [UIView animateWithDuration:0.2 animations:^{
                
                _mapView.alpha  = 1;
            }];
           
            
            return;
        }
        
        
        //坐标
        if(anno_lon>0 && anno_lat>0 && anno_name.length>0){
            CLLocationCoordinate2D coor;
            coor.latitude = anno_lat;
            coor.longitude = anno_lon;
            annotationEnd = [[MAPointAnnotation alloc] init];
            annotationEnd.coordinate = coor;
            annotationEnd.title = anno_name;
            [_mapView addAnnotation:annotationEnd];
            
            [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(anno_lat,anno_lon) animated:NO];
            
            [UIView animateWithDuration:0.2f animations:^{
                 _mapView.alpha  = 1;
            }];
           
        }
        
    }
}


//刷新位置(跑跑用)
-(void)refreshMapShowView:(NSNotification*)notification{
    
    if(hasOpened){
        @try {
            
            NSDictionary *userdic = [notification userInfo];
            paoLat = [[userdic objectForKey:@"lastLat"] doubleValue];
            paoLon = [[userdic objectForKey:@"lastLon"] doubleValue];
            oldLon = [[userdic objectForKey:@"oldLon"] doubleValue];
            [self refreshLocation];
            userdic = nil;
        } @catch (NSException *exception) {
            
        }
    }
}


//刷新位置(跑跑用)
-(void)refreshLocation{
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        //添加跑跑anno
        if(motorAnnotation != nil){
            [_mapView removeAnnotation:motorAnnotation];
            motorAnnotation = nil;
            
        }
        
        
        if(paoLat==0 || paoLon==0){
            if(motorRunningTimer.isValid){
                [motorRunningTimer invalidate];
                motorRunningTimer = nil;
            }
            followView.alpha=0;
       
        }else{
            followView.alpha=1;
        
            if(oldLon==50){
                return;
            }
            
            CLLocationCoordinate2D coor;
            coor.latitude = paoLat;
            coor.longitude = paoLon;
            motorAnnotation = [[MAPointAnnotation alloc] init];
            motorAnnotation.coordinate = coor;
            motorAnnotation.title = @"跑跑";
            
            if(paoLon < oldLon && oldLon!= 0){//往左移动
                direction = 1;
            }else{
                direction = 0;
            }
            
            [_mapView addAnnotation:motorAnnotation];
            
         
            [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(paoLat,paoLon) animated:NO];
                //                [_mapView setZoomLevel:16];
            
            
            
   
                
            if(motorRunningTimer.isValid){
                [motorRunningTimer invalidate];
                motorRunningTimer = nil;
            }
            
            motorRunningTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(motorRunning) userInfo:nil repeats:YES];
            
            
            
            [UIView animateWithDuration:0.2f animations:^{
                _mapView.alpha  = 1;
            }];
        }
        
        
    });
    
}

//(跑跑用)
-(void)motorRunning{
    
    if(motorRunningImageView != nil){
        
        if(motorRunningCounter==0){
            
            if([appName isEqualToString:@"找跑跑"]){
                if(direction == 1){
                    [motorRunningImageView setImage:[UIImage imageNamed:@"left_motor1.png"]];
                }else{
                    [motorRunningImageView setImage:[UIImage imageNamed:@"motor1.png"]];
                }
            }else{
                [motorRunningImageView setImage:[UIImage imageNamed:@"default_head_boy_60_left.png"]];
            }
            
            
            
            motorRunningCounter = 1;
        }else{
            
            if([appName isEqualToString:@"找跑跑"]){
                if(direction == 1){
                    [motorRunningImageView setImage:[UIImage imageNamed:@"left_motor2.png"]];
                }else{
                    [motorRunningImageView setImage:[UIImage imageNamed:@"motor2.png"]];
                }
            }else{
                [motorRunningImageView setImage:[UIImage imageNamed:@"default_head_boy_60_right.png"]];
            }
           
            
            motorRunningCounter = 0;
        }
        
    }
    
}




//-------------------点击定位--------------------------
-(void)location_Myself{
    
  
    
    __weak typeof(self) weakSelf = self;
    
    if(locationUtil==nil){
        locationUtil = [[LocationUtils alloc] initLocation];
        locationUtil.callBackBlock = ^(double lat,double lon,NSString*position,NSString *city,BOOL refresh){
            if(lat!=-1){
                  [weakSelf showLocation:lat lon:lon];
            }
          
        };
    }
    
    locationUtil.handleLocationCity=YES;
    [locationUtil startLocation];
    
    
}


-(void)showLocation:(double)lat lon:(double)lon{
    if(lat == 0 || lon == 0){
        return;
    }
    if(annotationLocation != nil){
        [_mapView removeAnnotation:annotationLocation];
        annotationLocation = nil;
    }
    
    
    [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(lat,lon) animated:YES];
    
    CLLocationCoordinate2D coor;
    coor.latitude = lat;
    coor.longitude = lon;
    annotationLocation = [[MAPointAnnotation alloc] init];
    annotationLocation.coordinate = coor;
    annotationLocation.title = @"定位";
    [_mapView addAnnotation:annotationLocation];
    
}


//自定义annotation
#pragma mark - MAMapViewDelegate

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        
        static NSString *customReuseIndetifier = @"custom_mapshow_ReuseIndetifier";
        
        MAAnnotationView *annotationView = (MAAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:customReuseIndetifier];
        
        
        if ([annotation isKindOfClass:[MANaviAnnotation class]]){//路径规划的中间点不显示
            if (annotationView == nil){
                annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:customReuseIndetifier];
                annotationView.alpha=0;
            }
            
        }else{
            
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:customReuseIndetifier];
            [annotationView setFrame:CGRectMake(0, 0, 60, 60)];
            [annotationView setBackgroundColor:[UIColor clearColor]];
            // must set to NO, so we can show the custom callout view.
            
            annotationView.canShowCallout = NO;
            
            UIImageView *annoImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, 6, 30, 30)];
            if( [annotation.title isEqualToString:@"起点"]){
                [annoImage setImage:[UIImage imageNamed:@"begin_annotation_full.png"]];
            }else if([annotation.title isEqualToString:@"终点"]){
                [annoImage setImage:[UIImage imageNamed:@"end_annotation_full.png"]];
            }else if([annotation.title isEqualToString:@"定位"]){
                 [annoImage setFrame:CGRectMake(15, 5, 25, 25)];
                [annoImage setImage:[UIImage imageNamed:@"location_self_icon.png"]];
            }else if([annotation.title isEqualToString:@"跑跑"]){
                
                [annoImage setFrame:CGRectMake(14.5, 14.5, 25, 25)];
                
                if([appName isEqualToString:@"找跑跑"]){
                    if(direction == 1){
                        [annoImage setImage:[UIImage imageNamed:@"left_motor1.png"]];
                    }else{
                        [annoImage setImage:[UIImage imageNamed:@"motor1.png"]];
                    }
                }else{
                    [annoImage setImage:[UIImage imageNamed:@"default_head_boy_60.png"]];
                }
                
                
                motorRunningImageView = annoImage;
                
                paoAnnoTationView = annotationView;
                
                
                
            }else{
                return annotationView;
            }
            
            [annotationView addSubview:annoImage];
            annoImage = nil;
            
            
        }
        
        
        
        return annotationView;
    }
    
    return nil;
}



-(void)beback{
    
    if(motorAnnotation != nil){
        [_mapView removeAnnotation:motorAnnotation];
        motorAnnotation = nil;
    }
    
    if(annotationBegin != nil){
        [_mapView removeAnnotation:annotationBegin];
    }
    
    if(annotationEnd != nil){
        [_mapView removeAnnotation:annotationEnd];
    }

    if(annotationLocation != nil){
        [_mapView removeAnnotation:annotationLocation];
        annotationLocation = nil;
    }
    
    _mapView.delegate = nil;
    _mapView = nil;
    hasOpened = NO;
    
    if(motorRunningTimer.isValid){
        [motorRunningTimer invalidate];
        motorRunningTimer = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}



-(void)MapShowView_back{
    if(hasOpened){
        [self beback];
    }
    
}


- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)dealloc {
    //取消注册广播
    hasOpened = NO;
    _mapView = nil;

    [[NSNotificationCenter  defaultCenter] removeObserver:self  name:@"refreshMapShowOrder" object:nil];
    [[NSNotificationCenter  defaultCenter] removeObserver:self  name:@"MapShowView_back" object:nil];
    [[NSNotificationCenter  defaultCenter] removeObserver:self  name:@"refreshMapShowView" object:nil];

    if(motorRunningTimer.isValid){
        [motorRunningTimer invalidate];
        motorRunningTimer = nil;
    }
}

@end


