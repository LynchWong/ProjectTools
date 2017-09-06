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

    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.myncic.sendMsg",DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(concurrentQueue, ^{
        
        if(_sendStatus == 3&&!_sending){//发送中
            _sending = YES;
            
            if(([_type isEqualToString:@"pic"] || [_type isEqualToString:@"file"] || [_type isEqualToString:@"tuya"]) && !_uploadOk){//文件还未发送
                
           
                //检查压缩视频
                if([_type isEqualToString:@"file"] && [[APPUtils get_file_type:_fileTail] isEqualToString:@"video"] && _big_url!=nil && [_big_url hasPrefix:@"assets-"]){
                
                    
                    //没有压缩
                    _videocompressing = YES;
                    self.sendOverBlock(self);
                    
                    if(_fileName == nil || _fileName.length==0){
                        _fileName = @"snap_videoCompress.mp4";
                    }
                    
                    NSString* videoSavePath = [[MainViewController sharedMain].conversationPaths stringByAppendingPathComponent:_fileName];
                    
                    if ([APPUtils fileExist:videoSavePath]){
                        [[NSFileManager defaultManager] removeItemAtPath:videoSavePath error:nil];
                    }
                    
                    //压缩视频 转存沙盒
                    
                    //创建AVAsset对象
                    AVAsset* avasset =  [AVAsset assetWithURL:[NSURL URLWithString:_big_url]];
                    
                    //压缩质量
                    NSString *quality = AVAssetExportPresetMediumQuality;
                    
                    if(_filesize>512*1024*1024){
                        quality = AVAssetExportPresetLowQuality;//如果超过500m 就用低质量  压缩比为1:0.004 最大文件20mb
                    }
                    
                    AVAssetExportSession * session = [[AVAssetExportSession alloc] initWithAsset:avasset presetName:quality];
                    session.shouldOptimizeForNetworkUse = YES;
                    session.outputURL = [NSURL fileURLWithPath:videoSavePath];//压缩储存位置
                    //设置输出类型
                    session.outputFileType = AVFileTypeMPEG4;
                    avasset = nil;
                    [session exportAsynchronouslyWithCompletionHandler:^{
                        
                        //压缩完成
                        if (session.status==AVAssetExportSessionStatusCompleted) {
                            
                            [ShowWaiting hideWaiting];
                            
                            NSData *video = [NSData dataWithContentsOfFile:videoSavePath];
                            if(video!=nil){
                                
                                NSString *md5 = [APPUtils fileMD5:videoSavePath];
                                _big_url = [NSString stringWithFormat:@"mine_%@.%@",md5,_fileTail];
                                _filesize = video.length;
                                [APPUtils renameFile:videoSavePath newPath:[[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:_big_url]];
                            
                                NSString *sql = [NSString stringWithFormat:@"update MsgsContents set big_url = '%@',filesize = '%.0f' where msg_id = '%@' and username = '%@' and ipadd = '%@';",_big_url,_filesize,_msg_id,[AFN_util getUserId],[AFN_util getIpadd]];
                                [[MainViewController getDatabase] execSql:sql];
                                sql = nil;
                                
                               
                            }else{
                                 _sendStatus = 2;
                                [ToastView showToast:@"视频压缩异常,请重试"];
                            }
                            
                            video = nil;
                        }else{
                            _sendStatus = 2;
                        }
                        
                        _videocompressing = NO;
                        self.sendOverBlock(self);
                        _sending = NO;
                        [self sendMsg];
                    }];
                    
                    return ;
                }
                
                
                //检查服务器端是否存在
              
                NSString *sendString = [NSString stringWithFormat:@"[\"checkfileexists\",\"%@\"]\r\n",[self getRealMd5:_big_url]];
                
                SocketUtils *st = [[SocketUtils alloc] init];
                st.socketResult = ^(NSInteger succeed, NSString *resultString){
                    
                    if(succeed == 1){//存在
                      
                        self.progressResult(100);
                        
                        NSLog(@"文件存在，直接发送");
                        
                        _sending = NO;
                        _uploadOk = YES;
                        
                        [self sendMsg];
                        
                    }else if(succeed == 2){//不存在
                        
                         //在服务器上创建临时文件  xxx.tmp
                         NSString *sendString2 = [NSString stringWithFormat:@"%@",@"[\"adduploadfile\"]\r\n"];
                        SocketUtils *st2 = [[SocketUtils alloc] init];
                        st2.socketResult = ^(NSInteger succeed, NSString *resultString){
                            
                            if(succeed == 1){//创建成功
                                
                                _uploadData = [NSData dataWithContentsOfFile:[[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:self.big_url]];
                                if(_uploadData!=nil){
                                
                                    _defaultSize = 102400;//一次100kb
                                    _uploadPiece = _filesize/_defaultSize+1;//多少份 一次100k
                                    _nowPiece = 0;
                                    NSLog(@"总份数： %ld",(long)_uploadPiece);
                                    
                                    [self uploadFile:resultString];
                                    
                                }else{
                                  [self sendFail];
                                }
                                
                            }else{
                                [self sendFail];
                            }
                        };
                        [st2 send:sendString2];
                        st2= nil;
                        sendString2 = nil;
                        
                    }else{
                       [self sendFail];
                    }
                };
                [st send:sendString];
                st= nil;
                sendString = nil;
         
                
            }else{
                
                if([self.type isEqualToString:@"text"]){
                
                }else if([self.type isEqualToString:@"pos"]){
                    
                    UIImage  *snapImage = [UIImage imageWithContentsOfFile:[[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:self.big_url]];
                    NSString *snapBase64 = [APPUtils image2DataURL:snapImage];
                    if(snapBase64 == nil){
                        snapBase64 = @"";
                    }
                    
                    self.content = [NSString stringWithFormat:@"{\\\"lat\\\":\\\"%.6f\\\",\\\"lon\\\":\\\"%.6f\\\",\\\"pos\\\":\\\"%@\\\",\\\"snap\\\":\\\"%@\\\"}",self.address_lat,self.address_lon,self.addressString,snapBase64];
                    
                    snapBase64 = nil;
                    snapImage = nil;
                    
                }else if([self.type isEqualToString:@"voice"]){
                
                    NSData *amrData = [[NSFileManager defaultManager] contentsAtPath:[[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:self.big_url]];
                    NSString *amrBase64 = [APPUtils dataBase64String:amrData];
                    if(amrBase64 == nil){
                        amrBase64 = @"";
                    }
                    
                    self.content = [NSString stringWithFormat:@"{\\\"voicelength\\\":\\\"%d\\\",\\\"content\\\":\\\"%@\\\"}",(int)self.voice_length,amrBase64];
                    
                }else if([self.type isEqualToString:@"write"]){
                    
                    UIImage  *img = [UIImage imageWithContentsOfFile:[[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:(self.thumb_url)]];
                    NSString *imgBase64 = [APPUtils image2DataURL:img];
                    if(imgBase64 == nil){
                        imgBase64 = @"";
                    }
                    
                    self.content = [NSString stringWithFormat:@"{\\\"imageDirection\\\":\\\"%.2f\\\",\\\"content\\\":\\\"%@\\\"}",img.size.width/img.size.height,imgBase64];
                    
                    imgBase64 = nil;
                    img = nil;
                    
                }else{//文件
                
        
                    UIImage  *img = [UIImage imageWithContentsOfFile:[[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:(self.thumb_url)]];
                    NSString *imgBase64 = [APPUtils image2DataURL:img];
                    if(img == nil || imgBase64 == nil){
                        imgBase64 = @"";
                    }
                    
                    self.content = [NSString stringWithFormat:@"{\\\"imageDirection\\\":\\\"%.2f\\\",\\\"content\\\":\\\"%@\\\",\\\"fileid\\\":\\\"%@\\\",\\\"filename\\\":\\\"%@\\\",\\\"filesize\\\":\\\"%.2f\\\"}",(img!=nil?img.size.width/img.size.height:0),imgBase64,[self getRealMd5:_big_url],[APPUtils fixString:_fileName],_filesize];
                    
                    imgBase64 = nil;
                    img = nil;
                    
                    
                    [self deleteFile];
                    
                }
                
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
                        
                        NSDictionary *save2plist = [NSDictionary dictionaryWithObjectsAndKeys:resultString,@"id",nil];
                        
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
    });
}


//删除文件
-(void)deleteFile{
    //发送本来就有的文件，删掉md5名字的文件，避免重复
    if(self.fileName!=nil && self.fileName.length>0 && [APPUtils fileExist:[[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:self.fileName]] && _big_url!=nil && _big_url.length>0){
        [[NSFileManager defaultManager] removeItemAtPath:[[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:self.big_url] error:nil];
    }
}


-(NSString*)getRealMd5:(NSString*)string{
    NSString *md5 = string;
    if([md5 hasPrefix:@"mine_"]){
        md5 =  [md5 stringByReplacingOccurrencesOfString:@"mine_" withString:@""];
    }
    return md5;
}

//发送失败
-(void)sendFail{
    [self deleteFile];
    _uploadOk = NO;
    _sending = NO;
    _sendStatus = 2;
    [APPUtils userDefaultsSet :[NSDictionary dictionaryWithObjectsAndKeys:@"-1",@"id",nil] forKey:self.msg_id];
    
    self.sendOverBlock(self);
}



//上传文件 tempFileName(服务器临时文件名)
-(void)uploadFile:(NSString*)tempFileName{

    double uploadSize = _defaultSize;//本次上传大小
    NSData *tempData;//本次上传的data
    
    if((_nowPiece+1) == _uploadPiece){//最后一份
        if(_filesize <= _defaultSize){
            uploadSize = _filesize;//只有一份
            tempData = _uploadData;
        }else{
            uploadSize = _filesize - _defaultSize*_nowPiece;
            tempData = [_uploadData subdataWithRange:NSMakeRange(_nowPiece*_defaultSize, uploadSize)];
        }
    }else{
        tempData = [_uploadData subdataWithRange:NSMakeRange(_nowPiece*_defaultSize, _defaultSize)];
    }
    
    if(tempData == nil){
         [self sendFail];
         return;
    }
    
    _uploadedSize+= tempData.length;
    
    NSLog(@"开始上传数据: 份数第： %d",_nowPiece+1);
    
    //上传
    NSString *sendString = [NSString stringWithFormat:@"uploadfile %@ %.0f %.0f\r\n",tempFileName,_nowPiece*_defaultSize,uploadSize];
    
    SocketUtils *st = [[SocketUtils alloc] init];
    st.socketResult = ^(NSInteger succeed, NSString *resultString){
        
        if(succeed == 1){//该段上传完成
            
            if(_nowPiece+1 == _uploadPiece){//全部传完
                
                self.progressResult(100);
                
                NSString *md5;
                @try {
                    NSArray * parts = [_big_url componentsSeparatedByString:@"."];
                    md5 = [parts objectAtIndex:0];
                } @catch (NSException *exception) {
                    md5 = _big_url;
                }
                
                
                NSString *sendString2 = [NSString stringWithFormat:@"[\"uploadcompleted\",\"%@\",\"%@\",\"%@\",\"%.0f\"]\r\n",tempFileName,[self getRealMd5:md5],[APPUtils fixString:_fileTail],_filesize];
                
                SocketUtils *st2 = [[SocketUtils alloc] init];
                st2.socketResult = ^(NSInteger succeed, NSString *resultString){
                    
                    if(succeed == 1){//文件上传完成
                        
                        NSLog(@"上传完成，成功！");
                        
                        _sending = NO;
                        _uploadOk=YES;
                        
                        [self sendMsg];
                        
                    }else{
                        [self sendFail];
                    }
                };
                [st2 send:sendString2];
                st2= nil;
                sendString2 = nil;
                
                
            }else{
                
                //上传进度回调
                self.progressResult((_uploadedSize/_filesize)*100);
                
                //继续上传
                _nowPiece++;
                [self uploadFile:tempFileName];
            }
            
        }else{
            [self sendFail];
        }
    };
    [st send:sendString upData:tempData];
    st= nil;
    sendString = nil;
    
    
}




//检查文件下载
-(void)check_file{
   
    if(_downloading==1){
        return;
    }
    
    if(_sendStatus == 0 && _downloading==0){
        
      
        if(![APPUtils fileExist:[[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:_big_url]]){
        
            //下载文件
            dispatch_queue_t concurrentQueue = dispatch_queue_create("com.myncic.zpp",DISPATCH_QUEUE_CONCURRENT);
            dispatch_async(concurrentQueue, ^{
                
                //更改
                _downloading = 1;
                
                NSString *sql = [NSString stringWithFormat:@"update MsgsContents set downloading = '1' where msg_id = '%@' and username = '%@' and ipadd = '%@';",_msg_id,[AFN_util getUserId],[AFN_util getIpadd]];
                [[MainViewController getDatabase] execSql:sql];
                sql = nil;
                
                self.downloadCallback(1);
                
                
                _downloadData = [[NSMutableData alloc] init];
                
                if(_filesize<512000){
                    _defaultSize = _filesize;
                }else{
                    _defaultSize = 512000;//默认一次下载500kb
                }
                
                
                [self downloadFile:0 downloadLength:_defaultSize];
                
                
            });
            
        }else{
            //已存在相同文件
            _downloading = 2;
            
            NSString *sql = [NSString stringWithFormat:@"update MsgsContents set downloading = '2' where msg_id = '%@' and username = '%@' and ipadd = '%@';",_msg_id,[AFN_util getUserId],[AFN_util getIpadd]];
            [[MainViewController getDatabase] execSql:sql];
            sql = nil;
            
            self.downloadCallback(2);
        }
    }else{
        self.downloadCallback(2);
    }
    
}


//下载图片
-(void)downloadFile:(double)startPosition downloadLength:(double)downloadLength{

    NSString *sendString = [NSString stringWithFormat:@"downloadfile %@ %.0f %.0f\r\n",_big_url,startPosition,downloadLength];
    
    SocketUtils *st2 = [[SocketUtils alloc] initWithRead];

    st2.socketDataResult = ^(NSInteger succeed, NSData *resultData){
        
        if(succeed == 1 && resultData!=nil && resultData.length>0){
            
            @try {
                
                NSInteger totalDigit = [NSString stringWithFormat:@"%.0f",_filesize].length;//总长的字符串长度
                NSInteger downloadDigit = [NSString stringWithFormat:@"%.0f",downloadLength].length;
                double headLength = totalDigit + downloadDigit + 7;//+ok  \r\n
                
                resultData = [resultData subdataWithRange:NSMakeRange(headLength, resultData.length-headLength)];//减掉头部的+ok 512000 66666
                resultData = [resultData subdataWithRange:NSMakeRange(0, resultData.length-10)];//减掉尾部+success\r\n
                
                [_downloadData appendData:resultData];
                _downloadSize += resultData.length;
                
                if(_filesize<=_downloadSize){
                    //下载完成
                    self.progressResult(100);
                   //保存文件
                    [[NSData dataWithData:_downloadData] writeToFile:[[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:_big_url] atomically:YES];
                    
                    [self downloadResult:3];
                }else{
                    //继续下载
                    self.progressResult(_downloadSize/_filesize*100);
                    double downSize = _defaultSize;
                    if(_filesize-_downloadSize<_defaultSize){
                        downSize = _filesize-_downloadSize;
                    }
                    
                    [self downloadFile:_downloadSize downloadLength:downSize];
                }

                
            } @catch (NSException *exception) {
                [self downloadResult:0];
            }
            
        }else{
            [self downloadResult:0];
        }
    };
    [st2 send:sendString];
    st2= nil;
    sendString = nil;
    
}

//下载错误
-(void)downloadResult:(NSInteger)result{
    _downloading = result;
    if(_downloading==3){
        _downloading = 2;
    }
    NSString *sqlSave = [NSString stringWithFormat:@"update MsgsContents set downloading = '%d' where  msg_id='%@' and username = '%@' and ipadd = '%@';",(int)_downloading,_msg_id,[AFN_util getUserId],[AFN_util getIpadd]];
    [[MainViewController getDatabase] execSql:sqlSave];
    
    if(result==0){
        dispatch_async(dispatch_get_main_queue(), ^{
            [ToastView showToast:@"图片下载出错,请重试"];
        });
    }
    sqlSave = nil;
    
    self.downloadCallback(result);
}

//播放语音
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


