//
//  ScheduleViewController.h
//  zmams
//
//  Created by 李狗蛋 on 15-7-28.
//  Copyright (c) 2015年 李狗蛋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "AlarmEntity.h"
#import "AddScheduleViewController.h"
#import "ZJSwitch.h"
@interface ScheduleViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,PassValueDelegate>{

    NSMutableArray *dataList;
    BOOL _reloading;
    BOOL isEmpty;
    float cellHeight;
  
    UITableView *alarmTable;
    UIRefreshControl *refreshControl;
    
    BOOL deleteing;
    BOOL hasOpen;
    
}

//闹钟设定
+(void)resetSchedules:(NSMutableArray*)alarmArr;
//获取日程单例
+(AlarmEntity*)getAlarmEntity:(NSDictionary*)dic;

@end
