//
//  PlayVoiceUtil.h
//  paopao
//
//  Created by Chuck on 16/10/17.
//  Copyright © 2016年 myncic.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MainViewController.h"
@class MyBtnControl;
@class UAProgressView;

@interface PlayVoiceUtil : NSObject<AVAudioPlayerDelegate>{

  
    double localProgress;
    NSTimer *circleTimer;
    
    AVAudioPlayer *player;
    
}

@property (assign, nonatomic) BOOL playing;
@property (assign, nonatomic) double secondCounter;
@property (assign, nonatomic) double circleSeconds;//总秒数
@property (assign, nonatomic) NSInteger cellPlayingType;//cell里的播放状态  0未播放 1下载中 2播放中
@property (strong, nonatomic) MyBtnControl *cellPlayShowVoiceControl;
@property (strong, nonatomic) UAProgressView *circleProgressView;
@property (strong, nonatomic) NSString *recordFilePath;
@property (assign, nonatomic) double recordTime;
@property (strong, nonatomic) NSString *voiceUrl;
@property (strong, nonatomic) NSString *plan_id;


@property (assign, nonatomic) BOOL isPlanType;

@property (strong, nonatomic) UIImageView *playView;
@property (strong, nonatomic) UIImageView *voiceLoadingImage;
@property (strong, nonatomic) UIColor *circleColor;
@property (assign, nonatomic) BOOL hasClose;


@property (assign, nonatomic) BOOL playOverAlert;//播放完毕
typedef void (^PlayOverBlock)();
@property (nonatomic,strong)PlayOverBlock playOverBlock;


-(void)readyPlayVoice;
-(void)playVoice;
- (void)stopPlaying;
- (void)resetCircle;//播放中重置circle


@end
