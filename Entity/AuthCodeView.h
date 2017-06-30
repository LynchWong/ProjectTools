//
//  AuthCodeView.h
//  xsq
//
//  Created by Chuck on 2017/6/23.
//  Copyright © 2017年 myncic.com. All rights reserved. 图文验证码
//

#import <UIKit/UIKit.h>

@interface AuthCodeView : UIView{
    

    NSArray *dataArray;//字符素材数组
    NSString *authCodeStr; //验证码字符串
}



//刷新验证码
-(void)refreshAuth;

//验证
-(BOOL)auth:(NSString*)string;
@end
