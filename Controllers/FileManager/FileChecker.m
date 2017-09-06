//
//  WebShowViewController.m
//  MedicalCenter
//
//  Created by 李狗蛋 on 15-3-9.
//  Copyright (c) 2015年 李狗蛋. All rights reserved. 在线文件浏览器
//

#import "FileChecker.h"
#import "MainViewController.h"
#import "MovieViewController.h"

@implementation FileChecker


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
    [self openWebview];
    
    
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)initController{
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    ZppTitleView *titletView = [[ZppTitleView alloc] initWithTitle:webTitle];
    [self.view addSubview:titletView];
    titletView.goback = ^(){
        [self beBack];
    };
    
    myWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, TITLE_HEIGHT, SCREENWIDTH , BODYHEIGHT)];
    myWebView.delegate = self;
    [self.view addSubview:myWebView];
    [myWebView setScalesPageToFit:YES];
    //禁止webview整个界面上下拖动
    [(UIScrollView *)[[myWebView subviews] objectAtIndex:0] setBounces:NO];
    [(UIScrollView *)[[myWebView subviews] objectAtIndex:0] setShowsVerticalScrollIndicator:YES];
    
    
    juhua = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    juhua.center = CGPointMake(SCREENWIDTH/2, SCREENHEIGHT/2);
    [juhua startAnimating];
    [self.view addSubview:juhua];
    juhua.alpha = 0;
}


-(void)openWebview{

    ///编码可以解决 .txt 中文显示乱码问题
    NSStringEncoding *useEncodeing = nil;
    //带编码头的如utf-8等，这里会识别出来
    NSString *body = [NSString stringWithContentsOfFile:original_url usedEncoding:useEncodeing error:nil];
    //识别不到，按GBK编码再解码一次.这里不能先按GB18030解码，否则会出现整个文档无换行bug。
    if (!body) {
        body = [NSString stringWithContentsOfFile:original_url encoding:0x80000632 error:nil];
    }
    //还是识别不到，按GB18030编码再解码一次.
    if (!body) {
        body = [NSString stringWithContentsOfFile:original_url encoding:0x80000631 error:nil];
    }
    
    
    //展现
    if (body) {
        [myWebView loadHTMLString:body baseURL: nil];
    }else {
        NSString *urlString = [[NSBundle mainBundle] pathForAuxiliaryExecutable:original_url];
        urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        if(urlString==nil){
            urlString = original_url;
        }
        NSURL *requestUrl = [NSURL URLWithString:urlString];
        NSURLRequest *requests = [NSURLRequest requestWithURL:requestUrl];
        [myWebView loadRequest:requests];
        
    }
   
}


-(void)webViewDidStartLoad:(UIWebView *)webView{
    juhua.alpha = 1;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    juhua.alpha = 0;
}


-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    juhua.alpha = 0;
}



- (void)beBack{
    [myWebView loadHTMLString:@"" baseURL:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//本地查看文件 （非web）
+(void)viewFileInLocal:(NSString*)path filename:(NSString*)filename tail:(NSString*)tail{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if([APPUtils fileExist:path]){
            
            NSString *fileType = [APPUtils get_file_type:tail];
            if([fileType isEqualToString:@"office"]||[fileType isEqualToString:@"zip"]){//文档类 压缩包
                
                UIDocumentInteractionController *diController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:path]];
                
                
                if([tail hasPrefix:@"doc"]||[tail hasPrefix:@"docx"]){
                    diController.UTI = @"com.microsoft.word.doc";
                }else if([tail hasPrefix:@"ppt"]||[tail hasPrefix:@"pptx"]){
                    diController.UTI = @"com.microsoft.powerpoint.​ppt";
                }else if([tail hasPrefix:@"xls"]||[tail hasPrefix:@"xlt"]){
                    diController.UTI = @"com.microsoft.excel.xls";
                }else if([tail hasPrefix:@"pdf"]){
                    diController.UTI = @"com.adobe.pdf";
                }else if([fileType isEqualToString:@"zip"]){
                    diController.UTI = @"com.pkware.zip-archive";//压缩包
                }
                
                [diController presentOpenInMenuFromRect:CGRectMake(0, 20, 100, 100) inView:[MainViewController sharedMain].view animated:YES];
                
                diController = nil;
            }else if([fileType isEqualToString:@"video"]||[fileType isEqualToString:@"audio"]){//音视频
                
                MovieViewController *secondView = [[MovieViewController alloc] initWithtitle:filename url:path online:NO];
                //设置第二个窗口中的delegate为第一个窗口的self
                [[MainViewController sharedMain].navigationController pushViewController:secondView animated:YES];
                secondView = nil;
                
                
            }else{
                [ToastView showToast:@"抱歉,暂不支持查看该类文件"];
            }
            
            
            fileType = nil;
        }else{
            [ToastView showToast:@"文件不存在"];
        }
    });
}


@end


