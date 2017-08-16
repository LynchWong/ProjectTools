

#import "LocalAlbumTableViewController.h"
#import "UIColor+additions.h"
#import "MainViewController.h"

@interface LocalAlbumTableViewController ()
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *albums;
@end

@implementation LocalAlbumTableViewController


- (UIStatusBarStyle)preferredStatusBarStyle{
    
    return UIStatusBarStyleLightContent;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    
    titleView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 64)];
    [titleView setBackgroundColor:MAINRED];
    
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
    
    UILabel *nameTitle = [[UILabel alloc] initWithFrame:CGRectMake((SCREENWIDTH-150)/2, 20, 150, 44)];
    nameTitle.textAlignment = NSTextAlignmentCenter;
    nameTitle.textColor = [UIColor whiteColor];
    nameTitle.font =  [UIFont fontWithName:textDefaultBoldFont  size:17];
    nameTitle.text = @"选择相册";
    [titleView addSubview:nameTitle];
    
    
    bodyView = [[UIView alloc] initWithFrame:CGRectMake(0, titleView.height+titleView.y, SCREENWIDTH, SCREENHEIGHT-titleView.height)];
    
    [bodyView setBackgroundColor:[UIColor getColor:@"EFEEF4"]];
    [self.view addSubview:bodyView];
    
    
    albumTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, bodyView.height)];
    
    [bodyView addSubview:albumTableView];
    albumTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; //隐藏tableview多余行数的线条
    
    
    albumTableView.delegate = self;//调用delegate
    albumTableView.dataSource=self;
    
    if(([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
       self.edgesForExtendedLayout = UIRectEdgeNone;
       self.extendedLayoutIncludesOpaqueBars = NO;
       self.modalPresentationCapturesStatusBarAppearance = NO;
    }

    
    if (self.assetsLibrary == nil) {
            _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    if (self.albums == nil) {
        _albums = [[NSMutableArray alloc] init];
    } else {
        [self.albums removeAllObjects];
    }
    
    
    
    // setup our failure view controller in case enumerateGroupsWithTypes fails
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        
        NSString *errorMessage = nil;
        switch ([error code]) {
            case ALAssetsLibraryAccessUserDeniedError:
            case ALAssetsLibraryAccessGloballyDeniedError:
                errorMessage = @"The user has declined access to it.";
                break;
            default:
                errorMessage = @"Reason unknown.";
                break;
        }
        
    };
    

    
    // emumerate through our groups and only add groups that contain photos
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [group setAssetsFilter:onlyPhotosFilter];
        if ([group numberOfAssets] > 0)
        {
            [self.albums addObject:group];
        }
        else
        {
            [albumTableView reloadData];
            //[self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    };
    
    // enumerate only photos
    NSUInteger groupTypes = ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupPhotoStream|ALAssetsGroupSavedPhotos|ALAssetsGroupAll;
    [[AssetHelper defaultAssetsLibrary] enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)cancleAction{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger num=[_albums count];
    return num;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier=@"AlbumCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }else{
        
        if(isIos8){
            for (UIView *cellView in cell.subviews){
                [cellView removeFromSuperview];
            }
        }else{
            for (UIView *cellView in cell.subviews){ //ios7上cell第一层还有个scrollView
                for (UIView *cellView1 in cellView.subviews){
                    [cellView1 removeFromSuperview];
                }
            }
        }
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;//cell选中变灰
    
    
    
    ALAssetsGroup *group=[_albums objectAtIndex:indexPath.row];
    CGImageRef posterImageRef=[group posterImage];
    UIImage *posterImage=[UIImage imageWithCGImage:posterImageRef];
    
    UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 60)];
    [cellView setBackgroundColor:[UIColor whiteColor]];
    [cell addSubview:cellView];
    
    UIImageView *imgCover = [[UIImageView alloc] initWithFrame:CGRectMake(15, 5, 50, 50)];
    [imgCover setImage:posterImage];
    [cellView addSubview:imgCover];
    
    UILabel *lbName = [[UILabel alloc] initWithFrame:CGRectMake(75, 0, 200, 30)];
    lbName.textAlignment = NSTextAlignmentLeft;
    lbName.textColor = [UIColor getColor:@"64676E"];
    lbName.font = [UIFont fontWithName:textDefaultFont size: 15];
    lbName.text = [group valueForProperty:ALAssetsGroupPropertyName];
    [cellView addSubview:lbName];
    
    UILabel *lbCount = [[UILabel alloc] initWithFrame:CGRectMake(75, 30, 200, 30)];
    lbCount.textAlignment = NSTextAlignmentLeft;
    lbCount.textColor = [UIColor lightGrayColor];
    lbCount.font = [UIFont fontWithName:textDefaultFont size: 14];
    lbCount.text = [@(group.numberOfAssets) stringValue];
    [cellView addSubview:lbCount];
    

    [cellView addSubview:[APPUtils get_forward:60 x:SCREENWIDTH-22]];

    
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    if(self.delegate!=nil)
    {
        [self.delegate selectAlbum:self.albums[indexPath.row]];
    }
    
}

- (void)beBack{
    
    //退回到第一个窗口
     [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


- (void)beBackWithRefresh{
    
    //退回到第一个窗口
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)dealloc {
    albumTableView = nil;
    titleView = nil;
    bodyView = nil;
    

}
@end
