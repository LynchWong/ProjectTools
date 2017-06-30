//
//  UserEntity.h
//  MedicalCenter
//
//  Created by 李狗蛋 on 15-3-31.
//  Copyright (c) 2015年 李狗蛋. All rights reserved.  上传健康圈用
//

#import <Foundation/Foundation.h>

@interface MyNews : NSObject

@property (copy, nonatomic) NSString *tid;
@property (copy, nonatomic) NSString *uid;
@property (copy, nonatomic) NSString *nickname;
@property (copy, nonatomic) NSString *content;
@property (copy, nonatomic) NSString *type;
@property (copy, nonatomic) NSString *avatar;
@property (copy, nonatomic) NSString *showdate;
@property (copy, nonatomic) NSString *dateline;
@property (assign, nonatomic) float contentHeight;

//寻赏圈
@property (assign, nonatomic)NSInteger role;

//跑跑
@property (assign, nonatomic) NSInteger isVip;

@end
