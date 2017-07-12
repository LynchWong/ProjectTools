//
//  CitySelectView.h
//  zpp
//
//  Created by Chuck on 2017/4/27.
//  Copyright © 2017年 myncic.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "MyBtnControl.h"

@interface CitySelectView : UIView<UIScrollViewDelegate, UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>{
    
    BOOL allCitys;//显示全国
    
    //区域选择
    
    UIVisualEffectView *areaPickerView;
    UITextField *searchAreaView;
    MyBtnControl *all_area;//全国
    UIView *hotCityView;
    UITableView *areaTable;
    
    NSString *check_city;
    NSString *location_city;
    NSArray *serviceAreaArray;
    NSArray  *hotCityArray;
    NSMutableArray *serviceAreaFliterArray;//过滤
    
    CGFloat middleMargin;//间隙
}

@property(nonatomic,assign)BOOL cityLoadOver;//区域加载完成;
@property(nonatomic,assign) BOOL readyOpenAreaView;//加载完打开
@property(nonatomic,strong) MyBtnControl *relocationArea;//定位
typedef void (^CityBlock)(NSString *city);
@property (nonatomic,strong)CityBlock callBackBlock;

- (id)initCity:(BOOL)showAll;

-(void)openCityView;

//刷新定位城市
-(void)refresh_location_city;
-(void)closePickerView;
@end


@interface Area : NSObject
@property (copy, nonatomic) NSString *province;
@property (copy, nonatomic) NSString *city;
@property (copy, nonatomic) NSString *provinceWord;
@property (copy, nonatomic) NSString *cityWords;
@property (copy, nonatomic) NSString *cityAllWords;
@property (copy, nonatomic) NSString *cityFirstWord;
@property (assign, nonatomic) NSInteger sortid;
@property (assign, nonatomic) NSInteger cityCode;


@property (copy, nonatomic) NSDictionary *cityDic;
@end
