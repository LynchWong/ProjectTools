
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "LocalAlbumTableViewController.h"
#import "AssetHelper.h"
#import "AlbumEntity.h"
@class ViewController;
@protocol SelectPhotoDelegate<NSObject>
-(void)getSelectedPhoto:(NSMutableArray *)photos;
@end

@interface LocalPhotoViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,SelectAlbumDelegate>{
    
    UIView *bottomView;
    UIButton *okBtn;
    UILabel *lbAlert;
    

    
    CGFloat picWidth;
    
    UIControl *titleView;
    UIView *bodyView;
    UILabel *titleLabel;
    UICollectionView *collection;
    
}



@property (nonatomic,retain) id<SelectPhotoDelegate> selectPhotoDelegate;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) ALAssetsGroup *currentAlbum;
@property (nonatomic, strong) NSMutableArray *selectPhotos;
@property (assign, nonatomic) BOOL isQuan;
@property (assign, nonatomic) NSInteger mostCount;
@property (assign, nonatomic) BOOL isTuya;

@end
