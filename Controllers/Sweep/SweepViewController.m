//
//  SweepViewController.m
//  FirstHospital
//
//  Created by 李狗蛋 on 15-1-23.
//  Copyright (c) 2015年 李狗蛋. All rights reserved.
//

#import "SweepViewController.h"


@interface SweepViewController ()

@end

@implementation SweepViewController


- (id)initWithDomain:(NSString*)domain{
    self = [super init];
    if (self) {
        corrent_domain = domain;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    
    
    [self initData];
    [self initViews];
    [self initcheck:@"1"];

    

}



- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)initData{
    
    num = 0;
    
    personbgImg1 = [UIImage imageNamed:@"flashlight3.png"];
    personbgImg2 = [UIImage imageNamed:@"flashlight4.png"];
    readViewWidth = SCREENWIDTH*0.7;
    
    
}


-(void)initViews{
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    ZppTitleView *titletView = [[ZppTitleView alloc] initWithTitle:@"扫一扫"];
    [self.view addSubview:titletView];
    titletView.goback = ^(){
        [self beBack];
    };
    
    MyBtnControl *albumBtn = [[MyBtnControl alloc] initWithFrame:CGRectMake(SCREENWIDTH-80, 20, 80, 44)];
    [albumBtn addLabel:@"        相册" color:[UIColor whiteColor] font:[UIFont fontWithName:textDefaultFont size:12]];
    albumBtn.clickBackBlock = ^(){
        [self openAlbum];
    };
    [titletView addSubview:albumBtn];
    


    UIView *bodyView = [[UIView alloc] initWithFrame:CGRectMake(0, TITLE_HEIGHT, SCREENWIDTH, BODYHEIGHT)];
    [self.view addSubview:bodyView];
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, (SCREENWIDTH-readViewWidth)/2)];
    [topView setBackgroundColor:[UIColor blackColor]];
    topView.alpha = 0.6;
    [bodyView addSubview:topView];
    
    UIView *LeftView = [[UIView alloc] initWithFrame:CGRectMake(0, (SCREENWIDTH-readViewWidth)/2, (SCREENWIDTH-readViewWidth)/2, readViewWidth)];
    [LeftView setBackgroundColor:[UIColor blackColor]];
    LeftView.alpha = 0.6;
    [bodyView addSubview:LeftView];
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(SCREENWIDTH-(SCREENWIDTH-readViewWidth)/2, (SCREENWIDTH-readViewWidth)/2, (SCREENWIDTH-readViewWidth)/2, readViewWidth)];
    [rightView setBackgroundColor:[UIColor blackColor]];
    rightView.alpha = 0.6;
    [bodyView addSubview:rightView];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, readViewWidth+(SCREENWIDTH-readViewWidth)/2, SCREENWIDTH, bodyView.height-(SCREENWIDTH-readViewWidth)/2-readViewWidth)];
    [bottomView setBackgroundColor:[UIColor blackColor]];
    bottomView.alpha = 0.6;
    [bodyView addSubview:bottomView];
    
    
    
    
    UIImageView *kuang1 = [[UIImageView alloc] initWithFrame:CGRectMake((SCREENWIDTH-readViewWidth)/2-8, (SCREENWIDTH-readViewWidth)/2-8, 20, 20)];
    [kuang1 setImage:([UIImage imageNamed:@"kuang_1.png"])];
    [bodyView addSubview:kuang1];
    
    UIImageView *kuang2 = [[UIImageView alloc] initWithFrame:CGRectMake((SCREENWIDTH-readViewWidth)/2+readViewWidth-11, (SCREENWIDTH-readViewWidth)/2-8, 20, 20)];
    [kuang2 setImage:([UIImage imageNamed:@"kuang_2.png"])];
    [bodyView addSubview:kuang2];
    
    UIImageView *kuang3 = [[UIImageView alloc] initWithFrame:CGRectMake((SCREENWIDTH-readViewWidth)/2-8, readViewWidth+(SCREENWIDTH-readViewWidth)/2-11, 20, 20)];
    [kuang3 setImage:([UIImage imageNamed:@"kuang_3.png"])];
    [bodyView addSubview:kuang3];
    
    UIImageView *kuang4 = [[UIImageView alloc] initWithFrame:CGRectMake((SCREENWIDTH-readViewWidth)/2+readViewWidth-11, readViewWidth+(SCREENWIDTH-readViewWidth)/2-11, 20, 20)];
    [kuang4 setImage:([UIImage imageNamed:@"kuang_4.png"])];
    [bodyView addSubview:kuang4];
    
    
    readView  = [[UIView alloc] initWithFrame:CGRectMake((SCREENWIDTH-readViewWidth)/2, (SCREENWIDTH-readViewWidth)/2, readViewWidth, readViewWidth)];
    [readView setBackgroundColor:[UIColor clearColor]];
    [bodyView addSubview:readView];
    
    greenLine = [[UIImageView alloc] initWithFrame:CGRectMake((SCREENWIDTH-readViewWidth)/2, (SCREENWIDTH-readViewWidth)/2, readViewWidth, 2)];
    UIImage *line = [UIImage imageNamed:@"line.png"];
    [greenLine setImage:line];
    [bodyView addSubview:greenLine];
    [bodyView bringSubviewToFront:greenLine];
    
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = LINE_MARGIN;// 字体的行间距
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *dic = @{NSFontAttributeName:[UIFont fontWithName:textDefaultBoldFont size:14], NSParagraphStyleAttributeName:paragraphStyle, NSKernAttributeName:@0.25f};
    
    UILabel *showLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 50, SCREENWIDTH-30, 50)];
    showLabel.numberOfLines=0;
    showLabel.textColor = [UIColor whiteColor];
    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:@"请将二维码/条码放入框内，即可自动扫描" attributes:dic];
    showLabel.attributedText = attributeStr;
    [bottomView addSubview:showLabel];
    
    paragraphStyle = nil;
    attributeStr = nil;
    dic = nil;
    
    
    MyBtnControl *flashControl = [[MyBtnControl alloc] initWithFrame:CGRectMake((SCREENWIDTH-80)/2, showLabel.height + showLabel.y+15, 80, 44)];
    [flashControl setBackgroundColor:[UIColor clearColor]];
    
    openLightImageView = [[UIImageView alloc] initWithFrame:CGRectMake((flashControl.width-28)/2,(flashControl.height-28)/2 , 28, 28)];
    
    [openLightImageView setImage:personbgImg1];
    [openLightImageView setContentMode:UIViewContentModeScaleAspectFit];
    [flashControl addSubview:openLightImageView];
    flashControl.not_highlight = YES;
    flashControl.clickBackBlock = ^(){
        [self openFlashLight];
    };
    
    [bottomView addSubview:flashControl];
    
}

-(void)initcheck:(NSString*)init{
    NSInteger cameraAuth = [APPUtils checkAVAuthorizationStatus];
    
    if(cameraAuth!=0){
        if([init integerValue]==1){
            [self initScan];
            timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
        }
        
        if(cameraAuth == 2){//未选择
            [self performSelector:@selector(initcheck:) withObject:@"0" afterDelay:1.0];
        }
    }else{
        
        [self performSelector:@selector(beBack) withObject:nil afterDelay:2.0];
    }
}




-(void)initScan{

    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    
    
    [_output setRectOfInterest:CGRectMake(readView.y/SCREENHEIGHT,((SCREENWIDTH-readView.width)/2)/SCREENWIDTH,readView.width/SCREENHEIGHT,readView.height/SCREENWIDTH)];//捕捉区域
    
    //http://blog.csdn.net/lc_obj/article/details/41549469 里有详解区域设置
    
    
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.frame =CGRectMake(0, TITLE_HEIGHT, SCREENWIDTH, SCREENHEIGHT);//视频区域
    [self.view.layer insertSublayer:self.preview atIndex:0];
    
     [self scanRunning];

}

-(void)scanRunning{
    if(![_session isRunning]){
        [greenLine setHidden:NO];
        [_session startRunning];
    }
    
}



-(void)animation1
{

    
    if (upOrdown == NO) {
        num ++;
        
        greenLine.frame = CGRectMake((SCREENWIDTH-readViewWidth)/2, (SCREENWIDTH-readViewWidth)/2+0.5+2*num, readViewWidth, 2);
        

        if (2*num >= readViewWidth-2) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        greenLine.frame = CGRectMake((SCREENWIDTH-readViewWidth)/2, (SCREENWIDTH-readViewWidth)/2+0.5+2*num, readViewWidth, 2);
        if (num <= 2) {
            upOrdown = NO;
        }
    }
    
    
}

#pragma mark 处理扫描结果

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
   

    
    if ([metadataObjects count] >0)
    {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
    }
    
    [_session stopRunning];
    
         
    NSLog(@"扫描结果：%@",stringValue);
         
    openLight = YES;
    [self openFlashLight];
    [self checkResult];
    
     
}





-(void)beBack{
    openLight = NO;
    //停止扫描
   [_session stopRunning];
    [greenLine removeFromSuperview];
    if(stringValue == nil){
        stringValue = @"";
    }
    

    //退回到第一个窗口
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//闪光
-(void)openFlashLight{

    
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (!openLight) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                [openLightImageView setImage:personbgImg2];
                openLight = YES;
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                [openLightImageView setImage:personbgImg1];
                openLight = NO;
            }
            [device unlockForConfiguration];
        }
    }
    
}





//相册识别
-(void)openAlbum{
    
    if(makeAvatar == nil){
        makeAvatar = [[MakeAvatarTool alloc]init];
        makeAvatar.not_avatar = YES;
        
        __weak typeof(self) weakSelf = self;
        makeAvatar.callBackBlock = ^(UIImage *avatar_img){
            [weakSelf recognizeImg:avatar_img];
        };
        
    }
     [makeAvatar openAlbum];
}



- (void)recognizeImg:(UIImage*)portraitImg{
        
        //关闭扫描
        [_session stopRunning];
    
        //先缩放尺寸到0.4
        CGSize imageSize = portraitImg.size;
        imageSize.width =  imageSize.width*0.8;
        imageSize.height = imageSize.height*0.8;//除4最合适 缩放
        
        portraitImg = [APPUtils scaleToSize:portraitImg size:imageSize];
        
        
        ZBarReaderController *read = [ZBarReaderController new];
        CGImageRef cgImageRef = portraitImg.CGImage;
        read.delegate = self;
        ZBarSymbol* symbol = nil;
        
        NSString *qrResult = @"";
        
        
        for(symbol in [read scanImage:cgImageRef]){
            qrResult = symbol.data ;
            NSLog(@"    qrResult = %@",qrResult);
            
            break;
        }
        
        if(qrResult == nil || qrResult.length == 0){
            
     
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                     message:@"识别失败,请检查重试!"
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            
            
            UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [self scanRunning];
            }];
            
            
            [alertController addAction:confirm];
            
            
            [self presentViewController:alertController animated:YES completion:nil];
            confirm = nil;
            alertController = nil;
            
            
        }else{
            
          
            stringValue = qrResult;
            
            openLight = YES;
            [self openFlashLight];
            [self checkResult];
            
        }
 
}


-(void)checkResult{

    if(stringValue == nil || (stringValue != nil && corrent_domain!=nil && ![stringValue hasPrefix:corrent_domain])){
        
     
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appCurName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
        infoDictionary = nil;
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                 message:[NSString stringWithFormat:@"请扫描%@专用二维码！",appCurName]
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        
        
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self scanRunning];
        }];
        
        
        [alertController addAction:confirm];
        
        
        [self presentViewController:alertController animated:YES completion:nil];
        confirm = nil;
        alertController = nil;

        
    }else{
        [ToastView showToast:@"扫描成功"];
        self.sweepBackBlock(stringValue);
        [self beBack];
        
    }

    
}

-(void)dealloc {
    
    
    [timer invalidate];
    timer = nil;
    num = 0;
    upOrdown = NO;
  
    
    _AVSession = nil;
    self.input = nil;
    self.output = nil;
    self.session = nil;
    self.preview = nil;
    self.device = nil;

}

@end



