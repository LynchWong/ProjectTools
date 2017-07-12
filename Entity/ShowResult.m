//
//  ShowResult.m
//  zpp
//
//  Created by Chuck on 2017/5/4.
//  Copyright © 2017年 myncic.com. All rights reserved.
//

#import "ShowResult.h"
#import "MainViewController.h"


@implementation ShowResult

+(void)showResult:(NSString*)show succeed:(BOOL)succeed{
    
    if(!resultShowing){
        resultShowing = YES;
        
        if(showresult == nil){
            showresult = [[ShowResult alloc] init];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(succeed){
                [paySImageView setImage:[UIImage imageNamed:@"share_success.png"]];
            }else{
                [paySImageView setImage:[UIImage imageNamed:@"share_fail.png"]];
            }
            pay_result_Label.text = show;
            
            [UIView animateWithDuration:0.35f delay:0
                                options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState) animations:^(void) {
                                    showresult.alpha  = 0.8;
                                }
                             completion:^(BOOL finished){
                                 [self performSelector:@selector(closePayResult) withObject:nil afterDelay:1.5f];
                             }];
        });
        
        
        
    }
    
    
}

- (instancetype)init{
    
    if (self == [super init]) {
        
        [[[UIApplication sharedApplication].delegate window] addSubview:self];
        [self setFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        self.alpha=0;
        
        CGFloat shareSWidth = 100;
        CGFloat shareS_MWidth = shareSWidth*0.5;
        UIView *payResultView = [[UIView alloc] initWithFrame:CGRectMake((SCREENWIDTH-shareSWidth)/2, (SCREENHEIGHT-shareSWidth)/2, shareSWidth, shareSWidth)];
        payResultView.layer.cornerRadius=5;
        [payResultView.layer setMasksToBounds:YES];
        [payResultView setBackgroundColor:[UIColor blackColor]];
        
        [self addSubview:payResultView];
        
        
        paySImageView = [[UIImageView alloc] initWithFrame:CGRectMake((payResultView.width-shareS_MWidth)/2, (payResultView.width-shareS_MWidth)/2-8, shareS_MWidth, shareS_MWidth)];
        
        
        
        [payResultView addSubview:paySImageView];
        
        
        pay_result_Label = [[UILabel alloc] initWithFrame:CGRectMake(0,payResultView.height-32,payResultView.width,30)];
        pay_result_Label.textColor = [UIColor whiteColor];
        pay_result_Label.font =  [UIFont fontWithName:textDefaultBoldFont size:13];
        pay_result_Label.textAlignment = NSTextAlignmentCenter;
        [payResultView addSubview:pay_result_Label];
        [self addSubview:payResultView];
        
        payResultView = nil;
        
    }
    
    return self;
}

+(void)closePayResult{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.35f delay:0
                            options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState) animations:^(void) {
                                showresult.alpha  = 0;
                            }
                         completion:^(BOOL finished){
                             resultShowing = NO;
                         }];
    });
    
}


@end
