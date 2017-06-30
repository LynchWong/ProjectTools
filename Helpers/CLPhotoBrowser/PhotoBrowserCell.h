//
//  PhotoBrowserCell.h
//  李码哥Demo
//
//  Created by chengzi on 16/3/31.
//  Copyright © 2016年 ufutx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLPhoto.h"

@class PhotoBrowserCell;

@protocol PhotoBrowserCellDelegate <NSObject>

- (void)didSelectedPhotoBrowserCell:(PhotoBrowserCell *)cell;

- (void)longPressPhotoBrowserCell:(PhotoBrowserCell *)cell;

@end

@interface PhotoBrowserCell : UICollectionViewCell
@property (nonatomic, weak) UIImageView *imageView;

@property (nonatomic ,assign) id<PhotoBrowserCellDelegate> delegate;
@property (nonatomic, strong) CLPhoto *photo;
@end
