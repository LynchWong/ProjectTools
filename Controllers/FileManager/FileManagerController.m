//
//  FileManagerController.m
//  MedicalCenter
//
//  Created by 李狗蛋 on 15-6-15.
//  Copyright (c) 2015年 李狗蛋. All rights reserved.
//

#import "FileManagerController.h"
#import "MainViewController.h"
#import "MovieViewController.h"
#import "FileChecker.h"

@implementation FileManagerController{
    NSMutableArray *selectPhotoNames;
}


- (id)initWithClean{
    self = [super init];
    if (self) {
        clean_type = YES;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    

    
    [self initData];
    [self initUiControls];
    
    [ShowWaiting showWaiting:@"文件加载中,请稍后"];
    
    //获取沙盒文件
    NSThread *aThread = [[NSThread alloc] initWithTarget:self selector:@selector(getLocalData) object:nil];
    [aThread start];
 
    
    if(!clean_type){
        //加载相册文件
        NSThread *aThread = [[NSThread alloc] initWithTarget:self selector:@selector(getAlbumData) object:nil];
        [aThread start];
    }
   
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    
    return UIStatusBarStyleLightContent;
    
}

-(void)initData{
    
    cellheight = 90;
    sectionHeight = 45;
    lastSelectIndex = -1;
    
    documentsArr = [[NSMutableArray alloc] init];
    albumArr = [[NSMutableArray alloc] init];
    allVideoArr = [[NSMutableArray alloc] init];
    musicArr = [[NSMutableArray alloc] init];
    otherArr = [[NSMutableArray alloc] init];
    
    selectFilesList = [[NSMutableArray alloc] init];
    menuUIArray = [[NSMutableArray alloc] init];
    
    if(!clean_type){
        //左右滑动手势
        UISwipeGestureRecognizer *leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
        UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
        
        leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        
        [self.view addGestureRecognizer:leftSwipeGestureRecognizer];
        [self.view addGestureRecognizer:rightSwipeGestureRecognizer];
        
        
        leftSwipeGestureRecognizer = nil;
        rightSwipeGestureRecognizer = nil;
    }
   
}


-(void)initUiControls{
    
    ZppTitleView *titletView = [[ZppTitleView alloc] initWithTitle:clean_type?@"历史文件管理":@"文件选择"];
    [self.view addSubview:titletView];
    titletView.goback = ^(){
        [self beBack];
    };


    if(clean_type){
        __weak typeof(self) weakSelf = self;
        selectAllBtn = [[MyBtnControl alloc] initWithFrame:CGRectMake(SCREENWIDTH-70, 20, 70, 44)];
        [titletView addSubview:selectAllBtn];
        selectAllBtn.alpha=0;
        [selectAllBtn addLabel:@"全部勾选" color:[UIColor whiteColor] font:[UIFont fontWithName:textDefaultFont size:12]];
        selectAllBtn.clickBackBlock = ^(){
            [weakSelf selectAllFiles];
        };
       
    }
    

    UIView *bodyView = [[UIView alloc] initWithFrame:CGRectMake(0, TITLE_HEIGHT, SCREENWIDTH, BODYHEIGHT)];
    [bodyView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:bodyView];
    

   
    if(!clean_type){
        //标签菜单
        menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 45)];
        [bodyView addSubview:menuView];
        
        [self addMenuControl:0 name:@"文档"];
        [self addMenuControl:1 name:@"相册"];
        [self addMenuControl:2 name:@"视频"];
        [self addMenuControl:3 name:@"音乐"];
        [self addMenuControl:4 name:@"其他"];
        
        [menuView addSubview:[APPUtils get_line:0 y:menuView.height-0.5 width:SCREENWIDTH]];
        
        menuBar = [[UIView alloc] initWithFrame:CGRectMake(0, menuView.height-3, SCREENWIDTH/5, 3)];
        [menuBar setBackgroundColor:MAINCOLOR];
        [menuView addSubview:menuBar];
        
    }
    
    
    //table
    if(self.isMamsWeb || clean_type){
        tableHeight = BODYHEIGHT-45;
    }else{
        tableHeight = BODYHEIGHT-45*2;
    }
    
    
    fileTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, menuView.height, SCREENWIDTH, tableHeight)];
    fileTableView.delegate = self;
    fileTableView.dataSource = self;
    fileTableView.showsVerticalScrollIndicator = YES;
    //不要分割线
    fileTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [bodyView addSubview:fileTableView];
    
    
    
    //发送文件
    if(!self.isMamsWeb){
        
        __weak typeof(self) weakSelf = self;
        
        sendview = [[UIView alloc] initWithFrame:CGRectMake(0, BODYHEIGHT-45, SCREENWIDTH, 45)];
        [sendview setBackgroundColor:MAINGRAY];
        [bodyView addSubview:sendview];
        
        [sendview addSubview:[APPUtils get_line:0 y:0 width:SCREENWIDTH]];
   
        sendBtn = [[MyBtnControl alloc] initWithFrame:CGRectMake(SCREENWIDTH-73, (sendview.height-30)/2, 60, 30)];
        [sendview addSubview: sendBtn];
        [sendBtn setBackgroundColor:[UIColor lightGrayColor]];
        [sendBtn setEnabled:NO];
        sendBtn.layer.cornerRadius = 5;
        [sendBtn addLabel:clean_type?@"删除":@"发送" color:[UIColor whiteColor] font:[UIFont fontWithName:textDefaultBoldFont size:12]];
        sendBtn.clickBackBlock = ^(){
            [weakSelf getFile];
        };
        
        
        fileCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, sendBtn.x-20, 45)];
        fileCountLabel.text = @"请选择文件";
        fileCountLabel.textAlignment = NSTextAlignmentLeft;
        fileCountLabel.textColor = [UIColor lightGrayColor];
        fileCountLabel.font = [UIFont fontWithName:textDefaultFont size:12];
        [sendview addSubview: fileCountLabel];
        
    }
    
    
}

//增加菜单按键
-(void)addMenuControl:(NSInteger)tag name:(NSString*)name{

    float menuBtnWidth = SCREENWIDTH/5;
    
    MyBtnControl *menuControl = [[MyBtnControl alloc] initWithFrame:CGRectMake(menuBtnWidth*tag, 0, menuBtnWidth, menuView.height)];
    [menuView addSubview:menuControl];
    
    [menuControl addLabel:name color:(tag==0?MAINCOLOR:[UIColor lightGrayColor]) font:[UIFont fontWithName:textDefaultFont size:14]];
    
    [menuUIArray addObject:menuControl];
    
    menuControl.clickBackBlock = ^(){
        [self changeColumn:tag];
    };
    
 
}

//切换栏目
-(void)changeColumn:(NSInteger)tag{

    dispatch_async(dispatch_get_main_queue(), ^{
        if(tag != lastSelectIndex){
            lastSelectIndex = tag;
            NSInteger index = 0;
            for(MyBtnControl *btn in menuUIArray){
                if(tag!=index){
                    btn.shareLabel.textColor = [UIColor lightGrayColor];
                }else{
                    btn.shareLabel.textColor = MAINCOLOR;
                }
                index++;
            }
            
            [UIView animateWithDuration:0.2 animations:^{
                [menuBar setFrame:CGRectMake(tag*(menuBar.width), menuBar.y, menuBar.width, menuBar.height)];
            }];
            
            
            now_column = tag;
            
            if(!clean_type){
                if(tag == 0){
                    datalist = [documentsArr mutableCopy];
                }else if(tag == 1){
                   
                    if(albumLoadOver){
                        datalist = [albumArr mutableCopy];
                    }else{
                        [datalist removeAllObjects];
                    }
                    
                }else if(tag == 2){
                    if(albumLoadOver){
                        datalist = [allVideoArr mutableCopy];
                    }else{
                        [datalist removeAllObjects];
                    }
                }else if(tag == 3){
                    datalist = [musicArr mutableCopy];
                }else if(tag == 4){
                    datalist = [otherArr mutableCopy];
                }
            }
            
            
            
            if([datalist count]>0){
                isEmpty = NO;
            }else{
                isEmpty = YES;
            }
            
            [UIView transitionWithView:fileTableView duration: 0.2 options: UIViewAnimationOptionTransitionCrossDissolve
                            animations: ^(void){
                                [fileTableView reloadData];
                            }completion:^(BOOL finished){
                                [ShowWaiting hideWaiting];
                            }];
        }
    });
    
}



//手势左右滑动
- (void)handleSwipes:(UISwipeGestureRecognizer *)sender{
    
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        if(lastSelectIndex<4){
            [self changeColumn:lastSelectIndex+1];
        }
    }
    
    if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
        if(lastSelectIndex>0){
            [self changeColumn:lastSelectIndex-1];
        }
    }
}

//全选
-(void)selectAllFiles{
    if(!isEmpty){
        
        [selectFilesList removeAllObjects];
        
        BOOL add= NO;
        if([selectAllBtn.shareLabel.text hasPrefix:@"全部勾选"]){
            add = YES;
            selectAllBtn.shareLabel.text = @"取消全选";
            [sendBtn setBackgroundColor:MAINCOLOR];
            [sendBtn setEnabled:YES];
        }else{
            selectAllBtn.shareLabel.text = @"全部勾选";
            fileCountLabel.text = @"请选择文件";
            [sendBtn setBackgroundColor:[UIColor lightGrayColor]];
            [sendBtn setEnabled:NO];
        }
        
        NSMutableArray *tempArr = [datalist mutableCopy];
        float totalSize = 0;//kb
        
        NSInteger i=0;
        for(NSMutableDictionary *fileDic in tempArr){
            @try {
                NSMutableArray *fileArr = [fileDic objectForKey:@"array"];
                NSMutableArray *tempFileArr = [fileArr mutableCopy];
                NSInteger j=0;
                for(FilesEntity *file in tempFileArr){
                    if(add){
                        file.selected = 1;
                        [selectFilesList addObject:file];//增加
                    }else{
                        file.selected = 0;
                    }
                    
                    totalSize+=file.fileSize;
                    
                    [fileArr replaceObjectAtIndex:j withObject:file];
                    [fileDic setObject:fileArr forKey:@"array"];
                    j++;
                }
                fileArr = nil;
                tempFileArr = nil;
                
                [datalist replaceObjectAtIndex:i withObject:fileDic];
                
            } @catch (NSException *exception) {}
            i++;
        }
        

        if(add){
             fileCountLabel.text = [NSString stringWithFormat:@"共选择%d个文件,合计%@",(int)[selectFilesList count],[APPUtils fileSizeConver:totalSize]];
        }
       
        
        [UIView transitionWithView:fileTableView duration: 0.2 options: UIViewAnimationOptionTransitionCrossDissolve
                        animations: ^(void){
                            [fileTableView reloadData];
                        }completion:NULL];
        
    }
}

//获取本地沙盒文件
-(void)getLocalData{

    [documentsArr removeAllObjects];
    [albumArr removeAllObjects];
    [musicArr removeAllObjects];
    [allVideoArr removeAllObjects];
    [otherArr removeAllObjects];

    
    
    //遍历文件
    NSArray *allFiles_Array = [APPUtils filesByModDate:[MainViewController sharedMain].conversationPaths];
    filesCount = [allFiles_Array count];
    

    NSMutableArray *allFilesArray = [[NSMutableArray alloc]init];
    
    //倒序
    if([allFiles_Array count]>0){
        
        NSMutableArray *tempFileArray = [[NSMutableArray alloc]init];
        NSInteger i=0;
        for(NSString *name in allFiles_Array){
            FilesEntity *file = [[FilesEntity alloc] init];
            file.sort = i;
            file.fileName = name;
            [tempFileArray addObject:file];
            file = nil;
            i++;
        }
        
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:NO];
        NSMutableArray *descriptors = [NSMutableArray arrayWithObjects:descriptor,nil];
        [tempFileArray sortUsingDescriptors:descriptors];
        
        descriptors = nil;
        descriptor = nil;
        
        for(FilesEntity *file in tempFileArray){
            [allFilesArray addObject:file.fileName];
        }
        tempFileArray = nil;
        selectAllBtn.alpha=1;
    }else{
        allFilesArray = [allFiles_Array mutableCopy];
        selectAllBtn.alpha=0;
    }
    

    
    //分类数组
    NSMutableArray *wordlist = [[NSMutableArray alloc] init];
    NSMutableArray *excellist = [[NSMutableArray alloc] init];
    NSMutableArray *pptlist = [[NSMutableArray alloc] init];
    NSMutableArray *textlist = [[NSMutableArray alloc] init];
    NSMutableArray *pdflist = [[NSMutableArray alloc] init];
    NSMutableArray *picslist = [[NSMutableArray alloc] init];
    NSMutableArray *musiclist = [[NSMutableArray alloc] init];
    NSMutableArray *videoslist = [[NSMutableArray alloc] init];
    NSMutableArray *ziplist = [[NSMutableArray alloc] init];
    NSMutableArray *unknownlist = [[NSMutableArray alloc] init];
    
    
    for(NSString *fileName in allFilesArray){
        
        @try {
            
            if([fileName hasPrefix:@"thumb_"] || [fileName hasPrefix:@"tempRecord.wav"] || [fileName hasPrefix:@"snap_"] || [fileName hasSuffix:@".amr"] || [fileName hasPrefix:@"mine_"] || [fileName hasPrefix:@"md5File"]){
                continue;
            }
            
            FilesEntity *file = [[FilesEntity alloc] init];
            file.fileName = fileName;
            
            NSArray * parts = [fileName componentsSeparatedByString:@"."];
            NSString *tail = [parts lastObject];//后缀
            file.tail = tail;
            parts = nil;
         
            float fileS = ([APPUtils fileSizeAtPath:[[MainViewController sharedMain].conversationPaths stringByAppendingPathComponent:fileName]])/1024.0;//kb
            file.fileSize = fileS;
            file.fileSizeString = [APPUtils fileSizeConver:fileS];
          
            if([[APPUtils get_file_type:tail] isEqualToString:@"office"]){//文档类
                if([tail isEqualToString:@"txt"]){
                    [textlist addObject:file];
                }else if([tail hasPrefix:@"doc"]||[tail hasPrefix:@"dot"]){
                    [wordlist addObject:file];
                }else if([tail hasPrefix:@"ppt"]||[tail hasPrefix:@"pptx"]){
                    [pptlist addObject:file];
                }else if([tail hasPrefix:@"xls"] || [tail hasPrefix:@"xlt"]){
                    [excellist addObject:file];
                }else if([tail hasPrefix:@"pdf"]){
                    [pdflist addObject:file];
                }
            }else if([[APPUtils get_file_type:tail] isEqualToString:@"pic"]){//图片类
                
                UIImage *thumb = [UIImage imageWithContentsOfFile:[[MainViewController sharedMain].conversationPaths stringByAppendingPathComponent:file.fileName]];
                NSData *imgData = UIImageJPEGRepresentation(thumb, 0.4);
                
                if(imgData.length>30000){//>30k只有剪裁
                    
                    CGSize imageSize = thumb.size;
                    imageSize.width =  imageSize.width*0.4;
                    imageSize.height = imageSize.height*0.4;
                    thumb = [APPUtils scaleToSize:thumb size:imageSize];
                }
                file.thumb = thumb;
                thumb = nil;
                [picslist addObject:file];
            }else if([[APPUtils get_file_type:tail] isEqualToString:@"video"]){//视频类
                [videoslist addObject:file];
            }else if([[APPUtils get_file_type:tail] isEqualToString:@"audio"]){//音频类
                [musiclist addObject:file];
            }else if([[APPUtils get_file_type:tail] isEqualToString:@"zip"]){//压缩类
                [ziplist addObject:file];
            }else{//其他
                [unknownlist addObject:file];
            }

           
            
        } @catch (NSException *exception) {}
    
    }
    
    //装填
    if([textlist count]>0){
        [documentsArr addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"TXT",@"title",textlist,@"array",clean_type?@"1":@"0",@"status", nil]];
    }
    if([wordlist count]>0){
        [documentsArr addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"WORD",@"title",wordlist,@"array",clean_type?@"1":@"0",@"status", nil]];
    }
    if([pptlist count]>0){
        [documentsArr addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"PPT",@"title",pptlist,@"array",clean_type?@"1":@"0",@"status", nil]];
    }
    if([excellist count]>0){
        [documentsArr addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"EXCEL",@"title",excellist,@"array",clean_type?@"1":@"0",@"status", nil]];
    }
    if([pdflist count]>0){
        [documentsArr addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"PDF",@"title",pdflist,@"array",clean_type?@"1":@"0",@"status", nil]];
    }
    if([picslist count]>0){
        [albumArr insertObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"历史图片",@"title",picslist,@"array",@"1",@"pic",@"1",@"sort",(clean_type?@"1":@"0"),@"status", nil] atIndex:0];
    }
    if([musiclist count]>0){
        [musicArr addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"本地音乐",@"title",musiclist,@"array",clean_type?@"1":@"0",@"status", nil]];
    }
    if([videoslist count]>0){
        [allVideoArr insertObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"历史视频",@"title",videoslist,@"array",@"2",@"pic",clean_type?@"1":@"0",@"status",@"1",@"sort", nil] atIndex:0];
    }
    if([ziplist count]>0){
        [otherArr addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"压缩文件",@"title",ziplist,@"array",clean_type?@"1":@"0",@"status", nil]];
    }
    if([unknownlist count]>0){
        [otherArr addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"其他文件",@"title",unknownlist,@"array",clean_type?@"1":@"0",@"status", nil]];
    }
    
    
    
    allFilesArray = nil;
    wordlist = nil;
    excellist = nil;
    pptlist = nil;
    textlist = nil;
    pdflist = nil;
    picslist = nil;
    musiclist = nil;
    videoslist = nil;
    ziplist = nil;
    unknownlist = nil;
    
    
    
    if(clean_type){
     
        
        datalist = [[NSMutableArray alloc] init];
        
        if([documentsArr count]>0){
            [datalist addObjectsFromArray:documentsArr];
        }
        if([albumArr count]>0){
            [datalist addObjectsFromArray:albumArr];
        }
        if([allVideoArr count]>0){
            [datalist addObjectsFromArray:allVideoArr];
        }
        if([musicArr count]>0){
            [datalist addObjectsFromArray:musicArr];
        }
        if([otherArr count]>0){
            [datalist addObjectsFromArray:otherArr];
        }
        
    }else{
        //默认值
        if([documentsArr count]>0){
            NSMutableDictionary*dic0 = [documentsArr objectAtIndex:0];
            [dic0 setObject:@"1" forKey:@"status"];
            [documentsArr replaceObjectAtIndex:0 withObject:dic0];
            dic0 = nil;
        }
        
        if([musicArr count]>0){
            NSMutableDictionary*dic0 = [musicArr objectAtIndex:0];
            [dic0 setObject:@"1" forKey:@"status"];
            [musicArr replaceObjectAtIndex:0 withObject:dic0];
            dic0 = nil;
        }
        if([otherArr count]>0){
            NSMutableDictionary*dic0 = [otherArr objectAtIndex:0];
            [dic0 setObject:@"1" forKey:@"status"];
            [otherArr replaceObjectAtIndex:0 withObject:dic0];
            dic0 = nil;
        }
    }
    
    
    [self changeColumn:0];

    [ShowWaiting hideWaiting];
}


//遍历本地相册 (弃用新方法 Photo库，因为不能在table里拿到实际图片的大小)
-(void)getAlbumData{
    
    
    __block NSMutableArray *videosArr = [[NSMutableArray alloc] init];//装所有视频
    
    //遍历相簿
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        
        
        if(group){
            ALAssetsFilter *allFilter = [ALAssetsFilter allAssets];//所有相簿过滤
            [group setAssetsFilter:allFilter];
            
            if ([group numberOfAssets] > 0){//该相册内有数据
                
                __block NSMutableArray *picArr = [[NSMutableArray alloc] init];//当前相册的图片
                __block NSString*albumName = [group valueForProperty:ALAssetsGroupPropertyName];//相册名字
                
                //遍历当前相册内的图片
                ALAssetsGroupEnumerationResultsBlock assetsPhotosBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    
                    
                    if (result){
    
                        FilesEntity *file = [[FilesEntity alloc] init];
                        file.asset = result;
                        file.albumPicType = YES;
                        [picArr addObject:file];
                        file = nil;
                    }
                    
                    if(*stop){//当前相簿的图片遍历完成
                        [albumArr addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:albumName,@"title",picArr,@"array",@"1",@"albumType",@"1",@"pic",@"2",@"sort",nil]];
                        albumName = nil;
                        picArr = nil;
                    }
                    
                };
                //遍历照片
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                [group enumerateAssetsUsingBlock:assetsPhotosBlock];
                
                
                
                //遍历相册内视频
                ALAssetsGroupEnumerationResultsBlock assetsVideosBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    
                    if (result){
                        FilesEntity *file = [[FilesEntity alloc] init];
                        file.asset = result;
                        [videosArr addObject:file];
                        file = nil;
                    }
                    if(*stop){//当前相簿的视频遍历完成
                        albumName = nil;
                    }
                    
                };
                //遍历视频
                [group setAssetsFilter:[ALAssetsFilter allVideos]];
                [group enumerateAssetsUsingBlock:assetsVideosBlock];
                
            }
        }else{
            
            //相簿遍历完成  这里用*stop没用
            if([videosArr count]>0){//所有视频
                [allVideoArr addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"本地视频",@"title",videosArr,@"array",@"1",@"albumType",@"2",@"pic",@"2",@"sort",nil]];
                videosArr = nil;
            }
            
            //默认值
            if([albumArr count]>0){
                
                NSMutableDictionary*dic0 = [albumArr objectAtIndex:0];
                [dic0 setObject:@"1" forKey:@"status"];
                [albumArr replaceObjectAtIndex:0 withObject:dic0];
                dic0 = nil;
            }
            if([allVideoArr count]>0){
                
                NSMutableDictionary*dic0 = [allVideoArr objectAtIndex:0];
                [dic0 setObject:@"1" forKey:@"status"];
                [allVideoArr replaceObjectAtIndex:0 withObject:dic0];
                dic0 = nil;
            }
        
            albumLoadOver = YES;
            
            if(now_column == 1||now_column == 2){
               
                dispatch_async(dispatch_get_main_queue(), ^{
                    lastSelectIndex=0;
                    [self changeColumn:now_column];
                });
                
            }
            
        }
        
    };
    
    
    // 遍历相册
    /*
     ALAssetsGroupFaces 自拍
     ALAssetsGroupPhotoStream 我的照片流
     ALAssetsGroupAlbum 用户自定义相册
     ALAssetsGroupSavedPhotos 相机胶卷 图片视频
     ALAssetsGroupAll 所有相册
     */
    
    NSUInteger groupTypes =  ALAssetsGroupAll ;
    [[AssetHelper defaultAssetsLibrary] enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:NULL];
    
}





#pragma mark----tableViewDelegate
//返回几个表头
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    if(isEmpty){
        return 1;
    }else{
        return datalist.count;
    }
    
}


//每一个表头下返回几行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(isEmpty){
        return 1;
    }else{
        NSDictionary *fileDic = [datalist objectAtIndex:section];
        
        NSInteger rows = 0;
        
        if([[fileDic objectForKey:@"status"] integerValue]==0){
            
        }else {
            
            NSArray *fileArr = [fileDic objectForKey:@"array"];
            rows = [fileArr count];
            fileArr = nil;
        }
        
        fileDic = nil;
        return  rows;
    }
    
    
}

//设置表头的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(isEmpty){
        return 0;
    }else{
        return sectionHeight;
    }
    
}


//设置view，将替代titleForHeaderInSection方法
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(!isEmpty){
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, sectionHeight)];
        view.backgroundColor = [UIColor whiteColor];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (sectionHeight-16)/2, 16, 16)];
        
        NSDictionary *fileDic = [datalist objectAtIndex:section];
        NSInteger status = [[fileDic objectForKey:@"status"] integerValue];
        if(status==0){
            imageView.image = [UIImage imageNamed:@"triangleRight.png"];
        }else{
            imageView.image = [UIImage imageNamed:@"triangleDown.png"];
        }
        
        [view addSubview:imageView];
        imageView = nil;
        
        
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, 200, sectionHeight)];
        titleLabel.text = [fileDic objectForKey:@"title"];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.textColor = TEXTGRAY;
        titleLabel.font = [UIFont fontWithName:textDefaultBoldFont size:14];
        [view addSubview:titleLabel];
        titleLabel = nil;
        
        MyBtnControl *button = [[MyBtnControl alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, sectionHeight)];
        [view addSubview:button];
        button.not_highlight=YES;
        button.clickBackBlock = ^(){
            if(status==0){
                [fileDic setValue:@"1" forKey:@"status"];
            }else {
                [fileDic setValue:@"0" forKey:@"status"];
            }
            [datalist replaceObjectAtIndex:section withObject:fileDic];
            [UIView transitionWithView:fileTableView duration: 0.1 options: UIViewAnimationOptionTransitionCrossDissolve
                            animations: ^(void){
                                [fileTableView reloadData];
                            }completion:NULL];
        };
        button = nil;
        
        [view addSubview:[APPUtils get_line:0 y:view.height-0.5 width:SCREENWIDTH]];
        
        return view;
    }else{
        return nil;
    }
    
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"FileCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

    }else{
        
        if([[[UIDevice currentDevice] systemVersion] floatValue] >=8.0){
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
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    
    if(isEmpty){
    
        if((now_column==1||now_column==2) && !albumLoadOver){
        
            UIActivityIndicatorView *juhua = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            juhua.center = CGPointMake(SCREENWIDTH/2, tableHeight/2);
            [juhua startAnimating];
            [cell addSubview:juhua];
            
            UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, tableHeight/2, SCREENWIDTH, 50)];
            loadingLabel.textAlignment = NSTextAlignmentCenter;
            loadingLabel.textColor = [UIColor lightGrayColor];
            loadingLabel.font = [UIFont fontWithName:textDefaultFont size:12];
            loadingLabel.text = @"分类文件加载中,请稍后...";
            [cell addSubview:loadingLabel];
            loadingLabel = nil;

            
        }else{
            UIImageView *no_mission_imageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREENWIDTH-ERROR_STATE_BACKGROUND_WIDTH)/2, (tableHeight-ERROR_STATE_BACKGROUND_WIDTH)/2, ERROR_STATE_BACKGROUND_WIDTH, ERROR_STATE_BACKGROUND_WIDTH)];
            
                [no_mission_imageView setImage:[UIImage imageNamed:@"no_files.png"]];
            
            [cell addSubview:no_mission_imageView];
            no_mission_imageView = nil;
        }
        
    }else{
        
        NSMutableDictionary *fileDic = [datalist objectAtIndex:indexPath.section];
        NSMutableArray *fileArr = [fileDic objectForKey:@"array"];
        FilesEntity *file = [fileArr objectAtIndex:indexPath.row];
        NSInteger picType = [[fileDic objectForKey:@"pic"] integerValue];//视频 图片类型
        NSInteger albumType = [[fileDic objectForKey:@"albumType"] integerValue];//相册文件类型
        
        float leftX = 15;
        UIImageView *selectImg;
        if(!self.isMamsWeb){
            //文件选择
            selectImg = [[UIImageView alloc]initWithFrame:CGRectMake(leftX, (cellheight-23)/2, 23, 23)];
         
            if(file.selected){
                selectImg.image = [UIImage imageNamed:@"img_isselect.png"];
            }else{
                selectImg.image = [UIImage imageNamed:@"empty_circle.png"];
            }
            
        }else{
        
            selectImg = [[UIImageView alloc]initWithFrame:CGRectMake(leftX, (cellheight-23)/2, 23, 23)];
            [selectImg setImage:[UIImage imageNamed:@"upload_cloud.png"]];
        }
        
        leftX = selectImg.x*2+selectImg.width;
        [cell addSubview:selectImg];
        selectImg = nil;
        
        //文件图片
        float fileImgHeight = cellheight*0.75;
        UIImageView *fileImg = [[UIImageView alloc] initWithFrame:CGRectMake(leftX, (cellheight-fileImgHeight)/2, fileImgHeight, fileImgHeight)];
        fileImg.layer.cornerRadius=2;
        [fileImg.layer setMasksToBounds:YES];
        [cell addSubview:fileImg];
        
        //名字
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(fileImg.width+fileImg.x+10, 0, SCREENWIDTH-(fileImg.width+fileImg.x+20), cellheight*0.7)];
        nameLabel.font = [UIFont fontWithName:textDefaultFont size:14];
        nameLabel.numberOfLines = 2;
        [nameLabel setTextColor:TEXTGRAY];
        nameLabel.text = file.fileName;
        [cell addSubview:nameLabel];
        
        //大小
        UILabel *sizeLabel = [[UILabel alloc]initWithFrame:CGRectMake(nameLabel.x, cellheight/2, nameLabel.width, cellheight*0.4)];
        sizeLabel.font = [UIFont fontWithName:textDefaultFont size:12];
        [sizeLabel setTextColor:[UIColor lightGrayColor]];
        sizeLabel.text = file.fileSizeString;
        [cell addSubview:sizeLabel];
        
        
        if(picType!=1 && albumType!=1){//文件或历史视频
            [fileImg setImage:[APPUtils getFileIcon:file.tail]];
        }else{
            [fileImg setContentMode:UIViewContentModeScaleAspectFill];
            if(albumType == 0){
                //历史图片
                [fileImg setImage:file.thumb];
            }else{
                
                //相册图片或视频
                if(file.thumb==nil){
                    
                    ALAssetRepresentation* representation = [file.asset defaultRepresentation];
                    file.fileName = [representation filename];
                    
                    file.fileSize = [representation size]/1024;
                    file.fileSizeString = [APPUtils fileSizeConver:file.fileSize];
                    
                    @try {
                        NSArray * parts = [file.fileName componentsSeparatedByString:@"."];
                        NSString *tail = [parts lastObject];//后缀
                        file.tail = tail;
                        parts = nil;
                    } @catch (NSException *exception) {}
                    
                    
                    CGImageRef thumbnailImageRef = [file.asset thumbnail];
                    file.thumb = [UIImage imageWithCGImage:thumbnailImageRef];
                    thumbnailImageRef = nil;
                    representation = nil;
                    
                    nameLabel.text = file.fileName ;
                    sizeLabel.text = file.fileSizeString;
                    [fileImg setImage:file.thumb];
                    
                }else{
                    [fileImg setImage:file.thumb];//cell重用
                }
            }
        }
        
        
        [cell addSubview:[APPUtils get_line:sizeLabel.x y:cellheight-0.5 width:SCREENWIDTH]];
        
        //选择
        MyBtnControl *cellBtn = [[MyBtnControl alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, cellheight)];
        [cell addSubview:cellBtn];
        cellBtn.not_highlight=YES;
        cellBtn.shareView = cell;
        cellBtn.clickBackBlock = ^(){
            
            if(!clean_type && !file.selected && [selectFilesList count]>=9){
                [ToastView showToast:[NSString stringWithFormat:@"最多只能选择%d个文件!",(int)[selectFilesList count]]];
                return ;
            }
            
            file.selected = !file.selected;
            [fileArr replaceObjectAtIndex:indexPath.row withObject:file];
            [fileDic setObject:fileArr forKey:@"array"];
            [datalist replaceObjectAtIndex:indexPath.section withObject:fileDic];
            
            NSIndexPath *iPath=[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
            [fileTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:iPath,nil] withRowAnimation:UITableViewRowAnimationNone];
            iPath = nil;
            
            @try {
                if(file.selected){
                    [selectFilesList addObject:file];//增加
                }else{
                    //删除已选
                    NSInteger index = 0;
                    NSInteger selectIndex = -1;
                    for(FilesEntity *f in selectFilesList){
                        if([f.fileName isEqualToString:file.fileName]){
                            selectIndex = index;
                            break;
                        }
                        index++;
                    }
                    if(selectIndex>=0){
                        [selectFilesList removeObjectAtIndex:selectIndex];
                    }
                }
                
                if([selectFilesList count]==0){
                    [sendBtn setBackgroundColor:[UIColor lightGrayColor]];
                    [sendBtn setEnabled:NO];
                    fileCountLabel.text = @"请选择文件";
                }else{
                    [sendBtn setBackgroundColor:MAINCOLOR];
                    [sendBtn setEnabled:YES];
                    
                    float totalSize = 0;//kb
                    for(FilesEntity *f in selectFilesList){
                        totalSize+=f.fileSize;
                    }
                    fileCountLabel.text = [NSString stringWithFormat:@"共选择%d个文件,合计%@",(int)[selectFilesList count],[APPUtils fileSizeConver:totalSize]];
                }

                if(clean_type){
                    if([selectFilesList count]>=filesCount){
                       selectAllBtn.shareLabel.text = @"取消全选";
                    }else{
                        selectAllBtn.shareLabel.text = @"全部勾选";
                    }
                }
                
            } @catch (NSException *exception) {}
            
            if(_isMamsWeb&&file.selected){
                [self getFile];
            }
        };
        
        
        
        //预览
        MyBtnControl *checkBtn = [[MyBtnControl alloc] initWithFrame:fileImg.frame];
        [cell addSubview:checkBtn];
        checkBtn.not_highlight=YES;
        checkBtn.shareImage = fileImg;
        checkBtn.clickBackBlock = ^(){
            
            if([[APPUtils get_file_type:file.tail] isEqualToString:@"office"]){//预览文档
                
                FileChecker *secondView = [[FileChecker alloc] initWithtitle:file.fileName url:[[MainViewController sharedMain].conversationPaths stringByAppendingPathComponent:file.fileName]];
                [self.navigationController pushViewController:secondView animated:YES];
                secondView = nil;
                
            }else if([[APPUtils get_file_type:file.tail] isEqualToString:@"pic"]){//预览图片
                
                CLPhotoBrowser *imageBrower = [[CLPhotoBrowser alloc] init];
                imageBrower.photos = [NSMutableArray array];
                
                CLPhoto *photo = [[CLPhoto alloc] init];
                
                photo.thumbUrl = @"";
                if(albumType==1){//相册文件
                    ALAssetRepresentation* representation = [file.asset defaultRepresentation];
                    photo.local_img = [UIImage imageWithCGImage:representation.fullScreenImage];
                    representation = nil;
                    
                }else{
                    photo.local_img = [UIImage imageWithContentsOfFile:[[MainViewController sharedMain].conversationPaths stringByAppendingPathComponent:file.fileName]];
                }
                
                
                photo.scrRect = [fileImg convertRect:fileImg.bounds toView:nil];
                
                
                [imageBrower.photos addObject:photo];
                photo = nil;
                
                imageBrower.selectImageIndex = 0;
                [imageBrower show];
                imageBrower = nil;
                
            }else if([[APPUtils get_file_type:file.tail] isEqualToString:@"video"]||[[APPUtils get_file_type:file.tail] isEqualToString:@"audio"]){//预览音视频
                
                MovieViewController *secondView;
                if(albumType==1){//相册文件
                    secondView = [[MovieViewController alloc] initWithAsset:file.asset title:file.fileName];
                }else{
                    secondView = [[MovieViewController alloc] initWithtitle:file.fileName url:[[MainViewController sharedMain].conversationPaths stringByAppendingPathComponent:file.fileName] online:NO];
                }
                
                //设置第二个窗口中的delegate为第一个窗口的self
                [self.navigationController pushViewController:secondView animated:YES];
                secondView = nil;
                
            }else if([[APPUtils get_file_type:file.tail] isEqualToString:@"zip"]){//压缩包
            
                UIDocumentInteractionController *diController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:[[MainViewController sharedMain].conversationPaths stringByAppendingPathComponent:file.fileName]]];
                diController.UTI = @"com.pkware.zip-archive";
                [diController presentOpenInMenuFromRect:CGRectMake(0, 20, 100, 100) inView:self.view animated:YES];
                diController = nil;
                
            }else{
                [ToastView showToast:@"抱歉，暂不支持该文件类型的预览"];
            }
            
            
        };
        
        checkBtn = nil;
        cellBtn = nil;
        sizeLabel = nil;
        fileImg = nil;
        nameLabel = nil;
        file = nil;
        fileArr = nil;
        fileDic = nil;

    }
    
    return cell;
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(isEmpty){
        return tableHeight;
    }else{
        return cellheight;
    }
    
}

//发送/拿到文件
-(void)getFile{
    if([selectFilesList count]>0){
        if(clean_type){
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                     message:[NSString stringWithFormat:@"确认清理已勾选的%d个文件?",(int)[selectFilesList count]]
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}];
            
            
            UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确认清理" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [ShowWaiting showWaiting:@"清理中,请稍后"];
               
                NSFileManager *fileManager = [NSFileManager defaultManager];
                
                for(FilesEntity *file in selectFilesList){
                    [fileManager removeItemAtPath:[[MainViewController sharedMain].conversationPaths stringByAppendingPathComponent:file.fileName] error:nil];
                }
                fileManager = nil;
                
                [selectFilesList removeAllObjects];
                [sendBtn setBackgroundColor:[UIColor lightGrayColor]];
                [sendBtn setEnabled:NO];
                selectAllBtn.shareLabel.text = @"全部勾选";
                fileCountLabel.text = @"请选择文件";
                
                lastSelectIndex = -1;
                [self getLocalData];
                [ToastView showToast:@"文件已清理"];
            }];
            
            [alertController addAction:cancel];
            [alertController addAction:confirm];
            
            
            [[MainViewController sharedMain] presentViewController:alertController animated:YES completion:nil];
            cancel = nil;
            confirm = nil;
            alertController = nil;
            
        }else{
            self.fileBackBlock(selectFilesList);
            [self beBack];
        }
        
    }
    
}

- (void)beBack{
    
    [self.navigationController popViewControllerAnimated:YES];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end


@implementation FilesEntity
@end

