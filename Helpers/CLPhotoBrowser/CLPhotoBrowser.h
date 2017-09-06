//
//  CLPhotoBrowser.h
//  李码哥Demo
//
//  Created by apple on 16/3/31.
//  Copyright © 2016年 ufutx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLPhoto.h"
#import "PhotoBrowserCell.h"
#import "CCActionSheet.h"

@protocol BrowerCellDelegate <NSObject>
@optional
- (void)collectionViewCell:(PhotoBrowserCell *)cell cellForItemAtIndexPath:(NSIndexPath *)indexPath;
@end

static BOOL opening = NO;

@interface CLPhotoBrowser : UIViewController
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic ,assign) NSUInteger selectImageIndex;
@property (nonatomic ,assign) BOOL wx_type;//吾能OA正文类型
@property (nonatomic ,assign) BOOL msg_type;//消息类型

// 用来存放Cell的唯一标示符
@property (nonatomic, strong) NSMutableDictionary *cellDic;

@property (nonatomic ,assign) id<BrowerCellDelegate> delegate;
- (void)show;

+ (BOOL)getPhotoOpening;
+ (void)setPhotoOpening:(BOOL)open;
@end
