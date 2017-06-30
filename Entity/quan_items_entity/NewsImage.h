//
//  UserUtils.h
//  MedicalCenter
//
//  Created by 李狗蛋 on 15-4-1.
//  Copyright (c) 2015年 李狗蛋. All rights reserved.
// 朋友圈图片类

#import <Foundation/Foundation.h>



@interface NewsImage : NSObject

@property (assign, nonatomic) NSInteger imageId;
@property (copy, nonatomic) NSString *imageTid; //隶属消息id;

@property (copy, nonatomic) NSString *imageUrl;
@property (copy, nonatomic) NSString *imageThumb;

@property (copy, nonatomic) NSString *imageName;

@property (assign, nonatomic) NSInteger imageWidth;
@property (assign, nonatomic) NSInteger imageHeight;
@end
