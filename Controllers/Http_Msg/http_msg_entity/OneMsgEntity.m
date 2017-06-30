//
//  UserEntity.m
//  MedicalCenter
///Users/chuck/Desktop/ZPP_2.0/zpp/Files/Msgs/OneMsgEntity.m
//  Created by 李狗蛋 on 15-3-31.
//  Copyright (c) 2015年 李狗蛋. All rights reserved.
//

#import "OneMsgEntity.h"
#import "MsgUtil.h"
#import "MainViewController.h"
@implementation OneMsgEntity

//发送消息
-(void)sendMsg{

    if(_sendStatus == 3&&!_sending){//发送中
        _sending = YES;
       
        if([_type isEqualToString:@"pic"] && ![_big_url hasPrefix:@"upload/"]){//图片还未发送
            //上传图片
            
            __weak typeof(self) weakSelf = self;//防止block循环
            AFN_util *afn = [[AFN_util alloc] initWithAfnTag:@"upload_msg_pic"];
            
            //上传进度回调
            afn.progressResult= ^(NSString *progress){
                self.progressResult(progress);
            };
            
            //上传结果
            afn.afnResult = ^(NSString *afn_tag,NSString*resultString){
                if([afn_tag isEqualToString:@"upload_msg_pic"]){
            
                    @try {
                        NSDictionary *jsonDic =  [APPUtils getDicByJson:resultString];
                        
                        _big_url = [jsonDic objectForKey:@"url"];
                        _thumb_url = [jsonDic objectForKey:@"thumb"];
                        _sending = NO;
                        jsonDic = nil;
                        
                        [weakSelf sendMsg];
                    } @catch (NSException *exception) {
                        [weakSelf sendFail];
                    }
                    
                }else{
                    //图片上传失败
                    [weakSelf sendFail];
                }
                
            };
            
            [afn upload_msg_pic:[[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:_fileName] fileName:_fileName width_height:[NSString stringWithFormat:@"%.2f,%.2f",SCREENWIDTH*0.4*_imageDirection,SCREENWIDTH*0.4]];
            
            afn = nil;
        
        }else if(([_type isEqualToString:@"pos"]||[_type isEqualToString:@"voice"]) && ![_thumb_url hasPrefix:@"upload/"]){//位置截图还未发送
        
            __weak typeof(self) weakSelf = self;//防止block循环
            AFN_util *afn = [[AFN_util alloc] initWithAfnTag:@"uploadSnap"];
            
            //上传结果
            afn.afnResult = ^(NSString *afn_tag,NSString*resultString){
                if([afn_tag isEqualToString:@"uploadSnap"]){
            
                    _thumb_url = resultString;
                    _sending = NO;
            
                    [weakSelf sendMsg];
                    
                }else{
                    //截图上传失败
                    [weakSelf sendFail];
                }
                
            };
            
            [afn uploadRecord:[[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:_fileName] fileName:_fileName];
            
            afn = nil;
            
            
        }else{
            
            //发送
            _msgUtil = [[MsgUtil alloc] initMsgUtil];
            
            __weak typeof(self) weakSelf = self;//防止block循环
            _msgUtil.sendBackBlock = ^(NSString *resultString){
                
                NSInteger errorcode = -1;
                
                if(resultString!=nil && resultString.length>0 && ![resultString isEqualToString:@"error"]){
                    errorcode = 0;
                }
        
                if(errorcode==0){//发送成功
                    
                   
                    _sendStatus = 1;
                    
                    NSDictionary *save2plist = [NSDictionary dictionaryWithObjectsAndKeys:resultString,@"id",
                        weakSelf.big_url==nil?@"":weakSelf.big_url,@"big_url",
                        weakSelf.thumb_url==nil?@"":weakSelf.thumb_url,@"thumb_url",nil];
                    
                    [APPUtils userDefaultsSet :save2plist forKey:weakSelf.msg_id];
                    
                    _msg_id = resultString;
                    
                    
                    save2plist = nil;
                    
                    weakSelf.sendOverBlock(weakSelf);
                    
                }else{
                    [weakSelf sendFail];
                }
                
                _sending = NO;
               
            };
            
            [_msgUtil send_msgs:self];
        }
    }
}


//发送失败
-(void)sendFail{
   
    _sendStatus = 2;
    [APPUtils userDefaultsSet :[NSDictionary dictionaryWithObjectsAndKeys:@"-1",@"id",nil] forKey:self.msg_id];
    
    self.sendOverBlock(self);
}




//检查语音
-(void)checkVoice{
    
    if(_sendStatus == 0 && _downloading==0){
    
        
        NSString *downPath = [[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:_fileName];
        
        //下载语音
        dispatch_queue_t concurrentQueue = dispatch_queue_create("com.myncic.zpp",DISPATCH_QUEUE_CONCURRENT);
        dispatch_async(concurrentQueue, ^{
            
            //更改
            _downloading = 1;
            
            NSString *sql = [NSString stringWithFormat:@"update MsgContents set downloading = '1' where msg_id='%@' and username = '%@';",_msg_id,[AFN_util getUserId]];
            [[MainViewController getDatabase] execSql:sql];
            sql = nil;
            
            self.downloadCallback(1);
            
            
            NSData *voiceData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@",[AFN_util getIpadd],_thumb_url]]];
            
            NSString *sqlSave;
            if(voiceData != nil && voiceData.length>0){
                _downloading = 2;
                [voiceData writeToFile:downPath atomically:NO];
                voiceData = nil;
                
                sqlSave = [NSString stringWithFormat:@"update MsgContents set downloading = '2' where msg_id='%@' and username = '%@';",_msg_id,[AFN_util getUserId]];
                
            }else{
                _downloading = 0;
                sqlSave = [NSString stringWithFormat:@"update MsgContents set downloading = '0' where  msg_id='%@' and username = '%@';",_msg_id,[AFN_util getUserId]];
            
                [ToastView showToast:@"语音下载出错,请重试"];
            }
            
            [[MainViewController getDatabase] execSql:sqlSave];
            sqlSave = nil;
            
            self.downloadCallback(_downloading);
            
            if(_downloading == 2){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self playVoice];
                });
            }
            
        });


        
        
    }else{
        [self playVoice];
    }
}


-(void)playVoice{
    
    if(![MainViewController sharedMain].msgUtil.voice_playing){
        _playingIndex = 3;
        _imPlaying = YES;
        [[MainViewController sharedMain].msgUtil playVoice:self];
        [self playingShow];
    }else{
        [[MainViewController sharedMain].msgUtil stopPlayer];
    }
}

//波浪切换
-(void)playingShow{

    if([MainViewController sharedMain].msgUtil.voice_playing && [[MainViewController sharedMain].msgUtil.nowPlayingMsgId isEqualToString:_msg_id]) {
        
        self.playingvoiceBlock(_playingIndex);
        
        [self performSelector:@selector(playingShow) withObject:nil afterDelay:0.3f];
        
        _playingIndex++;
        
        if(_playingIndex>=4){
            _playingIndex = 1;
        }
    }else{
        self.playingvoiceBlock(3);
         _imPlaying = NO;
    }
}


@end



@implementation MsgSendContent

@end
