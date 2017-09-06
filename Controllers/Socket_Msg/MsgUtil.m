//
//  MsgUtil.m
//  zpp
//
//  Created by Chuck on 2017/4/21.
//  Copyright © 2017年 myncic.com. All rights reserved. 消息接受管理类
//

#import "MsgUtil.h"
#import "APPUtils.h"
#import "SendMsgViewController.h"
@implementation MsgUtil

@synthesize afn;


@synthesize voice_playing;

- (id)initMsgUtil{
    self = [super init];
    if (self) {
        afn = [[AFN_util alloc] initWithAfnTag:@"msgutil"];
    }
    return self;
}


//获取消息获取状态
-(BOOL)getMsgChecking{
    return  checking_msg;
}
//---------------------------------获取消息
-(void)check_msgs{

    if(checking_msg){
        return;
    }
    
    if(![AFN_util isLogin]){
        return;
    }
     [APPUtils setMethod:@"MsgUtil -> check_msgs"];
    
    checking_msg = YES;
    
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.myncic.msg",DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(concurrentQueue, ^{
  
        
        NSString *sendString = [NSString stringWithFormat:@"%@%@%@%@%@",@"[\"get_list\",\"",[AFN_util getUserId],@"\",\"",[AFN_util getScode],@"\"]\r\n"];
        SocketUtils *st = [[SocketUtils alloc] init];
        st.not_show_fail = YES;
        st.socketResult = ^(NSInteger succeed, NSString *resultString){
            
            if(succeed == 1){
                
                _unreadMsgArray = [[NSMutableArray alloc] init];//去readlist的分组
                NSInteger newMsgs = 0;//新消息数
                
                @try {
                    
                    NSArray *tepArray = [APPUtils getArrByJson:resultString];
                    
                    if(tepArray == nil || [tepArray isEqual:[NSNull null]] || [tepArray count]==0){//无会话
                        
                    }else{
                        
                        newMsgs = [tepArray count];
                        
                        
                        NSMutableString *ids = [[NSMutableString alloc] init];
                      
                        NSInteger i=0;
                        NSInteger index = 0;
                        BOOL tip=YES;//10条一组
                        for(NSDictionary *dic in tepArray){
                            
                            if(tip){
                                [ids appendString:@"["];
                                tip = NO;
                            }
                            
                            [ids appendString:[dic objectForKey:@"id"]];
                            
                            index++;
                     
                            if(index>=10||i==[tepArray count]-1){
                                index=0;
                                
                                [ids appendString:@"]"];
                                
                                [_unreadMsgArray addObject:[NSString stringWithFormat:@"%@",ids]];
                                ids = [[NSMutableString alloc] init];
                                tip = YES;
                            }else{
                                [ids appendString:@","];
                            }
                            
                            i++;
                        }
                        
                    }
                    
                    
                    tepArray = nil;
                    
                } @catch (NSException *exception) { }
                
        
                if(newMsgs==0){
                    NSLog(@"没有新消息");
                    [self check_over:NO];
                    
                }else{
                    //获取未读消息
                    [self downloadUnreadMsgs];
                }
                
            }else{
                 [self check_over:NO];
            }
        };
        [st send:sendString];
        st= nil;
        sendString = nil;
        

    });

    
}





//下载未读消息
-(void)downloadUnreadMsgs{
    
    [APPUtils setMethod:@"MsgUtil -> downloadUnreadMsgs"];
    
    if(_unreadMsgArray != nil && [_unreadMsgArray count]>0){
        
        NSString *ids = [_unreadMsgArray objectAtIndex:0];
        
        [_unreadMsgArray removeObjectAtIndex:0];
        
        NSString *sendString =  [NSString stringWithFormat:@"[\"read_list\",\"%@\",\"%@\",\"%@\",\"1\"]\r\n",[AFN_util getUserId],[AFN_util getScode],ids];
        SocketUtils *st = [[SocketUtils alloc] init];
         st.not_show_fail = YES;
        st.socketResult = ^(NSInteger succeed, NSString *resultString){
            
            if(succeed == 1){
                
                [self saveUnreadMsgs:resultString];//保存消息
             
                
            }else{
                 [self check_over:NO];
            }
        };
        [st send:sendString];
        st= nil;
        sendString = nil;
    
    }else{
         [self check_over:YES];
    }
    
}


//储存未读消息
-(void)saveUnreadMsgs:(NSString*)msgsString{
    
    [APPUtils setMethod:@"MsgUtil -> saveUnreadMsgs"];
    
    @try {
        
        NSMutableArray *msgsArray = [APPUtils getArrByJson:msgsString];
        
        
        NSInteger i=0;
        for(NSDictionary *msgDic in msgsArray){
            
            Conversation *conv = [MsgUtil getConversation:msgDic];
            if(conv!=nil){
                
                [self checkGroupExist:conv];//检查exist
                
                
                NSString *sqlList = [MsgUtil getSave2MsgListSql:conv msgFrom:@"0"];
                NSString*sqlContent = [MsgUtil getSave2MsgContentSql:conv fromMysefl:NO];
                
                if(sqlList != nil && sqlList.length>0){
                    [[MainViewController getDatabase] execSql:sqlList];
                }
                
                if(sqlContent != nil && sqlContent.length>0){
                    [[MainViewController getDatabase] execSql:sqlContent];
                }
            
                sqlContent = nil;
                sqlList = nil;
                
            }
            conv = nil;
            
            i++;
        }
        
        [self downloadUnreadMsgs];
        
        
        
        msgsArray = nil;
    } @catch (NSException *exception) {
       [self downloadUnreadMsgs];
    }
 
}


//检查储存更新会话组
-(void)checkGroupExist:(Conversation*)conv{
    
    [APPUtils setMethod:@"MsgUtil -> checkGroupExist"];

    BOOL exist = NO;
    NSInteger unreadMsgCount=1;
    NSString *existQuery = [NSString stringWithFormat:@"select unread_news_count from MsgGroupsList where groups='%@' and username = '%@' and ipadd = '%@';",conv.group,[AFN_util getUserId],[AFN_util getIpadd]];
   
    
    FMResultSet *rs = [[MainViewController getDatabase] queryDatabase:existQuery];
    
    while ([rs next]) {
        exist = YES;
        unreadMsgCount =  [rs intForColumnIndex:0]+1;
        break;
    }
    
    [rs close];
    rs = nil;
    existQuery = nil;
    conv.unread_news_count = unreadMsgCount;
    
    
    if(!exist){//不存在本地的会话 保存
        [[MainViewController getDatabase] execSql:[MsgUtil getSave2MsgGroupsListSql:conv]];
    }else{
        [[MainViewController getDatabase] execSql:[MsgUtil getUpdateMsgGroupsListSql:conv]];
        
    }
}




//获取消息存MsgGroupsList表的语句
+(NSString*)getSave2MsgGroupsListSql:(Conversation*)conv{
    
    [APPUtils setMethod:@"MsgUtil -> getSave2MsgGroupsListSql"];
    
    NSString* sqlString = [NSString stringWithFormat:
                           @"INSERT INTO 'MsgGroupsList' ('username', 'groups', 'lastmsg', 'lasttime', 'lastavatar', 'gname','otheruid','people','unread_news_count','master','ipadd') VALUES ('%@', '%@', '%@', '%d', '%@', '%@', '%d', '%d', '%d', '%d','%@')",
                           [AFN_util getUserId],
                           conv.group,
                           [APPUtils fixString:conv.lastmsg],
                           (int)conv.lasttime,
                           [APPUtils fixString:conv.lastAvatar],
                           [APPUtils fixString:conv.gname],
                           (int)conv.otheruid,
                           (int)conv.people,
                           (int)conv.unread_news_count,
                           conv.master,
                           [AFN_util getIpadd]];
    return sqlString;
}


//更新存MsgGroupsList表的语句
+(NSString*)getUpdateMsgGroupsListSql:(Conversation*)conv{
    
    [APPUtils setMethod:@"MsgUtil -> getUpdateMsgGroupsListSql"];
    
    NSString *sqlString = [NSString stringWithFormat:@"update MsgGroupsList set lastmsg = '%@', lasttime = '%d', lastavatar = '%@',gname = '%@',otheruid = '%d', people = '%d',unread_news_count = '%d' where groups='%@' and username = '%@' and ipadd = '%@';",
                           conv.lastmsg,
                           (int)conv.lasttime,
                           conv.lastAvatar,
                           conv.gname,
                           (int)conv.otheruid,
                           (int)conv.people,
                           (int)conv.unread_news_count,
                           conv.group,
                           [AFN_util getUserId],
                            [AFN_util getIpadd]];
    
    return sqlString;
}


//获取消息存msglist表的语句
+(NSString*)getSave2MsgListSql:(Conversation*)conv msgFrom:(NSString*)msgFrom{
    
     [APPUtils setMethod:@"MsgUtil -> getSave2MsgListSql"];
    
    NSString *saveSql = @"";
    
    @try {
     
        saveSql = [NSString stringWithFormat:
                   @"INSERT INTO 'MsgList' ('username', 'groups', 'msg_id', 'msg_uid', 'msg_name', 'msg_type', 'sendStatus', 'createtime','avatar','isread','isLoaded','level','autoplay','ipadd') VALUES ('%@', '%@', '%@', '%d', '%@', '%@', '%@', '%d','%@','%@','%d','%d','%d','%@')",
                   [AFN_util getUserId],
                   conv.group,
                   conv.msg_id,
                   conv.lastuid,
                   [APPUtils fixString:conv.lastName],
                   [APPUtils fixString:conv.lastType],
                   msgFrom,
                   conv.lasttime,
                   [APPUtils fixString:conv.lastAvatar],
                   @"-1",
                   ([msgFrom integerValue]==0)?0:1,
                   conv.alarm_level,
                   conv.auto_play_voice,
                   [AFN_util getIpadd]
                   ];

    } @catch (NSException *exception) {}
    
    return saveSql;
}


//获取消息存msgContent表的语句
+(NSString*)getSave2MsgContentSql:(Conversation*)conv fromMysefl:(BOOL)fromMyself{
    NSString *saveSql = @"";
    
    
     [APPUtils setMethod:@"MsgUtil -> getSave2MsgContentSql"];
    
    //    content：文本
    //    big_url：服务器文件id
    //    thumb_url：小图url/语音url/位置截图
    //    imageDirection：图片宽高比
    //    filesize：文件尺寸（不改动）
    //    filename：本地文件名(大图名/语音名/截图文件名)
    //    voice_length:语音长度
    //    addressString：位置中文
    //    address_lat 位置纬度
    //    address_lon 位置经度
    
    @try {
        
        
        NSDictionary *content = conv.content_dic;

        
        NSString *type = conv.lastType;
    
        float imageDirection;
        NSString *saveContent = @"";//文本内容
        NSString *fileName = @"";//文件名字
        NSString *fileTail = @"";//文件后缀
        NSString *big_url = @"";//接受图片大图
        NSString *thumb_url = @"";//接受图片小图
        NSInteger voice_length=0; //录音时长
        NSString *filesize = @"";//文件大小
        NSString *addressString = @"";
        float address_lat;
        float address_lon;
        NSString *win_alert = @"";
        
        
        if([type isEqualToString:@"text"]){
            
            saveContent = [content objectForKey:@"content"];
            saveContent =[APPUtils fixString:saveContent];
            
        }else{
            
            NSDictionary *cDic;
            if(fromMyself){
                cDic = content;
            }else{
                cDic = [APPUtils getDicByJson:[content objectForKey:@"content"]];
            }
           
            
            if([type isEqualToString:@"voice"]){
                
                big_url = [NSString stringWithFormat:@"%@.amr",conv.msg_id];
                NSString *base64Content = [cDic objectForKey:@"content"];
                voice_length = [[cDic objectForKey:@"voicelength"] integerValue];
                
                if(base64Content != nil){
                    
                    NSData *amrData = [APPUtils stringBase64Data:base64Content];
                    
                    if(amrData!= nil){
                        [amrData writeToFile: [[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:big_url] atomically:YES];
                    }
                    amrData = nil;
                }
                base64Content = nil;
                
            }else if([type isEqualToString:@"pos"]){
                
                addressString =[APPUtils fixString:[cDic objectForKey:@"pos"]];
                address_lat = [[cDic objectForKey:@"lat"] floatValue];
                address_lon = [[cDic objectForKey:@"lon"] floatValue];
                
                
                //截图
                if(!fromMyself){
                
                    @try {
                        UIImage *snapImage  = [APPUtils dataURL2Image:[cDic objectForKey:@"snap"]];
                        if(snapImage !=nil){
                            big_url = [NSString stringWithFormat:@"%@.jpg",conv.msg_id];
                            NSData *imageData = UIImageJPEGRepresentation(snapImage, 0.7);
                            [imageData writeToFile:[[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:big_url] atomically:YES];
                            imageData = nil;
                            snapImage = nil;
                        }
                    } @catch (NSException *exception) {}
                    
                }else{
                    big_url = [cDic objectForKey:@"big_url"];
                }
                
                
              

            }else if([type isEqualToString:@"broadcast"]){//广播类型
                
                @try {
                    NSDictionary *header =  conv.header_dic;
                    
                    win_alert = [[header objectForKey:@"win-alert"] boolValue]==1?@"1":@"0";
                    
                    saveContent = [NSString stringWithFormat:@"%@",[content objectForKey:@"content"]];
                    saveContent =[APPUtils fixString:saveContent];
                    
                    header = nil;
                } @catch (NSException *exception) {
                    
                }
                
                
            }else{//文件
                
                
                fileName = [cDic objectForKey:@"filename"];
                fileTail = conv.tail;
                filesize = [NSString stringWithFormat:@"%@",[cDic objectForKey:@"filesize"]];
                
                UIImage *smallImage;
                if(fromMyself){
                    big_url = [cDic objectForKey:@"big_url"];
                    thumb_url = [cDic objectForKey:@"thumb_url"];
                    smallImage = [UIImage imageWithContentsOfFile:[[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:thumb_url]];
                    
                }else{
                    if([type isEqualToString:@"write"]){
                        //手写
                         big_url = [NSString stringWithFormat:@"%@.jpg",conv.msg_id];
                    }else{
                         big_url = [cDic objectForKey:@"fileid"];
                        
                    }
                    
                    smallImage  = [APPUtils dataURL2Image:[cDic objectForKey:@"content"]];//先存储缩略图
                }
                
                if(smallImage !=nil && !fromMyself){
                    
                    thumb_url = [NSString stringWithFormat:@"thumb_%@",big_url];
                    //保存接收缩略图
                    NSData *imageData = UIImageJPEGRepresentation(smallImage, 0.4);
                    [imageData writeToFile:[[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:thumb_url] atomically:YES];
                    imageData = nil;
                }
                
                
                imageDirection = [[cDic objectForKey:@"imageDirection"] floatValue];
                if(imageDirection==0){
                    //android发来的信息没有方向 可计算
                    if(smallImage!=nil){
                        CGSize imgSize = smallImage.size;
                        imageDirection = imgSize.width/imgSize.height;
                    }else{
                        imageDirection = 1.0;
                    }
                }
                smallImage = nil;
                

            }
            
             cDic = nil;
        
        }
        
        
        
        
        saveSql = [NSString stringWithFormat:
                   @"INSERT INTO 'MsgsContents' ('username', 'content','direction', 'fileName','fileTail', 'big_url','thumb_url', 'filesize', 'voice_length','msg_id','addressString','address_lat','address_lon','groups','ipadd') VALUES ('%@', '%@', '%.2f', '%@', '%@','%@', '%@', '%@','%d','%@','%@','%.6f','%.6f','%@','%@')",
                   [AFN_util getUserId],
                   [APPUtils fixString:saveContent],
                   imageDirection,
                   fileName==nil?[APPUtils GetCurrentTimeString]:fileName,
                   fileTail,
                   [APPUtils fixString:big_url],
                   [APPUtils fixString:thumb_url],
                   [APPUtils fixString:filesize],
                   (int)voice_length,
                   conv.msg_id,
                   [APPUtils fixString:addressString],
                   address_lat,
                   address_lon,
                   conv.group,
                   [AFN_util getIpadd]
                   ];
        
        saveContent = nil;
        content = nil;
        type = nil;
        addressString = nil;
        filesize = nil;
        thumb_url = nil;
        big_url = nil;
        fileName = nil;
        win_alert = nil;
        
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    return saveSql;
}







//获取一个conversation对象
+(Conversation*)getConversation:(NSDictionary*)convDic{
    
    [APPUtils setMethod:@"MsgUtil -> getConversation"];
    
    @try {
        
        NSDictionary *headersDic = [convDic objectForKey:@"headers"];
        NSArray *contentArray = [APPUtils getArrByJson:[convDic objectForKey:@"content"]];
        NSDictionary *contentDic = [contentArray objectAtIndex:0];
        NSArray *sendGroupArray = [headersDic objectForKey:@"myncic-send-group"];
        
        
        //获取group 查重
        NSMutableString *tempString = [[NSMutableString alloc] init];
        [tempString appendString:@"["];
        
        NSInteger otherID = 0;
        NSInteger i=0;
        for(NSString* uid in sendGroupArray){
            [tempString appendString:[NSString stringWithFormat:@"%@",uid]];
            if(i==[sendGroupArray count]-1){
                [tempString appendString:@"]"];
            }else{
                [tempString appendString:@","];
            }
            if([uid integerValue] != [[AFN_util getUserId] integerValue]){
                otherID = [uid integerValue];
            }
            i++;
        }
        
        NSString *group = [NSString stringWithFormat:@"%@",tempString];//组id
        tempString = nil;
        
        
        
        Conversation *conv = [[Conversation alloc] init];
        
        
        conv.group = group;
        conv.lastType = [contentDic objectForKey:@"type"];
        conv.lastmsg = [contentDic objectForKey:@"content"];
        conv.lasttime = [[headersDic objectForKey:@"myncic-send-time"] integerValue];
        conv.lastuid = [[headersDic objectForKey:@"myncic-send-from-id"] integerValue];
        conv.lastName = [APPUtils fixString:[headersDic objectForKey:@"myncic-send-from-name"]];
        conv.lastAvatar= [headersDic objectForKey:@"myncic-send-from-avatar"];
        conv.people = [sendGroupArray count];
        conv.lastType = [contentDic objectForKey:@"type"];
        conv.msg_id = [convDic objectForKey:@"id"];
        conv.alarm_level = [[headersDic objectForKey:@"alarm-level"] integerValue];
        conv.auto_play_voice = [[headersDic objectForKey:@"auto-play-voice"] integerValue];
        conv.content_dic = contentDic;
        conv.header_dic = headersDic;
        
        if([conv.lastType isEqualToString:@"file"]){//重置类型
            
            @try {
                NSDictionary *fileDic = [APPUtils getDicByJson:[contentDic objectForKey:@"content"]];
                NSString *fileName = [fileDic objectForKey:@"fileid"];
                NSString *tail =  [[fileName componentsSeparatedByString:@"."] lastObject];
                
                conv.lastmsg = [NSString stringWithFormat:@"[%@]",[APPUtils get_file_type_name:tail]];
                conv.lastType = [APPUtils get_file_type:tail];
                conv.tail = tail;
                fileName = nil;
                fileDic = nil;
                tail = nil;
            } @catch (NSException *exception) {}
    
        }else{
            if(![conv.lastType isEqualToString:@"text"]){
                conv.lastmsg = [NSString stringWithFormat:@"[%@]",[APPUtils get_file_type_name:conv.lastType]];
            }
        }
        
        
        
        if(conv.people>2){
            //        conv.uid = [[convDic objectForKey:@"uid"] integerValue];群主id
//            conv.name = [NSString stringWithFormat:@"(群聊%d人)%@",(int)conv.people,conv.name];
            conv.isGroupTalk = 1;
        }else{
          conv.otheruid = otherID;
          conv.lastAvatar = [headersDic objectForKey:@"myncic-send-from-avatar"];//全路径
          conv.gname =[APPUtils fixString:[headersDic objectForKey:@"myncic-send-from-name"]];//名字组
        }

        contentDic = nil;
        sendGroupArray = nil;
        headersDic = nil;
        contentArray = nil;
        
        return conv;
        
    } @catch (NSException *exception) {
        return nil;
    }

}

//新消息刷新完毕 update是否需要更新
-(void)check_over:(BOOL)update{
    checking_msg = NO;
    self.callBackBlock(update);

    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMsgList" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:update?@"1":@"0",@"update",nil]];
    
    if(update){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"update_sendMsgPage" object:nil userInfo:nil];//刷新消息页
    }
    
}



//-----------------发送消息---------

//发送消息
-(void)send_msgs:(OneMsgEntity*)msg{

    [APPUtils setMethod:@"MsgUtil -> send_msgs"];
    
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.myncic.send_msgs",DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(concurrentQueue, ^{
        
        NSString *type;
        if(![msg.type isEqualToString:@"text"] && ![msg.type isEqualToString:@"pos"]&& ![msg.type isEqualToString:@"voice"]&& ![msg.type isEqualToString:@"tuya"]&& ![msg.type isEqualToString:@"write"]){
            type = @"file";
        }else{
            type = msg.type;
        }
        
        NSString *headerString = [APPUtils urlEncode:@"{\"Content-Transfer-Encoding\":\"MMS\",\"auto-play-voice\":false,\"alarm-level\":\"0\"}"];
        msg.content = [msg.content stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
        NSString *contentString = [APPUtils urlEncode:[NSString stringWithFormat:@"[{\"type\":\"%@\",\"encode\":\"\",\"content\":\"%@\"}]",type,msg.content]];
        
        NSString *sendString = [NSString stringWithFormat:@"[\"send\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\"]\r\n",[AFN_util getUserId],[AFN_util getScode],msg.group,headerString,contentString];
        contentString = nil;
        headerString = nil;
        
        
        SocketUtils *st = [[SocketUtils alloc] init];
        st.socketResult = ^(NSInteger succeed, NSString *resultString){
            
            if(succeed == 1){
                @try {
                    //[18434,1503454841]
                    NSArray *resuArr = [APPUtils getArrByJson:resultString];
                    if(resuArr !=nil && [resuArr count]==2){
                        self.sendBackBlock([NSString stringWithFormat:@"%@",[resuArr objectAtIndex:0]]);
                    }
                    resuArr = nil;
                } @catch (NSException *exception) {
                    self.sendBackBlock([APPUtils GetCurrentTimeString]);
                }
                
            }else{
                [self send_over:@"error"];
            }
        };
        [st send:sendString];
        st= nil;
        sendString = nil;
    });


}


//发送完成 结果
-(void)send_over:(NSString*)result{
    self.sendBackBlock(result);
}


//更新发送中的消息结果
+(void)updateSendingMsgs:(BOOL)reset{//reset把发送中的至为失败
    
    if(updateingSend){
        return;
    }
    
     [APPUtils setMethod:@"MsgUtil -> updateSendingMsgs"];
    
    updateingSend = YES;
    
    NSString *sql0 = @"update MsgsContents set downloading = '0' where downloading == '1';";
    [[MainViewController getDatabase] execSql:sql0];
    sql0 = nil;
    
    
    NSString *sqlResultQuery = [NSString stringWithFormat:@"select msg_id from MsgList where sendStatus='3' and username='%@' and ipadd = '%@';",[AFN_util getUserId],[AFN_util getIpadd]];
    FMResultSet *updateresultSet = [[MainViewController getDatabase] queryDatabase:sqlResultQuery];
    
    NSMutableArray *sendingIdsArr =[[NSMutableArray alloc] init] ;
    
    while ([updateresultSet next]) {
        [sendingIdsArr addObject:[updateresultSet stringForColumn:@"msg_id"]];
    }
    [updateresultSet close];
    updateresultSet = nil;
    sqlResultQuery = nil;
    
    if([sendingIdsArr count]>0){
       
        
        for (NSString *tempID in sendingIdsArr) {
            @try {
                
                NSDictionary *tempDic =  [[APPUtils getUserDefault] objectForKey:tempID];
                if(tempDic!=nil && ![tempDic isEqual:[NSNull null]]){
                   
                    NSInteger sendingStatus = [[tempDic objectForKey:@"id"] integerValue];
                    
                    
                    if(sendingStatus>1){//若发送成功 sendingStatus=真实msgid
                        
                        NSString *sql = [NSString stringWithFormat:@"update MsgList set msg_id = '%ld',sendStatus = 1 where msg_id='%@' and username = '%@' and ipadd = '%@';",(long)sendingStatus,tempID,[AFN_util getUserId],[AFN_util getIpadd]];
                        [[MainViewController getDatabase] execSql:sql];
                        sql = nil;
                        
                        NSString *sql2 = [NSString stringWithFormat:@"update MsgsContents set msg_id = '%ld' where msg_id='%@' and username = '%@' and ipadd = '%@';",(long)sendingStatus,tempID,[AFN_util getUserId],[AFN_util getIpadd]];
                        [[MainViewController getDatabase] execSql:sql2];
                        sql2 = nil;
                        
                        [APPUtils userDefaultsDelete:tempID];
                        
                    }else if(sendingStatus==-1 || (reset&&sendingStatus==1)){//发送失败
                        
                        NSString *sql = [NSString stringWithFormat:@"update MsgList set sendStatus = '2' where msg_id='%@' and username = '%@' and ipadd = '%@';" ,tempID,[AFN_util getUserId],[AFN_util getIpadd]];
                        [[MainViewController getDatabase] execSql:sql];
                        sql = nil;
                        
                        [APPUtils userDefaultsDelete:tempID];
                        
                    }
                    
                  
                    
                    tempDic = nil;
                
                }
            } @catch (NSException *exception) {
                
            }
            
        }
        
        
    }
    sendingIdsArr = nil;
    
    updateingSend = NO;
}



//-----------------播放声音---------------
-(void)playVoice:(OneMsgEntity*)msg{

     [APPUtils setMethod:@"MsgUtil -> playVoice"];
    
    _nowPlayingMsgId = msg.msg_id;
    
    if(player != nil && player.isPlaying){
        [self stopPlayer];
        return;
    }
    
    
    if([msg.type isEqualToString:@"voice"]){
        
        BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath: [[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:msg.big_url]];
        if (!blHave) {
           
            [ToastView showToast:@"该语音已被清除,无法播放"];
            return;
        }
        
        
        NSString *playPath = [[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:@"nowPlay.wav"];
        
        //转wav才能播放
        if ([VoiceConverter ConvertAmrToWav:[[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:msg.big_url] wavSavePath:playPath]){
           
            if([APPUtils get_ud_int:@"err_setting"] ==1){
                //设置听筒模式
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
                [[AVAudioSession sharedInstance] setActive:YES error:nil];
            }else{
                //设置下扬声器模式
                [APPUtils takeAudio:NO];
            }
            
            
            
            
            if(player == nil){
                player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:playPath] error:nil];
                player.delegate =self;
            }else{
                player = [player initWithContentsOfURL:[NSURL URLWithString:playPath] error:nil];
                player.delegate =self;
            }
            
            [player play];
            voice_playing = YES;
            

        }else{
        
            [ToastView showToast:@"语音文件损坏,无法播放"];
            NSLog(@"amr转wav失败");
        }
        
    }

}

//停止播放
-(void)stopPlayer{
    _nowPlayingMsgId = @"";
    if(player != nil && player.isPlaying){
        [player stop];
        voice_playing = NO;
        [APPUtils releseAudio];
    }
}

//播放完毕
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)playerq successfully:(BOOL)flag{
    NSLog(@"播放完毕");
    voice_playing = NO;
    [APPUtils releseAudio];
}



@end
