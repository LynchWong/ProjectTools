//
//  AddScheduleViewController.h
//  zmams
//
//  Created by 李狗蛋 on 15-8-6.
//  Copyright (c) 2015年 李狗蛋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "AlarmEntity.h"
#import "DateSelector.h"
#import "SetTextview.h"
@class DateSelector;
@class SetTextview;



@interface AddScheduleViewController : UIViewController{


    
    BOOL isAdd;
    float lastY;

 
    NSDateFormatter *formatterDate;
    NSDateFormatter *formatterTime;
  
    
    DateSelector *dateSelector;
    SetTextview *desText;
    MyBtnControl *alarmDateBtn;//响铃日期 会隐藏
    MyBtnControl *alertBtn;//提醒内容
 
    //星期选择
    UIView *chooseWeekView;

}


- (id)initWithAlarm:(AlarmEntity*)alarm;

@property(copy,nonatomic) AlarmEntity *myAlarm;
@property(nonatomic,assign) NSObject<PassValueDelegate> *delegate;

@end
