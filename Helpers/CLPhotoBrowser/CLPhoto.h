//
//  MJPhoto.h
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>



@interface CLPhoto : NSObject

///网络图片需要赋值的数据
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *thumbUrl;
@property (nonatomic, assign) CGRect scrRect; // 原图图片的位置
@property (nonatomic, copy) UIImage *local_img;//本地图片

///网络图片由url加载得到,动态加载
@property (nonatomic, strong ,readonly) UIImage *get_image; // 大图图片
@property (nonatomic, assign) BOOL downLoad;            // 判断是非下载完成
@property (nonatomic, assign) CGRect imageViewBounds;   // 图片大小
@property (nonatomic ,copy) void (^progressBlock)(CGFloat progress);   //下载进度


//图片宽高
+ (CGSize)displaySize:(UIImage *)image;
//根据URL返回缓存图片
+ (UIImage *)existImageWithUrl:(NSString *)urlStr;

@end
