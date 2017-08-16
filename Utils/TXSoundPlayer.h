//
//  TXSoundPlayer.h
//  paopao
//
//  Created by Chuck on 16/10/17.
//  Copyright © 2016年 myncic.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

@interface TXSoundPlayer : NSObject<AVSpeechSynthesizerDelegate>
{

    NSString* path;  //配置文件路径
    AVSpeechSynthesizer* player;
    
    NSInteger calling;//通话状态
}

@property(nonatomic,assign)float rate;   //语速
@property(nonatomic,assign)float volume; //音量
@property(nonatomic,assign)float pitchMultiplier;  //音调
@property(nonatomic,assign)BOOL autoPlay;  //自动播放

@property(nonatomic,assign)BOOL checkVoice;
@property(nonatomic,assign)BOOL tts_playing;

@property (nonatomic, strong) CTCallCenter *callCenter;//通话状态


+(TXSoundPlayer*)soundPlayerInstance;

-(void)play:(NSString*)text;
-(void)stop;
// 注册电话状态
-(void)registerPhone;

@property (assign, nonatomic) BOOL playOverAlert;//播放完毕
typedef void (^TTSOverBlock)();
@property (nonatomic,strong)TTSOverBlock playOverBlock;

@end
