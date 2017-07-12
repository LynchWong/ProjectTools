//
//  AuthDialog.m
//  zpp
//
//  Created by Chuck on 2017/7/12.
//  Copyright © 2017年 myncic.com. All rights reserved.
//

#import "AuthDialog.h"

@implementation AuthDialog

- (instancetype)init{
    
    if (self == [super init]) {
        
        [[[UIApplication sharedApplication].delegate window] addSubview:self];
        [self setFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        self.alpha=0;
    }
    
    return self;
}


//显示验证码
-(void)showAuthCode{
    
    if(authUnder == nil){
        
        authUnder = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        [authUnder setBackgroundColor:[UIColor blackColor]];
        authUnder.alpha = 0.6;
        [authUnder addTarget:self action:@selector(closeAuth) forControlEvents:UIControlEventTouchDown];
        [self addSubview:authUnder];
        
        
        float authWidth = SCREENWIDTH*0.8;
        float authHeight = 100;
        authDialog = [[UIView alloc] initWithFrame:CGRectMake((SCREENWIDTH-authWidth)/2, (SCREENHEIGHT-authHeight)/2-20, authWidth, authHeight)];
        [authDialog setBackgroundColor:[UIColor whiteColor]];
        authDialog.layer.cornerRadius = 4;
        [authDialog.layer setMasksToBounds:YES];
        [self addSubview:authDialog];
        
        
        UIView *scodeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,authWidth, authHeight/2)];
        [authDialog addSubview:scodeView];
        
        //输入
        authInput =  [[UITextField alloc] initWithFrame:CGRectMake(15, 0, authWidth*0.6-30, scodeView.height)];
        [authInput setTextColor:[UIColor darkGrayColor]];
        authInput.placeholder = @"请输入右图验证码";
        [authInput setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
        [authInput setKeyboardType:UIKeyboardTypeNumberPad];
        authInput.textAlignment = NSTextAlignmentLeft;
        authInput.font = [UIFont fontWithName:textDefaultFont size:13];
        authInput.delegate = self;
        [authInput setReturnKeyType:UIReturnKeyDone];
        [authInput setBorderStyle:UITextBorderStyleNone];
        [authInput setClearButtonMode:UITextFieldViewModeNever];
        [scodeView addSubview:authInput];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkText) name:UITextFieldTextDidChangeNotification object:authInput];
        
        
        
        //显示验证码界面
        authCodeView = [[AuthCodeView alloc] initWithFrame:CGRectMake(authWidth-authWidth*0.4-10, (authHeight/2-35)/2, authWidth*0.4, 35)];
        [scodeView addSubview:authCodeView];
        
        
        
        [authDialog addSubview:[APPUtils get_line:0 y:authHeight/2 width:authWidth]];
        
        
        UIView *clickView = [[UIView alloc] initWithFrame:CGRectMake(0, authHeight/2, authWidth, authHeight/2)];
        [authDialog addSubview:clickView];
        
        //取消验证
        MyBtnControl *cancelCheck = [[MyBtnControl alloc] initWithFrame:CGRectMake(0, 0, authWidth/2, clickView.height)];
        cancelCheck.clickBackBlock = ^(){
            [self closeAuth];
        };
        
        [clickView addSubview:cancelCheck];
        
        [cancelCheck addLabel:@"取消" color:[UIColor lightGrayColor] font:[UIFont fontWithName:textDefaultFont size:14]];
        
        //验证
        MyBtnControl *checkbtn = [[MyBtnControl alloc] initWithFrame:CGRectMake(clickView.width/2, 0, authWidth/2, clickView.height)];
        [clickView addSubview:checkbtn];
        
        [checkbtn addLabel:@"验证" color:MAINCOLOR font:[UIFont fontWithName:textDefaultFont size:14]];
        
        [clickView addSubview:[APPUtils get_line2:CGRectMake(clickView.width/2-0.25, 0, 0.5,clickView.height)]];
        
        checkbtn.clickBackBlock = ^(){
            
            [authInput resignFirstResponder];
            
            if(authInput.text.length==0){
                [ToastView showToast:@"请输入验证码！"];
                return;
            }
            
            if(authInput.text.length!=4 || ![authCodeView auth:authInput.text]){
                [ToastView showToast:@"验证码错误！"];
                return;
            }
            
            authInput.text = @"";
            authOK = YES;
            [self closeAuth];
            
            self.authBackBlock();
            
        };
        
        checkbtn = nil;
        cancelCheck = nil;
        clickView = nil;
        scodeView = nil;
        
        
    }
    
    [authCodeView refreshAuth];//刷新验证码
    
    [self bringSubviewToFront:authUnder];
    [self bringSubviewToFront:authDialog];
    
    [UIView animateWithDuration:0.2 animations:^{
      
        self.alpha=1;
    }];
    
    
}



-(void)checkText{
    
    if(authInput.text.length>0){
        
        if(authInput.text.length>4){
            authInput.text = [authInput.text substringWithRange:NSMakeRange(0,4)];
        }
        
    }
}




-(void)closeAuth{
    [authInput resignFirstResponder];
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha=0;
    }];
    
}


@end
