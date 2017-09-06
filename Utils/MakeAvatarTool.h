//
//  MakeAvatarTool.h
//  6995
//
//  Created by Chuck on 2017/1/4.
//  Copyright © 2017年 myncic.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VPImageCropperViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
@interface MakeAvatarTool : NSObject<UIImagePickerControllerDelegate,VPImageCropperDelegate,UINavigationControllerDelegate>{

    UIImagePickerController *controller;
}


typedef void (^AvatarBlock)(UIImage *avatar_img);
@property (nonatomic,copy)AvatarBlock callBackBlock;


typedef void (^VideoBlock)(NSData *video_data,UIImage *snap);
@property (nonatomic,copy)VideoBlock video_callBackBlock;

//拍照
-(void)takePhoto;
//打开相册
-(void)openAlbum;

@property (nonatomic,assign)BOOL not_avatar;//非头像类型
@property (nonatomic,assign)BOOL backCamera;//后摄像头
@property (nonatomic,assign)BOOL support_video;//支持录像
@property (nonatomic,assign)NSInteger record_time;//最大录制时长
@property (nonatomic,assign)NSInteger record_quality;//录制质量


@end
