//
//  CLPhotoBrowser.m
//  李码哥Demo
//
//  Created by apple on 16/3/31.
//  Copyright © 2016年 ufutx. All rights reserved.
//

#import "CLPhotoBrowser.h"
#import "PhotoBrowserCell.h"
#import "UIImageView+WebCache.h"
#import "MainViewController.h"
#import "APPUtils.h"
#ifndef ScreenWidth
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#endif
#ifndef ScreenHeight
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#endif
#define PhotoBrowerMargin 20.f


@interface CLPhotoBrowser ()<UICollectionViewDataSource,UICollectionViewDelegate,PhotoBrowserCellDelegate>

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, weak) UIPageControl *pageCtl;

///当前页
@property (nonatomic ,assign) NSUInteger currentSelectIndex;

@end


static NSString *const PhotoBrowserCellIdentifier = @"PhotoBrowserCellIdentifier";
static NSTimeInterval const duration = 0.3;

@implementation CLPhotoBrowser
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
}

- (void)show
{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];

    UIViewController *rootViewCtl = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewCtl addChildViewController:self];
    [rootViewCtl.view addSubview:self.view];
    [self showFirstImageView];
}

- (void)showFirstImageView{

    CLPhoto *photo = [self.photos objectAtIndex:self.selectImageIndex];
    self.imageView = [[UIImageView alloc] init];
    [self.view addSubview:self.imageView];
    
    self.cellDic = [[NSMutableDictionary alloc] init];
    
    BOOL existBigPic = NO;
    
    self.imageView.frame = photo.scrRect;
    
    if(photo.local_img!=nil){//看本地
        existBigPic = YES;
        self.imageView.image = photo.local_img;
    }else{
        self.imageView.image = [CLPhoto existImageWithUrl:photo.url];
        if (self.imageView.image) { //查看大图是否存在
            existBigPic = YES;
        }else{//查看小图是否存在
            self.imageView.image = [CLPhoto existImageWithUrl:photo.thumbUrl];
        }
    }
    
    
    //渐变显示
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
    if(self.imageView.frame.size.width==0 && self.imageView.frame.size.height==0 && existBigPic){
        CGSize size = [CLPhoto displaySize:self.imageView.image];
        self.imageView.frame = CGRectMake((SCREENWIDTH-size.width)/2, SCREENHEIGHT, size.width, size.height);
    }else{
        self.imageView.frame = photo.scrRect;
    }
    
    __weak typeof(self)weakself = self;
    CGPoint ScreenCenter = self.view.window.center;

    [UIView animateWithDuration:duration animations:^{
        //有大图直接显示大图，没有先显示小图
        if (existBigPic) {
            CGSize size = [CLPhoto displaySize:self.imageView.image];
            weakself.imageView.frame = CGRectMake(0, 0, size.width, size.height);
            
            //长图处理
            if (size.height<=[UIScreen mainScreen].bounds.size.height) {
                weakself.imageView.center = ScreenCenter;
            }

        }else{
            self.imageView.center = self.view.center;
        }
        weakself.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1.0];

        
    } completion:^(BOOL finished) {
        [weakself.imageView removeFromSuperview];

        weakself.imageView = nil;
        weakself.collectionView.contentOffset = CGPointMake(self.selectImageIndex*[UIScreen mainScreen].bounds.size.width, 0);
        weakself.pageCtl.numberOfPages = self.photos.count;
        weakself.pageCtl.currentPage = self.selectImageIndex;
        weakself.currentSelectIndex = self.selectImageIndex;
        [_collectionView setContentOffset:(CGPoint){weakself.currentSelectIndex * (self.view.bounds.size.width + 20),0} animated:NO];

    }];
}




#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photos.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    // 每次先从字典中根据IndexPath取出唯一标识符  防止下载圈混乱
    NSString *identifier = [_cellDic objectForKey:[NSString stringWithFormat:@"%@", indexPath]];
    // 如果取出的唯一标示符不存在，则初始化唯一标示符，并将其存入字典中，对应唯一标示符注册Cell
    if (identifier == nil) {
        identifier = [NSString stringWithFormat:@"%@%@", [APPUtils getUniquenessString], [NSString stringWithFormat:@"%@", indexPath]];
        [_cellDic setValue:identifier forKey:[NSString stringWithFormat:@"%@", indexPath]];
        // 注册Cell
        [self.collectionView registerClass:[PhotoBrowserCell class]  forCellWithReuseIdentifier:identifier];
    }
    
    PhotoBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    CLPhoto *photo = [self.photos objectAtIndex:indexPath.item];
    cell.photo = photo;
    cell.delegate = self;
    if (self.delegate && [self.delegate respondsToSelector:@selector(collectionViewCell:cellForItemAtIndexPath:)]) {
        [self.delegate collectionViewCell:cell cellForItemAtIndexPath:indexPath];
    }

    identifier = nil;
    
    return cell;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.currentSelectIndex = round(scrollView.contentOffset.x / (ScreenWidth + 20));

    self.pageCtl.currentPage = self.currentSelectIndex;
}

#pragma mark - PhotoBrowserCellDelegate
- (void)didSelectedPhotoBrowserCell:(PhotoBrowserCell *)cell{

    
    if (cell.imageView.frame.size.height > [UIScreen mainScreen].bounds.size.height || cell.imageView.frame.size.width > [UIScreen mainScreen].bounds.size.width) {
        self.imageView = [[UIImageView alloc] init];
        // 开启图形上下文
        UIGraphicsBeginImageContextWithOptions([UIScreen mainScreen].bounds.size, YES, 0.0);
        
        // 将下载完的image对象绘制到图形上下文
        CGFloat width = cell.imageView.frame.size.width;
        CGFloat height = width *  cell.imageView.image.size.height /  cell.imageView.image.size.width;
        [cell.imageView.image drawInRect:CGRectMake(0, 0,  cell.imageView.image.size.width, height)];
        
        // 获得图片
        self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        CGRect frame = cell.imageView.frame;
        frame.size.height = [UIScreen mainScreen].bounds.size.height;
        self.imageView.frame = frame;
        
        // 结束图形上下文
        UIGraphicsEndImageContext();
        
        [self.view addSubview:self.imageView];
        [self.collectionView removeFromSuperview];
        
        [self hide:self.imageView with:cell.photo];

    }else{
        
        [self hide:cell.imageView with:cell.photo];
    }

    
}

- (void)hide:(UIImageView *)imageView with:(CLPhoto *)photo{

    
    CGFloat width  = imageView.image.size.width;
    CGFloat height = imageView.image.size.height;
    
    CGSize tempRectSize = (CGSize){ScreenWidth,(height * ScreenWidth / width) > ScreenHeight ? ScreenHeight:(height * ScreenWidth / width)};
    
    if(!isnan(tempRectSize.width)&&!isnan(tempRectSize.height)){
        [imageView setBounds:(CGRect){CGPointZero,{tempRectSize.width,tempRectSize.height}}];
    }
    
    
    [imageView setCenter:self.view.center];
    [self.view addSubview:imageView];
    
   
    CGRect closeRect = photo.scrRect;//最终的收回位置
    if(closeRect.size.width==0 && closeRect.size.height==0){
        closeRect = CGRectMake((SCREENWIDTH-photo.imageViewBounds.size.width)/2, -(photo.imageViewBounds.size.height), photo.imageViewBounds.size.width, photo.imageViewBounds.size.height);
    }
    
    //吾能OA图片超过1张时候 关闭的时候不是打开的那张的位置

    if(_wx_type&&[self.photos count]>1&&_selectImageIndex!=self.pageCtl.currentPage){
        CLPhoto *firstOpenphoto = [self.photos objectAtIndex:_selectImageIndex];//进来的第一张
        NSInteger closePosition = self.pageCtl.currentPage;
        
        CGFloat firstLineY = 0;//首行图片的Y
        if(_selectImageIndex==0||_selectImageIndex==1||_selectImageIndex==2){
            firstLineY = firstOpenphoto.scrRect.origin.y;
         }else if(_selectImageIndex==3||_selectImageIndex==4||_selectImageIndex==5){
             firstLineY = firstOpenphoto.scrRect.origin.y - firstOpenphoto.scrRect.size.height-5;
        }else{
            firstLineY = firstOpenphoto.scrRect.origin.y - firstOpenphoto.scrRect.size.height*2-10;
        }
        
        CGFloat closeLineY = 0;//关闭图片的Y
        if(closePosition==0||closePosition==1||closePosition==2){
            closeLineY = firstLineY;
        }else if(closePosition==3||closePosition==4||closePosition==5){
            closeLineY = firstLineY+firstOpenphoto.scrRect.size.height+5;
        }else{
            closeLineY = firstLineY+ firstOpenphoto.scrRect.size.height*2+10;
        }
        
        
        CGFloat closeX = 0;//关闭图片的x
        if(closePosition==0||closePosition==3||closePosition==6){
            closeX = 10;
        }else if(closePosition==1||closePosition==4||closePosition==7){
            closeX = 15+firstOpenphoto.scrRect.size.width;
        }else{
            closeX = 20+firstOpenphoto.scrRect.size.width*2;
        }
        
        firstOpenphoto = nil;
        
        closeRect.origin.x = closeX;
        closeRect.origin.y = closeLineY;
    }
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [imageView setFrame:closeRect];
        self.view.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
    
}

#pragma mark - 保存图片
- (void)longPressPhotoBrowserCell:(PhotoBrowserCell *)cell
{
    CCActionSheet *actionSheet = [[CCActionSheet alloc] initWithTitle:@"是否将该图保存到手机相册？" clickedAtIndex:^(NSInteger index) {
        
        if(index == 0){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                CLPhoto *photo = self.photos[self.currentSelectIndex];
                UIImageWriteToSavedPhotosAlbum(photo.get_image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            });
        }
        
    } cancelButtonTitle:@"取消" otherButtonTitles:@"保存图片",nil];
    
    [actionSheet show];
    actionSheet = nil;
  
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{

    NSString *saveResult = @"";
    if (error) {
        saveResult = @"保存失败";
    }   else {
        saveResult= @"保存成功";
    }

    [ShowResult showResult:saveResult succeed:YES];

    saveResult = nil;
}

#pragma mark - lazy
- (UICollectionView *)collectionView
{
    if (_collectionView == nil) {
        
        CGRect bounds = [UIScreen mainScreen].bounds;
        bounds.size.width += PhotoBrowerMargin;
        
        // 1.create layout
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setItemSize:bounds.size];
        [layout setMinimumInteritemSpacing:0];
        [layout setMinimumLineSpacing:0];
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:bounds collectionViewLayout:layout];
        collectionView.backgroundColor = [UIColor clearColor];
        [collectionView setPagingEnabled:YES];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([PhotoBrowserCell class]) bundle:nil] forCellWithReuseIdentifier:PhotoBrowserCellIdentifier];
        [self.view addSubview:collectionView];
        _collectionView = collectionView;
    }
    return _collectionView;
}
- (UIPageControl *)pageCtl
{
    if (_pageCtl == nil && !_msg_type) {
        UIPageControl *pageCtl = [[UIPageControl alloc] init];
        pageCtl.userInteractionEnabled = NO;
        pageCtl.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 49, [UIScreen mainScreen].bounds.size.width, 49);
        [self.view addSubview:pageCtl];
        
        _pageCtl = pageCtl;
    }
    return _pageCtl;
}
@end
