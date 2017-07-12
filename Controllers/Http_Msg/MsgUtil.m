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
@synthesize checking_msg;
@synthesize afn;
@synthesize unreadMsgCount;
@synthesize lastMsgType;
@synthesize lastMsgID;
@synthesize voice_playing;

- (id)initMsgUtil{
    self = [super init];
    if (self) {
        afn = [[AFN_util alloc] initWithAfnTag:@"msgutil"];
    }
    return self;
}


//创建回话
-(void)createGroup:(NSString*)user1 user2:(NSString*)user2{

    //根据orderID获取conversation
    
    [ShowWaiting showWaiting:@"会话创建中,请稍后"];
    
    AFN_util *afn_create = [[AFN_util alloc] initWithAfnTag:@"createGroup"];
    [afn_create createGroup:[NSString stringWithFormat:@"%@,%@",user1,user2]];
    afn_create.afnResult = ^(NSString *afn_tag,NSString*resultString){
        if([afn_tag isEqualToString:@"createGroup"]){
            
            
            NSDictionary *jsonDic =  [APPUtils getDicByJson:resultString];
            Conversation *conv = [MsgUtil getConversation:jsonDic];
            jsonDic = nil;
            
            if(conv!=nil){
                
                FMResultSet *resultSet1 = [[MainViewController getDatabase] queryDatabase:[NSString stringWithFormat:@"select * from MsgGroupList where group_id = '%d' and username = '%@';",(int)conv.group_id,[AFN_util getUserId]]];
                
                NSInteger exist=0;
                while ([resultSet1 next]) {
                    exist = 1;
                    break;
                }
                
                [resultSet1 close];//清理资源
                resultSet1 = nil;
                
                
                if(exist==0){//储存该会话
                    
                    NSString *saveConvString = [MsgUtil getSave2MsgGroupListSql:conv];
                    if(saveConvString != nil && saveConvString.length>0){
                        [[MainViewController getDatabase] execSql:saveConvString];
                        saveConvString = nil;
                    }
                }
                
                SendMsgViewController *secondView = [[SendMsgViewController alloc] initWithConversation:conv show:YES];
                
                [[MainViewController sharedMain].navigationController pushViewController:secondView animated:YES];
                secondView = nil;
                
                conv = nil;
            }
            
              [ShowWaiting hideWaiting];
        }
        
    };
    afn_create = nil;
    
}

//---------------------------------获取消息
-(void)check_msgs{

    if(checking_msg){
        return;
    }
    
    if(![AFN_util isLogin]){
        return;
    }
    
    checking_msg = YES;
    
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.myncic.msg",DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(concurrentQueue, ^{
        __weak typeof(self) weakSelf = self;//防止block循环
        
        afn.afn_tag = @"getGroupList";
        
        afn.afnResult = ^(NSString *afn_tag,NSString*resultString){
            
            if([afn_tag isEqualToString:@"getGroupList"]){
                
                
                weakSelf.unreadMsgGroupArray = [[NSMutableArray alloc] init];
                weakSelf.msgArray = [[NSMutableArray alloc] init];
                
                
                NSMutableArray *allGroupArray = [[NSMutableArray alloc] init];//装目前所有的消息分组
                NSInteger newMsgs = 0;//新消息数
                
                @try {
                    
                    NSArray *tepArray = [APPUtils getArrByJson:resultString];
                    
                    if(tepArray == nil || [tepArray isEqual:[NSNull null]]){//无会话
                        
                        [weakSelf check_over:NO];
                        
                    }else{
                        
                        for(int i=0;i<[tepArray count];i++){
                            NSDictionary *groupDic = [tepArray objectAtIndex:i];
                            
                            Conversation *conv = [MsgUtil getConversation:groupDic];
                            newMsgs += conv.unread_news_count;
                            
                            [allGroupArray addObject:conv];
                            if(conv.unread_news_count>0){
                                [weakSelf.unreadMsgGroupArray addObject:conv];
                            }
                            
                            conv = nil;
                            groupDic = nil;
                        }
                    }
                    
                    
                    tepArray = nil;
                    
                } @catch (NSException *exception) {
                }
                
                
                
                //本地检查所有会话 插入
                for(int i=0;i<[allGroupArray count];i++){
                    Conversation *conv  = [allGroupArray objectAtIndex:i];
                    [weakSelf checkGroupExist:conv];
                    conv = nil;
                }
                
                if(newMsgs==0){
                    NSLog(@"没有新消息");
                    [weakSelf check_over:NO];
                    
                }else{
                    //获取未读消息
                    [weakSelf downloadUnreadMsgs];
                }
                
                allGroupArray = nil;
                
            }else{
                [weakSelf check_over:NO];
            }
            
        };
        
        [afn getGroupList];
    });

    
}






//检查储存更新会话组
-(void)checkGroupExist:(Conversation*)conv{
    
    FMResultSet *resultSet = [[MainViewController getDatabase] queryDatabase:[NSString stringWithFormat:@"select * from MsgGroupList where group_id = '%d' and username = '%@';",(int)conv.group_id,[AFN_util getUserId]]];
    
    BOOL exist = NO;
    NSInteger lastId = -1;
    NSInteger peopleCount = 0;
    
    
    while ([resultSet next]) {
        exist = YES;
        lastId = [resultSet intForColumn:@"last_news_id"];
        peopleCount = [resultSet intForColumn:@"people"];
        
        break;
    }
    
    [resultSet close];//清理资源
    resultSet=nil;
    
    if(!exist){//不存在本地的会话 保存
        [[MainViewController getDatabase] execSql:[MsgUtil getSave2MsgGroupListSql:conv]];
    }else{
        if(lastId != conv.last_news_id || peopleCount != conv.people ){//如果存在数据库 但最后一条数据id不同就更新
            [[MainViewController getDatabase] execSql:[MsgUtil getUpdateMsgGroupListSql:conv]];
        }
    }
}


//下载未读消息
-(void)downloadUnreadMsgs{
    
    if(_unreadMsgGroupArray != nil && [_unreadMsgGroupArray count]>0){
        
        Conversation *conv = [_unreadMsgGroupArray objectAtIndex:0];
        
         __weak typeof(self) weakSelf = self;//防止block循环
        
        afn.afn_tag = @"getUnReadMessage";
        
        afn.afnResult = ^(NSString *afn_tag,NSString*resultString){
            
            if([afn_tag isEqualToString:@"getUnReadMessage"]){
                
                dispatch_queue_t concurrentQueue = dispatch_queue_create("com.myncic.zpp.msg",DISPATCH_QUEUE_CONCURRENT);
                dispatch_async(concurrentQueue, ^{
                    [weakSelf saveUnreadMsgs:resultString];//保存消息
                });
                concurrentQueue = nil;

            }else{
                [weakSelf check_over:NO];
            }
        };
        
        [afn getUnReadMessage:[NSString stringWithFormat:@"%d",(int)conv.group_id] lastid:[NSString stringWithFormat:@"%d",(int)conv.last_news_id]];
    
        conv = nil;
    }
    
}


//储存未读消息
-(void)saveUnreadMsgs:(NSString*)msgsString{
    
    
    @try {
        
        NSMutableArray *msgsArray = [APPUtils getArrByJson:msgsString];
        
        
        if(msgsArray == nil || [msgsArray isEqual:[NSNull null]] || [msgsArray count]==0){//单一分组的消息下载完毕
            
            @try {
                //更新当前下载的分组 更新lastid
                Conversation *conv = [_unreadMsgGroupArray objectAtIndex:0];
                [self checkGroupExist:conv];
                conv = nil;
                
                [_unreadMsgGroupArray removeObjectAtIndex:0];
                
                //检查下一分组新消息
                if([_unreadMsgGroupArray count]>0){
                    [self downloadUnreadMsgs];
                }else{
                    //全部分组未读下载完毕
                    NSLog(@"所有分组未读消息下载完毕");
                    
                    [self check_over:YES];
                    
                    
                    //最后一条广播消息提示
                    if(lastMsgType != nil && [lastMsgType isEqualToString:@"broadcast"] && lastMsgID != nil && lastMsgID.length>0){
                        
                        NSString *showContent = @"";
                        NSString *openOrderId = @"";
                        
                        
                        NSString *sqlQuery = [NSString stringWithFormat:@"select * from MsgContents where msg_id='%@';",lastMsgID];
                        
                        FMResultSet *resultSet = [[MainViewController getDatabase] queryDatabase:sqlQuery];
                        while ([resultSet next]) {
                            showContent = [resultSet stringForColumn:@"content"];
                            openOrderId = [resultSet stringForColumn:@"orderid"];
                            break;
                        }
                        
                        [resultSet close];//清理资源
                        resultSet=nil;
                        sqlQuery = nil;
                        
                        
                        
                        
                        openOrderId = nil;
                        showContent = nil;
                    }
                    
                    checking_msg = NO;
                }
                
            } @catch (NSException *exception) {
                checking_msg = NO;
            }
        }else{
            
            NSInteger lastid = -1;//当前组获取的最后一条消息id
            
            for(int i=0;i<[msgsArray count];i++){
                
                NSMutableDictionary *msgDic = [msgsArray objectAtIndex:i];
                
                
                NSString *sqlList = [MsgUtil getSave2MsgListSql:msgDic msgFrom:@"0"];
                NSString*sqlContent = [MsgUtil getSave2MsgContentSql:msgDic  fromMysefl:NO];
                
                if(sqlList != nil && sqlList.length>0){
                    [[MainViewController getDatabase] execSql:sqlList];
                }
                
                if(sqlContent != nil && sqlContent.length>0){
                    [[MainViewController getDatabase] execSql:sqlContent];
                }
                
                
                if(i==[msgsArray count] -1){
                    lastid = [[msgDic objectForKey:@"id"] integerValue];
                    lastMsgType = [msgDic objectForKey:@"type"];
                    lastMsgID = [msgDic objectForKey:@"id"];
                    
                }
                
                msgDic = nil;
                sqlContent = nil;
                sqlList = nil;
                
            }
            
            //继续读当前分组未读消息 每次20条
            Conversation *conv = [_unreadMsgGroupArray objectAtIndex:0];
            conv.last_news_id = lastid;
            [_unreadMsgGroupArray replaceObjectAtIndex:0 withObject:conv];
            conv = nil;
            
            [self downloadUnreadMsgs];
            
        }
        
        msgsArray = nil;
    } @catch (NSException *exception) {
        
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


//获取消息存msglist表的语句
+(NSString*)getSave2MsgListSql:(NSMutableDictionary*)jsonDic msgFrom:(NSString*)msgFrom{
    NSString *saveSql = @"";
    
    @try {
        
        NSString *read_type = @"";
        NSString *headString = [jsonDic objectForKey:@"header"];
        if(headString!=nil&&headString.length>0){
            
            NSDictionary *header =  [APPUtils getDicByJson:[jsonDic objectForKey:@"header"]];
    
            
            read_type = [header objectForKey:@"read-type"];
            header = nil;
        }
        
        
        
        
        saveSql = [NSString stringWithFormat:
                   @"INSERT INTO 'MsgsList' ('username', 'groupid', 'msg_id', 'msg_uid', 'user', 'msg_type', 'sendStatus', 'createtime','avatar','isread','read_type','isLoaded') VALUES ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@','%@','%@','%@','%d')",
                   [AFN_util getUserId],
                   [NSString stringWithFormat:@"%@",[jsonDic objectForKey:@"gid"]],
                   [NSString stringWithFormat:@"%@",[jsonDic objectForKey:@"id"]],
                   [NSString stringWithFormat:@"%@",[jsonDic objectForKey:@"uid"]],
                   [NSString stringWithFormat:@"%@",[APPUtils fixString:[jsonDic objectForKey:@"user"]]],
                   [NSString stringWithFormat:@"%@",[jsonDic objectForKey:@"type"]],
                   msgFrom,
                   [NSString stringWithFormat:@"%@",[jsonDic objectForKey:@"createtime"]],
                   [NSString stringWithFormat:@"%@",[jsonDic objectForKey:@"avatar"]],
                   @"-1",
                   read_type==nil?@"":read_type,
                   ([msgFrom integerValue]==0)?0:1
                   ];
        
        
        
        
        headString = nil;
    } @catch (NSException *exception) {
        
    }
    
    return saveSql;
}


//获取消息存msgContent表的语句
+(NSString*)getSave2MsgContentSql:(NSMutableDictionary*)dic fromMysefl:(BOOL)fromMyself{
    NSString *saveSql = @"";
    
    
    //    content：文本
    //    big_url：大图URL
    //    thumb_url：小图url/语音url/位置截图
    //    imageDirection：图片宽高比
    //    filesize：文件尺寸（不改动）
    //    filename：文件名(大图名/语音名/截图文件名)
    //    voice_length:语音长度
    //    addressString：位置中文
    //    address_lat 位置纬度
    //    address_lon 位置经度
    
    @try {
        
        
        NSDictionary *content;
        if(fromMyself){
            content = dic;
        }else{
            
            content = [dic objectForKey:@"content"];//发送的消息
            
            if([content isKindOfClass:[NSMutableString class]]){//接受的消息
                content = [APPUtils getDicByJson:[dic objectForKey:@"content"]];
            }
        }
        
        
        float imageDirection=[[content objectForKey:@"imageDirection"] floatValue];
        NSString *type = [content objectForKey:@"type"];
        NSString *orderId = [content objectForKey:@"id"];//订单
        
        NSString *saveContent = @"";//文本内容
        NSString *fileName = @"";//录音amr名字
        NSString *big_url = @"";//接受图片大图
        NSString *thumb_url = @"";//接受图片小图
        NSString *voice_length=@""; //录音时长
        NSString *filesize = @"";//文件大小
        NSString *addressString = @"";
        NSString *address_lat = @"";
        NSString *address_lon = @"";
        NSString *win_alert = @"";
        
        
        if([type isEqualToString:@"text"]){
            
            saveContent = [content objectForKey:@"content"];
            saveContent =[APPUtils fixString:saveContent];
            
        }else if([type isEqualToString:@"pic"]){
            
            big_url = [content objectForKey:@"big_url"];
            thumb_url = [content objectForKey:@"thumb_url"];
            imageDirection = [[content objectForKey:@"imageDirection"] floatValue];
            if(imageDirection==0){
                imageDirection = 1.0;
            }
            
            filesize = [content objectForKey:@"filesize"];
            fileName = [content objectForKey:@"filename"];
            
            
            
        }else if([type isEqualToString:@"voice"]){
            
            thumb_url = [content objectForKey:@"thumb_url"];//voice下载url
            voice_length = [content objectForKey:@"voice_length"];
            fileName = [content objectForKey:@"filename"];
            
        }else if([type isEqualToString:@"pos"]){
            
            addressString = [content objectForKey:@"addressString"];
            address_lat = [content objectForKey:@"address_lat"];
            address_lon = [content objectForKey:@"address_lon"];
            
            if(addressString!=nil){
                addressString =[APPUtils fixString:addressString];
            }else{
                addressString = @"";
            }
            thumb_url = [content objectForKey:@"thumb_url"];//截图url
            fileName = [content objectForKey:@"filename"];//截图名
            
        }else if([type isEqualToString:@"broadcast"]){//广播类型
            
            @try {
                NSDictionary *header =  [APPUtils getDicByJson:[dic objectForKey:@"header"]];
                
                win_alert = [[header objectForKey:@"win-alert"] boolValue]==1?@"1":@"0";
                
                saveContent = [NSString stringWithFormat:@"%@",[content objectForKey:@"content"]];
                saveContent =[APPUtils fixString:saveContent];
                
                header = nil;
            } @catch (NSException *exception) {
                
            }
            
            
        }else{
            
            NSLog(@"未知类型信息");
            
            content = nil;
            type = nil;
            return @"";
        }
        
        
        
        
        saveSql = [NSString stringWithFormat:
                   @"INSERT INTO 'MsgContents' ('username', 'content','direction', 'fileName', 'big_url','thumb_url', 'filesize', 'voice_length','ttsString','orderid','msg_id','addressString','address_lat','address_lon','groupid','win_alert') VALUES ('%@', '%@', '%.2f', '%@', '%@', '%@', '%@', '%@','%@','%@','%@','%@','%@','%@','%@','%@')",
                   [AFN_util getUserId],
                   saveContent==nil?@"":saveContent,
                   imageDirection,
                   fileName==nil?[APPUtils getUniquenessString]:fileName,
                   big_url==nil?@"":big_url,
                   thumb_url==nil?@"":thumb_url,
                   filesize==nil?@"":filesize,
                   voice_length==nil?@"":voice_length,
                   @"",
                   (orderId==nil||fromMyself)?@"":orderId,
                   [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]],
                   addressString==nil?@"":addressString,
                   address_lat==nil?@"":address_lat,
                   address_lon==nil?@"":address_lon,
                   [dic objectForKey:@"gid"],
                   win_alert
                   ];
        
        saveContent = nil;
        content = nil;
        orderId = nil;
        type = nil;
        address_lon = nil;
        address_lat = nil;
        addressString = nil;
        voice_length = nil;
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


//获取消息存MsgGroupList表的语句
+(NSString*)getSave2MsgGroupListSql:(Conversation*)conv{
    
   
    NSString *nickName = [[APPUtils getUserDefaults] stringForKey:@"nickname"];
    NSString *realName = [[APPUtils getUserDefaults] stringForKey:@"realname"];
    
    if(nickName!=nil){
        nickName = @"";
    }
    if(realName!=nil){
        realName = @"";
    }
    
    if(conv.people==2){
        if(conv.name!= nil && conv.name.length>0){
            
            @try {
                 NSArray * parts = [conv.name componentsSeparatedByString:@"、"];
                for(NSString*name in parts){
                    if(name.length>0 && ![name isEqualToString:nickName] && ![name isEqualToString:realName]){
                        conv.otherName = name;
                    }
                }
                parts = nil;
            } @catch (NSException *exception) {}
            
           
            conv.otherName =  [conv.otherName stringByReplacingOccurrencesOfString:@" " withString:@""];
            conv.otherName  = [conv.otherName  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
            
            if(conv.otherName==nil||conv.otherName.length==0){//处理同名情况
                conv.otherName = conv.lastuser;
            }
            
        }else{
            conv.otherName = conv.name;
        }
    }
    
    

    
    NSString* sqlString = [NSString stringWithFormat:
                           @"INSERT INTO 'MsgGroupList' ('username', 'avatar', 'createtime', 'group_id', 'last_news_id', 'lastmsg', 'lasttime', 'lastuid', 'lastuser', 'name','otheruid','people','uid','unread_news_count','user','avatar_md5') VALUES ('%@', '%@', '%d', '%d', '%d', '%@', '%d', '%d', '%@', '%@','%d','%d','%d','%d','%@','%d')",
                           [AFN_util getUserId],conv.avatar,(int)conv.createtime,(int)conv.group_id,(int)conv.last_news_id,conv.lastmsg,(int)conv.lasttime,(int)conv.lastuid,conv.lastuser,conv.otherName,(int)conv.otheruid,(int)conv.people,(int)conv.uid,(int)conv.unread_news_count,conv.user,(int)conv.auth_type
                           ];//avatar_md5:authtype是不是专业跑跑
    
    nickName = nil;
    realName = nil;
    return sqlString;
}


//更新存MsgGroupList表的语句
+(NSString*)getUpdateMsgGroupListSql:(Conversation*)conv{
    
   
    NSString *nickName = [[APPUtils getUserDefaults] stringForKey:@"nickname"];
    NSString * realName = [[APPUtils getUserDefaults] stringForKey:@"realname"];
    
    
    if(conv.people==2){
        if(conv.name!= nil && conv.name.length>0){
            conv.otherName =  [conv.name stringByReplacingOccurrencesOfString:@"、" withString:@""];
            if(nickName!=nil){
                conv.otherName =  [conv.otherName stringByReplacingOccurrencesOfString:nickName withString:@""];
            }
            if(realName!=nil){
                conv.otherName =  [conv.otherName stringByReplacingOccurrencesOfString:realName withString:@""];
            }
            conv.otherName =  [conv.otherName stringByReplacingOccurrencesOfString:@" " withString:@""];
            conv.otherName  = [conv.otherName  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
        }else{
            conv.otherName = conv.name;
        }
        
    }
    
    NSString *sqlQuery = [NSString stringWithFormat:@"select sum(unread_news_count) from MsgGroupList where username='%@';",[AFN_util getUserId]];
    FMResultSet *rs = [[MainViewController getDatabase] queryDatabase:sqlQuery];
    NSInteger unreadMsgCount=0;
    while ([rs next]) {
        unreadMsgCount =  [rs intForColumnIndex:0];
        break;
    }
    [rs close];
    rs = nil;
    sqlQuery = nil;
    
    
    NSString *sqlString = [NSString stringWithFormat:@"update MsgGroupList set avatar = '%@',last_news_id = '%d', lastmsg = '%@', lasttime = '%d',lastuid = '%d',lastuser = '%@', name = '%@',otheruid = '%d',people = '%d',uid = '%d',unread_news_count = '%d' ,user = '%@',avatar_md5 = '%@' where group_id='%d' and username = '%@';",
                           conv.avatar,(int)conv.last_news_id,conv.lastmsg,(int)conv.lasttime,(int)conv.lastuid,conv.lastuser,conv.otherName,(int)conv.otheruid,(int)conv.people,(int)conv.uid,(int)conv.unread_news_count+unreadMsgCount,conv.user,@"",(int)conv.group_id,[AFN_util getUserId]];
    
    return sqlString;
}


//获取一个conversation对象
+(Conversation*)getConversation:(NSDictionary*)convDic{
    
    Conversation *conv = [[Conversation alloc] init];
    
    conv.avatar = [convDic objectForKey:@"avatar"];//全路径
    conv.createtime = [[convDic objectForKey:@"createtime"] integerValue];
    conv.group_id = [[convDic objectForKey:@"id"] integerValue];
    conv.last_news_id = [[convDic objectForKey:@"last_news_id"] integerValue];
    conv.lastmsg = [convDic objectForKey:@"lastmsg"];
    conv.lasttime = [[convDic objectForKey:@"lasttime"] integerValue];
    conv.lastuid = [[convDic objectForKey:@"lastuid"] integerValue];
    conv.lastuser = [convDic objectForKey:@"lastuser"];
    conv.name = [convDic objectForKey:@"name"];
    conv.people = [[convDic objectForKey:@"people"] integerValue];
    conv.uid = [[convDic objectForKey:@"uid"] integerValue];
    conv.unread_news_count = [[convDic objectForKey:@"unread_news_count"] integerValue];
    conv.user = [convDic objectForKey:@"user"];
    conv.auth_type = [[convDic objectForKey:@"auth_type"] integerValue];
    if(conv.people>2){
        conv.name = [NSString stringWithFormat:@"(%ld人)%@",(long)conv.people,conv.name];
    }
    
    
    
    if(conv.uid == [[AFN_util getUserId] integerValue]){//otheruid和uid不会一样
        conv.otheruid = [[convDic objectForKey:@"otheruid"] integerValue];
    }else{
        conv.otheruid = conv.uid;
    }
    
    conv.user =[APPUtils fixString:conv.user];
    conv.lastuser =[APPUtils fixString:conv.lastuser];
    conv.name =[APPUtils fixString:conv.name];
    conv.lastmsg =[APPUtils fixString:conv.lastmsg];
    
    return conv;
}


//-----------------发送消息---------

//发送消息
-(void)send_msgs:(OneMsgEntity*)msg{

    //组建json数据
    MsgSendContent * model = [[MsgSendContent alloc] init];
    [model setContent:msg.content];
     [model setBig_url:msg.big_url];
     [model setThumb_url:msg.thumb_url];
     [model setImageDirection:msg.imageDirection];
     [model setFileName:msg.fileName];
     [model setFilesize:msg.filesize];
     [model setVoice_length:msg.voice_length];
     [model setAddressString:msg.addressString];
     [model setAddress_lat:msg.address_lat];
     [model setAddress_lon:msg.address_lon];
     [model setType:msg.type];
    
    NSString *contentString = [model toJSONString];
    

    
    afn.afn_tag = @"send_msg";
    __weak typeof(self) weakSelf = self;//防止block循环
    if(weakSelf!=nil){
        afn.afnResult = ^(NSString *afn_tag,NSString*resultString){
            
            if([afn_tag isEqualToString:@"send_msg"]){
                
                if(resultString!=nil){
                    weakSelf.sendBackBlock(resultString);
                }else{
                    [weakSelf send_over:@"error"];
                }
                
            }else{
                [weakSelf send_over:@"error"];
            }
        };
    }else{
        NSLog(@"MsgUtil -> weak - nil???");
    }
    
    
    [afn send_msg:msg.group_id content:contentString sendWho:SENDWHO];
    
    contentString = nil;

    
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
    
    updateingSend = YES;
    
    NSString *sqlResultQuery = [NSString stringWithFormat:@"select msg_id from MsgsList where sendStatus='3' and username='%@';",[AFN_util getUserId]];
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
                
                 NSDictionary *tempDic = [[APPUtils getUserDefaults] objectForKey:tempID];
                
                if(tempDic!=nil && ![tempDic isEqual:[NSNull null]]){
                   
                    NSInteger sendingStatus = [[tempDic objectForKey:@"id"] integerValue];
                    
                    
                    if(sendingStatus>1){//若发送成功 sendingStatus=真实msgid
                        
                        NSString *sql = [NSString stringWithFormat:@"update MsgsList set msg_id = '%ld',sendStatus = 1 where msg_id='%@' and username = '%@';",(long)sendingStatus,tempID,[AFN_util getUserId]];
                        [[MainViewController getDatabase] execSql:sql];
                        sql = nil;
                        
                        NSString *sql2 = [NSString stringWithFormat:@"update MsgContents set msg_id = '%ld',big_url = '%@',thumb_url = '%@' where msg_id='%@' and username = '%@';",(long)sendingStatus,[tempDic objectForKey:@"big_url"],[tempDic objectForKey:@"thumb_url"],tempID,[AFN_util getUserId]];
                        [[MainViewController getDatabase] execSql:sql2];
                        sql2 = nil;
                        
                        [APPUtils userDefaultsDelete:tempID];
                        
                    }else if(sendingStatus==-1 || (reset&&sendingStatus==1)){//发送失败
                        
                        NSString *sql = [NSString stringWithFormat:@"update MsgsList set sendStatus = '2' where msg_id='%@' and username = '%@';" ,tempID,[AFN_util getUserId]];
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

    _nowPlayingMsgId = msg.msg_id;
    
    if(player != nil && player.isPlaying){
        [self stopPlayer];
        return;
    }
    
    
    if([msg.type isEqualToString:@"voice"]){
        
        BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath: [[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:msg.fileName]];
        if (!blHave) {
           
            [ToastView showToast:@"该语音已被清除,无法播放"];
            return;
        }
        
        
        NSString *playPath = [[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:@"nowPlay.wav"];
        
        //转wav才能播放
        if ([VoiceConverter ConvertAmrToWav:[[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:msg.fileName] wavSavePath:playPath]){
            
           
            NSString *earState = [[APPUtils getUserDefaults] stringForKey:@"err_setting"];
            
            
            if(earState!=nil&&[earState isEqualToString:@"on"]){
                //设置听筒模式
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
            }else{
                //设置下扬声器模式
                [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:nil];
            }
            
            
            [[AVAudioSession sharedInstance] setActive:YES error:nil];
            
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
    }
}

//播放完毕
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)playerq successfully:(BOOL)flag{
    NSLog(@"播放完毕");
    voice_playing = NO;
}

@end
