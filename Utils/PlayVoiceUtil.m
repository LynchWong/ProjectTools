//
//  PlayVoiceUtil.m
//  paopao
//
//  Created by Chuck on 16/10/17.
//  Copyright © 2016年 myncic.com. All rights reserved.
//

#import "PlayVoiceUtil.h"
#import "AppDelegate.h"
@implementation PlayVoiceUtil
@synthesize playingState;
@synthesize plan_id;
@synthesize isPlanType;

+ (PlayVoiceUtil*)player{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        playUtil = [[self alloc] init];
    });
    
    return playUtil;
}


-(void)setVoice:(BOOL)plan pid:(NSInteger)pid url:(NSString*)url duration:(double)duration pView:(UIImageView*)pView loading:(UIImageView*)loading btn:(MyBtnControl*)btn{

    [APPUtils setMethod:@"PlayVoiceUtil -> setVoice"];
    
    isPlanType = plan;
    plan_id = pid;
    voiceUrl = url;
    recordTime = duration;
    
    playView = pView;
    voiceLoadingImage = loading;
    cellPlayShowVoiceControl = btn;
    
    if(isPlanType){
        recordFileName = [NSString stringWithFormat:@"record_plan_%d.wav",(int)plan_id];
    }else{
        recordFileName = [NSString stringWithFormat:@"record_%d.wav",(int)plan_id];
        
    }
    recordFilePath = [[MainViewController sharedMain].voicePaths stringByAppendingPathComponent:recordFileName];
}


//准备播放
-(void)readyPlayVoice{
    
     [APPUtils setMethod:@"PlayVoiceUtil -> readyPlayVoice"];
    
    [cellPlayShowVoiceControl setEnabled:NO];
    
    if (![APPUtils fileExist:recordFilePath]) {//未下载
        
        [APPUtils takeAround:0 duration:1.0 view:voiceLoadingImage];
       
         playingState = 1;
        
        [UIView animateWithDuration:0.1f
                              delay:0
                            options:(UIViewAnimationOptionAllowUserInteraction|
                                     UIViewAnimationOptionBeginFromCurrentState)
                         animations:^(void) {
                             
                             [playView setImage:[UIImage imageNamed:@"just_play_empty_small.png"]];
                              voiceLoadingImage.alpha = 1;
                             
                         }
                         completion:^(BOOL finished) {
                             NSThread * sThread = [[NSThread alloc] initWithTarget:self
                                                                          selector:@selector(download_voice)
                                                                            object:nil];
                             [sThread start];
                         }];

    }else{
         [cellPlayShowVoiceControl setEnabled:YES];
         [playView setImage:[UIImage imageNamed:@"just_stop_small.png"]];
         voiceLoadingImage.alpha = 0;
         [self playVoice];
    }
  
}

-(void)playVoice{
  
     [APPUtils setMethod:@"PlayVoiceUtil -> playVoice"];
    
    if(player != nil && playing){
        [self stopPlaying];
        return;
    }
    
    playingState = 2;
    playing = YES;
    [self createCircle];
    [self play];
}


//创建圆圈
- (void)createCircle{
    
    
    [APPUtils setMethod:@"PlayVoiceUtil -> createCircle"];
    
    circleSeconds = recordTime;
    
    circleProgressView = [[UAProgressView alloc] init];
    [circleProgressView setFrame:CGRectMake(5, 3.5, playView.width-10, playView.width-10)];
    
    circleProgressView.borderWidth = 0;
    circleProgressView.lineWidth = 0.8;
    circleProgressView.fillOnTouch = NO;
    circleProgressView.tintColor = MAINYELLOW;
    [playView addSubview:circleProgressView];
    
    if (circleTimer!= nil || circleTimer.isValid) {
        [circleTimer invalidate];
        circleTimer = nil;
    }
    

    localProgress = 0;
    secondCounter = 0;
    [self updateProgress];
    
    circleTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    //防止scroll时 timer暂停
    [[NSRunLoop currentRunLoop] addTimer:circleTimer forMode:NSRunLoopCommonModes];
    
}

- (void)resetCircle{
    if(circleProgressView!=nil){
        [circleProgressView removeFromSuperview];
         [playView addSubview:circleProgressView];
    }
    if(playingState==1){
        [playView setImage:[UIImage imageNamed:@"just_play_empty_small.png"]];
        voiceLoadingImage.alpha = 1;
    }else if(playingState==2){
        [playView setImage:[UIImage imageNamed:@"just_stop_small.png"]];
    }
}

- (void)updateProgress {
    
    
    secondCounter+=0.05;
    
    localProgress = secondCounter / circleSeconds;
    
    [circleProgressView setProgress:localProgress];
    
    
    NSLog(@"----  %f",localProgress);
    
    if(localProgress >=1 || secondCounter>=circleSeconds || !playing){
//        if (circleTimer!= nil || circleTimer.isValid) {
            [circleTimer invalidate];
            circleTimer = nil;
//        }
        
        if(playing){
            [self stopPlaying:YES];
        }
    }
}




//播放语音
-(void)play{
    
    [APPUtils setMethod:@"PlayVoiceUtil -> play"];
    
    if(player!= nil){
        [player stop];
        player = nil;
        player.delegate = nil;
    }

    //设置下扬声器模式
    [APPUtils takeAudio:[AppDelegate getIsBackGround]];
    
    
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:recordFilePath] error:nil];
    player.delegate =self;
    
    
    [player play];
    
}

//播放完毕
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)playerq successfully:(BOOL)flag{
    NSLog(@"播放完毕");
    [self stopPlaying:YES];
}


- (void)stopPlaying{
    [self stopPlaying:NO];
}
- (void)stopPlaying:(BOOL)finished{//finished =播放完毕
    
     [APPUtils setMethod:@"PlayVoiceUtil -> stopPlaying"];
    
    if(player != nil){
        [player stop];
        
    }
    playing = NO;
    
    secondCounter=circleSeconds+10;//关闭圈圈
    
    playingState = 0;
    localProgress = 2;
    [playView setImage: [UIImage imageNamed:@"just_play_small.png"]];


    if(circleProgressView != nil){
        if (circleTimer!= nil || circleTimer.isValid) {
            [circleTimer invalidate];
            circleTimer = nil;
        }
        [UIView animateWithDuration:0.2f delay:0
                            options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState) animations:^(void) {
                                circleProgressView.alpha=0;
                            }
                         completion:^(BOOL finished){
                             [circleProgressView removeFromSuperview];
                             circleProgressView = nil;
                             
                             [APPUtils releseAudio];
                         }];
    }
    
    if(_playOverAlert && finished){
        self.playOverBlock();
    }
    
}



//下载语音
-(void)download_voice{

    [APPUtils setMethod:@"PlayVoiceUtil -> download_voice"];
    
    NSInteger now_id = plan_id;
    
    NSData *voiceData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:voiceUrl]];
    
    if(voiceData != nil && voiceData.length>0){
        
       
        if([voiceUrl hasSuffix:@"amr"]){//如果是amr 必须转换
            NSLog(@"转换 AMR");
            
            NSString *tempPath = [[MainViewController sharedMain].voicePaths stringByAppendingPathComponent:@"temp_record.amr"];
            [voiceData writeToFile:tempPath atomically:YES];
            
            
            [VoiceConverter ConvertAmrToWav:tempPath wavSavePath:recordFilePath];
            [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];
            tempPath = nil;
            
        }else{
            
            [voiceData writeToFile:recordFilePath atomically:YES];
        }
        
        if(now_id==plan_id){
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [cellPlayShowVoiceControl setEnabled:YES];
                [playView setImage:[UIImage imageNamed:@"just_stop_small.png"]];
                voiceLoadingImage.alpha = 0;
                [self playVoice];
                
                
            });

        }
        
    }else{
        playingState = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            if(now_id==plan_id){
                [ToastView showToast:@"语音下载出错,请重试"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [cellPlayShowVoiceControl setEnabled:YES];
                     voiceLoadingImage.alpha = 0;
                     [self stopPlaying];
                    
                    
                });
               
            }
        });
    }
}



@end
