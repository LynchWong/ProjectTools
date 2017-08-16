//
//  ShareUtils.m
//  zpp
//
//  Created by Chuck on 2017/5/2.
//  Copyright © 2017年 myncic.com. All rights reserved.
//

#import "ShareUtils.h"

@implementation ShareUtils
@synthesize shareUrl;

+ (ShareUtils*)share{

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareUtil = [[self alloc] initShare];
    });
    
    return shareUtil;
    
}
- (id)initShare{
    self = [super init];
    if (self) {
        
        [self setFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        self.alpha=0;
        [[[UIApplication sharedApplication].delegate window] addSubview:self];
        
        if(backCoverView == nil){
            backCoverView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
            backCoverView.alpha = 0.1;
            [backCoverView addTarget:self action:@selector(closeShareView) forControlEvents:UIControlEventTouchDown];
            [self addSubview:backCoverView];
            
        }
    }
    return self;
}

-(void)createView{

     [APPUtils setMethod:@"ShareUtils -> createView"];
    
    CGFloat tHeight = 45;
    CGFloat margin = 10;
    if(only_share){
        shareWidth = SCREENWIDTH*0.28;
        shareViewMargin = (SCREENWIDTH-margin*2-(shareWidth*3))/2;//间隔
    }else{
        shareWidth = (SCREENWIDTH-margin*2)/4;
        shareViewMargin = 0;
    }
    
    shareHeight = 80;
    share_imageWidth = shareWidth*0.5;
    
    
    
    shareView = [[UIView alloc] init];
    
    if(only_share){
        [shareView setFrame:CGRectMake(0, SCREENHEIGHT,SCREENWIDTH, shareHeight*2+tHeight*2+margin*2)];
    }else{
        [shareView setFrame:CGRectMake(0, SCREENHEIGHT,SCREENWIDTH, shareHeight*2+tHeight+margin*2)];
    }

    [self addSubview:shareView];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *mainView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    if(only_share){
        [mainView setFrame:CGRectMake(margin,0, SCREENWIDTH-margin*2, shareHeight*2+tHeight)];
    }else{
        [mainView setFrame:CGRectMake(margin,0, SCREENWIDTH-margin*2, shareHeight*2)];
    }
    
    mainView.layer.cornerRadius = 5;
    [mainView.layer setMasksToBounds:YES];
    [shareView addSubview:mainView];
    
    
    UIView *wLine = [[UIView alloc] init];
    
    if(only_share){
        UIView *shareTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainView.width,tHeight)];
        [mainView addSubview:shareTitleView];
        UILabel *share_title_Label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, mainView.width, tHeight)];
        share_title_Label.textAlignment = NSTextAlignmentCenter;
        share_title_Label.textColor = [UIColor whiteColor];
        share_title_Label.font = [UIFont fontWithName:textDefaultBoldFont size:14];
        share_title_Label.text = share_title_content;
        [shareTitleView addSubview:share_title_Label];
        share_title_Label = nil;
        
        [wLine setFrame:CGRectMake((shareTitleView.width-shareTitleView.width*0.5)/2, shareTitleView.height-0.5, shareTitleView.width*0.5, 0.5)];
        [shareTitleView addSubview:wLine];
        shareTitleView = nil;
        
    }else{
        
        [wLine setFrame:CGRectMake(0, shareHeight, shareView.width, 0.5)];
        [shareView addSubview:wLine];
    }
    
//    [wLine setBackgroundColor:LINECOLOR3];
    wLine = nil;

    
    
    UIView *share_view = [[UIView alloc] initWithFrame:CGRectMake(0, (only_share?tHeight:0), mainView.width, shareHeight*2)];
    [mainView addSubview:share_view];
    
    xPositionShare=0;
    lineShare=0;
    [share_view addSubview:[self getShareControl:201 imageName:@"share_weixin_no_press.png" showName:@"微信"]];
    [share_view addSubview:[self getShareControl:202 imageName:@"share_pengyouquan_no_press.png" showName:@"朋友圈"]];
    [share_view addSubview:[self getShareControl:203 imageName:@"share_qq_no_press.png" showName:@"QQ"]];
    [share_view addSubview:[self getShareControl:204 imageName:@"share_weibo_no_press.png" showName:@"新浪微博"]];
    
    if(share_app){
        [share_view addSubview:[self getShareControl:205 imageName:@"share_msg_no_press" showName:@"短信"]];
        [share_view addSubview:[self getShareControl:206 imageName:@"share_qrcode_no_press" showName:@"二维码"]];
    }
    
    
    if(!only_share){
        xPositionShare=0;
        lineShare=1;
        if(_hasFocused>=0 && !_my_publish){
            [share_view addSubview:[self getShareControl:301 imageName:_hasFocused==1?@"uncollect_xsq.png":@"collect_xsq.png" showName:_hasFocused==1?@"取消关注":@"关注"]];
        }
        [share_view addSubview:[self getShareControl:302 imageName:@"copy_link.png" showName:@"复制链接"]];
        if(!_my_publish){
            [share_view addSubview:[self getShareControl:303 imageName:@"report_xsq.png" showName:@"举报"]];
        }
        [share_view addSubview:[self getShareControl:304 imageName:@"close_page.png" showName:@"关闭页面"]];
    }
    
    
    UIVisualEffectView *cancelv = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [cancelv setFrame:CGRectMake(margin,mainView.height+margin, mainView.width, tHeight)];
    cancelv.layer.cornerRadius = 5;
    [cancelv.layer setMasksToBounds:YES];
    [shareView addSubview:cancelv];
    
    
    MyBtnControl *cControl = [[MyBtnControl alloc] initWithFrame:CGRectMake(0, 0, cancelv.width, tHeight)];
    [cancelv addSubview:cControl];
    
    cControl.clickBackBlock = ^(){
        
        [self closeShareView];
    };
    
    UILabel *c_Label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cControl.width, tHeight)];
    c_Label.textAlignment = NSTextAlignmentCenter;
    c_Label.textColor = [UIColor whiteColor];
    c_Label.text = @"取消";
    c_Label.font = [UIFont fontWithName:textDefaultFont size:14];
    [cControl addSubview:c_Label];
    c_Label = nil;
    cControl = nil;
    
    share_view = nil;
    
}




-(UIView*)getShareControl:(NSInteger)index imageName:(NSString*)name showName:(NSString*)showName{
    
    [APPUtils setMethod:@"ShareUtils -> getShareControl"];
    
    if(xPositionShare >=3 && only_share){
        xPositionShare = 0;
        lineShare++;
    }
    
    
    UIView *sView = [[UIView alloc] initWithFrame:CGRectMake(shareViewMargin+xPositionShare*shareWidth, lineShare*shareHeight, shareWidth, shareHeight)];
    
    
    UIImageView *shareImage =[[UIImageView alloc] initWithFrame:CGRectMake((shareWidth-share_imageWidth)/2, (shareHeight-share_imageWidth)/2-10, share_imageWidth, share_imageWidth)];
    shareImage.layer.shouldRasterize = YES;
    shareImage.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    [shareImage setImage:[UIImage imageNamed:name]];
    [sView addSubview:shareImage];
    
    
    UILabel *share_Label = [[UILabel alloc] initWithFrame:CGRectMake(0, shareHeight-24, shareWidth, 20)];
    share_Label.textAlignment = NSTextAlignmentCenter;
    share_Label.textColor = [UIColor whiteColor];
    share_Label.text = showName;
    share_Label.font = [UIFont fontWithName:textDefaultFont size:11];
    [sView addSubview:share_Label];
    
    
    MyBtnControl *sControl = [[MyBtnControl alloc] initWithFrame:CGRectMake(0, 0, shareWidth, shareHeight)];
    [sView addSubview:sControl];
    sControl.shareImage = shareImage;
    sControl.shareLabel = share_Label;
    
    sControl.clickBackBlock = ^(){
        
        if(index<300){//分享
            [self readyShare:index];
        }else{
            [self closeShareView];
            self.callBackBlock(index);
        }
        
    };
    
    
    shareImage = nil;
    share_Label = nil;
    xPositionShare++;
    return sView;
}

//分享
-(void)openShareView:(BOOL)onlyShare title:(NSString*)title share_Title:(NSString*)share_Title share_Body:(NSString*)share_Body share_Url:(NSString*)share_Url shareApp:(BOOL)shareApp shareImg:(UIImage*)shareImg{
    
    [APPUtils setMethod:@"ShareUtils -> openShareView"];
    
    only_share = onlyShare;
    share_title_content =title;
    share_app = shareApp;
    shareTitle = share_Title;
    shareBody = share_Body;
    shareUrl = share_Url;
    imageStore = shareImg;
    
    
    [self createView];
    
    backCoverView.alpha = 0.1;
    [backCoverView setBackgroundColor:[UIColor whiteColor]];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha=1;
        [shareView setFrame:CGRectMake(0, SCREENHEIGHT-shareView.height,SCREENWIDTH, shareView.height)];
    }];

}



//分享
-(void)readyShare:(NSInteger)index{
    
    [APPUtils setMethod:@"ShareUtils -> readyShare"];
    
    if(index == 205){
        
        [ShowWaiting showWaiting:@"加载中,请稍等"];
        
    }else if(index == 204){
        
        [ShowWaiting showWaiting:@"分享中,请稍等"];
        
    }else if(index == 206){//二维码
        
        [self showQrcode];
        return;
        
    }else if(index == 201 || index == 202){
        if(![WXApi isWXAppInstalled]){
            
            [ToastView showToast:@"请先安装微信客户端再分享"];
            return;
        }
    }else if(index == 203){
        if(![QQApiInterface isQQInstalled]){
            [ToastView showToast:@"请先安装QQ客户端再分享"];
            return;
        }
    }
    
    
    
    
    NSArray* imageArray = @[imageStore];
    
    
    //创建分享参数（必要）
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    
    NSUInteger shareType;
    
    
    if(index == 205){//短信
        
        [shareParams SSDKSetupShareParamsByText:[NSString stringWithFormat:@"%@。 %@ 下载地址:%@",shareTitle,shareBody,shareUrl]
                                         images:nil
                                            url:[NSURL URLWithString:shareUrl]
                                          title:nil
                                           type:SSDKContentTypeAuto];
        
        
        shareType = SSDKPlatformTypeSMS;
        
    }else{
        
        
        if(index == 201){//发微信
            
            shareType = SSDKPlatformSubTypeWechatSession;
        }else if(index == 202){ //发朋友圈
            
            if(_shareTitleWithNewsInPYQ!=nil && _shareTitleWithNewsInPYQ.length>0){
                shareTitle = _shareTitleWithNewsInPYQ;
            }
            _shareTitleWithNewsInPYQ = @"";
            
            shareType = SSDKPlatformSubTypeWechatTimeline;
            
        }else if(index ==203){//QQ好友
            
            shareType = SSDKPlatformSubTypeQQFriend;
            
        }else if(index ==204){//新浪微博
            
            
            if(share_app){
                UIImage *sinaImg = [UIImage imageNamed:@"share_sina.jpeg"];
                if(sinaImg != nil){
                    imageArray = @[sinaImg];
                }
                sinaImg = nil;
                
                shareBody = [NSString stringWithFormat:@"%@。%@ 下载地址:%@",shareTitle,shareBody,shareUrl];
            }else{
                shareBody = [NSString stringWithFormat:@"%@。%@ 链接:%@",shareTitle,shareBody,shareUrl];
            }
            
            shareType = SSDKPlatformTypeSinaWeibo;
            
        }
        
        [shareParams SSDKSetupShareParamsByText:shareBody
                                         images:imageArray
                                            url:[NSURL URLWithString:shareUrl]
                                          title:shareTitle
                                           type:SSDKContentTypeAuto];
    }
    
    [self closeShareView];
    
    //进行分享
    [ShareSDK share:shareType
         parameters:shareParams
     onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
         
         [ShowWaiting hideWaiting];
         
         
         switch (state) {
             case SSDKResponseStateSuccess:
             {
                 [ShowResult showResult:@"分享成功" succeed:YES];
                 
                 break;
             }
             case SSDKResponseStateFail:
             {
                 [ShowResult showResult:@"分享失败" succeed:NO];
                 
                 break;
             }
             case SSDKResponseStateCancel:
             {
                 
                 break;
             }
             default:
                 break;
         }
     }];

}



-(void)showQrcode{
    
    [APPUtils setMethod:@"ShareUtils -> showQrcode"];
    
    if(shareQRCodeView == nil){
        
        
        shareQRCodeView = [[UIView alloc] init];
        [shareQRCodeView setFrame:CGRectMake((SCREENWIDTH-300)/2, (SCREENHEIGHT-300)/2, 300, 300)];
        [shareQRCodeView setBackgroundColor:[UIColor whiteColor]];
        shareQRCodeView.layer.cornerRadius = 4;
        shareQRCodeView.alpha = 0;
        [shareQRCodeView.layer setMasksToBounds:YES];
        [self addSubview:shareQRCodeView];
        
        
        UIView *shareQRCodeControl = [[UIView alloc] initWithFrame:CGRectMake(0, 0, shareQRCodeView.width, shareQRCodeView.height)];
        shareQRCodeControl.layer.cornerRadius = 4;
        
        
        [shareQRCodeView addSubview:shareQRCodeControl];
        
        
        
        CGFloat qrWidth = shareQRCodeControl.width*0.7;
        
        UIImageView *qrCodeView = [[UIImageView alloc] initWithFrame:CGRectMake((shareQRCodeControl.width-qrWidth)/2, (shareQRCodeControl.width-qrWidth)/2, qrWidth, qrWidth)];
        
        [qrCodeView setBackgroundColor:[UIColor clearColor]];
        [qrCodeView setContentMode:UIViewContentModeScaleAspectFill];
        
        
        
        [qrCodeView setImage:[UIImage imageNamed:@"share_qr.png"]];
        [shareQRCodeControl addSubview:qrCodeView];
        
        
        UILabel *scanLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,qrCodeView.y+qrCodeView.height+10,shareQRCodeControl.width,18)];
        scanLabel.textColor = TEXTGRAY;
        scanLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
        scanLabel.textAlignment = NSTextAlignmentCenter;
        scanLabel.text = @"扫一扫上面的二维码,下载客户端";
        [shareQRCodeControl addSubview:scanLabel];
        scanLabel = nil;
        
        shareQRCodeControl = nil;
        qrCodeView = nil;
        
    }
    
    backCoverView.alpha = 0.6;
    [backCoverView setBackgroundColor:[UIColor blackColor]];
    [self bringSubviewToFront:backCoverView];
    [self bringSubviewToFront:shareQRCodeView];
    
    [UIView animateWithDuration:0.2f animations:^{
        self.alpha=1;
        [shareView setFrame:CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, shareView.height)];
        shareQRCodeView.alpha=1.0;
    }];
    

}



//关闭全部选择框
-(void)closeShareView{

    [UIView animateWithDuration:0.2f delay:0
                        options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState) animations:^(void) {
                            
                            self.alpha=0;
                            shareQRCodeView.alpha=0;
                            [shareView setFrame:CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, shareView.height)];
                       
                        }
                     completion:^(BOOL finished){
                         [shareView removeFromSuperview];
                         shareView = nil;
                     }];
    
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
