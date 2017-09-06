//
//  SettingViewController.m
//  MedicalCenter
//
//  Created by 李狗蛋 on 15-3-19.
//  Copyright (c) 2015年 李狗蛋. All rights reserved.
//

#import "TuyaViewController.h"
#import "SelectEndViewController.h"
@interface TuyaViewController ()

@end

@implementation TuyaViewController



- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


- (id)initWithTuya:(BOOL)tuya{
    self = [super init];
    if (self) {
        isTuya = tuya;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initView];
  
}


-(void)initView{

    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    ZppTitleView *titleView = [[ZppTitleView alloc] initWithTitle:(isTuya?@"涂鸦":@"手写板")];
    [self.view addSubview:titleView];
    titleView.goback = ^(){
        [self beBack];
    };
    
    
    MyBtnControl *sendBtn = [[MyBtnControl alloc] initWithFrame:CGRectMake(SCREENWIDTH-50, 20, 50, 44)];
    [titleView addSubview:sendBtn];
    [sendBtn addLabel:@"发送" color:[UIColor whiteColor] font:[UIFont fontWithName:textDefaultBoldFont size:12]];
    sendBtn.clickBackBlock = ^(){
        [self sendTuya];
    };
    
    
    btnWidth = 0;
    btnHeight = 50;
   

    
    bodyView = [[UIView alloc] initWithFrame:CGRectMake(0, TITLE_HEIGHT, SCREENWIDTH, BODYHEIGHT-btnHeight)];
    [bodyView setBackgroundColor:[UIColor getColor:@"EFEEF4"]];
    [self.view addSubview:bodyView];

    
    
    
    if(!isTuya){
        btnWidth = SCREENWIDTH/3;
    }else{
        backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, bodyView.height)];
        [backgroundImageView setBackgroundColor:[UIColor whiteColor]];
        [backgroundImageView setContentMode:UIViewContentModeScaleAspectFit];
        [bodyView addSubview:backgroundImageView];
        
        btnWidth = SCREENWIDTH/4;
    }
    
    
    
    tuyaView = [[TuyaView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, bodyView.height)];
    [tuyaView setBackgroundColor:[UIColor whiteColor]];
    [bodyView addSubview:tuyaView];
    tuyaView.isWrite = !isTuya;
    
    if(!isTuya){
        [tuyaView setBold:1.0f];
    }else{
        [tuyaView setBold:3.0f];
    }
    
    [tuyaView setColor:@"000000"];//画笔颜色
    
    UIView *menuview = [[UIView alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT-btnHeight, SCREENWIDTH, btnHeight)];
     [menuview setBackgroundColor:MAINGRAY];
    [self.view addSubview:menuview];
    
    if(isTuya){
        [menuview addSubview:[self getMenuBtn:0 icon:[UIImage imageNamed:@"openPic.png"] name:@"打开"]];
    }else{
        //画线
        gegeHeight = SCREENWIDTH/6;
        int LineCounts = tuyaView.height/gegeHeight;
        
        for(int i=0;i<LineCounts+1;i++){
            [tuyaView addSubview:[APPUtils get_line:0 y:gegeHeight*i width:SCREENWIDTH]];
        }
    }

    [menuview addSubview:[self getMenuBtn:SCREENWIDTH-btnWidth*3 icon:[UIImage imageNamed:@"rabbish.png"] name:@"清空"]];
    [menuview addSubview:[self getMenuBtn:SCREENWIDTH-btnWidth*2 icon:[UIImage imageNamed:@"pen.png"] name:@"画笔"]];
    [menuview addSubview:[self getMenuBtn:SCREENWIDTH-btnWidth icon:[UIImage imageNamed:@"revoke.png"] name:@"撤销"]];
    [menuview addSubview:[APPUtils get_line:0 y:0 width:SCREENWIDTH]];
    
    
}


-(MyBtnControl*)getMenuBtn:(float)x icon:(UIImage*)icon name:(NSString*)name{

    MyBtnControl *btn = [[MyBtnControl alloc] initWithFrame:CGRectMake(x, 0, btnWidth, btnHeight)];
    [self.view addSubview:btn];
    
    [btn addImage:icon frame:CGRectMake((btnWidth-25)/2, (btnHeight-25)/2, 25, 25)];
    btn.clickBackBlock = ^(){
    
        if([name isEqualToString:@"打开"]){
        
            if(makeAvatar == nil){
                makeAvatar = [[MakeAvatarTool alloc]init];
                makeAvatar.not_avatar = YES;
                [self getPic];
            }
            
            CCActionSheet *actionSheet = [[CCActionSheet alloc] initWithTitle:@"请选择:"clickedAtIndex:^(NSInteger index) {
                
                if(index == 0){
                   
                    [makeAvatar takePhoto];
                    
                }else if(index == 1){
                   
                    [makeAvatar openAlbum];
                    
                }else if(index ==2){
                    
                    SelectEndViewController *secondView = [[SelectEndViewController alloc] initWithSendPostion:MAINCOLOR];
                    secondView.delegate = self;
                    secondView.getSnap = YES;
                    [self.navigationController pushViewController:secondView animated:YES];
                    secondView = nil;
                    
                    
                }else if(index ==3){
                    if(hasBackPic){
                        hasBackPic = NO;
                        [tuyaView setBackgroundColor:[UIColor whiteColor]];
                        [backgroundImageView setImage:nil];
                    }
                  
                }
                
            } cancelButtonTitle:@"取消" otherButtonTitles:@"拍照", @"从相册中选取",@"地图涂鸦",@"移除背景图片",nil];
            
            
            if(!hasBackPic){
                [actionSheet.otherButtons removeObjectAtIndex:3];
                actionSheet.maxCount--;
            }
            
            [actionSheet show];
            actionSheet = nil;
        
            
        }else if([name isEqualToString:@"清空"]){
        
            CCActionSheet *actionSheet = [[CCActionSheet alloc] initWithTitle:@"您确定要清空画布吗?" clickedAtIndex:^(NSInteger index) {
                
                if(index == 0){
                    [tuyaView tapClean];
                    hasBackPic = NO;
                }
          
            } cancelButtonTitle:@"取消" otherButtonTitles:@"确定清空",nil];
            
            [actionSheet show];
            actionSheet = nil;
            
        }else if([name isEqualToString:@"画笔"]){
        
            [self openBoard];
            
        }else if([name isEqualToString:@"撤销"]){
            
            [tuyaView last];
            
        }
    };
    
    return btn;
}


//打开画板
-(void)openBoard{
    
    if(chooseColorView == nil){
        chooseBackControl = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        [chooseBackControl setBackgroundColor:[UIColor whiteColor]];
        chooseBackControl.alpha = 0;
        [chooseBackControl addTarget:self action:@selector(closeColorChoose) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:chooseBackControl];

        
        chooseColorView = [[UIView alloc] initWithFrame:CGRectMake((SCREENWIDTH-SCREENWIDTH*0.8)/2, 0, SCREENWIDTH*0.8, 0)];
        chooseColorView.alpha=0;
        [chooseColorView setBackgroundColor:[UIColor getColor:@"d3d3d3"]];
        chooseColorView.layer.cornerRadius = 4;
        [self.view addSubview:chooseColorView];
        
        
        float lastY = 0;
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, 150, 30)];
        lineLabel.text = @"线条粗细:";
        lineLabel.textAlignment = NSTextAlignmentLeft;
        lineLabel.textColor = TEXTGRAY;
        lineLabel.font = [UIFont systemFontOfSize:12];
        [chooseColorView addSubview:lineLabel];
        lastY+=lineLabel.height;
        
        CGFloat pointWidth = 45;//点宽
        
        slide = [[UISlider alloc]initWithFrame:CGRectMake(pointWidth , lastY, chooseColorView.width-pointWidth*2, 30)];
        slide.minimumValue = 1;
        slide.maximumValue = 5;
        slide.value = 3;
        [slide setMinimumTrackTintColor:[UIColor blackColor]];
        [slide addTarget:self action:@selector(sliderV:) forControlEvents:UIControlEventValueChanged];
        [chooseColorView addSubview:slide];
        
        i1 = [[UIView alloc] initWithFrame:CGRectMake((pointWidth-pointWidth*0.25)/2,lastY+(slide.height-pointWidth*0.25)/2,pointWidth*0.25,pointWidth*0.25)];
        [i1.layer setCornerRadius:(i1.height/2)];
        [i1.layer setMasksToBounds:YES];
        [i1 setBackgroundColor:[UIColor blackColor]];
        [chooseColorView addSubview:i1];
        
        i2 = [[UIView alloc] initWithFrame:CGRectMake(chooseColorView.width-(pointWidth-pointWidth*0.5)/2-pointWidth*0.5,lastY+(slide.height-pointWidth*0.5)/2,pointWidth*0.5,pointWidth*0.5)];
        [i2.layer setCornerRadius:(i2.height/2)];
        [i2.layer setMasksToBounds:YES];
        [i2 setBackgroundColor:[UIColor blackColor]];
        [chooseColorView addSubview:i2];
        
        lastY+=slide.height;
        
        UILabel *colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, lastY, 150, 30)];
        colorLabel.text = @"选择颜色:";
        colorLabel.textAlignment = NSTextAlignmentLeft;
        colorLabel.textColor = TEXTGRAY;
        colorLabel.font = [UIFont systemFontOfSize:12];
        [chooseColorView addSubview:colorLabel];
        
        lastY+=colorLabel.height;
        
        UIView *colors = [[UIView alloc] initWithFrame:CGRectMake(0, lastY, chooseColorView.width, chooseColorView.width/5*4)];
        [chooseColorView addSubview:colors];
        lastY+=colors.height;
        
        chooseColorView.height = lastY;
        chooseColorView.y = (SCREENHEIGHT-lastY)/2;
        
        
        [self addColorBtns:colors];

    }
    
    [UIView animateWithDuration:0.2 animations:^{
        chooseBackControl.alpha=0.2;
        chooseColorView.alpha=1;
    }];
}


-(void)addColorBtns:(UIView*)colorsView{


    NSMutableArray *colorBtnArray = [[NSMutableArray alloc] init];
    NSArray *colorArray = [[NSArray alloc] initWithObjects:@"000000",@"DC143C",@"EE1289",@"DA70D6",@"FF8C00",@"FFA500",@"FFD700",@"FFFF00",@"3CB371",@"00FF7F",@"7CFC00",@"40E0D0",@"00FFFF",@"00BFFF",@"1E90FF",@"000080",@"8A2BE2",@"7B68EE",@"E6E6FA",@"808080", nil];
    

    float colorWidth = chooseColorView.width/5;
    CGFloat xx = 0;
    CGFloat yy = 0;
    
    for(int i=0;i<[colorArray count];i++){
      
        MyBtnControl *colorView = [[MyBtnControl alloc] initWithFrame:CGRectMake(xx*colorWidth,yy*colorWidth, colorWidth, colorWidth)];
        [colorsView addSubview:colorView];
        
        [colorView addImage:nil frame:CGRectMake((colorWidth-colorWidth*0.8)/2, (colorWidth-colorWidth*0.8)/2, colorWidth*0.8, colorWidth*0.8)];
        [colorView.shareImage setBackgroundColor:[UIColor getColor:[colorArray objectAtIndex:i]]];
        [colorView.shareImage.layer setCornerRadius:(colorView.shareImage.height/2)];
        [colorView.shareImage.layer setMasksToBounds:YES];
        
        colorView.clickBackBlock = ^(){
          
            NSInteger index = 0;
            for(MyBtnControl*c in colorBtnArray){
                if(c == colorView){
                
                    c.shareImage.layer.borderColor = [[UIColor whiteColor] CGColor];
                    c.shareImage.layer.borderWidth = 2.0f;
                    
                    UIColor *cc = [UIColor getColor:[colorArray objectAtIndex:index]];
                    [i1 setBackgroundColor:cc];
                    [i2 setBackgroundColor:cc];
                    [slide setMinimumTrackTintColor:cc];
                    [tuyaView setColor:[colorArray objectAtIndex:index]];
                    cc = nil;
                }else{
                
                    c.shareImage.layer.borderColor = [[UIColor clearColor] CGColor];
                    c.shareImage.layer.borderWidth = 0;
                    
                }
                index++;
            }
        };
        
        
        [colorBtnArray addObject:colorView];
    
        colorView = nil;
        
        if(xx>=4){
            xx=0;
            yy++;
        }else{
            xx++;
        }
    }
}

-(void)sliderV:(UISlider *)s{
    [tuyaView setBold:s.value];
}


-(void)closeColorChoose{
    
    [UIView animateWithDuration:0.2 animations:^{
        chooseBackControl.alpha=0;
        chooseColorView.alpha=0;
    }];
}







-(void)getPic{

    makeAvatar.callBackBlock = ^(UIImage *avatar_img){
        
        if(avatar_img!=nil){
            
            [tuyaView setBackgroundColor:[UIColor clearColor]];
            [backgroundImageView setImage:avatar_img];
            hasBackPic = YES;
        }
    };
    
}



//位置获取回调
-(void)passValue:(NSMutableDictionary *)dic
{
    
    [APPUtils setMethod:@"SendMsgViewController -> passValue"];
    
    @try {
        
        NSString *passType = [dic objectForKey:@"type"];
        if(passType!= nil && passType.length>0){
            
            if([passType isEqualToString:@"location_ok"]){//截图
                
                UIImage *snapImage = [dic objectForKey:@"snap"];
                if(snapImage!=nil){
                    
                    [tuyaView setBackgroundColor:[UIColor clearColor]];
                    
                    [backgroundImageView setImage:snapImage];
                    
                    snapImage = nil;
                    
                    hasBackPic = YES;
                }
            }
        }
        
        passType = nil;
        
    } @catch (NSException *exception) {
        
    }
    
}


-(void)sendTuya{
    
    CGSize size = CGSizeMake(SCREENWIDTH, bodyView.height);
    
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snapImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
  
    
    UIImage *sendImage;
    
    
    BOOL isPlus = ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242,2208), [[UIScreen mainScreen] currentMode].size) : NO);
    //iphone6 plus 截图偏小
    
    if(!isTuya){
        long totalLines = [tuyaView getTotalLines];
        CGRect rect;
        if(isPlus){
            rect = CGRectMake(0, 128*1.5, SCREENWIDTH*3,gegeHeight*totalLines*3);
        }else{
            rect = CGRectMake(0, 128, SCREENWIDTH*2,gegeHeight*totalLines*2);//创建矩形框 长宽都是两倍。。。
        }
    
        sendImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([snapImage CGImage], rect)];
        
    }else{
        CGRect rect;
        
        if(isPlus){
            rect = CGRectMake(0, 128*1.5, SCREENWIDTH*3,SCREENHEIGHT*3);
        }else{
            rect = CGRectMake(0, 128, SCREENWIDTH*2,SCREENHEIGHT*2);//创建矩形框 长宽都是两倍。。。
        }
        sendImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([snapImage CGImage], rect)];
    }
   
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:sendImage,@"img",(isTuya?@"1":@"0"),@"tuya",@"tuya",@"type" ,nil];

    [self.delegate passValue:dic];
    dic = nil;
   [self beBack];

}

- (void)beBack{
    
     [tuyaView closeTimer];
    //退回到第一个窗口
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
