//
//  UserEntity.h
//  MedicalCenter
//
//  Created by 李狗蛋 on 15-3-31.
//  Copyright (c) 2015年 李狗蛋. All rights reserved.
//
//消息表类

#import <Foundation/Foundation.h>

@interface Conversation : NSObject
@property (copy, nonatomic) NSString *avatar;//头像

@property (assign, nonatomic) NSInteger createtime;//群创建时间
@property (assign, nonatomic) NSInteger group_id; //群组ID
@property (assign, nonatomic) NSInteger last_news_id;
@property (copy, nonatomic) NSString *lastmsg;//后发表的消息内容
@property (assign, nonatomic) NSInteger lasttime;//最后发表时间
@property (assign, nonatomic) NSInteger lastuid;//最后发表人UID
@property (copy, nonatomic) NSString *lastuser;//最后发表人昵称
@property (copy, nonatomic) NSString *name;//群名称
@property (assign, nonatomic) NSInteger otheruid;
@property (assign, nonatomic) NSInteger people;//群人数
@property (assign, nonatomic) NSInteger uid;//群主UID
@property (assign, nonatomic) NSInteger unread_news_count;//未读消息数
@property (copy, nonatomic) NSString *user;//群主昵称
@property (copy, nonatomic) NSString *showTime;//显示时间

@property (copy, nonatomic) NSString *otherName;//2人 对方名字

@property (assign, nonatomic) BOOL selected;//转发选择群组用
@property (assign, nonatomic) NSInteger auth_type;//是否专业跑跑

@property (copy, nonatomic) NSString *sendWho;//发给跑跑还是客户

@end
