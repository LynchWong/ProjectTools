//
//  MsgUtil.h
//  zpp
//
//  Created by Chuck on 2017/4/21.
//  Copyright © 2017年 myncic.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMResultSet.h"
#import "MainViewController.h"
#import "OneMsgEntity.h"
#import "Conversation.h"

@class AFN_util;
@class OneMsgEntity;

static BOOL updateingSend;//正在更新发送中的消息到数据库
static BOOL checking_msg;//获取中
@interface MsgUtil : NSObject<AVAudioPlayerDelegate>{
    
     AVAudioPlayer *player;
    
}


@property(nonatomic,assign) NSInteger unreadMsgCount;//未读消息数
@property(nonatomic,retain) NSMutableArray *unreadMsgGroupArray;//未读消息组
@property(nonatomic,strong) NSString *lastMsgType; //上一次获取消息的最新msg类型
@property(nonatomic,strong) NSString *lastMsgID; //上一次获取消息的最新id
@property(nonatomic,strong) NSMutableArray *msgArray;



typedef void (^RefreshBlock)(BOOL update);//获取完毕
@property (nonatomic,copy)RefreshBlock callBackBlock;


typedef void (^SendMsgBlock)(NSString *resultString);//发送完毕
@property (nonatomic,copy)SendMsgBlock sendBackBlock;


@property(nonatomic,strong)AFN_util *afn;


- (id)initMsgUtil;
//获取消息
-(void)check_msgs;

//创建回话
-(void)createGroup:(NSString*)user1 user2:(NSString*)user2;

//获取一个conversation对象
+(Conversation*)getConversation:(NSDictionary*)convDic;

//获取消息存msglist表的语句
+(NSString*)getSave2MsgListSql:(NSMutableDictionary*)jsonDic msgFrom:(NSString*)msgFrom;


//获取消息存msgContent表的语句
+(NSString*)getSave2MsgContentSql:(NSMutableDictionary*)dic  fromMysefl:(BOOL)fromMyself;//fromMysefl 我发送的


//获取消息存MsgGroupList表的语句
+(NSString*)getSave2MsgGroupListSql:(Conversation*)conv;

//更新存MsgGroupList表的语句
+(NSString*)getUpdateMsgGroupListSql:(Conversation*)conv;

//发送消息
-(void)send_msgs:(OneMsgEntity*)msg;

//更新发送中的消息结果
+(void)updateSendingMsgs:(BOOL)reset;


//-----------------播放声音---------------
@property(nonatomic,assign) BOOL voice_playing;//播放中
@property(nonatomic,strong) NSString *nowPlayingMsgId;//当前正在播放的语音消息id
-(void)playVoice:(OneMsgEntity*)msg;
-(void)stopPlayer;
@end
