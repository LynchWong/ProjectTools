//
//  UserEntity.h
//  MedicalCenter
//
//  Created by 李狗蛋 on 15-3-31.
//  Copyright (c) 2015年 李狗蛋. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlarmEntity : NSObject



@property (strong, nonatomic) NSString *alarmId;//区别唯一性
@property (strong, nonatomic) NSString *uid;

@property (strong, nonatomic) NSDate *alarmDate;//响铃时间
@property (assign, nonatomic) NSInteger alarmTime;//响铃时间
@property (strong, nonatomic) NSString *tempDate;//设置日期yyyy-mm-dd
@property (strong, nonatomic) NSString *tempTime;//设置时间 hh:mm a
@property (strong, nonatomic) NSString *labelshow;


@property (strong, nonatomic) NSString *repeatword;//显示重复文字
@property (assign, nonatomic) NSInteger repeatType;//是否重复
@property (strong, nonatomic) NSString *repeatDays;//重复的星期

@property (assign, nonatomic) BOOL everyDay;//每天
@property (assign, nonatomic) BOOL outOfDate;//过期
@end
