
#import <UIKit/UIKit.h>
#import "AssetHelper.h"
@protocol SelectAlbumDelegate<NSObject>
-(void)selectAlbum:(ALAssetsGroup *)album;
@end

@interface LocalAlbumTableViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{


    UIControl *titleView;
    UIView *bodyView;
    UITableView *albumTableView;
    
     BOOL isIos8;
}




@property(nonatomic,assign) id<SelectAlbumDelegate> delegate;
@end
