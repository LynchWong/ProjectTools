//
//  UncaughtExceptionHandler.m
//  MedicalCenter
//
//  Created by 李狗蛋 on 15/10/16.
//  Copyright © 2015年 李狗蛋. All rights reserved.
//

#import "UncaughtExceptionHandler.h"
#import "APPUtils.h"
@implementation UncaughtExceptionHandler


void uncaughtExceptionHandler(NSException *exception)
{
    // 异常的堆栈信息
    NSArray *stackArray = [exception callStackSymbols];
    // 出现异常的原因
    NSString *reason = [exception reason];
    // 异常名称
    NSString *name = [exception name];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // app名称
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    infoDictionary = nil;
    if(app_Name==nil){
        app_Name = @"";
    }
    
    NSString *exceptionInfo = [NSString stringWithFormat:@"appName: %@  Error_Method:%@  Exception reason：%@\nException name：%@\nException stack：%@",app_Name,[APPUtils getMethod],name, reason, stackArray];
    NSLog(@"%@", exceptionInfo);
    
    NSMutableArray *tmpArr = [NSMutableArray arrayWithArray:stackArray];
    [tmpArr insertObject:reason atIndex:0];
    
    //保存到本地  --  当然你可以在下次启动的时候，上传这个log
    NSUserDefaults *user_Defaults = [NSUserDefaults standardUserDefaults];
    [user_Defaults setObject:exceptionInfo forKey:@"errorInfo"];
    [user_Defaults synchronize];
    user_Defaults = nil;
    
//    [exceptionInfo writeToFile:[NSString stringWithFormat:@"%@/Documents/error.log",NSHomeDirectory()]  atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

@end
