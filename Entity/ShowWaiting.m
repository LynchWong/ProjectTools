//
//  ShowResult.m
//  zpp
//
//  Created by Chuck on 2017/5/4.
//  Copyright © 2017年 myncic.com. All rights reserved.
//

#import "ShowWaiting.h"
#import "MainViewController.h"


@implementation ShowWaiting

+(void)showWaiting:(NSString*)show{
    

    if(showWaiting == nil){
        showWaiting = [[ShowWaiting alloc] init];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIApplication sharedApplication].delegate window] bringSubviewToFront:showWaiting];
        showWaiting.showLabel.text = show;
        [UIView animateWithDuration:0.2f delay:0
                            options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState) animations:^(void) {
                                
                                showWaiting.alpha  = 1;
                                
                            }
                         completion:NULL];
    });
    
}


- (instancetype)init{
    
    if (self == [super init]) {
        [[[UIApplication sharedApplication].delegate window] addSubview:self];
        [self setFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        self.alpha=0;
        
        
        UIView *waitingUnder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        [waitingUnder setBackgroundColor:[UIColor whiteColor]];
        waitingUnder.alpha=0.1;
        [self addSubview:waitingUnder];
        
        
        float waitingWidth = 150;
        UIVisualEffectView *waitingView= [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        [waitingView setFrame:CGRectMake((SCREENWIDTH-waitingWidth)/2, (SCREENHEIGHT-waitingWidth*0.618)/2, waitingWidth, waitingWidth*0.618)];
        [waitingView.layer setCornerRadius:4];
        [waitingView.layer setMasksToBounds:YES];//圆角不被盖住
        [waitingView setClipsToBounds:YES];//减掉超出部分
        
        [self addSubview:waitingView];
        
        
        UIImageView *waitingImageview = [[UIImageView alloc] initWithFrame:CGRectMake((waitingWidth-50)/2, 10, 50, 50)];
        [waitingImageview setImage:[UIImage imageNamed:@"waiting.png"]];
        [waitingView addSubview:waitingImageview];
        
        CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
        rotationAnimation.duration =1.2;
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = CGFLOAT_MAX;
        rotationAnimation.removedOnCompletion = NO;//必须加 不然到其他页面后会停止
        [waitingImageview.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
        rotationAnimation = nil;

        
        _showLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, waitingView.frame.size.height-30, waitingView.frame.size.width, 20)];
        _showLabel.textAlignment = NSTextAlignmentCenter;
        _showLabel.textColor = [UIColor whiteColor];
        _showLabel.numberOfLines=1;
        _showLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
        [waitingView addSubview:_showLabel];
        
        
        //进度
        _progressLabel = [[UILabel alloc] initWithFrame:waitingImageview.frame];
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        _progressLabel.textColor = [UIColor whiteColor];
        _progressLabel.numberOfLines=1;
        _progressLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:10];
        [waitingView addSubview:_progressLabel];
        _progressLabel.alpha=0;
        
        
        _cancelView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        [_cancelView setFrame:CGRectMake(waitingView.frame.origin.x, waitingView.frame.size.height+waitingView.frame.origin.y, waitingWidth, 30)];
        [_cancelView.layer setCornerRadius:4];
        [_cancelView.layer setMasksToBounds:YES];//圆角不被盖住
        [_cancelView setClipsToBounds:YES];//减掉超出部分
        _cancelView.alpha=0;
        [self addSubview:_cancelView];
        
        [_cancelView addSubview:[APPUtils get_line:0 y:0 width:_cancelView.frame.size.width]];
        
        MyBtnControl *cancelBtn = [[MyBtnControl alloc] initWithFrame:CGRectMake(0, 0, _cancelView.frame.size.width, _cancelView.frame.size.height)];
        [cancelBtn addLabel:@"取消" color:[UIColor whiteColor] font:[UIFont fontWithName:@"HelveticaNeue" size:12]];
        [_cancelView addSubview:cancelBtn];
        cancelBtn.clickBackBlock = ^(){
            @try {
                if(showWaiting.now_task!=nil){
                    [AFN_util set_handCancel:YES];
                    [showWaiting.now_task cancel];
                    showWaiting.now_task = nil;
                   
                }
                
                if(showWaiting.now_afn!=nil){
                    [showWaiting.now_afn cancelAll];
                    showWaiting.now_afn = nil;
                    
                }
            } @catch (NSException *exception) {}
        };
        
        waitingImageview = nil;
    }
    
    return self;
}


//设置进度
+(void)setProgress:(NSString*)progress{
    dispatch_async(dispatch_get_main_queue(), ^{
        showWaiting.progressLabel.text = progress;
        showWaiting.progressLabel.alpha=1;
    });
}


//显示取消
+(void)addCancel:(NSURLSessionDownloadTask*)task afn:(AFN_util*)afn{
    dispatch_async(dispatch_get_main_queue(), ^{
        showWaiting.now_task = task;
        showWaiting.now_afn = afn;
        showWaiting.cancelView.alpha=1;
    });
}

+(void)hideWaiting{
    if(showWaiting.alpha>0){
    
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.35f delay:0
                                options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState) animations:^(void) {
                                    showWaiting.alpha  = 0;
                                    showWaiting.progressLabel.alpha=0;
                                    showWaiting.cancelView.alpha=0;
                                    if(showWaiting.now_task!=nil){
                                        showWaiting.now_task = nil;
                                    }
                                    if(showWaiting.now_afn!=nil){
                                        showWaiting.now_afn = nil;
                                    }
                                }
                             completion:NULL];
        });
       
    }
    
}


@end
