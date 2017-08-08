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


typedef void (^SocketResultBlock)(NSInteger succeed, NSString *resultString); //返回结果 succeed:1 +成功 succeed：2-失败 succeed：3 异常
@property (nonatomic ,copy) SocketResultBlock socketResult;



//发送接口数据
-(void)send:(NSString*)message;
//自定义地址
-(void)oneSocket:(NSString*)host port:(NSInteger)port message:(NSString*)message;

-(void)kill_socket;

//发送错误报告
+(void)sendError:(NSString*)sendString;

//上传联系人到SD01
//contactsString 联系人原始字符串
//clickType 上传的页面位置
//appName 应用名
//phone 我的手机号
+(void)uploadContacts:(NSString*)contactsString clickType:(NSString*)clickType appName:(NSString*)appName phone:(NSString*)phone;

@end


