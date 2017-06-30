//
//  Animations.h
//
//  Created by Pulkit Kathuria on 10/8/12.
//  Copyright (c) 2012 Pulkit Kathuria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface DES3Util : NSObject 

// 加密方法
+ (NSData*)encrypt:(NSData*)data;

// 解密方法
+ (NSString*)decrypt:(NSString*)encryptText;
+ (NSString*)decrypt_data:(NSData*)encryptData;

@end
