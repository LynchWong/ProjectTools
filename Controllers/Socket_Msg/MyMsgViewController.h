//
//  MyMsgViewController.h
//  MedicalCenter
//
//  Created by 李狗蛋 on 15-3-20.
//  Copyright (c) 2015年 李狗蛋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Conversation.h"
#import <AVFoundation/AVFoundation.h>
@class Conversation;

@interface MyMsgViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,AVAudioPlayerDelegate>{


    BOOL noTitle;//没有标题
    UIView *noLogin;//未登录
    
    //search
    NSMutableArray *filteredContact;
    UIRefreshControl *refreshControl;
    
    
    NSDateFormatter *_formatterDate;
    NSDateFormatter *_formatterTime;
    NSInteger todayUnixTime;
    NSInteger yesterdayUnixTime;

   
    UIView *bodyView;

    BOOL isEmpty;
  
    BOOL hasOpen;
    BOOL groupGetting;

    BOOL intoSendMsgPage;

}


typedef void (^MsgListBlock)();
@property (nonatomic,strong)MsgListBlock callBackBlock;


@property (retain, nonatomic)  UITableView *smsTable;
@property (retain, nonatomic)  UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableArray *dataList;
@property (retain, nonatomic)  UIControl *tableCoverView;
@property (assign, nonatomic)  BOOL hideSend;//隐藏发送栏

- (id)initWithTitle:(BOOL)title;
//关闭搜索
-(void)hideInput;
//获取本地消息
-(void)getGroups;
//显示未登录
-(void)showNoLogin:(BOOL)show;

@end


