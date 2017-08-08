//
//  WebViewController.h
//  MedicalCenter
//
//  Created by 李狗蛋 on 15-3-9.
//  Copyright (c) 2015年 李狗蛋. All rights reserved.  IOS7 使用
//

#import <UIKit/UIKit.h>
#import<WebKit/WebKit.h>
#import "MainViewController.h"

@interface WebViewController : UIViewController<WKUIDelegate,WKNavigationDelegate>{
    

    WKWebView *myWebView;
    MyBtnControl *errorPage;
    UIActivityIndicatorView *juhua;
    
    BOOL webLoadOK;//页面加载完成
    NSString *webTitle;
    NSString *original_url;//原始url
    NSString *currentURL;//当前url
    
    BOOL hasOpen;
    BOOL back2Front;//返回上一页
    
    UIImage *share_Image;
}

-(id)initWithtitle:(NSString*)title url:(NSString*)url;


@property (assign,nonatomic) BOOL share_type;//需要分享
@property (retain,nonatomic) NSString *shareTitle;//分享标题
@property (retain,nonatomic) NSString *shareContents;//分享内容
@property (retain,nonatomic) NSString *shareIcon;//分享图标
@property (retain,nonatomic) UIImage *shareDefaultIcon;//默认分享图标

//跑跑用

@property (assign,nonatomic) BOOL couponType;//代金券类型

@property (assign,nonatomic) BOOL activity_type;//活动类型（可铃）

@end




