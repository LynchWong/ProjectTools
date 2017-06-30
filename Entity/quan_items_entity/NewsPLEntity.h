//
//  UserUtils.h
//  MedicalCenter
//
//  Created by 李狗蛋 on 15-4-1.
//  Copyright (c) 2015年 李狗蛋. All rights reserved.
// 朋友圈评论类

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface NewsPLEntity : NSObject

@property (copy, nonatomic) NSString *news_pl_id;
@property (copy, nonatomic) NSString *parentid; //被评论的评论父级id

@property (copy, nonatomic) NSString *plContent;

@property (copy, nonatomic) NSString *comment_uid;//评论人id
@property (copy, nonatomic) NSString *comment_nickname;
@property (assign, nonatomic) CGSize comment_nickname_size;//评论人的名字长度

@property (copy, nonatomic) NSString *be_comment_uid;//被评论人id
@property (copy, nonatomic) NSString *be_comment_nickname;
@property (assign, nonatomic) CGSize be_comment_nickname_size;//被评论人的名字长度

@property (copy, nonatomic) NSString *namecolor;
@property (copy, nonatomic) NSString *be_namecolor;

@property (copy, nonatomic) NSString *showTime;
@property (copy, nonatomic) NSString *avatar;

@property (assign, nonatomic) float plHeight;

@property (assign, nonatomic) NSInteger isVip; //评论人vip
@property (assign, nonatomic) NSInteger beIsVip;//被评人vip

@property (assign, nonatomic) NSInteger dateline;
@property (assign, nonatomic) NSInteger repeatOther;//回复其他人的评论
@property (assign, nonatomic) BOOL replyBeComment;//回复被评论人

@end
