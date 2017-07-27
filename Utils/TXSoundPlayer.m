//
//  TXSoundPlayer.m
//  paopao
//
//  Created by Chuck on 16/10/17.
//  Copyright © 2016年 myncic.com. All rights reserved.
//

#import "TXSoundPlayer.h"
static TXSoundPlayer* soundplayer=nil;

@implementation TXSoundPlayer

+(TXSoundPlayer*)soundPlayerInstance{
  if(soundplayer==nil){
      
        soundplayer=[[TXSoundPlayer alloc]init];
        [soundplayer initSoundSet];
     }
   return soundplayer;
}

//播放声
-(void)play:(NSString*)text{
    if(text!= nil && text.length>0){
        player=[[AVSpeechSynthesizer alloc]init];
        player.delegate = self;
    
       
        AVSpeechUtterance* u=[[AVSpeechUtterance alloc]initWithString:text];//设置要朗读的字符串
        u.voice=[AVSpeechSynthesisVoice voiceWithLanguage:@"ZH-TW"];//设置语言
        u.volume=1.0;  //设置音量（0.0~1.0）默认为1.0
        u.rate=0.5;  //设置语速
        u.pitchMultiplier=self.pitchMultiplier;  //设置语调
        
        [player speakUtterance:u];
        _tts_playing=YES;
    }else{
        _tts_playing = NO;
    }

}

-(void)stop{
 
    [player stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    player = nil;
    
}

//初始化配置
-(void)initSoundSet{
    path=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"SoundSet.plist"];
    soundSet=[NSMutableDictionary dictionaryWithContentsOfFile:path];
    if(soundSet==nil){
        soundSet=[NSMutableDictionary dictionary];
        [soundplayer setDefault];
        [soundplayer writeSoundSet];
    }else{
        self.autoPlay=[[soundSet valueForKeyPath:@"autoPlay"] boolValue];
        self.volume=[[soundSet valueForKeyPath:@"volume"] floatValue];
        self.rate=[[soundSet valueForKeyPath:@"rate"] floatValue];
        self.pitchMultiplier=[[soundSet valueForKeyPath:@"pitchMultiplier"] floatValue];
        
    }
    
}

//恢复默认设置
-(void)setDefault{
    self.volume=0.7;
    self.rate=0.166;
    self.pitchMultiplier=1.0;
}

//将设置写入配置文件
-(void)writeSoundSet{
    [soundSet setValue:[NSNumber numberWithBool:self.autoPlay] forKey:@"autoPlay"];
    [soundSet setValue:[NSNumber numberWithFloat:self.volume] forKey:@"volume"];
    [soundSet setValue:[NSNumber numberWithFloat:self.rate] forKey:@"rate"];
    [soundSet setValue:[NSNumber numberWithFloat:self.pitchMultiplier] forKey:@"pitchMultiplier"];
    [soundSet writeToFile:path atomically:YES];
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utteranc
{
    _tts_playing = NO;
   
    
    if(_playOverAlert){
        self.playOverBlock();
    }

}


@end
