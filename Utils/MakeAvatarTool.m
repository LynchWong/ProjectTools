//
//  MakeAvatarTool.m
//  6995
//
//  Created by Chuck on 2017/1/4.
//  Copyright © 2017年 myncic.com. All rights reserved.
//

#import "MakeAvatarTool.h"
#import "APPUtils.h"
#import "MainViewController.h"
#import <MediaPlayer/MPMoviePlayerController.h>
#define ORIGINAL_MAX_WIDTH 640.0f

@implementation MakeAvatarTool
@synthesize not_avatar;


//拍照
-(void)takePhoto{
    
    if ([MakeAvatarTool isCameraAvailable] && [MakeAvatarTool doesCameraSupportTakingPhotos]) {
        controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        
        if(not_avatar ||_backCamera){
            if ([MakeAvatarTool isRearCameraAvailable]) {//后置
                controller.cameraDevice = UIImagePickerControllerCameraDeviceRear;
            }
        }else{
            if ([MakeAvatarTool isFrontCameraAvailable]) {
                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
        }
        
        NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
        [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
        if(_support_video){
             controller.allowsEditing = YES;
            [mediaTypes addObject:(__bridge NSString *)kUTTypeMovie];//支持录像
            controller.videoMaximumDuration = _record_time;//最大录制时长
            controller.videoQuality = _record_quality;//视频质量
        }
       
        
        controller.mediaTypes = mediaTypes;
        controller.delegate = self;
        
        
        [[MainViewController sharedMain] presentViewController:controller
                           animated:YES
                         completion:^(void){
                             
                         }];
    }
    
}



//打开相册
-(void)openAlbum{
    if ([MakeAvatarTool isPhotoLibraryAvailable]) {
        
        controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
        [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
        if(_support_video){
            controller.allowsEditing = YES;
            [mediaTypes addObject:(__bridge NSString *)kUTTypeMovie];//支持视频
            controller.videoMaximumDuration = _record_time;//最大时长
            controller.videoQuality = _record_quality;//视压缩质量
        }
        controller.mediaTypes = mediaTypes;
        controller.delegate = self;
        [[MainViewController sharedMain] presentViewController:controller
                           animated:YES
                         completion:^(void){
                         }];
    }
}


//头像剪裁

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:^() {
        
         NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        
        if ([mediaType isEqualToString:@"public.image"]){
            UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
            
            
            portraitImg = [MakeAvatarTool imageByScalingToMaxSize:portraitImg];
        
            
            if(not_avatar){
                self.callBackBlock(portraitImg);
            }else{
                // 裁剪
                VPImageCropperViewController *imgEditorVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.width) limitScaleRatio:3.0];
                imgEditorVC.delegate = self;
                [[MainViewController sharedMain] presentViewController:imgEditorVC animated:YES completion:^{
                    // TO DO
                }];
            }
        }else if([mediaType isEqualToString:@"public.movie"]){
        
            
            //保存视频到本地
            NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
            BOOL compatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([url path]);
            if (compatible){
                UISaveVideoAtPathToSavedPhotosAlbum([url path], self, nil, NULL);
            }
            
            NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
            NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
            
            if(videoData!=nil){
                //截图
                MPMoviePlayerController *playerr = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
                UIImage  *thumbnail = [playerr thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
                [playerr stop];
                playerr = nil;
                
                self.video_callBackBlock(videoData,thumbnail);
                thumbnail = nil;
            }
            videoData = nil;
            
            videoURL = nil;
        }
       
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}



#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // TO DO
    }];
    
    self.callBackBlock(editedImage);
    
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
}



//拍照用
+(BOOL) isCameraAvailable{
    
    if([APPUtils checkAVAuthorizationStatus] ==0){
        return NO;
    }
    
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}


+(BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

+ (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

+ (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

+ (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
+(BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
+ (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

+ (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

+ (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}


+ (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

@end
