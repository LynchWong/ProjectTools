//
//  ShowResult.h
//  zpp
//
//  Created by Chuck on 2017/5/4.
//  Copyright © 2017年 myncic.com. All rights reserved. 显示结果
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class ShowResult;
static BOOL resultShowing;
static ShowResult *showresult;
static UILabel *pay_result_Label;
static UIImageView *paySImageView;

@interface ShowResult : UIView{

}


+(void)showResult:(NSString*)show succeed:(BOOL)succeed;

@end
