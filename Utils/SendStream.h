//
//  SendStream.h
//  MedicalCenter
//
//  Created by 李狗蛋 on 15-5-18.
//  Copyright (c) 2015年 李狗蛋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface SendStream : NSObject<NSStreamDelegate>{
    BOOL isConnection;
    
}

@property (strong, nonatomic) NSString *Flag;//识别是拿个view正在使用 回传

@property (strong,nonatomic) NSInputStream *inputStream;

@property (strong, nonatomic) NSOutputStream *outputStream;

@property (strong, nonatomic)  NSMutableData *_incomingDataBuffer;


@property (assign, nonatomic) BOOL isClosed;

@property (strong, nonatomic) NSString *hostIp;

@property (assign, nonatomic) NSString *hostPort;

@property (assign, nonatomic) BOOL ipDIY;


typedef void (^StreamBlock)(NSString *contentString);
@property (nonatomic,strong)StreamBlock callBackBlock;


-(void)close;
-(void)initNetworkCommunication;
- (void)writeString: (NSString *) string;

@end
