//
//  UncaughtExceptionHandler.h
//  MedicalCenter
//
//  Created by 李狗蛋 on 15/10/16.
//  Copyright © 2015年 李狗蛋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface UncaughtExceptionHandler : NSObject


void uncaughtExceptionHandler(NSException *exception);  

@end

