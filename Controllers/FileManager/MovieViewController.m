//
//  MovieViewController.m
//  PartyConstructionSystem
//
//  Created by 李狗蛋 on 15/10/8.
//  Copyright © 2015年 李狗蛋. All rights reserved.
//

#import "MovieViewController.h"
#import "MainViewController.h"

@interface MovieViewController ()

@end

@implementation MovieViewController


- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(id)initWithtitle:(NSString*)title url:(NSString*)url online:(BOOL)online{
    self = [super init];
    if (self) {
        // Custom initialization
        
        moviePath = url;
        movieTitle = title;
        on_line = online;
    }
    return self;
}

-(id)initWithAsset:(ALAsset*)alAsset title:(NSString*)title{
    self = [super init];
    if (self) {
        // Custom initialization
        
        asset = alAsset;
        movieTitle = title;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    


    [self initController];
  
}

-(void)initController{
    
  
    
     __weak typeof(self) weakSelf = self;
    
    titletView = [[ZppTitleView alloc] initWithTitle:movieTitle];
    [self.view addSubview:titletView];
    titletView.goback = ^(){
        [weakSelf beBack];
    };
    
    
    //判断音频模式
    @try {
        NSArray * parts = [movieTitle componentsSeparatedByString:@"."];
        NSString *tail = [parts lastObject];//后缀
        parts = nil;
        if([[APPUtils get_file_type:tail] isEqualToString:@"audio"]){
            audioType = YES;
            [self.view setBackgroundColor:MAINGRAY];
            
            UIImageView *music = [[UIImageView alloc] initWithFrame:CGRectMake((SCREENWIDTH-40)/2, (BODYHEIGHT-40)/2, 40, 40)];
            [music setImage:[UIImage imageNamed:@"music.png"]];
            [self.view addSubview:music];
            music = nil;
            
        }else{
            [self.view setBackgroundColor:[UIColor blackColor]];
        }
    } @catch (NSException *exception) {}
    
    

    AVPlayerItem *item;
    if(!on_line && asset!=nil){//播放相册视频
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:[representation url] options:nil];
        representation = nil;
        item = [AVPlayerItem playerItemWithAsset:movieAsset];
        
    }else{//沙盒视频
        
        if(on_line){
            item = [[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:moviePath]];//网络视频
        }else{
            item = [[AVPlayerItem alloc]initWithURL:[NSURL fileURLWithPath:moviePath]];//沙盒视频
        }
    }

    //创建播放器
    player = [AVPlayer playerWithPlayerItem:item];
    player.externalPlaybackVideoGravity = AVLayerVideoGravityResizeAspectFill;
    //这个属性和图片填充试图的属性类似，也可以设置为自适应试图大小。
    
    //创建视频显示的图层
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:player];
    layer.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
    // 显示播放视频的视图层要添加到self.view的视图层上面
    [self.view.layer addSublayer:layer];
    
   
    
    
    MyBtnControl *controlUnder = [[MyBtnControl alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    [self.view addSubview:controlUnder];
    controlUnder.not_highlight=YES;
    controlUnder.clickBackBlock = ^(){
    
        [weakSelf hideController];

    };
    
    [self.view bringSubviewToFront:titletView];
    
    UIBlurEffect *blurEffect;
    if(audioType){
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    }else{
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    }
    
    controlmenu = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [controlmenu setFrame:CGRectMake(0, controlUnder.height-80, SCREENWIDTH, 80)];
    [controlUnder addSubview:controlmenu];
    
    //播放进度
    progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(50, controlmenu.height-40, SCREENWIDTH-100, 40)];
    progressSlider.value = 0;// 设置初始值
    [progressSlider setEnabled:NO];
    progressSlider.continuous = NO;//滑动中也能执行
    progressSlider.minimumTrackTintColor = MAINCOLOR; //滑轮左边颜色
    progressSlider.maximumTrackTintColor = [UIColor whiteColor]; //滑轮右边颜色
    progressSlider.thumbTintColor = [UIColor whiteColor];//设置了滑轮的颜色，
    [progressSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];// 针对值变化添加响应方法
    [controlmenu addSubview:progressSlider];
    
    //当前时间
    nowLabel  = [[UILabel alloc] initWithFrame:CGRectMake(0, progressSlider.y, 45, progressSlider.height)] ;
    nowLabel.font=[UIFont fontWithName:textDefaultFont size: 10];
    nowLabel.textAlignment = NSTextAlignmentRight;
    nowLabel.text = @"00:00";
    nowLabel.textColor = [UIColor whiteColor];
    [controlmenu addSubview:nowLabel];
    
    
    //总时长
    totalLabel  = [[UILabel alloc] initWithFrame:CGRectMake(progressSlider.width+progressSlider.x+5, progressSlider.y, 45, progressSlider.height)] ;
    totalLabel.font=[UIFont fontWithName:textDefaultFont size: 10];
    totalLabel.textAlignment = NSTextAlignmentLeft;
    totalLabel.textColor = [UIColor whiteColor];
    [controlmenu addSubview:totalLabel];
    
    
    pauseControl = [[MyBtnControl alloc] initWithFrame:CGRectMake((SCREENWIDTH-80)/2, 5, 80, 40)];
    [controlmenu addSubview:pauseControl];
    pauseControl.clickBackBlock = ^(){
       
        [weakSelf pauseVideo];
    };
    
    [pauseControl addImage:[UIImage imageNamed:@"video_play.png"] frame:CGRectMake((pauseControl.width-25)/2, (pauseControl.height-25)/2, 25, 25)];


    //    采取kvo的形式获取视频总时长
    //    通过监视status判断是否准备好
    
    // 播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:item];

    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];

}

//监听
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    AVPlayerItem *item = (AVPlayerItem *)object;
    
    if ([keyPath isEqualToString:@"status"]) {
        
        hasOpened = YES;
        
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue]; // 获取更改后的状态
        if (status == AVPlayerStatusReadyToPlay) {
            CMTime duration = item.duration; // 获取视频长度
         
            sumPlayOperation = CMTimeGetSeconds(duration);//总时长
            totalLabel.text = [APPUtils unixSecond2Time:sumPlayOperation];
            progressSlider.value = 0;// 设置初始值
            progressSlider.minimumValue = 0;// 设置最小值
            progressSlider.maximumValue = CMTimeGetSeconds(duration);// 设置最大值
            nowTime = 0;
            
            dataPrepareOk = YES;
            [progressSlider setEnabled:YES];
            // 播放
            [self performSelector:@selector(play) withObject:nil afterDelay:0.5];
            
        } else if (status == AVPlayerStatusFailed) {
            NSLog(@"AVPlayerStatusFailed");
        } else {
            NSLog(@"AVPlayerStatusUnknown");
        }
        
    }
}

//播放
-(void)play{
    
    [self stopTimer];
    [pauseControl.shareImage setImage:[UIImage imageNamed:@"video_pause.png"]];
    [player play];
    playing = YES;
    controlShow = YES;
    [self performSelector:@selector(hideController) withObject:nil afterDelay:3.0];
    
    if(sumPlayOperation>0){
        playTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
    }
}

//检测
-(void)timerFired{
    if(nowTime>=sumPlayOperation){
        [self stopTimer];
        return;
    }
    nowTime++;
    progressSlider.value = nowTime;
    nowLabel.text = [APPUtils unixSecond2Time:nowTime];
}

//手动更改进度
- (void)sliderValueChanged:(UISlider*)slider {
    
    [self stopTimer];
    
    nowTime = slider.value;
    nowLabel.text = [APPUtils unixSecond2Time:nowTime];
    if(nowTime<sumPlayOperation){
        [player seekToTime:CMTimeMakeWithSeconds(nowTime, player.currentItem.duration.timescale) completionHandler:^(BOOL finished) {
            [self play];
        }];
    }
    
}

//暂停
-(void)pauseVideo{
    
    if(!dataPrepareOk){
        return;
    }
    
    if(playing){
        [self stopTimer];
        [player pause];
    }else{
        if(nowTime>=sumPlayOperation){//重新播放
            nowTime = 0;
            progressSlider.value = nowTime;
            nowLabel.text = [APPUtils unixSecond2Time:nowTime];
        }
        [player seekToTime:CMTimeMakeWithSeconds(nowTime, player.currentItem.duration.timescale) completionHandler:^(BOOL finished) {
            [self play];
        }];
    }
}

//播放完成
- (void)playbackFinished:(NSNotification *)notification {
    [self stopTimer];
    nowLabel.text = [APPUtils unixSecond2Time:sumPlayOperation];
    progressSlider.value = sumPlayOperation;
    controlShow = NO;
    [self hideController];
}


//停止
-(void)stopTimer{
    playing = NO;
    [pauseControl.shareImage setImage:[UIImage imageNamed:@"video_play.png"]];
    if(playTimer!=nil){
        [playTimer invalidate];
        playTimer = nil;
    }
}


-(void)hideController{
    if(audioType){
        return;
    }
    if(!dataPrepareOk){
        return;
    }
    if(controlShow){
        [UIView animateWithDuration:0.2f delay:0
                            options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState) animations:^(void) {
                                
                                [titletView setFrame:CGRectMake(0, -TITLE_HEIGHT, SCREENWIDTH, TITLE_HEIGHT)];
                                [controlmenu setFrame:CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, controlmenu.height)];
                            }
                         completion:^(BOOL finished){
                             controlShow = NO;
                         }];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            
            [UIView animateWithDuration:0.2f delay:0
                                options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState) animations:^(void) {
                                    [titletView setFrame:CGRectMake(0, 0, SCREENWIDTH, TITLE_HEIGHT)];
                                    [controlmenu setFrame:CGRectMake(0, SCREENHEIGHT-controlmenu.height, SCREENWIDTH, controlmenu.height)];
                                }
                             completion:^(BOOL finished){
                                 controlShow = YES;
                             }];
            
        }];
    }
}

-(void)beBack{
    if(!hasOpened){
        return;
    }
 
    [self stopTimer];
    [player pause];
    [player setRate:0];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [player.currentItem removeObserver:self forKeyPath:@"status" context:nil];
    [player replaceCurrentItemWithPlayerItem:nil];
    player = nil;
    
    [self.navigationController popViewControllerAnimated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
