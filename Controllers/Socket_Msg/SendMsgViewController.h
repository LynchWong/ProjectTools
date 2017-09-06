//
//  SendMsgViewController.h
//  MedicalCenter
//
//  Created by 李狗蛋 on 15-4-28.
//  Copyright (c) 2015年 李狗蛋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"
#import "LocalPhotoViewController.h"
#import "SelectEndViewController.h"
#import "VoiceConverter.h"
#import "MainViewController.h"
#import "MsgUtil.h"


@class  OneMsgEntity;
@class ZppTitleView;
@class MsgUtil;
@class MakeAvatarTool;

@interface SendMsgViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,HPGrowingTextViewDelegate,SelectPhotoDelegate,UIActionSheetDelegate,PassValueDelegate,NSURLConnectionDataDelegate>{


    BOOL firstOpenOver;
    ZppTitleView *titleView;
    UIView *bodyView;
    UIImageView *noChatView;
  
    
    UITableView *smsTableView;
    NSMutableArray *dataList;
    
    
    BOOL hasOpen;
    NSString *myname;
    NSString *myAvatarUrl;
    
    HPGrowingTextView *textView;
    UIView *tableFootView;


    NSString *downloadResult;
 
    
    
    MyBtnControl *changeVoiceBtn;
    MyBtnControl *openMenuBtn;
    UIControl *sendVoiceBtn;
   
    UIView *menuView;//+底部菜单
    CGFloat menuViewHeight;
    UIView *sendView;
    CGFloat sendViewHeight;
    float diff;
    BOOL voiceState;
    BOOL menuState;
    BOOL keyboardOpened;
    float nowKeyboardHeight;//当前键盘高
    
   //基本参数
    MsgUtil *msgUtil;
    NSInteger clicktime;
    NSInteger currentPage;//每页20条
    NSInteger totalCount;
    NSInteger realMsgCount;//不算time 真实消息已加载数
    UIFont *textFont;
    CGFloat oneLineHeight;
    
    CGFloat maxPicWidth; //最高最宽显示图片
    CGFloat maxPicHeight;
    NSInteger lastMsgTime;//用于判断要不要显示时间
    NSDateFormatter *_formatterDate;
    NSDateFormatter *_formatterTime;
    NSInteger todayUnixTime;
    NSInteger yesterdayUnixTime;
    BOOL user_scrolled;//用户滑动过 避免初始化乱跳
    BOOL showSendView;
    NSString *mainSqlQuery;//查询语句主体
    BOOL loadingOldMsg;//老消息加载中
    BOOL loadingNewMsgs;//新消息加载中
    UIView *fillHeaderView;//不满一页的占坑
    CGFloat smsTableHeight;//table高
    NSInteger now_in_page_add_msgs;//当前进去页面后增加的条数
    
    //语音录制
    UIView *recordUnderView;
    UIView *voiceView; //发送语言消息的窗口
    UILabel *voiceLabel;
    UILabel *voiceShowLabel;//手指上滑提示
    UIImageView *voiceShowImage;
    UIView *voiceShowLabelView;
    UILabel *voiceTimeLabel;//倒计时
    BOOL cancelVoice;
    
    AVAudioRecorder  *recorder;
   
  
    NSString *recordFilePath;
    CGFloat recordTime;//当前录音时长
    BOOL updatingRecordMeters;//更新声音峰值
    UIImageView  *currentPlayingBolang;


    
    //位置
    CGFloat posWidth;
    CGFloat posheight;//位置图片宽高
    CGFloat fileImageHeight;
    UIImageView*openImageSourceView;
    
    
    //图片
    NSInteger lastRefreshTime;//上一次刷新时间
    NSInteger lastPrograss;
    OneMsgEntity*currentDownloadMsg;
    MakeAvatarTool *makeAvatar;

    //文件
    float fileheight;
    
    
    //长按菜单
    UIMenuController *menuController;
    
   
    OneMsgEntity *ready_handle_msg;//准备操作的msg(复制/删除)
    
    NSTimer *refreshTimer;
    
}

-(id)initWithConversation:(Conversation*)conv show:(BOOL)show;

@property (strong, nonatomic) Conversation *conversation;//打开的绘画组


@end



