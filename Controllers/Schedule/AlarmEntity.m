//
//  UserEntity.m
//  MedicalCenter
//
//  Created by 李狗蛋 on 15-3-31.
//  Copyright (c) 2015年 李狗蛋. All rights reserved.
//

#import "AlarmEntity.h"

@implementation AlarmEntity

- (id)copyWithZone:(NSZone *)zone
{
    AlarmEntity *copy = [[[self class] allocWithZone:zone] init];
    copy->_alarmId = [_alarmId copy];
    copy->_uid = [_uid copy];
    copy->_alarmDate = [_alarmDate copy];
    copy->_alarmTime = _alarmTime;
    copy->_tempDate = [_tempDate copy];
    copy->_tempTime = [_tempTime copy];
    copy->_labelshow = [_labelshow copy];
    copy->_labelshow = [_labelshow copy];
    copy->_repeatword = [_repeatword copy];
    copy->_repeatType = _repeatType;
    copy->_repeatDays = [_repeatDays copy];
    copy->_everyDay = _everyDay;
    return copy;
}


@end
