//
//  AddTips.h
//  zpp
//
//  Created by Chuck on 16/7/5.
//  Copyright © 2016年 myncic.com. All rights reserved.  加小费 View
//

#import <UIKit/UIKit.h>
#import "OrderEntity.h"
#import "SetTextview.h"
@class SetTextview;

@interface EvaluateView : UIView <HPGrowingTextViewDelegate>{
    
    
    
    
    //评论
    UIView *evaluate_view;
    UIView *evaView;
    UILabel *evaLabel;
    NSString *evaString;
    
    NSInteger goodrate;
    UIImageView *starView;
    
    
    SetTextview *setText;
    UIControl *blackCoverView;
    
    NSString *defaultString;
}

typedef void (^EvaluateBlock)(BOOL result);
@property (nonatomic,strong)EvaluateBlock callBackBlock;


@property (retain,nonatomic) NSString *checkOrderId;


- (id)initWithOrder:(NSString*)orderId;
-(void)init_views;
-(void)setOrderId:(NSString*)orderId;
@end
