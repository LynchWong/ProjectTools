//
//  PhotoBrowserCell.m
//  李码哥Demo
//
//  Created by chengzi on 16/3/31.
//  Copyright © 2016年 ufutx. All rights reserved.
//

#import "PhotoBrowserCell.h"
#import "UIImageView+WebCache.h"
#import "CLPhotoProgressView.h"




@interface PhotoBrowserCell()<UIScrollViewDelegate>

@property (nonatomic, weak) UIScrollView *scrollview;
@property (nonatomic, weak) CLPhotoProgressView *progressView;
@property (nonatomic, assign) CGFloat zoomScale;

@end



@implementation PhotoBrowserCell

- (void)setPhoto:(CLPhoto *)photo
{
    _photo = photo;
    [self reset];
    
    [photo addObserver:self forKeyPath:@"downLoad" options:NSKeyValueObservingOptionNew context:nil];
    __weak typeof(self)weakself = self;
    
  
    [photo setProgressBlock:^(CGFloat progress) {
        weakself.progressView.progress = progress;
    }];
    
    self.imageView.image = photo.get_image;

    if (photo.imageViewBounds.size.height<=[UIScreen mainScreen].bounds.size.height) {
        self.imageView.bounds = photo.imageViewBounds;
        self.imageView.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.height * 0.5);
    }else{
        self.scrollview.contentSize = photo.imageViewBounds.size;
        self.imageView.frame = CGRectMake(0, 0, photo.imageViewBounds.size.width, photo.imageViewBounds.size.height);
        
    }
    
}

- (void)reset
{
    self.scrollview.contentInset = UIEdgeInsetsZero;
    self.scrollview.contentSize = CGSizeZero;
    self.imageView.transform = CGAffineTransformIdentity;
}

#pragma mark - =====================  监听处理  =====================
- (void)prepareForReuse
{
    [_photo removeObserver:self forKeyPath:@"downLoad"];
}
- (void)dealloc
{
    [_photo removeObserver:self forKeyPath:@"downLoad"];
}


//download 监听的
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    self.imageView.image = self.photo.get_image;
    [UIView animateWithDuration:0.3 animations:^{
        self.imageView.bounds = self.photo.imageViewBounds;
        
    }];
}


- (void)scrollViewDidTap
{
    

    if ([self.delegate respondsToSelector:@selector(didSelectedPhotoBrowserCell:)]) {
        [self.delegate didSelectedPhotoBrowserCell:self];
    }
}

///长安保存手势
-(void)longPressToDo:(UILongPressGestureRecognizer *)gesture
{
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        if ([self.delegate respondsToSelector:@selector(longPressPhotoBrowserCell:)]) {
            [self.delegate longPressPhotoBrowserCell:self];
        }
    }
}
#pragma mark - 双击
- (void)scrollViewDidDoubleTap:(UITapGestureRecognizer *)doubleTap{
    // 这里先判断图片是否下载好,, 如果没下载好, 直接return
    if(!_imageView.image) return;
    
    if(_scrollview.zoomScale <= 1){
        // 1.获取到 手势 在 自身上的 位置
        // 2.scrollView的偏移量 x(为负) + 手势的 x 需要放大的图片的X点
        CGFloat x = [doubleTap locationInView:self].x + _scrollview.contentOffset.x;
        
        // 3.scrollView的偏移量 y(为负) + 手势的 y 需要放大的图片的Y点
        CGFloat y = [doubleTap locationInView:self].y + _scrollview.contentOffset.y;
        [_scrollview zoomToRect:(CGRect){{x,y},CGSizeZero} animated:YES];
    }else{
        // 设置 缩放的大小  还原
        [_scrollview setZoomScale:1.f animated:YES];
    }
}
#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    CGFloat offsetX = ([UIScreen mainScreen].bounds.size.width - view.frame.size.width) * 0.5;
    CGFloat offsetY = ([UIScreen mainScreen].bounds.size.height - view.frame.size.height) * 0.5;
    if (offsetX>0 && offsetY>0) {
        view.center = scrollView.center;
        scrollView.contentSize = view.frame.size;
    }else{
        scrollView.contentSize = CGSizeMake(view.frame.size.width+2*view.frame.origin.x, CGRectGetHeight(view.frame)+2*view.frame.origin.y);
    }
    
}

#pragma mark - 懒加载
- (UIScrollView *)scrollview
{
    if (_scrollview == nil) {
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        scrollView.maximumZoomScale = 2.0;
        scrollView.minimumZoomScale = 0.5;
        scrollView.delegate = self;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        
        [self.contentView addSubview:scrollView];

        _scrollview = scrollView;
        scrollView.translatesAutoresizingMaskIntoConstraints = NO;
        self.zoomScale = 1.0;
        
    }
    return _scrollview;
}

- (UIImageView *)imageView
{
    if (_imageView == nil) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView.userInteractionEnabled = YES;

        
        // 1.生产 两种 手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDidTap)];
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDidDoubleTap:)];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo:)];
        
        // 2.设置 手势的要求
        [tap setNumberOfTapsRequired:1];
        [tap setNumberOfTouchesRequired:1];
        [doubleTap setNumberOfTapsRequired:2];
        [doubleTap setNumberOfTouchesRequired:1];
        
        // 3.避免两种手势冲突
        [tap requireGestureRecognizerToFail:doubleTap];
        
        // 4.添加 手势
        [self addGestureRecognizer:tap];
        [self addGestureRecognizer:doubleTap];
        [self addGestureRecognizer:longPress];
        
        
        [self.scrollview addSubview:imageView];
        _imageView = imageView;
        
    }
    return _imageView;
}
- (CLPhotoProgressView *)progressView
{
    if (_progressView == nil) {
        CLPhotoProgressView *progressView = [[CLPhotoProgressView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        progressView.center = CGPointMake([UIScreen mainScreen].bounds.size.width *0.5, [UIScreen mainScreen].bounds.size.height *0.5);
        progressView.progress = 0;
        [self.contentView addSubview:progressView];
        _progressView = progressView;
        [_progressView setHidden:YES];
    }
   
   
    return _progressView;
}
@end
