//
//  MyMsgViewController.h
//  MedicalCenter
//
//  Created by 李狗蛋 on 15-3-20.
//  Copyright (c) 2015年 李狗蛋. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>
@class Conversation;

@interface MyMsgViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,AVAudioPlayerDelegate>{


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


    BOOL intoSendMsgPage;

}


typedef void (^MsgListBlock)();
@property (nonatomic,strong)MsgListBlock callBackBlock;


@property (retain, nonatomic)  UITableView *smsTable;
@property (retain, nonatomic)  UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableArray *dataList;
@property (retain, nonatomic)  UIControl *tableCoverView;



@end


