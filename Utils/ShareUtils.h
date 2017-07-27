//
//  ShareUtils.h
//  zpp
//
//  Created by Chuck on 2017/5/2.
//  Copyright © 2017年 myncic.com. All rights reserved. 分享
//

#import <UIKit/UIKit.h>
#import "APPUtils.h"
#import "MainViewController.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKExtension/SSEShareHelper.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareActionSheetStyle.h>
#import <ShareSDKUI/SSUIShareActionSheetCustomItem.h>
#import <ShareSDK/ShareSDK+Base.h>
#import <ShareSDKExtension/ShareSDK+Extension.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WXApi.h"

@class ShareUtils;
@class MyBtnControl;

static ShareUtils *shareUtil;

@interface ShareUtils : UIView{
  

    //分享
    UIControl *backCoverView;
    UIView *shareView;
    CGFloat shareWidth;
    CGFloat shareHeight;
    NSInteger xPositionShare;
    NSInteger lineShare;
    CGFloat share_imageWidth;
    CGFloat shareViewMargin;

    UIView *shareResultView;
    UILabel *share_result_Label;
    UIImageView *shareSImageView;
    UIView *shareQRCodeView;
    
   
    BOOL only_share;//只有分享
    BOOL share_app;//分享app
    NSString *share_title_content;//标题
    
    NSString *shareTitle;//分享标题
    NSString *shareBody;//分享内容
    UIImage *imageStore;//分享图片
}

+ (ShareUtils*)share;



- (id)initShare;

//打开分享
-(void)openShareView:(BOOL)onlyShare title:(NSString*)title share_Title:(NSString*)share_Title share_Body:(NSString*)share_Body share_Url:(NSString*)share_Url shareApp:(BOOL)shareApp shareImg:(UIImage*)shareImg;


@property(nonatomic,strong) NSString *shareTitleWithNewsInPYQ;//分享朋友圈的标题
@property(nonatomic,strong) NSString *shareUrl;//分享url

@property(assign,nonatomic)NSInteger hasFocused;//关注过
@property(assign,nonatomic)BOOL my_publish;//自己发布的

typedef void (^ShareBlock)(NSInteger tag);
@property (nonatomic,strong)ShareBlock callBackBlock;

@end
