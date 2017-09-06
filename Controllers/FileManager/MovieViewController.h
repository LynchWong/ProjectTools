//
//  MovieViewController.h
//  PartyConstructionSystem
//
//  Created by 李狗蛋 on 15/10/8.
//  Copyright © 2015年 李狗蛋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import "MainViewController.h"
@class MyBtnControl;
@class ZppTitleView;
@interface MovieViewController : UIViewController{


    ZppTitleView *titletView;
    
    AVPlayer *player;
    BOOL dataPrepareOk;//资源准备ok
    BOOL hasOpened;
    
    NSString *movieTitle;
    NSString *moviePath;//视频path
 
    UIVisualEffectView *controlmenu;
    UISlider *progressSlider;// 控制视频播放的控件
    NSInteger sumPlayOperation;//播放的总时长 秒
    NSInteger nowTime;//当前时长 秒
    NSTimer *playTimer;
    UILabel *nowLabel;//当前时长
    UILabel *totalLabel;//总时长
    MyBtnControl *pauseControl;//播放键
    BOOL playing;
    BOOL controlShow;//控制器显示
    
    
    ALAsset *asset;//播放相册视频
    BOOL on_line;//在线
    BOOL audioType;//音频类型
}



-(id)initWithtitle:(NSString*)title url:(NSString*)url online:(BOOL)online;

-(id)initWithAsset:(ALAsset*)alAsset title:(NSString*)title;

@end
