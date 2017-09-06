//
//  AuthDialog.h
//  zpp
//
//  Created by Chuck on 2017/7/12.
//  Copyright © 2017年 myncic.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AuthCodeView.h"
#import "MainViewController.h"
@interface AuthDialog : UIView<UITextFieldDelegate>{
    UIControl *authUnder;
    UIView *authDialog;
    AuthCodeView *authCodeView;//验证码区域
    UITextField *authInput;
    BOOL authOK;//验证成功
    NSInteger maxNumber;
}

typedef void (^AuthCodeBlock)();
@property (nonatomic,strong)AuthCodeBlock authBackBlock;


-(id)initWithMax:(NSInteger)max;
//显示验证码
-(void)showAuthCode;
@end
