//
//  UserUtils.h
//  MedicalCenter
//
//  Created by 李狗蛋 on 15-4-1.
//  Copyright (c) 2015年 李狗蛋. All rights reserved.


#import <Foundation/Foundation.h>



@interface NewsDealEntity : NSObject

@property (copy, nonatomic) NSString *avatar;
@property (assign, nonatomic) NSInteger isVip; 

@property (copy, nonatomic) NSString *deal_id; 
@property (copy, nonatomic) NSString *deal_uid; //dz用户id;

@property (copy, nonatomic) NSString *newsNickName;
@property (copy, nonatomic) NSString *showDate;

@end
