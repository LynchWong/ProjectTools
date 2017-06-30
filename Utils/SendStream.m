//
//  SendStream.m
//  MedicalCenter
//
//  Created by 李狗蛋 on 15-5-18.
//  Copyright (c) 2015年 李狗蛋. All rights reserved.
//

#import "SendStream.h"
#include "sys/stat.h"
#import "DBControl.h"
#import "MainViewController.h"
@implementation SendStream
@synthesize hostIp;
@synthesize hostPort;


-(void)initNetworkCommunication{
    
    
    if(hostIp == nil || hostIp.length == 0){
        NSBundle *bundle = [NSBundle mainBundle];
        NSURL *plistURL = [bundle URLForResource:@"AppInfo" withExtension:@"plist"];
        
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfURL:plistURL];
        
        hostIp = [AFN_util getIpadd];
        hostPort = [AFN_util getPort];
        
        dictionary = nil;
        bundle = nil;
        plistURL = nil;
    }
    
    
    if(!self.ipDIY){
        hostIp = [AFN_util getIpadd];
        hostPort = [AFN_util getPort];
    }
    
    
    
    CFReadStreamRef readStream;
    
    CFWriteStreamRef writeStream;
    
    CFStreamCreatePairWithSocketToHost(NULL,
                                       
                                       (__bridge CFStringRef)hostIp, [hostPort integerValue], &readStream, &writeStream);
    
    _inputStream = (__bridge_transfer NSInputStream *)readStream;
    
    _outputStream = (__bridge_transfer NSOutputStream*)writeStream;
    
    [_inputStream setDelegate:self];
    
    [_outputStream setDelegate:self];
    
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
     
                            forMode:NSDefaultRunLoopMode];
    
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
     
                             forMode:NSDefaultRunLoopMode];
    
    [_inputStream open];
    
    [_outputStream open];
    
    
    if(_inputStream != nil && _outputStream != nil){
        isConnection = YES;
    }
    
    readStream = nil;
    writeStream = nil;
    
    
}


- (void)writeString: (NSString *) string{
    
    if(string.length<500){
        NSLog(@"sendstring %@",string);
    }
    
    
    if(!isConnection){
        NSLog(@"stream is no connect");
        return;
    }
    
    
    @try {
        
        
        NSData* tempData = [string dataUsingEncoding:NSUTF8StringEncoding];
        
        uint8_t *sendBytes = (uint8_t *)[tempData bytes];
        
        unsigned long len = tempData.length;
        
        [_outputStream write:(const uint8_t *)sendBytes maxLength:len];
        
        
        [[NSRunLoop currentRunLoop] run];//必须有 不然不能收到返回
        
        tempData = nil;
    }
    @catch (NSException *exception) {
        NSLog(@"send stream exception: %@",exception);
        [self close];
        
        return;
    }
    
    
}



-(void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
    NSString *event;
    
    switch (streamEvent) {
            
        case NSStreamEventNone:
            
            event = @"NSStreamEventNone";
            
            break;
            
        case NSStreamEventOpenCompleted:
            
            event = @"NSStreamEventOpenCompleted";
            
            break;
            
        case NSStreamEventHasBytesAvailable:
            
            event = @"NSStreamEventHasBytesAvailable";
            
            if (theStream == _inputStream) {
                
                
                NSMutableData *input = [[NSMutableData alloc] init];
                
                uint8_t buffer[1024];
                
                int len;
                
                @try {
                    while([_inputStream hasBytesAvailable])
                        
                    {
                        
                        len = [_inputStream read:buffer maxLength:sizeof(buffer)];
                        
                        if (len > 0)
                            
                        {
                            [input appendBytes:buffer length:len];
                            
                        }
                        
                    }
                }
                
                @catch (NSException *exception) {
                    [self close];
                    return;
                }
                
                
                NSString *resultstring = @"";
                NSData *tempData = [NSData dataWithData:input];
                
                
                resultstring = [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
                
                tempData = nil;
                input = nil;
                
                NSLog(@"下载数据:--%@" , resultstring);
                
                self.callBackBlock(resultstring);
                
                [self close];
                
                resultstring = nil;
            }
            
            break;
            
        case NSStreamEventHasSpaceAvailable:
            
            event = @"NSStreamEventHasSpaceAvailable";
            
            break;
            
        case NSStreamEventErrorOccurred:{
            event = @"NSStreamEventErrorOccurred";
            
            self.callBackBlock(@"");
            
            //网络错误
            [self close];
            
            
            break;
            
        }
            
        case NSStreamEventEndEncountered:
            
            event = @"NSStreamEventEndEncountered";
            
            NSLog(@"Error:%ld:%@",[[theStream streamError] code],
                  
                  [[theStream streamError] localizedDescription]);
            
            break;
            
        default:
            
            [self close];
            
            event = @"Unknown";
            
            break;
            
    }
    
    
}




-(void)close

{
    NSLog(@"stream close!");
    
    [_outputStream close];
    
    [_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
     
                             forMode:NSDefaultRunLoopMode];
    
    [_outputStream setDelegate:nil];
    
    [_inputStream close];
    
    [_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
     
                            forMode:NSDefaultRunLoopMode];
    
    [_inputStream setDelegate:nil];
    
    self.isClosed = YES;
}



@end
