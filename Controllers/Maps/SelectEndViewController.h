//
//  SelectEndViewController.h
//  zpp
//
//  Created by Chuck on 16/6/12.
//  Copyright © 2016年 myncic.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "APIKey.h"
#import "PassValueDelegate.h"
#import "LocationUtils.h"
@class MyBtnControl;
@class LocationUtils;
@interface SelectEndViewController : UIViewController<UITextFieldDelegate,MAMapViewDelegate,AMapSearchDelegate, UITableViewDataSource,UITableViewDelegate>{
    
    NSString *mapType;//使用app
    
    MAMapView* _mapView;
    AMapSearchAPI *_mapSearcher;//搜索类
    BOOL hasOpened;
    
    
    UIImageView *desPosition;
    UIImageView *desPosition_bottom;
    
    //标注提示
    UIView *prompView;
    MyBtnControl *prompControl;
    
    //定位
    BOOL locationEnable;
    LocationUtils * locationUtil;
    NSInteger myCityCode;
    NSInteger myCityAdcode;
    
    NSInteger thisCityCode;
    NSInteger thisCityAdcode;
    
    CGFloat lon;//选择坐标
    CGFloat lat;
    NSString *locationAddress;//目标地址
    NSString *myProvinceName;
    NSString *myCityName;
    NSString *location_showAddress;//poi名字
    NSInteger adcodeDifference;
    
    UIView *searchUnder;
    
    UIImageView *search_NoresultView;
    BOOL isSearching;
    MyBtnControl *search_control;
    MyBtnControl *cleanSeach_control;
    NSMutableArray *dataList; //
    UITableView *searchTable;
    UIVisualEffectView *tableUnderBlur;
    
    double search_lon;//搜索坐标
    double search_lat;
    NSString *search_String;
    NSString *search_address;
    
    
    UILabel *end_position_label;
    MyBtnControl *positionControl;
    MyBtnControl*okControl;
    
    
    UIBlurEffect *blurEffect;
    
    UIView *searchView;
    UITextField *search_input;
    
    BOOL locationAsking;//未给定位权限提示中
    BOOL move_by_search;//只显示当前名字 map移动后不做geo地理查询

    
    
    BOOL defaultData;
    BOOL isSetBegin;//重置起点
    
    UIColor *selectMainColor;
    
    NSString *defaultLocationString;
    
    
    
    MyBtnControl *goSetLocationControl;//开启定位
 
    BOOL sendPositionType;//发送位置类型
    BOOL isShop;
  
    
}

@property(nonatomic,assign) NSObject<PassValueDelegate> *delegate;
@property(nonatomic,strong) NSMutableArray *addressArr;//历史记录
@property(nonatomic,assign) BOOL presentType;//控制器类型
@property(nonatomic,assign) BOOL getSnap;//获得截图

typedef void (^MapDeleteBlock)(NSString *addressId);
@property (nonatomic,strong)MapDeleteBlock deleteBackBlock;


- (id)initWithLocation:(NSString*)address city:(NSString*)city endLon:(CGFloat)endLon endLat:(CGFloat)endLat begin:(BOOL)begin hasData:(BOOL)hasData shop:(BOOL)shop color:(UIColor*)color mType:(NSString*)mType;


- (id)initWithSendPostion:(UIColor*)color;



@end


//poi搜索类

@interface POIData : NSObject

@property(nonatomic,copy) NSString *poiaddress;
@property(nonatomic,copy) NSString *poiName;
@property (nonatomic, assign) double poi_lat;
@property (nonatomic, assign)double poi_lon;
@property (nonatomic, copy)NSString *poi_id;
@property (nonatomic, assign)NSInteger poi_distance;
//常用地址
@property(assign,nonatomic) NSInteger address_id;


@end
