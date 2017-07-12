//
//  ActivityView.m
//  zpp
//
//  Created by Chuck on 2017/4/27.
//  Copyright © 2017年 myncic.com. All rights reserved.
//

#import "ActivityView.h"
#import "MainViewController.h"
@implementation ActivityView
@synthesize activityArray;



- (id)initActivity:(NSString*)url{
    self = [super init];
    if (self) {
        self.alpha=0;
        originalUrl = url;
        [self setFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        [[[UIApplication sharedApplication].delegate window] addSubview:self];
        
    }
    return self;
}

//展示新的活动
-(void)handleActivity:(NSString*)dataString{
    
    @try {
        activityArray = [[NSMutableArray alloc] init];
        
        
        NSMutableArray *dataArray = [APPUtils getArrByJson:dataString];
        
        for(int i=0;i<[dataArray count];i++){
            
            NSDictionary *activityDic = [dataArray objectAtIndex:i];
            Activity *cp = [[Activity alloc] init];
            cp.activity_id = [activityDic objectForKey:@"id"];
            cp.name = [activityDic objectForKey:@"name"];
            cp.icon = [activityDic objectForKey:@"icon"];
            cp.icon_s = [activityDic objectForKey:@"icon_s"];
            cp.activity_description = [activityDic objectForKey:@"description"];
            cp.endtime = [activityDic objectForKey:@"endtime"];
            cp.cost = [[activityDic objectForKey:@"cost"] integerValue];
            cp.image_size = [activityDic objectForKey:@"size"];
            
            [activityArray addObject:cp];
            cp = nil;
            activityDic = nil;
        }
        
        dataArray = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self makeActivityView];
            
            if([activityArray count]>0){
                [[MainViewController sharedMain] showGift];
            }else{
                [[MainViewController sharedMain] closeGift];
            }
        });
        
    
    } @catch (NSException *exception) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MainViewController sharedMain] closeGift];
        });
        
    }
    
    
}


//创建活动显示view
-(void)makeActivityView{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(activityViewArray != nil && [activityViewArray count]>0){
            for(int i=0;i<[activityViewArray count];i++){
                UIView *tempView = [activityViewArray objectAtIndex:i];
                [tempView removeFromSuperview];
                tempView = nil;
            }
            
            [activityViewArray removeAllObjects];
            activityViewArray = nil;
        }
        
        activityViewArray = [[NSMutableArray alloc] init];
        
        if(activityMainView == nil){
            
            activityMainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
            [self addSubview:activityMainView];
          
            
            activityScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
            [activityMainView addSubview:activityScrollView];
            activityScrollView.tag = 102;
            
            [activityScrollView setPagingEnabled:YES];
            [activityScrollView setBounces:NO];
            [activityScrollView setScrollEnabled:YES];
            [activityScrollView setDelegate:self];
            [activityScrollView setShowsHorizontalScrollIndicator:NO];
            [activityScrollView setShowsVerticalScrollIndicator:NO];
            
            activityPageControl = [[UIPageControl alloc] init];
            activityPageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
            activityPageControl.pageIndicatorTintColor = TEXTGRAY;
            activityPageControl.frame = CGRectMake(0, 0, 100, 44.0f);
            
            [activityMainView addSubview:activityPageControl];
            
            if(!ISIPHONE4){
                UIImageView *closeCouponX = [[UIImageView alloc] initWithFrame:CGRectMake((SCREENWIDTH-35)/2, activityMainView.height-45, 35, 35)];
                [closeCouponX setImage:[UIImage imageNamed:@"close_pocket.png"]];
                [activityMainView addSubview:closeCouponX];
                closeCouponX = nil;
            }
            
        }
        
        [activityScrollView setContentSize:CGSizeMake(SCREENWIDTH * [activityArray count], SCREENHEIGHT)];
        activityPageControl.numberOfPages = [activityArray count];
        
        CGFloat picY=0;
        for(int i=0;i<[activityArray count];i++){
            Activity *cp = [activityArray objectAtIndex:i];
            
            UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(SCREENWIDTH*i, 0, SCREENWIDTH, SCREENHEIGHT)];
            
            UIControl *backControl = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
            [backControl setBackgroundColor:[UIColor blackColor]];
            backControl.alpha=0.7;
            [activityView addSubview:backControl];
            
            [backControl addTarget:self action:@selector(closeNewActivity) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
            
            backControl = nil;
            
            NSArray * parts = [cp.image_size componentsSeparatedByString:@","];
            CGFloat bili = [[parts objectAtIndex:1] floatValue]/[[parts objectAtIndex:0] floatValue];
            parts = nil;
            
            UIImageView *couponImageView =[[UIImageView alloc] init];
            [couponImageView setFrame:CGRectMake((SCREENWIDTH-SCREENWIDTH*0.8)/2, (SCREENHEIGHT-SCREENWIDTH*0.8*bili)/2-15, SCREENWIDTH*0.8, SCREENWIDTH*0.8*bili)];
            [couponImageView sd_setImageWithURL:[NSURL URLWithString:cp.icon] placeholderImage:[UIImage imageNamed:@"gray_square.png"]];
            [couponImageView.layer setMasksToBounds:YES];//圆角不被盖住
            [couponImageView setClipsToBounds:YES];//减掉超出部分
            [couponImageView setUserInteractionEnabled:NO];
            [activityView addSubview:couponImageView];
            
            
            MyBtnControl*openAvtivityControl1 = [[MyBtnControl alloc] initWithFrame:couponImageView.frame];
            openAvtivityControl1.shareImage = couponImageView;
            [activityView addSubview:openAvtivityControl1];
            openAvtivityControl1.clickBackBlock = ^(){
                [self closeNewActivity];
                [self open_activity:cp];
            };
            
            openAvtivityControl1 = nil;
            
            picY = couponImageView.y;
            
            
            
            
            UIView *getView = [[UIView alloc] initWithFrame:CGRectMake((activityView.width-couponImageView.width)/2, couponImageView.y+couponImageView.height+10, couponImageView.width, 40)];
            
            [activityView addSubview:getView];
            
            
            MyBtnControl*openAvtivityControl = [[MyBtnControl alloc] initWithFrame:getView.frame];
            [openAvtivityControl setBackgroundColor:MAINCOLOR];
            openAvtivityControl.layer.cornerRadius = openAvtivityControl.height/2;
            [openAvtivityControl.layer setMasksToBounds:YES];
            [activityView addSubview:openAvtivityControl];
            openAvtivityControl.clickBackBlock = ^(){
                [self closeNewActivity];
                [self open_activity:cp];
            };
            
            
            getView = nil;
            
            [openAvtivityControl addLabel:@"查看详情" color:[UIColor whiteColor] font:[UIFont fontWithName:textDefaultFont size:14]];
            
        
            openAvtivityControl = nil;
            
            
            couponImageView = nil;
            [activityScrollView addSubview:activityView];
            [activityViewArray addObject: activityView];
            activityView = nil;
            cp = nil;
            
        }
        
        if([activityViewArray count]==0){
            [[MainViewController sharedMain] closeGift];
        }
        
        activityPageControl.center = CGPointMake(activityScrollView.width / 2, picY-15);
        
        
    });
}

//显示活动view
-(void)showNewActivity{
    
    [[MainViewController sharedMain].makeOrderPage textClose];
  
    
    [[[UIApplication sharedApplication].delegate window] bringSubviewToFront:self];
    
    [UIView animateWithDuration:0.2f animations:^{
        self.alpha=1;
    }];
    
 
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if(scrollView.tag == 102){//优惠券滑动
        
        int index = fabs(scrollView.contentOffset.x) / scrollView.width;
        activityPageControl.currentPage = index;
    }
}

//关闭活动view
-(void)closeNewActivity{
    [UIView animateWithDuration:0.2f delay:0
                        options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState) animations:^(void) {
                            
                            self.alpha=0;
                        }
                     completion:^(BOOL finished){
                         BOOL changed = NO;
                         
                         
                         for(int i=0;i<[activityArray count];i++){
                             Activity *cp = [activityArray objectAtIndex:i];
                             
                             if(cp.getted){
                                 changed = YES;
                             }
                             cp = nil;
                         }
                         
                         if(changed){
                             
                             [self makeActivityView];
                             
                         }
                     }];
}




//查看活动详情
-(void)open_activity:(Activity*)cp{
    
        WebViewController *webview = [[WebViewController alloc] initWithtitle:cp.name url:[NSString stringWithFormat:@"%@%@",originalUrl,cp.activity_id]];
    
        if(cp.cost>0){//代金券类型
            webview.couponType=YES;
        }else{//软文类型
            webview.share_type = YES;
            webview.shareContents = cp.activity_description;
            webview.shareIcon = cp.icon_s;
        }
        [[MainViewController sharedMain].navigationController pushViewController:webview animated:YES];
        webview = nil;

}



//清理数据
-(void)clearData{
    if(activityArray!= nil){
        [activityArray removeAllObjects];
    }
    if(activityViewArray != nil && [activityViewArray count]>0){
        for(int i=0;i<[activityViewArray count];i++){
            UIView *tempView = [activityViewArray objectAtIndex:i];
            [tempView removeFromSuperview];
            tempView = nil;
        }
        
        [activityViewArray removeAllObjects];
        activityViewArray = nil;
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end


@implementation Activity
@end
