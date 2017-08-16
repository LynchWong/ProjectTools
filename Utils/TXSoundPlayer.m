//
//  TXSoundPlayer.m
//  paopao
//
//  Created by Chuck on 16/10/17.
//  Copyright © 2016年 myncic.com. All rights reserved.
//

#import "TXSoundPlayer.h"
#import "APPUtils.h"
#import "AppDelegate.h"
static TXSoundPlayer* soundplayer;

@implementation TXSoundPlayer

+(TXSoundPlayer*)soundPlayerInstance{
    
    
  if(soundplayer==nil){
    
        soundplayer=[[TXSoundPlayer alloc]init];
        [soundplayer registerPhone];
        [soundplayer initSoundSet];
     }
   return soundplayer;
}

//播放声
-(void)play:(NSString*)text{
    
    if(calling==1){//电话中 不播放
        _tts_playing = NO;
        return;
    }

    [self stop];
    
    if(soundplayer==nil){
      soundplayer=[[TXSoundPlayer alloc]init];
      [soundplayer initSoundSet];
    }
   
   
    if(text!= nil && text.length>0){
        
        //压低其他资源声音
        [APPUtils takeAudio:YES];
        
        player=[[AVSpeechSynthesizer alloc]init];
        player.delegate = self;
    
        AVSpeechUtterance* u=[[AVSpeechUtterance alloc]initWithString:text];//设置要朗读的字符串
        u.voice=[AVSpeechSynthesisVoice voiceWithLanguage:@"ZH-TW"];//设置语言
        u.volume=1.0;  //设置音量（0.0~1.0）默认为1.0
        u.rate=0.5;  //设置语速
        u.pitchMultiplier=self.pitchMultiplier;  //设置语调
        
        [player speakUtterance:u];
        _tts_playing=YES;
        u = nil;
    }else{
        _tts_playing = NO;
    }

}

-(void)stop{
    if(player!=nil){
        [player stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        player = nil;
    }
    
    
}

//初始化配置
-(void)initSoundSet{
    
    self.volume=0.7;
    self.rate=0.166;
    self.pitchMultiplier=1.0;
    
    //注册被打断
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
}


 // 注册电话状态
-(void)registerPhone{
    __weak typeof(self) weakSelf = self;
    //电话状态
    _callCenter = [[CTCallCenter alloc] init];
    _callCenter.callEventHandler = ^(CTCall *call) {
        
        if ([call.callState isEqualToString:CTCallStateDisconnected])
        {
            NSLog(@"Call has been disconnected");
            calling = 0;
        }
        else if ([call.callState isEqualToString:CTCallStateConnected])
        {
            NSLog(@"Call has just been connected");
            calling = 1;
        }
        else if([call.callState isEqualToString:CTCallStateIncoming])
        {
            NSLog(@"Call is incoming");
            calling = 1;
        }
        else if ([call.callState isEqualToString:CTCallStateDialing])
        {
            NSLog(@"call is dialing");
            calling = 1;
        }
        else
        {
            NSLog(@"Nothing is done");
            calling = 0;
        }
        
        if(calling==1 && _tts_playing && player!=nil){
            [weakSelf stop];//通知播放
        }
        
    };

}



- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utteranc
{
    _tts_playing = NO;
   
    if(!_checkVoice){
        //释放音频资源
        [APPUtils releseAudio];
    }
   
    
    if(_playOverAlert){
        self.playOverBlock();
    }

}


//音频被打断
-(void)handleInterruption:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    
    AVAudioSessionInterruptionType type = [info[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    if(type == AVAudioSessionInterruptionTypeBegan){//被打断
       
        _tts_playing = NO;
        if(_playOverAlert){
            self.playOverBlock();
        }
        
    }else{//恢复
     
    }
    
}

@end
