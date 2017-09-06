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


@property(nonatomic,retain) NSMutableArray *unreadMsgArray;//未读消息




typedef void (^RefreshBlock)(BOOL update);//获取完毕
@property (nonatomic,copy)RefreshBlock callBackBlock;


typedef void (^SendMsgBlock)(NSString *resultString);//发送完毕
@property (nonatomic,copy)SendMsgBlock sendBackBlock;


@property(nonatomic,strong)AFN_util *afn;


- (id)initMsgUtil;
//获取消息
-(void)check_msgs;
//获取消息获取状态
-(BOOL)getMsgChecking;

//获取一个conversation对象
+(Conversation*)getConversation:(NSDictionary*)convDic;

//获取消息存msglist表的语句
+(NSString*)getSave2MsgListSql:(Conversation*)conv msgFrom:(NSString*)msgFrom;

//获取消息存msgContent表的语句
+(NSString*)getSave2MsgContentSql:(Conversation*)conv  fromMysefl:(BOOL)fromMyself;//fromMysefl 我发送的


//获取消息存MsgGroupsList表的语句
+(NSString*)getSave2MsgGroupsListSql:(Conversation*)conv;

//更新存MsgGroupsList表的语句
+(NSString*)getUpdateMsgGroupsListSql:(Conversation*)conv;

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
