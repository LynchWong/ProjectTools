//
//  PlayVoiceUtil.m
//  paopao
//
//  Created by Chuck on 16/10/17.
//  Copyright © 2016年 myncic.com. All rights reserved.
//

#import "PlayVoiceUtil.h"

@implementation PlayVoiceUtil
@synthesize playing;
@synthesize secondCounter;
@synthesize circleSeconds;
@synthesize cellPlayingType;
@synthesize cellPlayShowVoiceControl;
@synthesize recordFilePath;
@synthesize recordTime;
@synthesize circleProgressView;


@synthesize playView;
@synthesize voiceLoadingImage;






-(void)readyPlayVoice{
    [cellPlayShowVoiceControl setEnabled:NO];
    
    if (![APPUtils fileExist:recordFilePath]) {
        
        [APPUtils takeAround:0 duration:1.0 view:voiceLoadingImage];
       
        
         cellPlayingType = 1;
        
        [UIView animateWithDuration:0.1f
                              delay:0
                            options:(UIViewAnimationOptionAllowUserInteraction|
                                     UIViewAnimationOptionBeginFromCurrentState)
                         animations:^(void) {
                             
                            
                             [playView setImage:[UIImage imageNamed:@"just_play_big_empty_shadow.png"]];
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
         [playView setImage:[UIImage imageNamed:@"just_stop_big_shadow.png"]];
         voiceLoadingImage.alpha = 0;
         [self playVoice];

    }
  
}

-(void)playVoice{
  
    cellPlayingType = 2;
    
    if(player != nil && playing){
        [self stopPlaying:NO];
        return;
    }
    
    playing = YES;
    [self createCircle];
    [self play];
}



- (void)createCircle{
    
    
    circleSeconds = recordTime;
    
    circleProgressView = [[UAProgressView alloc] init];
    [circleProgressView setFrame:CGRectMake(5, 5, playView.width-10, playView.width-10)];
    
    circleProgressView.borderWidth = 0;
    circleProgressView.lineWidth = 0.8;
    circleProgressView.fillOnTouch = NO;
    circleProgressView.tintColor = _circleColor;
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
    
    if(player!= nil){
        [player stop];
        player = nil;
        player.delegate = nil;
    }
    [MainViewController sharedMain].makeOrderPage.playMissionVoice = 1;


    
    //设置下扬声器模式
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    
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
    
    if(player != nil){
        [player stop];
        
    }
    playing = NO;
    
    secondCounter=self.circleSeconds+10;//关闭圈圈
    
    cellPlayingType = 0;
    localProgress = 2;
    [playView setImage: [UIImage imageNamed:@"just_play_big_shadow.png"]];

    [MainViewController sharedMain].makeOrderPage.playMissionVoice = 0;
    
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
                         }];
    }
    
    if(_playOverAlert && finished){
        self.playOverBlock();
    }
    
}




-(void)download_voice{
    
    
    NSString *downloadVoice;
    NSString *saveName;
    NSString *now_id;
    
    now_id = [NSString stringWithFormat:@"%@",_plan_id];
    downloadVoice = _voiceUrl;
    NSArray * parts = [downloadVoice componentsSeparatedByString:@"."];
    NSString *fileTail = [parts lastObject];
    if(_isPlanType){
        saveName = [NSString stringWithFormat:@"record_plan_%@.%@",now_id,fileTail];
    }else{
        saveName = [NSString stringWithFormat:@"record_%@.%@",now_id,fileTail];
    }
    
    parts = nil;
    
   
    
    NSData *voiceData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:downloadVoice]];
    
    BOOL notChanged = YES;
    
    if(![now_id isEqualToString:_plan_id]){
        notChanged = NO;
    }
    
    if(voiceData != nil && voiceData.length>0){
        
        NSString *saveRecordFilePath = [[MainViewController sharedMain].voicePaths stringByAppendingPathComponent:saveName];
        [voiceData writeToFile:saveRecordFilePath atomically:NO];
        
        if([fileTail isEqualToString:@"amr"]){//如果是amr 必须转换
            NSLog(@"转换 AMR");
            
            NSString *wavRecordPath;
            if(_isPlanType){
                wavRecordPath = [[MainViewController sharedMain].voicePaths stringByAppendingPathComponent:[NSString stringWithFormat:@"record_plan_%@.wav",now_id]];
            }else{
                wavRecordPath = [[MainViewController sharedMain].voicePaths stringByAppendingPathComponent:[NSString stringWithFormat:@"record_%@.wav",now_id]];
            }
            
            
            [VoiceConverter ConvertAmrToWav:saveRecordFilePath wavSavePath:wavRecordPath];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:saveRecordFilePath error:nil];
            fileManager = nil;
            recordFilePath = wavRecordPath;
            wavRecordPath = nil;
            saveRecordFilePath = nil;
        }
        
        if(notChanged){
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(_hasClose){
                    return;
                }
                
                if(notChanged){
                    
                     [cellPlayShowVoiceControl setEnabled:YES];
                     [playView setImage:[UIImage imageNamed:@"just_stop_big_shadow.png"]];
                    voiceLoadingImage.alpha = 0;
                    [self playVoice];
                }
                
            });
        }
        
    }else{
        
        cellPlayingType = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(notChanged){
               
                [ToastView showToast:@"语音下载出错,请重试"];
            }
            
        });
        
    }
    
    saveName = nil;
    downloadVoice = nil;
}



@end
