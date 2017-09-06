//
//  SweepViewController.h
//  FirstHospital
//
//  Created by 李狗蛋 on 15-1-23.
//  Copyright (c) 2015年 李狗蛋. All rights reserved.  zbar方式请看5.4 现用ios7自带库
//

#import <UIKit/UIKit.h>
#import "PassValueDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ZBarSDK.h"
#import "GTMBase64.h"
#import "MainViewController.h"

@class MakeAvatarTool;
@interface SweepViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ZBarReaderViewDelegate>{
    
    NSString *corrent_domain;//正确的url开头
    
    BOOL upOrdown;
    NSTimer * timer;
    int num;
    BOOL openLight;
    AVCaptureSession * _AVSession;//调用闪光灯的时候创建的类
    UIImage *personbgImg1;
    UIImage *personbgImg2;
  
    
    UIView *readView;
    MakeAvatarTool* makeAvatar;
    
    UIImageView *openLightImageView;
    UIImageView *greenLine;

    
    CGFloat readViewWidth;
    NSString *stringValue;
    
    ZBarReaderView *zbarReadView;
   
}


- (id)initWithDomain:(NSString*)domain;

@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;



typedef void (^SweepBlock)(NSString *sweepString);
@property (nonatomic,strong)SweepBlock sweepBackBlock;

@end


