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
#import "UAProgressView.h"
#import "VoiceConverter.h"
@class MyBtnControl;
@class PlayVoiceUtil;
@class UAProgressView;

static PlayVoiceUtil *playUtil;

@interface PlayVoiceUtil : NSObject<AVAudioPlayerDelegate>{

    
    double localProgress;
    NSTimer *circleTimer;
 
    double secondCounter;
    double circleSeconds;//总秒数
    BOOL playing;
    double recordTime;
    
    MyBtnControl *cellPlayShowVoiceControl;
    UAProgressView *circleProgressView;
    
    NSString *recordFilePath;
    NSString *recordFileName;
    NSString *voiceUrl;
    AVAudioPlayer *player;
    
    UIImageView *playView;
    UIImageView *voiceLoadingImage;
    UIColor *circleColor;
}

+ (PlayVoiceUtil*)player;


@property (assign, nonatomic) BOOL isPlanType;
@property (assign, nonatomic) NSInteger plan_id;
@property (assign, nonatomic) NSInteger playingState;//cell里的播放状态  0未播放 1下载中 2播放中

@property (assign, nonatomic) BOOL playOverAlert;//播放完毕
typedef void (^PlayOverBlock)();
@property (nonatomic,strong)PlayOverBlock playOverBlock;


-(void)setVoice:(BOOL)plan pid:(NSInteger)pid url:(NSString*)url duration:(double)duration pView:(UIImageView*)pView loading:(UIImageView*)loading btn:(MyBtnControl*)btn;

-(void)readyPlayVoice;
-(void)stopPlaying;
-(void)resetCircle;//播放中重置circle 用于tableview


@end
