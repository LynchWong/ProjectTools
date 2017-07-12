//
//  SelectEndViewController.m
//  zpp
//
//  Created by Chuck on 16/6/12.
//  Copyright © 2016年 myncic.com. All rights reserved.
//

#import "SelectEndViewController.h"
#import "MainViewController.h"
@interface SelectEndViewController ()

@end

@implementation SelectEndViewController



- (id)initWithLocation:(NSString*)address city:(NSString*)city endLon:(CGFloat)endLon endLat:(CGFloat)endLat begin:(BOOL)begin hasData:(BOOL)hasData shop:(BOOL)shop color:(UIColor*)color mType:(NSString*)mType{
    self = [super init];
    if (self) {
        isSetBegin = begin;
        lon = endLon;
        lat = endLat;
        locationAddress = address;
        defaultData = hasData;
        location_showAddress = @"";
        isShop =shop;
        selectMainColor = color;
        mapType = mType;
       
    }
    return self;
}

- (id)initWithSendPostion:(UIColor*)color{
    self = [super init];
    if (self) {
        mapType = @"";
        sendPositionType = YES;
        location_showAddress = @"";
        selectMainColor = color;
        
    }
    return self;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MainViewController setPosition:@"SelectEndViewController"];
    
    
    [self initController];
    // Do any additional setup after loading the view.
    
}


-(void)initController{
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    hasOpened = YES;
    dataList = [[NSMutableArray alloc] init];
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    //地图板块
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    _mapSearcher =  [[AMapSearchAPI alloc] init];
    
    _mapView.delegate = self;
    _mapSearcher.delegate = self;
    
    [self.view addSubview:_mapView];
    
    
    [_mapView setMapType:MAMapTypeStandard];
    [_mapView setShowsCompass:NO];//隐藏指南针
    [_mapView setShowsScale:NO];//隐藏比例尺
    [_mapView setShowTraffic:NO];//显示交通
    _mapView.showsBuildings = NO;//是否显示楼块
    _mapView.skyModelEnable = NO;
    _mapView.touchPOIEnabled = NO;
    _mapView.showsIndoorMap = NO;
    _mapView.showsIndoorMapControl=NO;
    [_mapView setRotateEnabled:NO];
    _mapView.zoomLevel = 16;//默认缩放
    _mapView.cameraDegree = 40;
    
    //地图上显示标注
    
    desPosition_bottom = [[UIImageView alloc] initWithFrame:CGRectMake((SCREENWIDTH-23)/2, (SCREENHEIGHT-7.9)/2-1, 23, 7.9)];
    [desPosition_bottom setImage:[UIImage imageNamed:@"des_position_bottom.png"]];
    [self.view addSubview:desPosition_bottom];
    
    desPosition = [[UIImageView alloc] initWithFrame:CGRectMake((SCREENWIDTH-30)/2, desPosition_bottom.y-24, 30, 30)];
    
    [self.view addSubview:desPosition];
    
    if(!defaultData){
        desPosition.alpha = 0;
        desPosition_bottom.alpha=0;
        _mapView.alpha = 0;
    }else{
        _mapView.alpha = 1;
    }
    
    CGFloat prompWidth;
    CGFloat prompHeight;
    if([mapType isEqualToString:@"找跑跑"]){
        prompHeight = 55;
        if(isShop||sendPositionType){
            prompWidth = 120;
            [desPosition setImage:[UIImage imageNamed:@"begin_anno.png"]];
        }else{
            if(isSetBegin){
                prompWidth = 165;
                [desPosition setImage:[UIImage imageNamed:@"begin_anno.png"]];
            }else{
                prompWidth = 200;
                [desPosition setImage:[UIImage imageNamed:@"end_anno.png"]];
            }
        }
    }else{
        prompHeight = 45;
        prompWidth = 100;
        [desPosition setImage:[UIImage imageNamed:@"begin_anno.png"]];
    }
    
 
    
    
    prompView = [[UIView alloc] initWithFrame:CGRectMake((SCREENWIDTH-prompWidth)/2, desPosition_bottom.y-prompHeight-20, prompWidth,prompHeight)];
    prompView.alpha=0;
    if(!sendPositionType){
        [self.view addSubview:prompView];
        
        UIView *promptBlur= [[UIView alloc] initWithFrame:CGRectMake(0, 0, prompWidth, prompHeight-15)];
        [promptBlur.layer setMasksToBounds:YES];//圆角不被盖住
        [promptBlur setClipsToBounds:YES];//减掉超出部分
        [promptBlur setBackgroundColor:selectMainColor];
        promptBlur.layer.cornerRadius = promptBlur.height/2;
        [prompView addSubview:promptBlur];
        
        UIImageView *paoHead = [[UIImageView alloc] initWithFrame:CGRectMake(10, (promptBlur.height-21)/2, 21, 21)];
        [promptBlur addSubview:paoHead];
      
        
        UILabel *promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(33, 0, prompWidth, promptBlur.height)];
        promptLabel.textColor = [UIColor whiteColor];
        promptLabel.textAlignment = NSTextAlignmentLeft;
        promptLabel.font = [UIFont fontWithName:textDefaultBoldFont size:12];
        promptLabel.numberOfLines = 1;
        [promptBlur addSubview:promptLabel];
        
        
        UIImageView *blueTrungle = [[UIImageView alloc] initWithFrame:CGRectMake((prompWidth-15)/2, promptBlur.height, 15, 15)];
        [prompView addSubview:blueTrungle];
        
        if(isSetBegin){
            [blueTrungle setImage:[UIImage imageNamed:@"blue_trungle.png"]];
        }else{
            [blueTrungle setImage:[UIImage imageNamed:@"red_trungle.png"]];
        }
        
        
        if([mapType isEqualToString:@"找跑跑"]){
            
            if(isSetBegin){
                if(isShop){
                    promptLabel.text = @" 您的商铺地址";
                }else{
                    promptLabel.text = @"叫跑跑来这里办事/代购";
                }
                
                [blueTrungle setImage:[UIImage imageNamed:@"blue_trungle.png"]];
            }else{
                promptLabel.text = @"跑跑办完事将去这里验收/送货";
                [blueTrungle setImage:[UIImage imageNamed:@"red_trungle.png"]];
            }

            if(isShop){
                [paoHead setImage:[UIImage imageNamed:@"shop_little.png"]];
            }else{
                [paoHead setImage:[UIImage imageNamed:@"paopao_head.png"]];
            }
            
        }else{
            if([mapType isEqualToString:@"寻赏圈"]){
                promptLabel.text = @" 联系地址";
            }else if([mapType hasPrefix:@"吾能"]){
                promptLabel.text = @" 标记地址";
            }
            
            [paoHead setImage:[UIImage imageNamed:@"amazing.png"]];
        }
        
        promptBlur = nil;
        promptLabel = nil;
        paoHead = nil;
        
        __weak typeof(self) weakSelf = self;
        prompControl = [[MyBtnControl alloc] initWithFrame:CGRectMake(0, 0, prompView.width, prompView.height)];
        prompControl.back_highlight = YES;
        prompControl.clickBackBlock = ^(){
            [weakSelf begin_input_search];
        };
        
        [prompView addSubview:prompControl];
        
    
    }
    
    
    
    //头部View
    //实现模糊效果  如需加深  改MAINGRAYCOLOR 的alpha即可
    
    
    UIVisualEffectView *titletView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [titletView setFrame:CGRectMake(0, 0, SCREENWIDTH, TITLE_HEIGHT)];
    [self.view addSubview:titletView];
    
    UIControl *backControl = [[UIControl alloc] initWithFrame:CGRectMake(0, 20, 35, 44)];
    [backControl setBackgroundColor:[UIColor clearColor]];
    
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(9.5, 14, 16, 16)];
    UIImage *back = [UIImage imageNamed:@"beback_gray.png"];
    [backImageView setImage:back];
    [backImageView setContentMode:UIViewContentModeScaleAspectFill];
    [backControl addTarget:self action:@selector(beBack) forControlEvents:UIControlEventTouchUpInside];
    [backControl addSubview:backImageView];
    [titletView addSubview:backControl];
    
    
    [titletView addSubview:[APPUtils get_line:0 y:TITLE_HEIGHT-0.5 width:SCREENWIDTH]];
    
    
    
    //搜索框
    
    UIView *search_Under = [[UIView alloc] initWithFrame:CGRectMake(37, (44-32)/2+22, SCREENWIDTH-64, 28)];
    [search_Under setBackgroundColor:[UIColor whiteColor]];
    search_Under.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
    search_Under.layer.shadowOffset = CGSizeMake(0,0);//shadowOffset阴影偏移
    search_Under.layer.shadowOpacity = 0.4;//阴影透明度，默认0
    search_Under.layer.shadowRadius = 3;//阴影半径，默认3
    [titletView addSubview:search_Under];
    search_Under = nil;
    
    
    searchView = [[UIView alloc] init];
    [searchView setFrame:CGRectMake(35, (44-32)/2+20, SCREENWIDTH-60, 32)];
    [searchView.layer setCornerRadius:4];
    [searchView setBackgroundColor:[UIColor whiteColor]];
    
    [searchView.layer setMasksToBounds:YES];//圆角不被盖住
    [searchView setClipsToBounds:YES];//减掉超出部分
    searchView.layer.borderColor = [LINECOLOR2 CGColor];
    searchView.layer.borderWidth = 0.3f;
    [titletView addSubview:searchView];
    
    
    search_input = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, searchView.width-45, searchView.height)];
    [search_input setTextColor:TEXTGRAY];
    
    [search_input setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [search_input setKeyboardType:UIKeyboardTypeDefault];
    search_input.returnKeyType = UIReturnKeyDone;
    search_input.textAlignment = NSTextAlignmentLeft;
    [search_input setFont:[UIFont fontWithName:textDefaultFont size:14]];
    search_input.tag = 1111;
    search_input.delegate = self;
    [search_input setBorderStyle:UITextBorderStyleNone];
    search_input.returnKeyType = UIReturnKeySearch;
    [search_input setClearButtonMode:UITextFieldViewModeNever];
    search_input.enablesReturnKeyAutomatically = YES;//无文字就灰色
    [searchView addSubview:search_input];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkText) name:UITextFieldTextDidChangeNotification object:search_input];
    
    __weak typeof(self) weakSelf = self;
    
    //放大镜
    search_control = [[MyBtnControl alloc] initWithFrame:(CGRectMake(searchView.width-50, 0, 50, searchView.height))];
    [searchView addSubview:search_control];
    search_control.clickBackBlock = ^(){
        [weakSelf searchByGlass];
        
    };
    
    [search_control addImage:[UIImage imageNamed:@"searcher.png"] frame:CGRectMake(search_control.width-35, (search_control.height-23)/2-1, 23, 23)];
    
    
    
    //删除
    cleanSeach_control = [[MyBtnControl alloc] initWithFrame:(CGRectMake(searchView.width-40, 0, 40, searchView.height))];
    [searchView addSubview:cleanSeach_control];
    cleanSeach_control.clickBackBlock = ^(){
        [weakSelf close_search:YES close:(search_input.text.length>0)?NO:YES];
    };
    cleanSeach_control.alpha = 0;
    
    [cleanSeach_control addImage:[UIImage imageNamed:@"clean_search.png"] frame:CGRectMake((cleanSeach_control.width-13)/2, (cleanSeach_control.height-13)/2, 13, 13)];
    
    
    
    UIView *position_under  = [[UIView alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT-48, SCREENWIDTH, 5)];
    [position_under setBackgroundColor:[UIColor whiteColor]];
    position_under.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
    position_under.layer.shadowOffset = CGSizeMake(0,0);//shadowOffset阴影偏移
    position_under.layer.shadowOpacity = 0.8;//阴影透明度，默认0
    position_under.layer.shadowRadius = 3;//阴影半径，默认3
    [self.view addSubview:position_under];
    
    
    UIView *positionControlUnder = [[UIView alloc] init];
    [positionControlUnder setBackgroundColor:EMPTYGRAY];
    [positionControlUnder setFrame:CGRectMake(0, SCREENHEIGHT-50, SCREENWIDTH, 50)];
    [self.view addSubview:positionControlUnder];
    
    
    positionControl = [[MyBtnControl alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT-50, SCREENWIDTH, 50)];
    positionControl.not_highlight = YES;
    
    positionControl.clickBackBlock = ^(){
        [weakSelf begin_input_search];
        
    };
    
    [self.view addSubview:positionControl];
    
    
    
    
    end_position_label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREENWIDTH-90, positionControl.height)];
    end_position_label.lineBreakMode = NSLineBreakByWordWrapping;
    end_position_label.textAlignment = NSTextAlignmentLeft;
    end_position_label.numberOfLines = 2;
    positionControl.shareLabel = end_position_label;
    end_position_label.font = [UIFont fontWithName:textDefaultFont size:13];
    [positionControl addSubview:end_position_label];
    
    if(sendPositionType){
        end_position_label.text = @"选择您要发送的位置";
        end_position_label.textColor = [UIColor lightGrayColor];
    }else{
        if(defaultData){
            end_position_label.text = [NSString stringWithFormat:@"%@%@",locationAddress,location_showAddress];
            end_position_label.textColor = TEXTGRAY;
        }else{
            if([mapType isEqualToString:@"找跑跑"]){
                if(isShop){
                    end_position_label.text = @"请设定店铺地址";
                }else{
                    end_position_label.text = @"请设定地点";
                }
            }else if([mapType isEqualToString:@"寻赏圈"]){
                end_position_label.text = @"请设置联系地址";
            }else if([mapType hasPrefix:@"吾能"]){
                end_position_label.text = @"请标记地址";
            }
            
            end_position_label.textColor = [UIColor lightGrayColor];
        }
    }
    
    
    
    okControl = [[MyBtnControl alloc] initWithFrame:CGRectMake(SCREENWIDTH-70, 0, 70, 50)];
    [okControl setBackgroundColor:LINECOLOR2];
    [okControl setEnabled:NO];
    [okControl.layer setMasksToBounds:YES];
    [positionControl addSubview:okControl];
    okControl.clickBackBlock = ^(){
        
        [weakSelf selectOk];
    };
    
    [okControl addLabel:sendPositionType?@"发送":@"确定" color:[UIColor whiteColor] font:[UIFont fontWithName:textDefaultBoldFont size:13]];
    
    
    
    UIVisualEffectView * askLabelView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    [askLabelView setFrame:CGRectMake(0, positionControl.y-30, SCREENWIDTH, 30)];
    if(!sendPositionType){
        [self.view addSubview:askLabelView];
    }
    
    
    [askLabelView addSubview:[APPUtils get_line:0 y:0 width:SCREENWIDTH]];
    
    
    [askLabelView addSubview:[APPUtils get_line:0 y:askLabelView.height-0.5 width:SCREENWIDTH]];
    
    
    UILabel *askLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREENWIDTH, askLabelView.height)];
    askLabel.textAlignment = NSTextAlignmentLeft;
    askLabel.numberOfLines = 1;
    askLabel.textColor = selectMainColor;
    askLabel.font = [UIFont fontWithName:textDefaultBoldFont size:13];
    [askLabelView addSubview:askLabel];
    
    askLabelView = nil;
    
    
    //搜索数组
    //底部毛玻璃
    tableUnderBlur= [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [tableUnderBlur setFrame:CGRectMake(0, TITLE_HEIGHT, SCREENWIDTH, BODYHEIGHT)];
    tableUnderBlur.alpha = 0;
    [self.view addSubview:tableUnderBlur];
    
    
    searchTable = [[UITableView alloc] initWithFrame:tableUnderBlur.frame];
    searchTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; //隐藏tableview多余行数的线条
    [searchTable setBounces:YES];
    [searchTable setBackgroundColor:[UIColor clearColor]];
    searchTable.tag = 1111;
    searchTable.delegate = self;//调用delegate
    searchTable.dataSource=self;
    searchTable.separatorStyle = UITableViewCellSeparatorStyleNone; //去掉table分割线
    searchTable.showsVerticalScrollIndicator = YES;
    searchTable.alpha = 0;
    [self.view addSubview:searchTable];
    
    
    search_NoresultView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREENWIDTH-ERROR_STATE_BACKGROUND_WIDTH)/2, (SCREENHEIGHT-ERROR_STATE_BACKGROUND_WIDTH)/2, ERROR_STATE_BACKGROUND_WIDTH, ERROR_STATE_BACKGROUND_WIDTH)];
    
    [search_NoresultView setImage:[UIImage imageNamed:@"search_no_result.png"]];
    
    search_NoresultView.alpha=0;
    [self.view addSubview:search_NoresultView];
    

    UIImage *locationImg;
    if(sendPositionType||isShop){
        
        locationImg =[UIImage imageNamed:@"location_myself.png"];
        search_input.placeholder = @"搜索地点";
        
        if(isShop){
            if([mapType isEqualToString:@"找跑跑"]){
                askLabel.text = @"请在地图上标注您的商铺地址";
            }else if([mapType isEqualToString:@"寻赏圈"]){
                askLabel.text = @"请在地图上标明您的联系地址";
            }
        }
        
    }else{
    
        if([mapType isEqualToString:@"找跑跑"]){
            if(isSetBegin){
                 locationImg = [UIImage imageNamed:@"location_myself.png"];
                search_input.placeholder = @"搜索跑跑办事/代购地点";
                askLabel.text = @"您需要跑跑去哪里办事/代购?";
                
            }else{
                locationImg = [UIImage imageNamed:@"location_myself_red.png"];
                search_input.placeholder = @"搜索跑跑验收/送货地点";
                askLabel.text = @"您需要跑跑办完事/买完东西后去哪里验收/送货?";
            }
        }
    }
    
    
    askLabel =nil;
    
    
    //定位按钮
    UIView *locationView =  [APPUtils getLocationBtn:locationImg x:10 y:(SCREENHEIGHT-(sendPositionType?100:126)) width:0];
    [self.view  addSubview:locationView];
    
    MyBtnControl *locationControl = (MyBtnControl*)[locationView viewWithTag:123];
    locationControl.clickBackBlock = ^(){
        [search_input resignFirstResponder];
        [self startLocation];
    };
    locationControl = nil;
  

    if(locationUtil==nil){
        locationUtil = [[LocationUtils alloc] initLocationWithNoAlert];
        locationUtil.callBackBlock = ^(double latt,double lonn,NSString*position,NSString *city,BOOL refresh){
            
            [weakSelf showLocation:latt lonn:lonn posi:position city:city];
        };
    }
    
    
    locationEnable = YES;
    
    if(defaultData){
        move_by_search = YES;
        isSearching = NO;
        
        [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(lat,lon) animated:NO];


        [self setPositionShowView];
        
         myCityName = [[APPUtils getUserDefaults]objectForKey:@"location_city"];
         myCityAdcode = [MainViewController sharedMain].locationUtil.ad_code;
    }else{
        locationAddress = @"";
        location_showAddress = @"";
        
        [self startLocation];
    }
    
    
    
    [[UITextField appearance] setTintColor:selectMainColor];
    
    
    goSetLocationControl = [[MyBtnControl alloc] initWithFrame:CGRectMake(0, TITLE_HEIGHT, SCREENWIDTH, 50)];
    [goSetLocationControl setBackgroundColor:MAINRED];
    goSetLocationControl.alpha = 0;
    [self.view addSubview:goSetLocationControl];
    
    [goSetLocationControl addImage:[UIImage imageNamed:@"location_white.png"] frame:CGRectMake(10, (50-25)/2, 25, 25)];
    [goSetLocationControl addLabel:[NSString stringWithFormat:@"若要指定位置,请允许「%@」访问您的位置 点击去设置->",mapType] color:[UIColor whiteColor] font:[UIFont fontWithName:textDefaultBoldFont size:12] txtAlignment:NSTextAlignmentLeft frame:CGRectMake(45, 0, SCREENWIDTH-55, 50)
     ];
    goSetLocationControl.shareLabel.numberOfLines=2;
    
    goSetLocationControl.clickBackBlock = ^(){
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            //如果点击打开的话，需要记录当前的状态，从设置回到应用的时候会用到
            [[UIApplication sharedApplication] openURL:url];
            
        }
    };
    
    [APPUtils get_line:0 y:goSetLocationControl.height-0.5 width:SCREENWIDTH];
    
}




//定位
-(void)startLocation{
    
    if(locationEnable){
        [locationUtil startLocation];
    }
}


//定位结果
-(void)showLocation:(double)latt lonn:(double)lonn posi:(NSString*)posi city:(NSString*)city{

    
    if(latt == -1){
        
        goSetLocationControl.alpha = 1;
        locationEnable = NO;
        [self setDataEnable:NO];
        
    }else{
        lat = latt;
        lon = lonn;
        myCityName = city;
        location_showAddress = posi;
        myProvinceName = locationUtil.locationProvince;
        
        myCityCode = locationUtil.cityCode;
        myCityAdcode = locationUtil.ad_code;
        
        goSetLocationControl.alpha = 0;
        locationEnable = YES;
        
        [self setPositionShowView];
        
        [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(latt,lonn) animated:(_mapView.alpha==0?NO:YES)];
        
        [self showMap];
    }
 

}

//显示地图
-(void)showMap{
    [UIView animateWithDuration:0.2 animations:^{
        prompView.alpha=0.9;
        _mapView.alpha = 1;
        desPosition_bottom.alpha = 1;
        desPosition.alpha = 1;
        
    }];
    
    
}

//位置是否可用
-(void)setDataEnable:(BOOL)enable{

    if(enable){
        end_position_label.textColor = TEXTGRAY;
        [positionControl setEnabled:YES];
         okControl.alpha=1;
        [okControl setBackgroundColor:selectMainColor];
        [okControl setEnabled:YES];
        [prompControl setEnabled:YES];
     
    }else{
   
        end_position_label.textColor = [UIColor lightGrayColor];
        [okControl setBackgroundColor:LINECOLOR];
        [okControl setEnabled:NO];
        [positionControl setEnabled:NO];
        prompView.alpha=0.2;
         [prompControl setEnabled:NO];
        
    }
}


/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    
    
    if (response.regeocode != nil) {
        
        myCityName = response.regeocode.addressComponent.city;
        myProvinceName = response.regeocode.addressComponent.province;
        if(myCityName == nil || myCityName.length == 0){
            myCityName = myProvinceName;
        }
        myCityAdcode = [response.regeocode.addressComponent.adcode integerValue];
        
        if([mapType isEqualToString:@"找跑跑"]){
            
            thisCityCode = [response.regeocode.addressComponent.citycode integerValue];
            thisCityAdcode = [response.regeocode.addressComponent.adcode integerValue];
            
    
            adcodeDifference =18;
            
            if(thisCityCode>0 && thisCityAdcode>0 && myCityCode>0 && myCityAdcode>0){
                if(!sendPositionType && ( thisCityCode!=myCityCode || (abs(myCityAdcode-thisCityAdcode))>adcodeDifference)){
                    
                    [self setDataEnable:NO];
                    
                    [ToastView showToast:@"抱歉,暂不支持跨城服务,请回到您的所在城市"];
                    end_position_label.text = @"抱歉,暂不支持跨城服务,请回到您的所在城市";
                   
                    return;
                }
            }
        }
        
        [self showMap];
    
        @try {
            
            if([response.regeocode.pois count]>0){
                
                
                NSInteger minDisTance = 200;
                NSInteger index = -1;
                
                if(minDisTance<=20){//小于50m
                    
                    AMapPOI* poiInfo = [response.regeocode.pois objectAtIndex:index];
                    
                    locationAddress = [NSString stringWithFormat:@"%@%@",response.regeocode.addressComponent.district,poiInfo.address];;
                    location_showAddress = poiInfo.name;
                   
                    poiInfo = nil;
                    
                }else{
                    locationAddress = response.regeocode.formattedAddress;
                    location_showAddress = @"";
                    
                }
                
                
                
            }else{
                
                locationAddress = response.regeocode.formattedAddress;
                location_showAddress = @"";
                
            }
            
        
            //去掉省市名字
            locationAddress = [locationAddress stringByReplacingOccurrencesOfString:response.regeocode.addressComponent.city withString:@""];
            locationAddress = [locationAddress stringByReplacingOccurrencesOfString:response.regeocode.addressComponent.province withString:@""];
            
            
        } @catch (NSException *exception) {}
        
    
    }else {
        
        myCityName = @"";
        locationAddress = @"";
        
        NSLog(@"未找到逆地理编码结果");
    }

    [self setPositionShowView];
    
}



/**
 *地图区域即将改变时会调用此接口
 
 */

-(void)mapView:(MAMapView *)mapView mapWillMoveByUser:(BOOL)wasUserAction{
    
    
    [search_input resignFirstResponder];
 
    [UIView animateWithDuration:0.2 animations:^{
        if(!move_by_search){
            prompView.alpha=0.2;
        }
        
    }];
}



/**
 *地图区域改变完成后会调用此接口
 
 */

-(void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction{
    
    
    if(!move_by_search){
        // 地图中心坐标
        lon =  mapView.centerCoordinate.longitude;
        lat =  mapView.centerCoordinate.latitude;
        
        
        if(_mapView.alpha!= 0){
            //逆地理编码出地理位置
            AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
            regeo.location = [AMapGeoPoint locationWithLatitude:lat longitude:lon];
            regeo.requireExtension = YES;
            //发起逆地理编码
            [_mapSearcher AMapReGoecodeSearch:regeo];
            regeo = nil;
        }
        
        
    }else{
  
        move_by_search = NO;
    }
    
    
    //中心坐标跳一下
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:(UIViewAnimationOptionAllowUserInteraction|
                                 UIViewAnimationOptionBeginFromCurrentState)
                     animations:^(void) {
                       
                        
                         CGRect containerFrame = desPosition.frame;
                         containerFrame.origin.y = desPosition_bottom.y-28;
                         desPosition.frame = containerFrame;
                         
                         
                     }
                     completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                             
                            
                             
                             CGRect containerFrame = desPosition.frame;
                             containerFrame.origin.y = desPosition_bottom.y-24;
                             desPosition.frame = containerFrame;
                             
                             
                         } completion:NULL];
                     }];
}



-(void)setPositionShowView {
    
    
    [UIView animateWithDuration:0.2 animations:^{
         prompView.alpha=0.9;
    }];
    
    
    if(defaultLocationString != nil && defaultLocationString.length>0){
        end_position_label.text = defaultLocationString;
        defaultLocationString = @"";
    }else{
        end_position_label.text = [NSString stringWithFormat:@"%@%@",locationAddress,location_showAddress];
    }
    
    
    if(end_position_label.text.length>0){
        [self setDataEnable:YES];
    }else{
         [self setDataEnable:NO];
    }
}



//-------------------搜索-------------------------
-(void)checkText{
    if(search_input.text.length>0 && locationEnable){
        
        AMapInputTipsSearchRequest *tips = [[AMapInputTipsSearchRequest alloc] init];
        tips.keywords  = search_input.text;
        tips.city  = myCityName;
        [_mapSearcher AMapInputTipsSearch:tips];
        tips = nil;
        
    }else{
        
        [self close_search:YES close:NO];
        
    }
}



-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [search_input resignFirstResponder];
    
    if(textField.text.length>0 && locationEnable){
        
        
        AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
        
        request.keywords  = search_input.text;
        request.city     = myCityName;
        request.requireExtension = YES;
        [_mapSearcher AMapPOIKeywordsSearch:request];
        request = nil;
        
        
    }
    return YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField{
    //开始编辑时触发，文本字段将成为first responder
    
    [self.view bringSubviewToFront:tableUnderBlur];
    [self.view bringSubviewToFront:searchTable];
    [self.view bringSubviewToFront:search_NoresultView];
    
    isSearching = YES;
    
    [UIView animateWithDuration:0.3f animations:^{
        search_control.alpha = 0;
        cleanSeach_control.alpha = 0.4;
        tableUnderBlur.alpha=1;
        searchTable.alpha =1;
        
    }];
  
    
}




//关闭搜索

-(void)close_search:(BOOL)clean close:(BOOL)close{
    
    isSearching = NO;
    
    if(clean){
        search_input.text = @"";
        search_String = @"";
        search_address = @"";
        search_lon = 0;
        search_lat = 0;
        
    }
    
    
    if(close){
        [search_input resignFirstResponder];
        [UIView animateWithDuration:0.3f delay:0
                            options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState) animations:^(void) {
                                searchTable.alpha = 0;
                                tableUnderBlur.alpha = 0;
                                search_control.alpha = 1;
                                cleanSeach_control.alpha = 0;
                                search_NoresultView.alpha=0;
                                
                            }
                         completion:^(BOOL finished){
                             
                             if(clean){
                                 [dataList removeAllObjects];
                                 [searchTable reloadData];
                             }
                             
                         }];
        
    }else{
        [dataList removeAllObjects];
        [searchTable reloadData];
        
    }
    
}

//POI搜索的回调
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response{
    
    
    if(isSearching){ //搜索的poi数组
        [dataList removeAllObjects];
        
        BOOL isEmpty = NO;
        if (response.pois.count > 0){
            
            @try {
                for (int i=0; i<[response.pois count]; i++) {
                    
                    AMapPOI *tip = [response.pois objectAtIndex:i];
                    if(tip.location.latitude>0 && tip.location.longitude>0){
                        
                        NSInteger tip_adcode = [tip.adcode integerValue];
                        NSInteger tip_cityCode = [tip.citycode integerValue];
                        if(tip_cityCode == 0 || tip_cityCode!=myCityCode || tip_adcode==0 || (abs(myCityAdcode-tip_adcode))>18){//adcode >18 太远 不显示
                            tip = nil;
                            continue;
                        }
                        
                        POIData *poi = [[POIData alloc]init];
                        if([tip.address rangeOfString:tip.district].location !=NSNotFound)//去掉.0km格式
                        {
                            poi.poiaddress = tip.address;
                        }else{
                            poi.poiaddress = [NSString stringWithFormat:@"%@%@",tip.district,tip.address];
                        }
                        poi.poiName = tip.name;
                        poi.poi_id = tip.uid;
                        poi.poi_lat = tip.location.latitude;
                        poi.poi_lon = tip.location.longitude;
                        
                        if(myCityName!= nil){
                            poi.poiaddress  = [poi.poiaddress stringByReplacingOccurrencesOfString:myCityName withString:@""];
                        }
                        
                        if(myProvinceName!= nil){
                            poi.poiaddress  = [poi.poiaddress stringByReplacingOccurrencesOfString:myProvinceName withString:@""];
                        }
                        
                        [dataList addObject:poi];
                        poi = nil;
                    }
                    tip = nil;
                    
                }
            } @catch (NSException *exception) {
                
            }
            
            
        }else{
            isEmpty = YES;
        }
        
        [UIView animateWithDuration:0.2f animations:^{
            if(isEmpty){
                [self.view bringSubviewToFront:search_NoresultView];
                search_NoresultView.alpha=1;
            }else{
                search_NoresultView.alpha=0;
            }
            [searchTable reloadData];
        }];
   
        
        
    }else{//选择地点后的poi更新
        
        [self setPositionShowView];
        
    }
    
}


//建议搜索回调
- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response{
    
    
    [dataList removeAllObjects];
    
    if([response.tips count]>0){
        
        @try {
            for (int i=0; i<[response.tips count]; i++) {
                
                AMapTip *tip = [response.tips objectAtIndex:i];
                if(tip.location.latitude>0 && tip.location.longitude>0){
                    
                    NSInteger tip_adcode = [tip.adcode integerValue];
                    
                    if(tip_adcode==0 || (abs(myCityAdcode-tip_adcode))>18){//adcode >18 太远 不显示
                        tip = nil;
                        continue;
                    }
                    
                    POIData *poi = [[POIData alloc]init];
                    if([tip.address rangeOfString:tip.district].location !=NSNotFound)//去掉.0km格式
                    {
                        poi.poiaddress = tip.address;
                    }else{
                        poi.poiaddress = [NSString stringWithFormat:@"%@%@",tip.district,tip.address];
                    }
                    poi.poiName = tip.name;
                    poi.poi_id = tip.uid;
                    poi.poi_lat = tip.location.latitude;
                    poi.poi_lon = tip.location.longitude;
                    
                    if(myCityName!= nil){
                        poi.poiaddress  = [poi.poiaddress stringByReplacingOccurrencesOfString:myCityName withString:@""];
                    }
                    
                    if(myProvinceName!= nil){
                        poi.poiaddress  = [poi.poiaddress stringByReplacingOccurrencesOfString:myProvinceName withString:@""];
                    }
                    
                    [dataList addObject:poi];
                    poi = nil;
                }
                tip = nil;
                
            }
        } @catch (NSException *exception) {
            
        }
        
        
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        
        search_NoresultView.alpha=0;
        [searchTable reloadData];
    }];
    

}


//点击放大镜搜索
-(void)searchByGlass{
    if(search_input.text>0 && search_lat>0 && search_lon>0 && search_String!= nil && search_String.length>0){
        search_input.text = search_String;
        move_by_search = YES;
        end_position_label.text = search_address;
        
        [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(search_lat,search_lon) animated:YES];
        
        
    }else{
        if(locationEnable){
            [search_input becomeFirstResponder];
        }
    }
}


-(void)begin_input_search{
    if(locationEnable){
        [search_input becomeFirstResponder];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [search_input resignFirstResponder];
}


//显示tableview 的章节数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


//显示多少cells
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(search_input.text.length==0){
        if([mapType isEqualToString:@"找跑跑"]){
            return  [_addressArr count];
        }else{
            return  0;
        }
        
    }else{
        return  [dataList count];
    }
    
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    //定义个静态字符串为了防止与其他类的tableivew重复
    
    static NSString *CellIdentifier= @"CellIndentifer_end_Search";
    
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        
    }else{
        
        if([[[UIDevice currentDevice] systemVersion] floatValue] >=8.0){
            for (UIView *cellView in cell.subviews){
                [cellView removeFromSuperview];
            }
        }else{
            for (UIView *cellView in cell.subviews){ //ios7上cell第一层还有个scrollView
                for (UIView *cellView1 in cellView.subviews){
                    [cellView1 removeFromSuperview];
                }
            }
        }
        
        
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    POIData *poi;
    
    if([mapType isEqualToString:@"找跑跑"] && search_input.text.length==0){
        
        
            @try {
                poi = [_addressArr objectAtIndex:indexPath.row];
            } @catch (NSException *exception) {
                return cell;
            }
            
            
            UILabel *showNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREENWIDTH-60, 60)];
            showNameLabel.textAlignment = NSTextAlignmentLeft;
            showNameLabel.font = [UIFont fontWithName:textDefaultFont size:14];
            showNameLabel.textColor = TEXTGRAY;
            showNameLabel.text =poi.poiaddress;
            showNameLabel.numberOfLines = 1;
            [cell addSubview:showNameLabel];
            showNameLabel = nil;
            
            UIImageView *deleteImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREENWIDTH-40, (60-15)/2, 15, 15)];
            [deleteImage setImage:[UIImage imageNamed:@"delete_record.png"]];
            [cell addSubview:deleteImage];
            
            
            MyBtnControl *deleteControl = [[MyBtnControl alloc] initWithFrame:CGRectMake(SCREENWIDTH-60, 0, 60, 60)];
            deleteControl.shareImage = deleteImage;
            
            //删除常用地址
            deleteControl.clickBackBlock = ^(){
                @try {
                    
                    
                    [self delete_usedAddress:[NSString stringWithFormat:@"%d",(int)poi.address_id]];
                    [_addressArr removeObjectAtIndex:indexPath.row];
                    
                    [tableView beginUpdates];
                    NSMutableArray *indexPaths = [NSMutableArray arrayWithObject:[tableView indexPathForCell:cell]];
                    [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                    indexPaths = nil;
                    [tableView endUpdates];
                    
                    
                    
                    
                } @catch (NSException *exception) {
                    
                }
            };
            
            [cell addSubview:deleteControl];
            deleteControl = nil;
            deleteImage = nil;
            
        
    }else{
        @try {
            poi =[dataList objectAtIndex:indexPath.row];
        } @catch (NSException *exception) {
            return cell;
        }
        
        UILabel *showNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, SCREENWIDTH-30, 30)];
        showNameLabel.textAlignment = NSTextAlignmentLeft;
        showNameLabel.font = [UIFont fontWithName:textDefaultFont size:14];
        showNameLabel.textColor = TEXTGRAY;
        showNameLabel.text =poi.poiName;
        showNameLabel.numberOfLines = 1;
        [cell addSubview:showNameLabel];
        showNameLabel = nil;
        
        
        UILabel *showAddressLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, SCREENWIDTH-30, 30)];
        showAddressLabel.textAlignment = NSTextAlignmentLeft;
        showAddressLabel.font = [UIFont fontWithName:textDefaultFont size:11];
        showAddressLabel.textColor = [UIColor lightGrayColor];
        showAddressLabel.numberOfLines = 2;
        showAddressLabel.text =poi.poiaddress;
        [cell addSubview:showAddressLabel];
        showAddressLabel = nil;
        

    }
    
     [cell addSubview:[APPUtils get_line:15 y:59.5 width:SCREENWIDTH-30]];
    
    
    
    poi = nil;
    
    return  cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60.0;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

//处理行选择
- (NSIndexPath *)tableView:(UITableView *)tableView
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    @try {
        POIData *poi;
        if(search_input.text.length==0){
            if([mapType isEqualToString:@"找跑跑"]){
                poi = [_addressArr objectAtIndex:indexPath.row];
            }else{
                 return nil;
            }
           
        }else{
            poi = [dataList objectAtIndex:indexPath.row];
        }
        
        lat = poi.poi_lat;
        lon = poi.poi_lon;
        locationAddress = poi.poiaddress;
        location_showAddress = poi.poiName;
        
        
        search_input.text = location_showAddress;
        
        search_String = location_showAddress;
        search_lon = lon;
        search_lat = lat;
        search_address = [NSString stringWithFormat:@"%@%@",locationAddress,location_showAddress];
        
        
        if(search_input.text.length==0){
            search_input.text = search_address;
        }
        
        [self close_search:NO close:YES];
        
        move_by_search = YES;
        end_position_label.text = [NSString stringWithFormat:@"%@%@",locationAddress,location_showAddress];
        
        
        [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(lat,lon) animated:YES];
        
        
        poi = nil;
    } @catch (NSException *exception) {
        
    }
    
    return nil;
}






//确定选择
-(void)selectOk{
    
    NSMutableDictionary *endDic = [[NSMutableDictionary alloc] init];
    
    if(!sendPositionType){
        if(!locationEnable){
            return;
        }
        
        if(lat == 0 && lon==0){
            [ToastView showToast:@"坐标获取失败,请移动地图重新获取位置"];
            return;
        }
        if(isSetBegin){
            [endDic setObject:@"begin" forKey:@"type"];
        }else{
            [endDic setObject:@"end" forKey:@"type"];
        }
    }else{
        [endDic setObject:@"location_ok" forKey:@"type"];
        
        //截图
        UIImage *snap = [_mapView takeSnapshotInRect:CGRectMake(0, (_mapView.height-SCREENWIDTH*0.618)/2, SCREENWIDTH, SCREENWIDTH*0.618)];
        [endDic setObject:snap forKey:@"snap"];
        snap = nil;
    }
    
    
    [endDic setObject:location_showAddress forKey:@"poiname"];
    [endDic setObject:locationAddress forKey:@"address"];
    
    [endDic setObject:[NSString stringWithFormat:@"%f",lat] forKey:@"lat"];
    [endDic setObject:[NSString stringWithFormat:@"%f",lon] forKey:@"lon"];
        [endDic setObject:[NSString stringWithFormat:@"%d",(int)thisCityAdcode] forKey:@"adCode"];
    [endDic setObject:[APPUtils fixString:myCityName] forKey:@"city"];
    
    
    [self.delegate passValue:endDic];
    endDic = nil;
    
     [self closePage];
    
}


//删除常用地址
-(void)delete_usedAddress:(NSString*)addressID{
    
    self.deleteBackBlock(addressID);
}

- (void)beBack{
    
    hasOpened = NO;

    if(isSearching){
        [self close_search:NO close:YES];
    }else{
        
        _mapView = nil;
        _mapSearcher = nil;
        
        NSMutableDictionary *endDic = [[NSMutableDictionary alloc] init];
        [endDic setObject:@"end_cancle" forKey:@"type"];
        
        [self.delegate passValue:endDic];
        endDic = nil;
        
        [self closePage];
       
    }

}

-(void)closePage{
    if(_presentType){
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}


-(void)login_out{
    if(hasOpened){
        [self beBack];
    }
    
}

-(void)dealloc {
    _mapView.delegate = nil;
    _mapSearcher.delegate = nil;
    _mapView = nil;
    _mapSearcher = nil;
    
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


@implementation POIData

@end
