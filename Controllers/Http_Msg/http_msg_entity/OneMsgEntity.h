//
//  UserEntity.h
//  MedicalCenter
//
//  Created by 李狗蛋 on 15-3-31.
//  Copyright (c) 2015年 李狗蛋. All rights reserved.  单条消息的单例
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JSONModel.h"
#import "MsgUtil.h"

@class MsgUtil;

@interface OneMsgEntity : NSObject

//新接口参数
@property (copy, nonatomic) NSString *msg_id;//消息ID
@property (assign, nonatomic) NSInteger msg_uid;//发布人ID
@property (copy, nonatomic) NSString *user;//发布人昵称
@property (copy, nonatomic) NSString *type;//消息类型
@property (assign, nonatomic) NSInteger createtime;//发布时间
@property (copy, nonatomic) NSString *avatar;//发布人头像


//老接口参数
@property (assign, nonatomic) NSInteger isRead;
@property (assign, nonatomic) NSInteger sendStatus;//消息状态
@property (copy, nonatomic) NSString *content;
@property (copy, nonatomic) NSString *contentType;//消息内容的类型
@property (assign, nonatomic) CGFloat imageDirection;//图片宽/高比
@property (copy, nonatomic) NSString *fileName;//文件名字
@property (assign, nonatomic) double filesize;//文件大小
@property (copy, nonatomic) NSString *addressString;//地址
@property (assign, nonatomic) CGFloat address_lat;
@property (assign, nonatomic) CGFloat address_lon;
@property (assign, nonatomic) NSInteger voice_length;//语音长度
@property (copy, nonatomic) NSString *big_url;//图片url
@property (copy, nonatomic) NSString *thumb_url;//小图url
@property (copy, nonatomic) NSString *ttsString;

@property (assign, nonatomic) NSInteger index_row;//table位置
@property (assign, nonatomic) NSInteger group_id;//隶属于group
@property (assign, nonatomic) NSInteger downloading;//下载中(语音) 0:未下载 1下载中 2已下载

@property (assign, nonatomic) NSInteger isLoaded;//新消息是否刷新进来
@property (assign, nonatomic) CGSize textsize;
@property (nonatomic ,strong) void (^sendOverBlock)(OneMsgEntity *send_msg);//发送结果回调

typedef void (^ProgressResultBlock)(NSString *progress); //图片上传进度返回
@property (nonatomic ,strong) ProgressResultBlock progressResult;



typedef void (^DownloadResultBlock)(NSInteger downloading); //语音下载进度返回
@property (nonatomic ,strong) DownloadResultBlock downloadCallback;

//广播参数
@property (copy, nonatomic) NSString *broadcast_title;
@property (copy, nonatomic) NSString *broadcast_content;
@property (assign, nonatomic) NSInteger broadcast_time;
@property (assign, nonatomic) NSInteger orderId;
@property (copy, nonatomic) NSMutableArray *link;
@property (assign, nonatomic) NSInteger alarm_level;
@property (assign, nonatomic) BOOL auto_play_tts;
@property (copy, nonatomic) NSString *imageName;
@property (assign, nonatomic) NSInteger content_height;//内容高度



-(void)sendMsg;//发送消息
@property (strong, nonatomic) MsgUtil *msgUtil;
@property (assign, nonatomic) BOOL sending;//发送中



//检查语音下载
-(void)checkVoice;

//播放语音
-(void)playVoice;
@property (nonatomic ,assign) NSInteger playingIndex;//播放波浪切换
@property (nonatomic ,assign) NSInteger imPlaying;//正在播放
-(void)playingShow;//波浪切换
typedef void (^PlayingvoiceBlock)(NSInteger playingIndex); //语音播放中
@property (nonatomic ,strong) PlayingvoiceBlock playingvoiceBlock;

@end


//消息发送 json
//不想因为服务器的某个值没有返回就使程序崩溃， 我们会加关键字Optional.

@interface MsgSendContent : JSONModel

@property (copy, nonatomic) NSString  <Optional>*content;
@property (copy, nonatomic) NSString  <Optional>*big_url;//图片url
@property (copy, nonatomic) NSString  <Optional>*thumb_url;//小图url
@property (assign, nonatomic) CGFloat  imageDirection;//图片宽/高比
@property (copy, nonatomic) NSString  <Optional>*fileName;//文件名字
@property (assign, nonatomic) double  filesize;//文件大小
@property (copy, nonatomic) NSString  <Optional>*addressString;//地址
@property (assign, nonatomic) CGFloat  address_lat;
@property (assign, nonatomic) CGFloat  address_lon;
@property (copy, nonatomic) NSString *type;//消息类型
@property (assign, nonatomic) NSInteger  voice_length;//语音长度

@end
