//
//  MsgCellTableViewCell.h
//  zpp
//
//  Created by Chuck on 2017/4/21.
//  Copyright © 2017年 myncic.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OneMsgEntity.h"
#import "Conversation.h"
@class MsgCellTableViewCell;
@class MyBtnControl;


@interface MsgCellTableViewCell : UITableViewCell{
    CGFloat posWidth;
    CGFloat posheight;
    UIImageView *_unreadRedView;//未读语音红点
    
    CGFloat oneLineHeight;
    
}

@property (nonatomic, strong) OneMsgEntity *msg;
@property (nonatomic, strong) Conversation *conversation;

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSString *myAvatarUrl;
@property (nonatomic, assign) float maxPicWidth;//图片最宽
@property (nonatomic, assign) float maxPicHeight;//图片最高
@property (nonatomic, strong) UILabel *progressLabel;//上传进度
@property (nonatomic, strong) UIActivityIndicatorView *voiceActivityIndicator;//语音下载菊花
@property (nonatomic, strong)  UIImageView *bolang;//语音播放波浪

typedef void (^MsgCellBlock)(NSString *type);//处理回调
@property (nonatomic,strong)MsgCellBlock callBackBlock;


typedef void (^MsgCellClickBlock)(MyBtnControl*control,NSString *type);//长按处理回调
@property (nonatomic,strong)MsgCellClickBlock clickCallBackBlock;

@end
