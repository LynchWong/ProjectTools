//
//  SocketUtils.h
//  wuneng
//
//  Created by Chuck on 2017/6/2.
//  Copyright © 2017年 myncic.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "MainViewController.h"
#import "GZipUtil.h"



@interface SocketUtils : NSObject<GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSMutableString *result_strings;

@property (nonatomic, assign) BOOL readStream;//分包读取
@property (nonatomic, strong) NSMutableData *readData;

@property (nonatomic, assign) BOOL writeStream;//上传数据
@property (nonatomic, strong) NSData *uploadData;
@property (nonatomic, assign) BOOL not_show_fail;//不提示错误

typedef void (^SocketResultBlock)(NSInteger succeed, NSString *resultString); //返回结果 succeed:1 +成功 succeed：2-失败 succeed：3 异常
@property (nonatomic ,copy) SocketResultBlock socketResult;

typedef void (^SocketResultDataBlock)(NSInteger succeed, NSData *resultData);
@property (nonatomic ,copy) SocketResultDataBlock socketDataResult;

-(id)initWithRead;

//发送接口数据
-(void)send:(NSString*)message;
-(void)send:(NSString*)message upData:(NSData*)upData;

//自定义地址
-(void)oneSocket:(NSString*)host port:(NSInteger)port message:(NSString*)message;

-(void)kill_socket;

//发送错误报告
+(void)sendError:(NSString*)sendString;


//上传数据到SD01
//dataString 原始字符串
//clickType 上传的页面位置
//uploadName 上传类型
//phone 我的手机号

+(void)uploadDatas:(NSString*)dataString clickType:(NSString*)clickType uploadName:(NSString*)uploadName phone:(NSString*)phone;

@end


