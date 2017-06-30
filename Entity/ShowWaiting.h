//
//  ShowResult.h
//  zpp
//
//  Created by Chuck on 2017/5/4.
//  Copyright © 2017年 myncic.com. All rights reserved. 显示结果
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class ShowWaiting;
@class AFN_util;

static ShowWaiting *showWaiting;

@interface ShowWaiting : UIView


@property(nonatomic,strong)UILabel *showLabel;
@property(nonatomic,strong)UILabel *progressLabel;

@property(nonatomic,strong)UIView *cancelView;
@property(nonatomic,strong)NSURLSessionDownloadTask*now_task;//当前下载任务
@property(nonatomic,strong)AFN_util *now_afn;//当前上传任务

+(void)showWaiting:(NSString*)show;
+(void)hideWaiting;

//设置进度
+(void)setProgress:(NSString*)progress;

//显示取消键
+(void)addCancel:(NSURLSessionDownloadTask*)task afn:(AFN_util*)afn;
@end
