
#import "LocalPhotoViewController.h"
#import "UIColor+additions.h"
#import "MainViewController.h"
@interface LocalPhotoViewController ()
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;

@end

@implementation LocalPhotoViewController{
    UIBarButtonItem *btnDone;
    NSMutableArray *selectPhotoNames;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (UIStatusBarStyle)preferredStatusBarStyle{
    
    return UIStatusBarStyleLightContent;
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
   
    
    picWidth = (SCREENWIDTH-25)/4;
    
    titleView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 64)];
    [titleView setBackgroundColor:MAINCOLOR];
    
    [self.view addSubview:titleView];
    [self.view bringSubviewToFront:bodyView];
    
    UIControl *backControl = [[UIControl alloc] initWithFrame:CGRectMake(0, 20, 50, 44)];
    [backControl setBackgroundColor:[UIColor clearColor]];
    
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 14, 10.4, 16)];
    UIImage *back = [UIImage imageNamed:@"goBack_white.png"];
    [backImageView setImage:back];
    [backImageView setContentMode:UIViewContentModeScaleAspectFill];
    [backControl addTarget:self action:@selector(beBack) forControlEvents:UIControlEventTouchUpInside];
    [backControl addSubview:backImageView];
    [titleView addSubview:backControl];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREENWIDTH-150)/2, 20, 150, 44)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
    titleLabel.text = @"选择照片";
    [titleView addSubview:titleLabel];
    
    
    UIButton *albumBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH-50, 20, 50, 44)];
    
    [albumBtn setBackgroundColor:[UIColor clearColor]];
    [albumBtn setTitle:@"相册" forState:UIControlStateNormal];
    albumBtn.titleLabel.font = [UIFont fontWithName:textDefaultFont size: 13];
    [albumBtn setTitleColor:[UIColor getColor:@"d8d8d8"] forState:UIControlStateHighlighted];
    [albumBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [albumBtn addTarget:self action:@selector(albumAction) forControlEvents:UIControlEventTouchUpInside];
    
    [titleView addSubview:albumBtn];
    
    
    
    bodyView = [[UIView alloc] initWithFrame:CGRectMake(0, titleView.frame.size.height+titleView.frame.origin.y, SCREENWIDTH, SCREENHEIGHT-titleView.frame.size.height)];
    
    [bodyView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:bodyView];
    
    
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(picWidth, picWidth);
    flowLayout.minimumInteritemSpacing = 5;
    flowLayout.minimumLineSpacing = 5;
    
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    if(self.isTuya){
        collection = [[UICollectionView alloc]initWithFrame:CGRectMake(5, 5, SCREENWIDTH-10,bodyView.frame.size.height-10) collectionViewLayout:flowLayout];
    }else{
        collection = [[UICollectionView alloc]initWithFrame:CGRectMake(5, 5, SCREENWIDTH-10,bodyView.frame.size.height-55) collectionViewLayout:flowLayout];
    }
    
    
    [collection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"photocell"];
    [collection setBackgroundColor:[UIColor whiteColor]];
    
    //设置代理
    collection.delegate = self;
    collection.dataSource = self;
    [bodyView addSubview:collection];
    
    
    if(!self.isTuya){
        bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, bodyView.frame.size.height-45, SCREENWIDTH, 45)];
        
        UIImageView *bottomLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 0.5)];
        [bottomLine setBackgroundColor:[UIColor lightGrayColor]];
        bottomLine.alpha = 0.8;
        
        [bottomView setBackgroundColor:[UIColor getColor:@"F3F3F6"]];
        [bottomView addSubview:bottomLine];
        [bodyView addSubview:bottomView];
        
        lbAlert = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 45)];
        lbAlert.text = @"请选择照片";
        lbAlert.textAlignment = NSTextAlignmentLeft;
        lbAlert.textColor = [UIColor lightGrayColor];
        lbAlert.font = [UIFont fontWithName:textDefaultFont size: 14];
        [bottomView addSubview: lbAlert];
        
        
        okBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH-73, (45-33)/2, 60, 33)];
        [okBtn setBackgroundColor:[UIColor lightGrayColor]];
        [okBtn setEnabled:NO];
        
        [okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        okBtn.layer.cornerRadius = 4;
        [okBtn addTarget:self action:@selector(readyClickDown) forControlEvents:UIControlEventTouchDown];
        [okBtn addTarget:self action:@selector(readyClickUp) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchUpInside];
        if(self.isQuan){
            [okBtn setTitle:@"完成" forState:UIControlStateNormal];
        }else{
            [okBtn setTitle:@"发送" forState:UIControlStateNormal];
        }
        okBtn.titleLabel.font = [UIFont fontWithName:textDefaultFont size: 14];
        [bottomView addSubview: okBtn];
        
    
    }
    
    
    
    if(self.selectPhotos==nil)
    {
        self.selectPhotos=[[NSMutableArray alloc] init];
        selectPhotoNames=[[NSMutableArray alloc] init];
    }else{
        selectPhotoNames=[[NSMutableArray alloc] init];
        
        if(!self.isTuya){
            for (ALAsset *asset in self.selectPhotos ) {
                //NSLog(@"%@",[asset valueForProperty:ALAssetPropertyAssetURL]);
                [selectPhotoNames addObject:[asset valueForProperty:ALAssetPropertyAssetURL]];
            }
            lbAlert.text=[NSString stringWithFormat:@"已经选择%lu张照片",(unsigned long)self.selectPhotos.count];
        }
        
    }
    
    
    
    
    
    NSUInteger groupTypes = ALAssetsGroupSavedPhotos;//默认打开相机胶卷
    
    
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [group setAssetsFilter:onlyPhotosFilter];
        
        if ([group numberOfAssets] > 0)
        {
            [self showPhoto:group];
        }
        else
        {
            NSLog(@"读取相册完毕");
            
        }
    };
    
    [[AssetHelper defaultAssetsLibrary] enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock                                    failureBlock:nil];
}

-(void)readyClickDown{
    okBtn.alpha = 0.6;
}

-(void)readyClickUp{
    [self performSelector:@selector(chooseOk) withObject:nil afterDelay:0.1f];
    
}

-(void)chooseOk{
    
    [okBtn setEnabled:NO];
    okBtn.alpha = 1;
    
    if (self.selectPhotoDelegate!=nil) {
        [self.selectPhotoDelegate getSelectedPhoto:self.selectPhotos];
    }
    [self.navigationController popViewControllerAnimated:YES];
}



-(void)albumAction{
    LocalAlbumTableViewController *album=[[LocalAlbumTableViewController alloc] init];
    
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:album];
    [nvc setNavigationBarHidden:YES];
    album.delegate=self;
    [self.navigationController presentViewController:nvc animated:YES completion:^(void){
        NSLog(@"打开相册");
    }];
    
}





-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.photos.count;
}


#define kImageViewTag 1 // the image view inside the collection view cell prototype is tagged with "1"
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"photocell";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    AlbumEntity *entity = [self.photos objectAtIndex:indexPath.row];
    
    ALAsset *asset=[entity.photoArray objectAtIndex:1];
    CGImageRef thumbnailImageRef = [asset thumbnail];
    UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
    NSString *url=[asset valueForProperty:ALAssetPropertyAssetURL];
    
    
    UIImageView *picView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, picWidth, picWidth)];
    [picView setContentMode:UIViewContentModeScaleAspectFill];
    [cell addSubview:picView];
    
    [picView setImage:thumbnail];
    
    UIImageView *chooseView = [[UIImageView alloc] initWithFrame:CGRectMake(picWidth-picWidth/4-2, picWidth-picWidth/4-2, picWidth/4, picWidth/4)];
    [chooseView setContentMode:UIViewContentModeScaleAspectFill];
    [chooseView setImage:[UIImage imageNamed:@"img_isselect.png"]];
    chooseView.alpha = 0;
    chooseView.tag = 2222;
    
    
    if([selectPhotoNames indexOfObject:url]==NSNotFound){
        chooseView.alpha = 0;
    }else{
        chooseView.alpha = 1;
    }
    
    [cell addSubview:chooseView];
    [cell bringSubviewToFront:chooseView];
    
    entity = nil;
    
    return cell;
}



-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    AlbumEntity *entity = [self.photos objectAtIndex:indexPath.row];
    
    if(self.isTuya){
        
        
        
        ALAsset *asset=[entity.photoArray objectAtIndex:1];
        [self.selectPhotos addObject:asset];
        
        
        
        [self.selectPhotoDelegate getSelectedPhoto:self.selectPhotos];
        
        [self.navigationController popViewControllerAnimated:YES];
        
        entity = nil;
        return;
        
    }
    
    NSString *status = [NSString stringWithFormat:@"%@",[entity.photoArray objectAtIndex:0]];
    
    NSInteger most;
    if(self.isQuan){
        most = self.mostCount;
    }else{
        most = 9;
    }

    
    if([status integerValue] == 0)
    {
        if(self.selectPhotos.count>most-1){
            
            UIAlertView * alert = [[UIAlertView alloc]
                                   initWithTitle:[NSString stringWithFormat:@"%@%d%@",@"您最多只能选择",most,@"张照片"]
                                   message:@""
                                   delegate:self
                                   cancelButtonTitle:@"我知道了"
                                   otherButtonTitles:nil];
            
            [alert show];
            
            return;
        }
        
        
        NSMutableArray *temp1Array = [[NSMutableArray alloc] init];
        
        [temp1Array addObject:@"1"];
        [temp1Array addObject:[entity.photoArray objectAtIndex:1]];
        entity.photoArray = temp1Array;
        temp1Array = nil;
        
        
        
        [self.photos replaceObjectAtIndex:indexPath.row withObject:entity];
        
        
        
        ALAsset *asset=[entity.photoArray objectAtIndex:1];
        [self.selectPhotos addObject:asset];
        [selectPhotoNames addObject:[asset valueForProperty:ALAssetPropertyAssetURL]];
    }else{
        
        NSMutableArray *temp1Array = [[NSMutableArray alloc] init];
        
        [temp1Array addObject:@"0"];
        [temp1Array addObject:[entity.photoArray objectAtIndex:1]];
        entity.photoArray = temp1Array;
        temp1Array = nil;
        
        
        [self.photos replaceObjectAtIndex:indexPath.row withObject:entity];
        
        
        ALAsset *asset=[entity.photoArray objectAtIndex:1];
        for (ALAsset *a in self.selectPhotos) {
            //            NSLog(@"%@-----%@",[asset valueForProperty:ALAssetPropertyAssetURL],[a valueForProperty:ALAssetPropertyAssetURL]);
            NSString *str1=[asset valueForProperty:ALAssetPropertyAssetURL];
            NSString *str2=[a valueForProperty:ALAssetPropertyAssetURL];
            if([str1 isEqual:str2])
            {
                [self.selectPhotos removeObject:a];
                break;
            }
        }
        
        [selectPhotoNames removeObject:[asset valueForProperty:ALAssetPropertyAssetURL]];
    }
    
    if(self.selectPhotos.count==0)
    {
        lbAlert.text=@"请选择照片";
        [okBtn setBackgroundColor:[UIColor lightGrayColor]];
        [okBtn setEnabled:NO];
    }
    else{
        lbAlert.text=[NSString stringWithFormat:@"已经选择%lu张照片",(unsigned long)self.selectPhotos.count];
        [okBtn setBackgroundColor:MAINCOLOR];
        [okBtn setEnabled:YES];
    }
    
    entity = nil;
    
    [collectionView reloadData];
}


-(void) showPhoto:(ALAssetsGroup *)album
{
    if(album!=nil)
    {
        
        [titleLabel setText:[album valueForProperty:ALAssetsGroupPropertyName]];
        
        if(self.currentAlbum==nil||![[self.currentAlbum valueForProperty:ALAssetsGroupPropertyName] isEqualToString:[album valueForProperty:ALAssetsGroupPropertyName]])
        {
            self.currentAlbum=album;
            if (!self.photos) {
                _photos = [[NSMutableArray alloc] init];
            } else {
                [self.photos removeAllObjects];
                
            }
            
            ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    
                    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
                    [resultArray addObject:@"0"];//选中状态
                    [resultArray addObject:result];
                    
                    AlbumEntity *albumee = [[AlbumEntity alloc] init];
                    albumee.sort = index;
                    albumee.photoArray = resultArray;
                    [self.photos addObject:albumee];
                    resultArray = nil;
                    albumee = nil;
                }else{
                }
            };
            
            ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
            [self.currentAlbum setAssetsFilter:onlyPhotosFilter];
            [self.currentAlbum enumerateAssetsUsingBlock:assetsEnumerationBlock];
            
            [self.selectPhotos removeAllObjects];
            [selectPhotoNames removeAllObjects];
            
            lbAlert.text=@"请选择照片";
            [okBtn setBackgroundColor:[UIColor lightGrayColor]];
            [okBtn setEnabled:NO];
            
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:NO];
            NSMutableArray *descriptors = [NSMutableArray arrayWithObjects:descriptor,nil];
            [self.photos sortUsingDescriptors:descriptors];
            
            descriptors = nil;
            descriptor = nil;
            
            [collection reloadData];
        }
    }
}
-(void)selectAlbum:(ALAssetsGroup *)album{
    [self showPhoto:album];
}

- (void)beBack{
    
    //退回到第一个窗口
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    
    titleView = nil;
    bodyView = nil;
    collection = nil;
    bottomView = nil;
    okBtn = nil;
    okBtn = nil;
    
    self.photos = nil;
    self.selectPhotos = nil;
    
    self.currentAlbum = nil;
    
}
@end
