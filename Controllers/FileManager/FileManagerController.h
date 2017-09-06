//
//  FileManagerController.h
//  MedicalCenter
//
//  Created by 李狗蛋 on 15-6-15.
//  Copyright (c) 2015年 李狗蛋. All rights reserved. 文件管理器
//

#import <UIKit/UIKit.h>
#import "AssetHelper.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "LocalAlbumTableViewController.h"
#import "MainViewController.h"


@class MyBtnControl;

@interface FileManagerController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    
    
    NSInteger now_column;//当前栏目
    UIView *menuView;//标签菜单
    UIView *menuBar;
    NSMutableArray *menuUIArray;//装标签control

    BOOL isEmpty;
    BOOL albumLoadOver;//相册文件获取完成
    UITableView *fileTableView;
    float tableHeight;
    float cellheight;
    float sectionHeight;
 
    
    UIView *sendview;//发送
    UILabel *fileCountLabel;
    MyBtnControl *sendBtn;
    
    
  
    
    NSMutableArray *documentsArr;//文档
    NSMutableArray *albumArr;//相册
    NSMutableArray *allVideoArr;//视频
    NSMutableArray *musicArr;//音乐
    NSMutableArray *otherArr;//其他
    
   
    NSInteger lastSelectIndex;//本次选择的栏目
    
    NSMutableArray *datalist;
     NSMutableArray *selectFilesList;//最后选择的文件
    
    
    //清理模式
    BOOL clean_type;
    MyBtnControl *selectAllBtn;//全选
    NSInteger filesCount;//总文件数

}

typedef void (^FileBlick)(NSMutableArray *arr);
@property (nonatomic,strong)FileBlick fileBackBlock;

@property (assign, nonatomic) BOOL isMamsWeb;// web添加文件


//清理模式
- (id)initWithClean;

@end


@interface FilesEntity : NSObject

@property (copy, nonatomic) NSString *fileName;
@property (copy, nonatomic) NSString *tail;
@property (copy, nonatomic) NSString *fileSizeString;
@property (assign, nonatomic) float fileSize;//kb
@property (assign, nonatomic) NSInteger sort;
@property (assign, nonatomic) NSInteger selected;//选中

@property (strong, nonatomic) ALAsset*asset;//照片文件
@property (assign, nonatomic) BOOL albumPicType;//相册图片类型
@property (copy, nonatomic)UIImage*thumb;//缩率图
@end

