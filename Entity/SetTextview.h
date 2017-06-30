//
//  SetTextview.h
//  wuneng
//
//  Created by Chuck on 2017/6/13.
//  Copyright © 2017年 myncic.com. All rights reserved. //设置专用textview
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"
#import "LocalPhotoViewController.h"

@class MakeAvatarTool;

@interface SetTextview : UIView<HPGrowingTextViewDelegate,SelectPhotoDelegate>{
    NSString *title;
    UIControl *backCoverView;
  
    UIView *changeView;
    BOOL menuState;//键盘的显示和隐藏状态
    HPGrowingTextView *hpTextView;
    UILabel *hpLabel;
    
    NSInteger maxLength;
    
    
    BOOL replyType;
    UIView *sendView;//发送留言
    CGFloat sendViewHeight;
    UIColor *replyColor;//回复类型的viewcolor
    UILabel *placeHolderLabel;
    float diff;
    
    BOOL imgFull;//图片加完
    MakeAvatarTool *makeAvatar;
    NSMutableDictionary *addBtnDic;
    NSMutableArray *imagesList;//装图片uiimage
    NSMutableArray *imagesDatalist;//图片data
}

- (id)initWithReply:(UIColor*)color;//回复类型

- (id)initWithTitle:(NSString*)titleString;
- (id)initWithImg:(NSString*)titleString;

-(void)setTitle:(NSString*)string;
-(void)setKeyType:(NSInteger)type;
-(void)setMaxLength:(NSInteger)max;
-(void)show:(NSString*)defaultString;//显示
-(void)showWithPlace:(NSString*)placeString;//回复类型显示
-(void)clearContent;
-(void)hide;
-(void)destroy;

@property (nonatomic,assign)BOOL addImages;//有图片
@property (nonatomic,assign)NSInteger maxImgs;//图片最大数



typedef void (^SetTextviewBlock)(NSString *titleString,NSString *contentString);
@property (nonatomic,strong)SetTextviewBlock setback;

typedef void (^SetTextAndImagesBlock)(NSMutableArray* imgArr,NSString *contentString);
@property (nonatomic,strong)SetTextAndImagesBlock setImgback;

@end
