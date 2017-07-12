//
//  NoticesView.m
//  zpp
//
//  Created by Chuck on 2017/5/4.
//  Copyright © 2017年 myncic.com. All rights reserved.
//

#import "NoticesView.h"
#import "MainViewController.h"
@implementation NoticesView
@synthesize noticesArray;


- (id)initWithColor:(UIColor*)underColor wordColor:(UIColor*)wordColor laba:(UIImage*)laba clear:(UIImage*)clear{
    self = [super init];
    if (self) {
        [self setBackgroundColor:underColor];
        wColor = wordColor;
        labaImg = laba;
        clearImg = clear;
        [self setFrame:CGRectMake(0, TITLE_HEIGHT, SCREENWIDTH, 40)];
        self_w = self.width;
        self_h = self.height;
        self.alpha=0;
    }
    return self;
}



-(void)getNotice{
    
    AFN_util *afn = [[AFN_util alloc] initWithAfnTag:@"getNotice"];
    
    afn.afnResult = ^(NSString *afn_tag,NSString*resultString){
        if([afn_tag isEqualToString:@"getNotice"]){
            @try {
                
                if(self.alpha==0){
                    noticesArray = [[NSMutableArray alloc] init];
                    
                    
                    NSMutableArray *usersArray = [APPUtils getArrByJson:resultString ];
                    for(int i=0;i<[usersArray count];i++){
                        NSDictionary*noticeDic = [usersArray objectAtIndex:i];
                        [noticesArray addObject:noticeDic];
                        noticeDic = nil;
                    }
                    
                    
                    if(noticesArray!=nil&&[noticesArray count]>0){
                        [self showNoticeView];
                    }
                    
                    
                    usersArray = nil;
                    
                }
                
            } @catch (NSException *exception) {
                
            }
        }
    };
    [afn getNotice];
    afn = nil;
}


-(void)showNoticeView{
    
    if([MainViewController sharedMain].netState == 1 && self.alpha==0){
        
        if(noticeScrollView == nil){
        
            
            UIImageView *noticeimg = [[UIImageView alloc] initWithFrame:CGRectMake(10, (self_h-22)/2, 22, 22)];
            [noticeimg setImage:labaImg];
            [self addSubview:noticeimg];
            
            
            noticeScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(noticeimg.width+noticeimg.x*2, 0, self_w-(noticeimg.width+noticeimg.x*2+38), self_h)];
            [noticeScrollView setPagingEnabled:NO];
            [noticeScrollView setShowsHorizontalScrollIndicator:NO];
            [noticeScrollView setShowsVerticalScrollIndicator:NO];
            [noticeScrollView setScrollEnabled:NO];
            [noticeScrollView.layer setMasksToBounds:YES];
            [self addSubview:noticeScrollView];
            
            noticeLabelWidth = noticeScrollView.width;
            
            
            
            UIImageView *hideNoticeImg = [[UIImageView alloc] initWithFrame:CGRectMake(self_w-28, (self_h-18)/2, 18, 18)];
            [hideNoticeImg setImage:clearImg];
            [self addSubview:hideNoticeImg];
            
            MyBtnControl *hideNoticeBtn = [[MyBtnControl alloc] initWithFrame:CGRectMake(self_w-50, 0, 50, self_h)];
            hideNoticeBtn.clickBackBlock = ^(){
                [self hideNotice];
            };
            [self addSubview:hideNoticeBtn];
            hideNoticeBtn.shareImage=hideNoticeImg;
            
            hideNoticeBtn = nil;
            hideNoticeImg = nil;
            
        }
        
        
        
        NSInteger contentCount = 0;
        noticesLabelArray = [[NSMutableArray alloc] init];
        noticesLabelTempArray = [[NSMutableArray alloc] init];
        if([noticesArray count]>0){
            
            for(int i=0;i<[noticesArray count];i++){
                
                NSDictionary *noticeDic = [noticesArray objectAtIndex:i];
                NSString *showNotceString = [noticeDic objectForKey:@"content"];//只显示内容
                
                
                if(showNotceString!=nil&&showNotceString.length>0){
                    
                    UILabel *noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,contentCount*noticeScrollView.height,0,noticeScrollView.height)];
                    noticeLabel.textAlignment = NSTextAlignmentLeft;
                    noticeLabel.textColor = wColor;
                    noticeLabel.numberOfLines = 1;
                    noticeLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
                    [noticeScrollView addSubview:noticeLabel];
                    
                    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
                    paragraph.alignment = NSLineBreakByWordWrapping;
                    
                    NSDictionary *attribute = @{NSFontAttributeName: noticeLabel.font, NSParagraphStyleAttributeName: paragraph};
                    
                    CGSize noticeSize = [showNotceString boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
                    attribute = nil;
                    paragraph = nil;
                    
                    [noticeLabel setFrame:CGRectMake(0, noticeLabel.y, noticeSize.width, noticeLabel.height)];
                    noticeLabel.text = showNotceString;
                    
                    [noticesLabelArray addObject:noticeLabel];
                    [noticesLabelTempArray addObject:noticeLabel];
                    noticeLabel = nil;
                    
                    contentCount++;
                }
                noticeDic = nil;
                showNotceString = nil;
                
            }
            
            
            [noticeScrollView setContentSize:CGSizeMake(noticeLabelWidth, self_h*contentCount)];
            [noticeScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
            
          
            if(contentCount>0){
                
                [self changeNotice:@"1"];
                [self.superview bringSubviewToFront:self];
                [UIView animateWithDuration:0.2f animations:^{
                   self.alpha  = 0.9;
                }];
            
            }
            
        }
        
        
        
        
    }
}

-(void)changeNotice:(NSString*)first{
    
    if(noticesLabelArray==nil||[noticesLabelArray count]==0){
        
        [self hideNotice];
    }else{
        @try {
            
            UILabel *noticeLabel = [noticesLabelArray objectAtIndex:0];
            
            if([noticesLabelArray count]>0){
                [noticesLabelArray removeObjectAtIndex:0];
            }
            
            CGFloat scrollHeight = noticeScrollView.height;
            if([first integerValue]==1){//第一次不垂直滚动
                scrollHeight = 0;
            }
            
            
            [noticeScrollView setContentOffset:CGPointMake(0, scrollHeight+noticeScrollView.contentOffset.y) animated:YES];
            
            
            
            if(noticeLabel.width>noticeLabelWidth){//超出屏幕范围的
                
                CGFloat timePiece = noticeLabel.width/noticeLabelWidth;
                
                [UIView animateWithDuration:5.0f*timePiece delay:1.0
                                    options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState) animations:^(void) {
                                        [noticeLabel setFrame:CGRectMake(noticeLabelWidth-noticeLabel.width, noticeLabel.y, noticeLabel.width, noticeLabel.height)];
                                    }
                                 completion:^(BOOL finish){
                                     [self performSelector:@selector(changeNotice:) withObject:@"0" afterDelay:1.0];//停留时长
                                 }];
                
            }else{
                [self performSelector:@selector(changeNotice:) withObject:@"0" afterDelay:4.0];//显示时长
            }
            
            noticeLabel = nil;
            
        } @catch (NSException *exception) {
            @try {
                [noticesLabelArray removeObjectAtIndex:0];
            } @catch (NSException *exception) {
                [noticesLabelArray removeAllObjects];
            }
            [self changeNotice:@"0"];
        }
    }
}

-(void)hideNotice{
   
        
        [UIView animateWithDuration:0.2f delay:0
                            options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState) animations:^(void) {
                                self.alpha  = 0;
                                
                            }
                         completion:^(BOOL finished){
                             
                             //清理label
                             if(noticesLabelTempArray!=nil&&[noticesLabelTempArray count]>0){
                                 for(int i=0;i<[noticesLabelTempArray count];i++){
                                     
                                     @try {
                                         UILabel *tempLabel = [noticesLabelTempArray objectAtIndex:i];
                                         [tempLabel removeFromSuperview];
                                         tempLabel = nil;
                                     } @catch (NSException *exception) {
                                     }
                                     
                                 }
                                 
                                 [noticesLabelTempArray removeAllObjects];
                                 noticesLabelTempArray = nil;
                             }
                             
                             
                         }];
    
    
}

@end
