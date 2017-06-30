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
#import <AMapSearchKit/AMapSearchKit.h>
#import "MANaviRoute.h"
#import "LocationUtils.h"
@class MyBtnControl;
@class LocationUtils;
@interface MapShowViewController : UIViewController<MAMapViewDelegate>{
    
    BOOL hasOpened;
    UIView *bodyView;
    
    UIVisualEffectView *backView;
 

    double paoLon;
    double paoLat;
    double oldLon;
    NSString *desLocation;
    
    double anno_lat;//跑跑用
    double anno_lon;
    NSString *anno_name;
    
    UIView *followUnder;
    UIView *followView;
    MyBtnControl *followControl;
    
    //定位
    UIControl *llControl;
    LocationUtils * locationUtil;
    MAPointAnnotation *annotationLocation;

    //跑跑用
    MAPointAnnotation *motorAnnotation;//骑手位置
    MAPointAnnotation *annotationBegin;
    MAPointAnnotation *annotationEnd;
    MAAnnotationView *paoAnnoTationView;//跑跑的anno view; 保持最前
    NSInteger motorRunningCounter;
    UIImageView *motorRunningImageView;
    NSInteger direction;//方向
    NSTimer *motorRunningTimer;
    
    

}

- (id)initWithOrder:(double)old_Lon lastLon:(double)lastLon lastLat:(double)lastLat label:(NSString*)label annoLon:(double)annoLon annoLat:(double)annoLat annoName:(NSString*)annoName;//跑跑用
- (id)initWithLocation:(double)showLon showLat:(double)showLat label:(NSString*)label;

@property (retain,nonatomic) MAMapView* mapView;



@end

