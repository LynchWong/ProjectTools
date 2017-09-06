//
//  MapShowViewController.m
//  zpp
//
//  Created by Chuck on 16/5/10.
//  Copyright © 2016年 myncic.com. All rights reserved.
//

#import "MapShowViewController.h"

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


//搜索坐标
- (id)initWithSearch:(NSString*)searchString myLat:(double)myLat myLon:(double)myLon myDes:(NSString*)myDes{

    self = [super init];
    if (self) {
        search_type = YES;
        search_string = searchString;
        my_lon = myLon;
        my_lat = myLat;
        desLocation = myDes;

        annoDefaultWidth = 35;
        annoSelectWidth = 45;
        anno_view_arr = [[NSMutableArray alloc] init];
        _mapSearcher =  [[AMapSearchAPI alloc] init];
        _mapSearcher.delegate = self;

    }
    return self;
}

//导航类型
- (id)initWithLead:(NSString*)leadName leadIcon:(UIImage*)leadIcon leadAnnoIcon:(UIImage*)leadAnnoIcon showLon:(double)showLon showLat:(double)showLat{

    self = [super init];
    if (self) {
         oldLon = 50;
        lead_type = YES;
        paoLon = showLon;
        paoLat = showLat;
        desLocation = leadName;
        lead_icon = leadIcon;
        lead_anno_icon = leadAnnoIcon;
        anno_name = @"lead";
        annoDefaultWidth = 45;
    
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    hasOpened=YES;
    [self initController];

}


-(void)initController{
    
     [APPUtils setMethod:@"MapShowViewController -> initController"];
    
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
        
        
        positionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,0, SCREENWIDTH-20, 45)];
        positionLabel.text = desLocation;
       
        positionLabel.textAlignment = NSTextAlignmentLeft;
        positionLabel.numberOfLines = 2;
        positionLabel.textColor = [UIColor whiteColor];
        positionLabel.font = [UIFont fontWithName:textDefaultFont size:12];
        
        [bottomView addSubview:positionLabel];
        
    
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
    
    //联系人追踪//导航目的地
    if(!search_string){//非搜索模式
        UIImage *followImg;
        if(oldLon == 50){
            if(lead_type){
                followImg = lead_icon;
            }else{
               followImg = ([anno_name isEqualToString:@"终点"]?[UIImage imageNamed:@"end_anno.png"]:[UIImage imageNamed:@"begin_anno.png"]);
            }
         
        }else{
            if([appName isEqualToString:@"找跑跑"]){
                followImg =[UIImage imageNamed:@"paopao_head.png"];
            }else if([appName isEqualToString:@"找跑跑-骑手端"]){
                followImg =[UIImage imageNamed:@"default_head_boy_60.png"];
            }
        }
        followView =  [APPUtils getLocationBtn:followImg x:SCREENWIDTH-locationView.width-10 y:locationView.y width:20] ;
        [bodyView addSubview:followView];
        
        MyBtnControl * followControl = (MyBtnControl*)[followView viewWithTag:123];
        followControl.clickBackBlock = ^(){
            [weakSelf jump2contactLocation];
        };
        followControl = nil;

        
        //导航按钮
        if(lead_type){
        
            //步行
            UIView*walkView =  [APPUtils getLocationBtn:[UIImage imageNamed:@"workLead.png"] x:followView.x y:followView.y-followView.height width:20] ;
            [bodyView addSubview:walkView];
            
            MyBtnControl * walkControl = (MyBtnControl*)[walkView viewWithTag:123];
            walkControl.clickBackBlock = ^(){
                [ToastView showToast:@"正在为您规划行走路线..."];
                [self leadWay:@"walk"];
            };
            walkControl = nil;
            
            //驾车
            UIView*driveView =  [APPUtils getLocationBtn:[UIImage imageNamed:@"driveLead.png"] x:followView.x y:walkView.y-walkView.height width:20] ;
            [bodyView addSubview:driveView];
            
            MyBtnControl * driveControl = (MyBtnControl*)[driveView viewWithTag:123];
            driveControl.clickBackBlock = ^(){
                [ToastView showToast:@"正在为您规划驾车路线..."];
                  [self leadWay:@"drive"];
            };
            driveControl = nil;
        }
    }
    
    
    if(search_type){
        [self showLocation:my_lat lon:my_lon];
    }else{
     [self addAnno];
    }
  
    if([appName isEqualToString:@"找跑跑"]){
        [self refreshLocation];
    }
    
//    [UIView animateWithDuration:0.2 animations:^{
//        _mapView.alpha = 1;
//    }];

    
}


//跳到联系人位置
-(void)jump2contactLocation{
    
    if(annotationLocation!= nil && !lead_type){
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
    
     [APPUtils setMethod:@"MapShowViewController -> addAnno"];
    
    if(annotationBegin != nil){
        [_mapView removeAnnotation:annotationBegin];
    }
    
    if(annotationEnd != nil){
        [_mapView removeAnnotation:annotationEnd];
    }
    

        if(oldLon == 50){//oldLon == 50 消息位置发送的显示
            
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
    
      [APPUtils setMethod:@"MapShowViewController -> refreshLocation"];
    
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


//------------------------------------导航

-(void)leadWay:(NSString*)type{
    
    if(naving){
        return;
    }
    naving = YES;
    leadWay = type;
    [self location_Myself];
}




//步行导航回调
- (void)walkManagerOnCalculateRouteSuccess:(AMapNaviWalkManager *)walkManager
{
    NSLog(@"步行规划成果");
    
    [ToastView showToast:@"已为您成功规划步行路线"];
    //显示路径或开启导航
    [self showNaviRoutes:@"walk"];
}


//驾车导航回调
- (void)driveManagerOnCalculateRouteSuccess:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"驾车规划成果");
    
    [ToastView showToast:@"已为您成功规划驾车路线"];
    //显示路径或开启导航
    [self showNaviRoutes:@"drive"];
}


//显示路径或开启导航
- (void)showNaviRoutes:(NSString*)way{
   
    
    [self.mapView removeOverlays:self.mapView.overlays];
  
    //将路径显示到地图上
    AMapNaviRoute *aRoute;
    if([way isEqualToString:@"walk"]){
        aRoute = walkManager.naviRoute;
    }else{
        aRoute = driveManager.naviRoute;
    }
    int count = (int)[[aRoute routeCoordinates] count];
    
    //添加路径Polyline
    CLLocationCoordinate2D *coords = (CLLocationCoordinate2D *)malloc(count * sizeof(CLLocationCoordinate2D));
    for (int i = 0; i < count; i++)
    {
        AMapNaviPoint *coordinate = [[aRoute routeCoordinates] objectAtIndex:i];
        coords[i].latitude = [coordinate latitude];
        coords[i].longitude = [coordinate longitude];
    }
    
    MAPolyline *polyline = [MAPolyline polylineWithCoordinates:coords count:count];
    
    SelectableOverlay *selectablePolyline = [[SelectableOverlay alloc] initWithOverlay:polyline];
    [self.mapView addOverlay:selectablePolyline];
    free(coords);

     [self.mapView showAnnotations:self.mapView.annotations animated:NO];
    
    naving = NO;
}



//画线
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[SelectableOverlay class]])
    {
        SelectableOverlay * selectableOverlay = (SelectableOverlay *)overlay;
        id<MAOverlay> actualOverlay = selectableOverlay.overlay;
        
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:actualOverlay];
        
        polylineRenderer.lineWidth = 8.f;
        polylineRenderer.strokeColor = selectableOverlay.isSelected ? selectableOverlay.selectedColor : selectableOverlay.regularColor;
        
        return polylineRenderer;
    }
    
    return nil;
}

- (void)walkManager:(AMapNaviWalkManager *)walkManager error:(NSError *)error{
    [self naviFail];
}
- (void)walkManager:(AMapNaviWalkManager *)walkManager onCalculateRouteFailure:(NSError *)error{
    [self naviFail];
}
- (void)driveManager:(AMapNaviDriveManager *)driveManager error:(NSError *)error{
    [self naviFail];
}
- (void)driveManager:(AMapNaviDriveManager *)driveManager onCalculateRouteFailure:(NSError *)error{
     [self naviFail];
}

//导航失败
-(void)naviFail{
    [ToastView showToast:@"导航失败,请重试"];
    naving = NO;
}
//-------------------点击定位--------------------------
-(void)location_Myself{
    
  
    __weak typeof(self) weakSelf = self;
    
    if(locationUtil==nil){
        locationUtil = [[LocationUtils alloc] initLocationWithShowAlert];
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
    
    //只定位
    if(annotationLocation != nil){
        [_mapView removeAnnotation:annotationLocation];
        annotationLocation = nil;
    }
    
    my_lat = lat;
    my_lon = lon;
    
    CLLocationCoordinate2D coor;
    coor.latitude = lat;
    coor.longitude = lon;
    annotationLocation = [[MAPointAnnotation alloc] init];
    annotationLocation.coordinate = coor;
    annotationLocation.title = @"定位";
    [_mapView addAnnotation:annotationLocation];
    
    
    [UIView animateWithDuration:0.2 animations:^{
        _mapView.alpha = 1;
    }];
    
    //导航
    if(leadWay!=nil && leadWay.length>0){
        
        if([leadWay isEqualToString:@"walk"]){
            if (walkManager == nil){
                walkManager = [[AMapNaviWalkManager alloc] init];
                [walkManager setDelegate:self];
            }
            
            [walkManager calculateWalkRouteWithStartPoints:@[[AMapNaviPoint locationWithLatitude:lat longitude:lon]]
                                                      endPoints:@[[AMapNaviPoint locationWithLatitude:paoLat longitude:paoLon]]];
        }else if([leadWay isEqualToString:@"drive"]){
        
            if(driveManager == nil){
                driveManager = [[AMapNaviDriveManager alloc] init];//MMP!
                [driveManager setDelegate:self];
            }
            
            [driveManager calculateDriveRouteWithStartPoints:@[[AMapNaviPoint locationWithLatitude:lat longitude:lon]]
                                                 endPoints:@[[AMapNaviPoint locationWithLatitude:paoLat longitude:paoLon]] wayPoints:nil drivingStrategy:AMapNaviDrivingStrategySingleDefault];
            
        }
        
        leadWay = nil;
        
    }else{
        [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(lat,lon) animated:YES];
        
        //显示周边
        if(search_type && !poiSearching){
            poiSearching = YES;
            AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
            
            request.location  = [AMapGeoPoint locationWithLatitude:my_lat longitude:my_lon];
//            request.keywords  = search_string;
            request.types = search_string;
            /* 按照距离排序. */
            request.sortrule  = 0;
            request.requireExtension  = YES;
            [_mapSearcher AMapPOIAroundSearch:request];
            request = nil;
        }
    }
    
}



//自定义annotation
#pragma mark - MAMapViewDelegate

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    
     [APPUtils setMethod:@"MapShowViewController -> viewForAnnotation"];
    
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
                
            }else if(lead_type || search_type){
            
                UIColor *grayColor = [UIColor getColor:@"A7A9AB"];
                
                [annotationView setFrame:CGRectMake(0, 0, annoSelectWidth, (annoSelectWidth+10)*2)];
                [annotationView setBackgroundColor:[UIColor clearColor]];
                
                
                UIImageView *pillar = [[UIImageView alloc] initWithFrame:CGRectMake(annotationView.width/2-2, annotationView.height/2-15, 15*1.38, 15)];//高度+5防止中间有空隙
                [pillar setImage:[UIImage imageNamed:@"pin_under.png"]];
                pillar.layer.shouldRasterize = YES;
                pillar.layer.rasterizationScale = [[UIScreen mainScreen] scale];
                pillar.tag=104;
                [annotationView addSubview:pillar];
                
                UIView *avatarUnder = [[UIView alloc] initWithFrame:CGRectMake((annotationView.width-annoDefaultWidth)/2, pillar.y-annoDefaultWidth+5, annoDefaultWidth, annoDefaultWidth)];
                avatarUnder.layer.cornerRadius = avatarUnder.height/2;
                [avatarUnder setBackgroundColor:grayColor];
                avatarUnder.tag=101;
                [avatarUnder.layer setMasksToBounds:YES];
                [annotationView addSubview:avatarUnder];
                
                
                
                UIImageView *avatar = [[UIImageView alloc] initWithFrame:CGRectMake(1, 1, annoDefaultWidth-2, annoDefaultWidth-2)];
                avatar.layer.cornerRadius = avatar.height/2;
                [avatar setBackgroundColor:[UIColor whiteColor]];
                avatar.tag=102;
                [avatar.layer setMasksToBounds:YES];
                [avatarUnder addSubview:avatar];
              
                if(lead_type){
                    [avatar setImage:lead_anno_icon];
                }else if(search_type){
                
                    UIImage *zhuzi;
                    UIColor *selectColor;
                    if([annotation.title isEqualToString:@"药"]){
                        [avatar setImage:[UIImage imageNamed:@"pills.png"]];
                        zhuzi = [UIImage imageNamed:@"pin_under_green.png"];
                        selectColor = [UIColor getColor:@"3fb253"];
                    }else if([annotation.title isEqualToString:@"医院"]){
                        [avatar setImage:[UIImage imageNamed:@"hostital.png"]];
                        zhuzi = [UIImage imageNamed:@"pin_under_red.png"];
                        selectColor = SECONDRED;
                    }
                    
                    
                    
                    MyBtnControl *selectBtn = [[MyBtnControl alloc] initWithFrame:CGRectMake(0, 0, annoSelectWidth, annotationView.height/2)];
                    selectBtn.tag=103;
                    selectBtn.not_highlight=YES;
                    [annotationView addSubview:selectBtn];
                    
                    
                    __weak __typeof(MyBtnControl*)weakBtn = selectBtn;
                    
                    selectBtn.clickBackBlock = ^(){
                        
                       
                        for( MAAnnotationView *a_View in anno_view_arr){
                            
                            [UIView animateWithDuration:0.2 animations:^{
                                
                                
                                if(a_View != annotationView){//其他
                                    
                                    @try {
                                        UIView *a_under = (UIImageView*)[a_View viewWithTag:101];
                                        UIImageView *a_avatar = (UIImageView*)[a_under viewWithTag:102];
                                        MyBtnControl *a_btn = (MyBtnControl*)[a_View viewWithTag:103];
                                        UIImageView *a_pillar = (UIImageView*)[a_View viewWithTag:104];
                                        a_pillar.layer.shouldRasterize = YES;
                                        a_pillar.layer.rasterizationScale = [[UIScreen mainScreen] scale];
                                        
                                        a_btn.choosed = NO;
                                        
                                        [a_under setFrame:CGRectMake((annotationView.width-annoDefaultWidth)/2, pillar.y-annoDefaultWidth+5, annoDefaultWidth, annoDefaultWidth)];
                                        a_under.layer.cornerRadius = annoDefaultWidth/2;
                                        
                                        [a_avatar setSize:CGSizeMake(annoDefaultWidth-2, annoDefaultWidth-2)];
                                        a_avatar.layer.cornerRadius = (annoDefaultWidth-2)/2;
                                        
                                        if(a_under.layer.borderWidth==0){
                                            [a_under setBackgroundColor:grayColor];
                                        }else{
                                            a_under.layer.borderColor = [grayColor CGColor];
                                        }
                                        
                                        [a_pillar setImage:[UIImage imageNamed:@"pin_under.png"]];
                                        
                                        
                                        a_pillar = nil;
                                        a_under = nil;
                                        a_avatar = nil;
                                        a_btn = nil;
                                    } @catch (NSException *exception) {}
                                    
                                }else if(weakBtn.choosed){//不选中
                                    
                                    weakBtn.choosed = NO;
                                    
                                    
                                    [avatarUnder setFrame:CGRectMake((annotationView.width-annoDefaultWidth)/2, pillar.y-annoDefaultWidth+5, annoDefaultWidth, annoDefaultWidth)];
                                    avatarUnder.layer.cornerRadius = annoDefaultWidth/2;
                                    
                                    [avatar setSize:CGSizeMake(annoDefaultWidth-2, annoDefaultWidth-2)];
                                    avatar.layer.cornerRadius = (annoDefaultWidth-2)/2;
                                    
                                    if(avatarUnder.layer.borderWidth==0){
                                        [avatarUnder setBackgroundColor:grayColor];
                                    }else{
                                        avatarUnder.layer.borderColor = [grayColor CGColor];
                                    }
                                    
                                    [pillar setImage:[UIImage imageNamed:@"pin_under.png"]];
                                    
                                    
                                    positionLabel.text = desLocation;
                                    
                                    
                                }else{//选中
                                    
                                    [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(annotation.coordinate.latitude,annotation.coordinate.longitude) animated:YES];
                                    
                                    weakBtn.choosed = YES;
                                    
                                    [avatarUnder setFrame:CGRectMake((annotationView.width-annoSelectWidth)/2, pillar.y-annoSelectWidth+5, annoSelectWidth, annoSelectWidth)];
                                    avatarUnder.layer.cornerRadius = annoSelectWidth/2;
                                    
                                    
                                    [avatar setSize:CGSizeMake(annoSelectWidth-2, annoSelectWidth-2)];
                                    avatar.layer.cornerRadius = (annoSelectWidth-2)/2;
                                    
                                    if(avatarUnder.layer.borderWidth==0){
                                        [avatarUnder setBackgroundColor:selectColor];
                                    }else{
                                        avatarUnder.layer.borderColor = [selectColor CGColor];
                                    }
                                    
                                    
                                    [pillar setImage:zhuzi];
                                    
                                    positionLabel.text = annotation.subtitle;
                                }
                                
                            }];
                        }
                       
                    };
                    
                    selectBtn = nil;
                    avatarUnder = nil;
                    avatar = nil;
                    pillar = nil;
                    [anno_view_arr addObject:annotationView];
                }
          
                
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



//显示周边
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response{
    
    @try {
        
        if (response.pois.count > 0){
            
            @try {
                
                if(poiAnnotations!=nil){
                    for(MAPointAnnotation *anno in poiAnnotations){
                        [_mapView removeAnnotation:anno];
                    }
                }
                
                
                poiAnnotations = [[NSMutableArray alloc] init];
               
                for (int i=0; i<[response.pois count]; i++) {
                    
                    AMapPOI *tip = [response.pois objectAtIndex:i];
                    if(tip.location.latitude>0 && tip.location.longitude>0){
                        
                        MAPointAnnotation *anno = [[MAPointAnnotation alloc] init];
                        anno.coordinate = CLLocationCoordinate2DMake(tip.location.latitude,tip.location.longitude);
                        
                        if([APPUtils stringinstring:tip.type found:@"药"]){
                            anno.title = @"药";
                        }else{
                            anno.title = @"医院";
                        }
                        anno.subtitle = tip.name;
                       
                        [_mapView addAnnotation:anno];
                        [poiAnnotations addObject:anno];
                        anno = nil;
                    }
                    tip = nil;
                    
                }
                
                
            } @catch (NSException *exception) {}
            
            
        }
        
    } @catch (NSException *exception) {}
    
    poiSearching = NO;
}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error{
        poiSearching = NO;
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

    _mapView.delegate = nil;
    _mapView = nil;
    
    if(search_type){
        _mapSearcher.delegate = nil;
        _mapSearcher = nil;
    }
    
    
    [[NSNotificationCenter  defaultCenter] removeObserver:self  name:@"refreshMapShowOrder" object:nil];
    [[NSNotificationCenter  defaultCenter] removeObserver:self  name:@"MapShowView_back" object:nil];
    [[NSNotificationCenter  defaultCenter] removeObserver:self  name:@"refreshMapShowView" object:nil];

    if(motorRunningTimer.isValid){
        [motorRunningTimer invalidate];
        motorRunningTimer = nil;
    }
    
//    if(walkManager!=nil){
//        [walkManager setDelegate:nil];
//    }
}

@end


