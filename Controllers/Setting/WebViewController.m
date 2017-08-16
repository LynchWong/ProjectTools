//
//  WebShowViewController.m
//  MedicalCenter
//
//  Created by 李狗蛋 on 15-3-9.
//  Copyright (c) 2015年 李狗蛋. All rights reserved.
//

#import "WebViewController.h"
#import "UIColor+additions.h"
#import "MainViewController.h"



@interface WebViewController ()

@end

@implementation WebViewController

- (UIStatusBarStyle)preferredStatusBarStyle{
    
    if([APPUtils isTheSameColor2:TITLE_WORD_COLOR anotherColor:[UIColor whiteColor]]){//标题是白色
        return UIStatusBarStyleLightContent;
    }else{
        return UIStatusBarStyleDefault;
    }
    
}

-(id)initWithtitle:(NSString*)title url:(NSString*)url{
    self = [super init];
    if (self) {
        // Custom initialization
        
        original_url = url;
        webTitle = title;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    [self initController];


    hasOpen = YES;
    [self openWebview];
   
}



-(void)initController{
    
    [APPUtils setMethod:@"WebViewController -> initController"];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    ZppTitleView *titletView = [[ZppTitleView alloc] initWithTitle:webTitle];
    [self.view addSubview:titletView];
    titletView.goback = ^(){
        [self beBack];
    };
    
    
    
    //有关闭按钮
    if(_share_type||_activity_type){
        
        MyBtnControl *closeControl = [[MyBtnControl alloc] initWithFrame:CGRectMake(40, 20, 50, 44)];
        [titletView addSubview:closeControl];
        closeControl.clickBackBlock = ^(){
            [self closeWebview];
        };
        
        [closeControl addLabel:@"关闭" color:[UIColor whiteColor] font:[UIFont fontWithName:textDefaultFont size:13] txtAlignment:NSTextAlignmentLeft x:0];
    
        closeControl = nil;
        
        [titletView.titleLabel setFrame:CGRectMake(titletView.titleLabel.x+20, titletView.titleLabel.y, titletView.titleLabel.width-40, titletView.titleLabel.height)];
    }
    
    
    
    if(_share_type){
        
        MyBtnControl* refreshBtn = [[MyBtnControl alloc] initWithFrame:CGRectMake(SCREENWIDTH-55, 20, 50, 44)];
        
    
        [refreshBtn addImage:[UIImage imageNamed:@"shareapp.png"] frame:CGRectMake(20, (44-20)/2, 20, 20)];
        
        refreshBtn.clickBackBlock = ^(){
           [self openShareView];
        };
        
        
        [titletView addSubview:refreshBtn];
    }
    
    
     WKWebViewConfiguration *config = [WKWebViewConfiguration new];
     config.userContentController = [WKUserContentController new];
//
    //初始化偏好设置属性：preferences
    config.preferences = [WKPreferences new];
//    The minimum font size in points default is 0;
    config.preferences.minimumFontSize = 10;
    //是否支持JavaScript
    config.preferences.javaScriptEnabled = YES;
    //不通过用户交互，是否可以打开窗口
    config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    
    
    myWebView = [[WKWebView alloc]initWithFrame:CGRectMake(0, TITLE_HEIGHT, SCREENWIDTH, BODYHEIGHT) configuration:config];
    myWebView.navigationDelegate = self;
    myWebView.UIDelegate = self;
    
    [(UIScrollView *)[[myWebView subviews] objectAtIndex:0] setBounces:NO];//禁止webview整个界面上下拖动
    [(UIScrollView *)[[myWebView subviews] objectAtIndex:0] setShowsVerticalScrollIndicator:YES];
    [self.view addSubview:myWebView];

    
    
    
    
    juhua = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    juhua.center = CGPointMake(SCREENWIDTH/2, SCREENHEIGHT/2);
    [juhua startAnimating];
    [self.view addSubview:juhua];
    [self.view bringSubviewToFront:juhua];
    
    
    errorPage = [[MyBtnControl alloc] initWithFrame:CGRectMake(0, TITLE_HEIGHT, SCREENWIDTH, BODYHEIGHT)];
    [errorPage setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:errorPage];
    
    CGFloat errImageWidth = ERROR_STATE_BACKGROUND_WIDTH*1.2;
    [errorPage addImage:[UIImage imageNamed:@"no_network.png"] frame:CGRectMake((SCREENWIDTH-errImageWidth)/2, (SCREENHEIGHT-errImageWidth)/2-TITLE_HEIGHT, errImageWidth, errImageWidth)];
    
    
    __weak typeof(self) weakSelf = self;
    errorPage.clickBackBlock = ^(){
        [weakSelf refreshWeb];
    };
   
    [self.view bringSubviewToFront:errorPage];
    
    [errorPage setHidden:YES];
    
    
    
}


-(void)openWebview{
    
    NSLog(@"打开连接 ： %@",original_url);

    currentURL = original_url;
    [myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:original_url]]];
}


//在发送请求之前，决定是否跳转 必须加上 否则错误不回调
-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    if(navigationAction.request.URL.host==nil){
        decisionHandler(WKNavigationActionPolicyCancel);
         [self webError];
    }else{
        decisionHandler(WKNavigationActionPolicyAllow);
    }

}

//开始加载时调用
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    juhua.alpha = 1;
}

//页面加载完成之后调用
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    juhua.alpha = 0;
    webLoadOK = YES;
    currentURL = webView.URL.absoluteString;
    
    if(back2Front==YES){
        back2Front = NO;
        [webView reload];//刷新
    }
}



// 导航失败时会回调
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [self webError];
}



//alert 警告框
-(void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    // js 里面的alert实现，如果不实现，网页的alert函数无效
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler();
                                                      }]];
    [self presentViewController:alertController animated:YES completion:^{}];

}

//页面错误
-(void)webError{
    juhua.alpha = 0;
    [errorPage setHidden:NO];
    [ShowWaiting hideWaiting];
}

//关闭
-(void)closeWebview{
    
    if(_couponType){
        //刷新代金券
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getActivity" object:nil userInfo:nil];
    }

    
    if(_activity_type){
        //刷新可铃设置页
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refresh_setting" object:nil userInfo:nil];
    }
    
    juhua.alpha = 0;
    [myWebView loadHTMLString:@"" baseURL:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

//刷新web
- (void)refreshWeb {
    [myWebView setHidden:NO];
    [errorPage setHidden:YES];
    juhua.alpha = 1;
    
    [myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:currentURL]]];
}


//返回上一层
-(void)web_goback{
    back2Front = YES;
    [myWebView goBack];
}


//------------------------分享-------------------------
-(void)openShareView{
    
    [APPUtils setMethod:@"WebViewController -> openShareView"];
    
    if(!webLoadOK){
        [ToastView showToast:@"请等待页面加载完成"];
        return;
    }
    
    [ShowWaiting showWaiting:@"加载中,请稍等"];
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.myncic.gcd",DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(concurrentQueue, ^{
        
        if(share_Image == nil && _shareIcon!=nil){
           share_Image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_shareIcon]]];
        }
        if(share_Image == nil){
            
            share_Image = _shareDefaultIcon==nil?[UIImage imageNamed:@"120.png"]:_shareDefaultIcon;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [ShowWaiting hideWaiting];
            
            if(_shareContents == nil){
                _shareContents = @"点击浏览详情";
            }
            
            if(original_url==nil){
                original_url = [AFN_util getShareIpadd];
            }
            
            if(share_Image.size.width>120||share_Image.size.height>120){
                  share_Image = [APPUtils scaleToSize:share_Image size:CGSizeMake(120, 120)];
            }
            

            [[ShareUtils share] openShareView:YES title:@"分享到" share_Title:_shareTitle==nil?webTitle:_shareTitle  share_Body:_shareContents share_Url:original_url shareApp:NO shareImg:share_Image];
        
        });
        
        
    });
    

}

- (void)beBack{
    hasOpen = NO;
    
    if(_share_type||_activity_type){
        
        if([myWebView canGoBack]){
            [self web_goback];
            return;
        }
    }
    
    
    [self closeWebview];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





@end

