//
//  MyBtnControl.h
//  zpp
//
//  Created by Chuck on 2017/5/2.
//  Copyright © 2017年 myncic.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyBtnControl : UIView{
    NSInteger clicktime;
    
    CGRect shareImg_originalFrame;
    
    UIControl *btnControl;
}

@property (assign, nonatomic) NSInteger btn_num;//第一个按钮还是第二个按钮   从左到右
@property (assign, nonatomic) NSInteger btn_num2;
@property (assign, nonatomic) NSInteger btn_num3;
//分享用
@property (retain, nonatomic) UIImageView *shareImage;
@property (retain, nonatomic) UIImageView *shareImage2;
@property (retain, nonatomic) UIView *shareView;
@property (retain, nonatomic) UILabel *shareLabel;
@property (retain, nonatomic) UILabel *shareLabel2;

@property (retain, nonatomic) NSString *filePlateName;
@property (assign, nonatomic) BOOL click_enable;

@property (assign, nonatomic)  BOOL planType;//临时订单的
@property (retain, nonatomic)  NSString* belong2;//隶属页

@property (nonatomic,assign)BOOL back_highlight;//需不需要背景点击闪烁
@property (nonatomic,assign)BOOL not_highlight;//背景不需要闪烁
@property (nonatomic,assign)BOOL not_ShareHighlight;//所有不需要闪烁

@property (assign, nonatomic)  BOOL no_single_click;//没得单击事件
@property (assign, nonatomic)  BOOL choosed;//选择中的

@property (retain, nonatomic) NSString *searchContent;
@property (retain, nonatomic) NSString *select_icon_Name;
@property (retain, nonatomic) NSString *unselect_icon_Name;

@property (assign, nonatomic)  BOOL functype;//应用点击类型

-(void)setEnabled:(BOOL)enable;//允许点击

-(void)setShareLabel:(UILabel *)label;
-(void)setShareImage:(UIImageView *)image;

typedef void (^ClickBlock)();
@property (nonatomic,strong)ClickBlock clickBackBlock;

//添加文字
-(void)addLabel:(NSString*)text color:(UIColor*)color font:(UIFont*)font;
-(void)addLabel:(NSString*)text color:(UIColor*)color font:(UIFont*)font txtAlignment:(NSInteger)txtAlignment x:(float)x;
-(void)addLabel:(NSString*)text color:(UIColor*)color font:(UIFont*)font txtAlignment:(NSInteger)txtAlignment frame:(CGRect)frame;

//添加图片
-(void)addImage:(UIImage*)img frame:(CGRect)frame;
-(void)addImage2:(UIImage*)img frame:(CGRect)frame;
-(void)addImage:(UIImage*)img frame:(CGRect)frame url:(NSString*)url;
-(void)addImage:(UIImage*)img;


-(void)btn_action;

-(void)addLongclick;//长按
typedef void (^LongClickBlock)();
@property (nonatomic,strong)LongClickBlock longClickBackBlock;

@property (assign, nonatomic) CGRect shareImg_clickFrame;//func类型点击变化

@end
