//
//  MapShowViewController.h
//  zpp
//
//  Created by Chuck on 16/5/10.
//  Copyright © 2016年 myncic.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapNaviKit/AMapNaviKit.h>
#import "MANaviRoute.h"
#import "LocationUtils.h"
#import "APPUtils.h"
#import "SelectableOverlay.h"
#import "SelectEndViewController.h"
@class POIData;
@class MyBtnControl;
@class LocationUtils;



@interface MapShowViewController : UIViewController<MAMapViewDelegate,AMapNaviWalkManagerDelegate,AMapNaviDriveManagerDelegate,AMapSearchDelegate>{
    
    BOOL hasOpened;
    UIView *bodyView;
    
    UIVisualEffectView *backView;
 

    double paoLon;
    double paoLat;
    double oldLon;
    NSString *desLocation;
    
    NSString *appName;
    double anno_lat;//跑跑用
    double anno_lon;
    NSString *anno_name;
    
    double my_lat;
    double my_lon;

    //定位
    LocationUtils * locationUtil;
    MAPointAnnotation *annotationLocation;
    UILabel *positionLabel;
    //联系人追踪
    UIView *followView;
    
    
    //跑跑用
    MAPointAnnotation *motorAnnotation;//骑手位置
    MAPointAnnotation *annotationBegin;
    MAPointAnnotation *annotationEnd;
    MAAnnotationView *paoAnnoTationView;//跑跑的anno view; 保持最前
    NSInteger motorRunningCounter;
    UIImageView *motorRunningImageView;
    NSInteger direction;//方向
    NSTimer *motorRunningTimer;
    
    //搜索坐标
    BOOL search_type;
    NSString *search_string;//关键字
 
    AMapSearchAPI *_mapSearcher;//搜索类
    BOOL poiSearching;
    NSMutableArray *poiAnnotations;
    float annoDefaultWidth;//未选择的宽度
    float annoSelectWidth;//选择的宽度
    NSMutableArray *anno_view_arr;
    
    //导航类型
    BOOL lead_type;
    NSString *lead_name;
    UIImage *lead_icon;//小图
    UIImage *lead_anno_icon;//anno大图
    NSString *leadWay;//导航方式
    
    AMapNaviWalkManager*walkManager;//步行导航类
    AMapNaviDriveManager*driveManager;//驾车导航类
    BOOL naving;//规划中
    
  
    

}

- (id)initWithOrder:(double)old_Lon lastLon:(double)lastLon lastLat:(double)lastLat label:(NSString*)label annoLon:(double)annoLon annoLat:(double)annoLat annoName:(NSString*)annoName;//跑跑用

//打开定位
- (id)initWithLocation:(double)showLon showLat:(double)showLat label:(NSString*)label;

//搜索坐标
- (id)initWithSearch:(NSString*)searchString myLat:(double)myLat myLon:(double)myLon myDes:(NSString*)myDes;

//导航类型
- (id)initWithLead:(NSString*)leadName leadIcon:(UIImage*)leadIcon leadAnnoIcon:(UIImage*)leadAnnoIcon showLon:(double)showLon showLat:(double)showLat;

@property (retain,nonatomic) MAMapView* mapView;



@end

