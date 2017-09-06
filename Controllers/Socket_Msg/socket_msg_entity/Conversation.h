//
//  UserEntity.h
//  MedicalCenter
//
//  Created by 李狗蛋 on 15-3-31.
//  strongright (c) 2015年 李狗蛋. All rights reserved.
//
//消息表类

#import <Foundation/Foundation.h>

@interface Conversation : NSObject

@property (strong, nonatomic) NSString *group;//[1，2]
@property (strong, nonatomic) NSString *lastmsg;//后发表的消息内容
@property (assign, nonatomic) NSInteger lasttime;//最后发表时间
@property (assign, nonatomic) NSInteger lastuid;//最后发表人UID
@property (strong, nonatomic) NSString *lastName;//最后发表人名字
@property (strong, nonatomic) NSString *lastAvatar;//最后发表人头像 或 对方头像
@property (strong, nonatomic) NSString *lastType;//最后发表信息类型
@property (strong, nonatomic) NSString *tail;//文件类型
@property (assign, nonatomic) NSInteger otheruid;//对方id
@property (assign, nonatomic) NSInteger people;//群人数
@property (assign, nonatomic) NSInteger unread_news_count;//未读消息数
@property (strong, nonatomic) NSString *showTime;//显示时间
@property (assign, nonatomic) NSInteger alarm_level;//通知等级
@property (assign, nonatomic) NSInteger auto_play_voice;//通知自动播放

@property (strong, nonatomic) NSString *msg_id;//当前回话的新消息id
@property (strong, nonatomic) NSDictionary *content_dic;//当前回话的新消息dic
@property (strong, nonatomic) NSDictionary *header_dic;//当前回话的新消息dic

//群聊
@property (assign, nonatomic) NSInteger master;//群主UID
@property (strong, nonatomic) NSString *gname;//群名称 或对方名称
@property (assign, nonatomic) NSInteger isGroupTalk;//是不是群聊


@end
