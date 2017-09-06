//
//  TuyaViewController.h
//  MedicalCenter
//
//  Created by 李狗蛋 on 15-3-19.
//  Copyright (c) 2015年 李狗蛋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "TuyaView.h"
#import "MakeAvatarTool.h"
@class MakeAvatarTool;
@interface TuyaViewController : UIViewController<PassValueDelegate>{

  
    CGFloat gegeHeight;//手写行高
    BOOL isTuya;//涂鸦类型
    CGFloat btnWidth;
    CGFloat btnHeight;
    
    UIView *bodyView;
    TuyaView *tuyaView;
    
    
    UIImageView *backgroundImageView;//图片背景
    BOOL hasBackPic;//背景图存在
    
    //颜色选择
    UISlider * slide;
    UIView *chooseColorView;
    UIControl *chooseBackControl;
    UIView *i1;
    UIView *i2;

    MakeAvatarTool *makeAvatar;
    
}

- (id)initWithTuya:(BOOL)tuya;

@property(nonatomic,assign) NSObject<PassValueDelegate> *delegate;



@end
