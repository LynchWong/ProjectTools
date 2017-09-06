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
@property (copy, nonatomic) NSString *msg_name;//发布人昵称
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
@property (copy, nonatomic) NSString *fileTail;//文件后缀
@property (assign, nonatomic) double filesize;//文件大小
@property (copy, nonatomic) NSString *addressString;//地址
@property (assign, nonatomic) CGFloat address_lat;
@property (assign, nonatomic) CGFloat address_lon;
@property (assign, nonatomic) NSInteger voice_length;//语音长度 秒
@property (copy, nonatomic) NSString *big_url;//图片url
@property (copy, nonatomic) NSString *thumb_url;//小图url
@property (copy, nonatomic) NSString *ttsString;

@property (assign, nonatomic) NSInteger index_row;//table位置
@property (copy, nonatomic) NSString* group;//隶属于group
@property (assign, nonatomic) NSInteger downloading;//下载中 0:未下载 1下载中 2已下载 3刚下载
@property (assign, nonatomic) float progress;//进度

@property (assign, nonatomic) double defaultSize;//一次下载/上传多少
@property (assign, nonatomic) double downloadSize;//当前已下载多少
@property (strong, nonatomic) NSMutableData *downloadData;//下载缓存数据

@property (strong, nonatomic) NSData *uploadData;//要上传的文件数据
@property (assign, nonatomic) NSInteger uploadPiece;//上传总份数
@property (assign, nonatomic) NSInteger nowPiece;//当前份数
@property (assign, nonatomic) double uploadedSize;//当前已上传多少
@property (assign, nonatomic) BOOL videocompressing;//视频压缩中


@property (assign, nonatomic) NSInteger isLoaded;//新消息是否刷新进来
@property (assign, nonatomic) CGSize textsize;
@property (nonatomic ,strong) void (^sendOverBlock)(OneMsgEntity *send_msg);//发送结果回调

typedef void (^ProgressBlock)(float p); //图片上传进度返回
@property (nonatomic ,strong) ProgressBlock progressResult;



typedef void (^DownloadResultBlock)(NSInteger downloading); //下载进度返回
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
@property (assign, nonatomic) BOOL uploadOk;//文件上传完成

//检查图片下载
-(void)check_file;

//播放语音
-(void)playVoice;
@property (nonatomic ,assign) NSInteger playingIndex;//播放波浪切换
@property (nonatomic ,assign) NSInteger imPlaying;//正在播放
-(void)playingShow;//波浪切换
typedef void (^PlayingvoiceBlock)(NSInteger playingIndex); //语音播放中
@property (nonatomic ,strong) PlayingvoiceBlock playingvoiceBlock;

@end


