//
//  NoticesView.h
//  zpp
//
//  Created by Chuck on 2017/5/4.
//  Copyright © 2017年 myncic.com. All rights reserved. 喇叭通知
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface NoticesView : UIView{

    CGFloat self_w;
    CGFloat self_h;
    
   
    UIScrollView *noticeScrollView;
    CGFloat noticeLabelWidth;//内容总宽
    NSMutableArray *noticesLabelArray;
    NSMutableArray *noticesLabelTempArray;//缓存
    
    
    UIImage *labaImg;//喇叭
    UIImage *clearImg;//喇叭
    UIColor *wColor;
    
}

- (id)initWithColor:(UIColor*)underColor wordColor:(UIColor*)wordColor laba:(UIImage*)laba clear:(UIImage*)clear;


@property(nonatomic,strong) NSMutableArray *noticesArray;
//装载
-(void)setNotice:(NSArray*)arr;
-(void)showNoticeView;

@end
