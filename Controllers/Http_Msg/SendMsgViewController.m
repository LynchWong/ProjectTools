//
//  SendMsgViewController.m
//  MedicalCenter
//
//  Created by 李狗蛋 on 15-4-28.
//  Copyright (c) 2015年 李狗蛋. All rights reserved.

/*
   消息发送增改机制： 1.DB检索所有消息->列表呈现
                   2.新发消息 status=3插入DB,检索DB出来刷新列表
                   3.cell里的news判断status=3，就执行自身的sendMsg。
                   4.sendMsg里先判断以消息tempID作为key的NSUserDefaults，假如value为0，就马上发送，同时把value至为1。
                   5.sendMsg结束，修改status，成功value：msgId 失败value:-1,刷新cell
                   6.每次getmsg的时候,先检索status=3的消息id，作为key对应查找NSUserDefaults，如果value>1,将对应value作为status后update DB.
 */


#import "SendMsgViewController.h"
#import "UIColor+additions.h"
#import "MainViewController.h"
#import "MapShowViewController.h"
#import "OneMsgEntity.h"
#import "LocalAlbumTableViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import <MediaPlayer/MPMoviePlayerController.h>
#include "APPUtils.h"
#import "CCActionSheet.h"
#import "WebViewController.h"
#import "MsgCellTableViewCell.h"



@interface SendMsgViewController ()

@end

@implementation SendMsgViewController

static NSString *CellIdentifier = @"SmsCell";

@synthesize conversation;

-(id)initWithConversation:(Conversation*)conv show:(BOOL)show send2User:(NSString*)send2User{
    self = [super init];
    if (self) {
        conversation = conv;
        showSendView = show;
        sendWho = send2User;

    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

     [MainViewController setPosition:@"SendMsgViewController"];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self getuserID];
    [self initController];
    [self initData];

    
}


-(void)getuserID{
    
   

    nickName = [[APPUtils getUserDefaults] stringForKey:@"nickname"];
    realname = [[APPUtils getUserDefaults] stringForKey:@"realname"];
    myAvatarUrl = [[APPUtils getUserDefaults] stringForKey:@"avatar"];
    [APPUtils userDefaultsSet :sendWho forKey:@"sendWho"];
    [[APPUtils getUserDefaults] synchronize];
    
}


//受到信息刷新
-(void)refreshMsg{
    
    if(hasOpen){
    
        if(!loadingOldMsg && !loadingNewMsgs){
        
            loadingNewMsgs = YES;
            @try {
                NSString *sqlQuery = [NSString stringWithFormat:@"%@ and l.isLoaded = '0' and l.sendStatus = '0' order by l.createtime",mainSqlQuery];//时间从大到小获取新消息
                
                FMResultSet *resultSet = [[MainViewController getDatabase] queryDatabase:sqlQuery];
                sqlQuery = nil;
                
                NSMutableArray *newMsgsArr = [[NSMutableArray alloc] init];
                float newMsgTotalHeight = 0;
                while ([resultSet next]) {
                    OneMsgEntity *oneMSg =  [self getOneMsgFromDb:resultSet];
                
                    //时间
                    OneMsgEntity *timeMsg =  [self getTimeMsg:oneMSg insertType:YES];
                    if(timeMsg!=nil){
                        [newMsgsArr addObject:timeMsg];
                        newMsgTotalHeight+=[self getCellHeight:timeMsg];
                    }
                    timeMsg = nil;
                    
                    [newMsgsArr addObject:oneMSg];
                    newMsgTotalHeight+=[self getCellHeight:oneMSg];
                    now_in_page_add_msgs++;
                    oneMSg = nil;
                }
                
                [resultSet close];
                resultSet = nil;
                
                
                //先把消息设为已获取
                NSString *updateIsLoadString= [NSString stringWithFormat:@"update MsgsList set isLoaded = '1' where groupid='%ld' and username = '%@';",(long)conversation.group_id,[AFN_util getUserId]];
                [[MainViewController getDatabase] execSql:updateIsLoadString];
                updateIsLoadString = nil;

                
                
                if([newMsgsArr count]>0){
                    
                    NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
                    
                    for(int i=0;i<[newMsgsArr count];i++){
                        
                        [dataList insertObject:[newMsgsArr objectAtIndex:i] atIndex:0];
                        NSIndexPath *refreshCell = [NSIndexPath indexPathForRow:[newMsgsArr count]-i-1 inSection:0];
                        [insertIndexPaths addObject:refreshCell];
                        refreshCell = nil;
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [smsTableView insertRowsAtIndexPaths:insertIndexPaths  withRowAnimation:UITableViewRowAnimationLeft];
                        
                        
                        [self checkFullOfTable:newMsgTotalHeight];//检查一行高
                        
                        
                        //如果在最下面些就跳
                        if(smsTableView.contentOffset.y <= smsTableHeight*2){
                            [self jump2LastLine:YES];
                        }
                    });
                    
                    insertIndexPaths = nil;
                    
                }
                newMsgsArr = nil;
                
                
            } @catch (NSException *exception) {
                
            }
        }
        
        loadingNewMsgs = NO;
    }else{
        if(refreshTimer!=nil){
            [refreshTimer invalidate];
            refreshTimer = nil;
        }
    }
    
}

-(void)initController{
    
    [MainViewController setMethod:@"initController"];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;//tableView 上会多出20个像素 去掉
    [self.view setBackgroundColor:[UIColor whiteColor]];
    

    NSString *showtitle = @"";
    
    
    if(conversation.people>2){
        showtitle = conversation.name;
        
    }else{
        showtitle = conversation.otherName;
    }
    
    __weak typeof(self) weakSelf = self;
    titleView = [[ZppTitleView alloc] initWithTitle:showtitle];
    [self.view addSubview:titleView];
    titleView.goback = ^(){
        [weakSelf beBack];
    };

  
    bodyView = [[UIView alloc] initWithFrame:CGRectMake(0, TITLE_HEIGHT, SCREENWIDTH, BODYHEIGHT)];
    [bodyView setBackgroundColor:MAINGRAY];
    [self.view addSubview:bodyView];
    
    [self.view bringSubviewToFront:titleView];

    //没有消息
    noChatView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREENWIDTH-ERROR_STATE_BACKGROUND_WIDTH)/2, (SCREENHEIGHT-ERROR_STATE_BACKGROUND_WIDTH)/2-TITLE_HEIGHT, ERROR_STATE_BACKGROUND_WIDTH, ERROR_STATE_BACKGROUND_WIDTH)];
    [noChatView setImage:[UIImage imageNamed:@"no_msg.png"]];
    [bodyView addSubview: noChatView];
    noChatView.alpha=0;
    
    sendViewHeight = 46;
    
    
    smsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, BODYHEIGHT-sendViewHeight)];
    [smsTableView setBackgroundColor:[UIColor clearColor]];
    smsTableHeight = smsTableView.frame.size.height;
    
    [bodyView addSubview:smsTableView];
    smsTableView.separatorStyle = UITableViewCellSeparatorStyleNone; //去掉table分割线
    smsTableView.delegate = self;//调用delegate
    smsTableView.dataSource=self;
    smsTableView.alpha = 0;
    smsTableView.canCancelContentTouches = NO;
    smsTableView.delaysContentTouches = NO;
    smsTableView.transform = CGAffineTransformMakeScale (1,-1);//倒转table
    
    
    

    
    //加载菊花
    tableFootView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 45)];
    UIActivityIndicatorView *loading_juhua = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loading_juhua.center = CGPointMake(SCREENWIDTH/2, tableFootView.frame.size.height/2);
    [loading_juhua startAnimating];
    [tableFootView addSubview:loading_juhua];
    loading_juhua = nil;
   
    
    
    
    sendView = [[UIView alloc] initWithFrame:CGRectMake(0, BODYHEIGHT-sendViewHeight, SCREENWIDTH, sendViewHeight)];
    [bodyView addSubview:sendView];
    UIImageView *sendLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 0.5)];
    [sendLine setBackgroundColor:[UIColor lightGrayColor]];
    sendLine.alpha = 0.8;
    [sendView addSubview:sendLine];
    [sendView setBackgroundColor:[UIColor getColor:@"F3F3F6"]];
  
    
    CGFloat imgWidth = sendViewHeight*0.7;
    //改变方式

    
    changeVoiceBtn = [[MyBtnControl alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH*0.15, sendViewHeight)];
    [sendView addSubview:changeVoiceBtn];
    changeVoiceBtn.clickBackBlock = ^(){
        [weakSelf change_voice_text];
    };
    [changeVoiceBtn addImage:[UIImage imageNamed:@"voice_btn_normal.png"] frame:CGRectMake((changeVoiceBtn.frame.size.width-imgWidth)/2, (changeVoiceBtn.frame.size.height-imgWidth)/2, imgWidth, imgWidth)];
    
    
    //打开菜单
    openMenuBtn = [[MyBtnControl alloc] initWithFrame:CGRectMake(SCREENWIDTH-changeVoiceBtn.frame.size.width, 0, changeVoiceBtn.frame.size.width, sendViewHeight)];
    [sendView addSubview:openMenuBtn];
    openMenuBtn.clickBackBlock = ^(){
        [weakSelf bottomMenuControl];
    };
    
    [openMenuBtn addImage:[UIImage imageNamed:@"type_select_btn_nor.png"] frame:CGRectMake((openMenuBtn.frame.size.width-imgWidth)/2,(openMenuBtn.frame.size.width-imgWidth)/2, imgWidth, imgWidth)];
    
    
    
    //语音录制
    sendVoiceBtn = [[UIControl alloc] initWithFrame:CGRectMake(changeVoiceBtn.frame.size.width, (sendViewHeight-sendViewHeight*0.8)/2, SCREENWIDTH-changeVoiceBtn.frame.size.width*2, sendViewHeight*0.8)];
    sendVoiceBtn.layer.cornerRadius = 4;
    sendVoiceBtn.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    sendVoiceBtn.layer.borderWidth = 0.5f;
    sendVoiceBtn.backgroundColor = [UIColor getColor:@"F3F3F6"];
    
    voiceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, sendVoiceBtn.frame.size.width, sendVoiceBtn.frame.size.height)];
    voiceLabel.textColor = [UIColor darkGrayColor];
    voiceLabel.font = [UIFont fontWithName:textDefaultBoldFont size:13];
    voiceLabel.textAlignment = NSTextAlignmentCenter;
    voiceLabel.text = @"按住 说话";
    [sendVoiceBtn addSubview:voiceLabel];
    sendVoiceBtn.alpha=0;
    [sendView addSubview:sendVoiceBtn];
    [sendVoiceBtn addTarget:self action:@selector(voiceDown) forControlEvents:UIControlEventTouchDown];
    [sendVoiceBtn addTarget:self action:@selector(voiceUp) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchUpInside|UIControlEventTouchCancel];
    [sendVoiceBtn addTarget:self action:@selector(voiceDragExit) forControlEvents:UIControlEventTouchDragExit];
    [sendVoiceBtn addTarget:self action:@selector(voiceDragEnter) forControlEvents:UIControlEventTouchDragEnter];
    
    
    //文本输入
    textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(changeVoiceBtn.frame.size.width, (sendViewHeight-sendViewHeight*0.8)/2+1, SCREENWIDTH-changeVoiceBtn.frame.size.width*2, sendViewHeight*0.8)];
    textView.delegate = self;
    [sendView addSubview:textView];
    
    textView.minNumberOfLines = 1;
    textView.maxNumberOfLines = 5;
    textView.tintColor = MAINCOLOR;
    textView.layer.cornerRadius = 4;
    textView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    [textView.layer setMasksToBounds:YES];
    textView.layer.borderWidth = 0.5f;
    textView.backgroundColor = [UIColor whiteColor];
    textView.returnKeyType = UIReturnKeySend;//返回键的类型
    [textView setFont:[UIFont fontWithName:@"Helvetica" size:14.0]];
    textView.textColor = [UIColor blackColor];
    
    textView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    textView.enablesReturnKeyAutomatically = YES;
    
 
    [bodyView bringSubviewToFront:sendView];
    
    
  
    
    
    
    menuViewHeight = 80;
    menuView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, menuViewHeight)];
    [menuView setBackgroundColor:[UIColor getColor:@"F3F3F6"]];
    
    UIImageView *menuViewLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 0.5)];
    [menuViewLine setBackgroundColor:[UIColor lightGrayColor]];
    menuViewLine.alpha = 0.5;
    [menuView addSubview:menuViewLine];
    [bodyView addSubview:menuView];
    
    
    //--------------3按钮---------
    
    [menuView addSubview:[self getBottomMenuView:1 name:@"照片" icon:@"photo_btn.png"]];
    [menuView addSubview:[self getBottomMenuView:2 name:@"拍照" icon:@"camera_btn.png"]];
    [menuView addSubview:[self getBottomMenuView:3 name:@"位置" icon:@"position_btn.png"]];
   
    
  
    textFont = [UIFont fontWithName:textDefaultFont size:13];
    oneLineHeight = [APPUtils getOnelineHeight:textFont];
    

    
    
    [[UITextField appearance] setTintColor:MAINCOLOR];
    
}


//获取底部菜单
-(UIView*)getBottomMenuView:(NSInteger)tag name:(NSString*)name icon:(NSString*)icon{
  
    CGFloat btnWidth = menuViewHeight*0.65;
    CGFloat marginWidth = (SCREENWIDTH-btnWidth*3)/4;
    
    UIView *menu_View = [[UIView alloc] initWithFrame:CGRectMake((tag-1)*btnWidth+marginWidth*tag, 0, btnWidth, menuViewHeight)];
    
    
    CGFloat imageWidth = menu_View.frame.size.width*0.7;


    UILabel *menuLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, menu_View.frame.size.height-20, menu_View.frame.size.width, 20)];
    menuLabel.textColor = [UIColor darkGrayColor];
    menuLabel.font = [UIFont fontWithName:textDefaultFont size:12];
    menuLabel.textAlignment = NSTextAlignmentCenter;
    menuLabel.text = name;
    [menu_View addSubview:menuLabel];
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((menu_View.frame.size.width-imageWidth)/2, menuViewHeight*0.1+btnWidth/2-imageWidth/2, imageWidth, imageWidth)];
    [imageView setImage:[UIImage imageNamed:icon]];
    [menu_View addSubview:imageView];
    
    
    MyBtnControl *menuControl = [[MyBtnControl alloc] initWithFrame:CGRectMake(0, menuViewHeight*0.1, btnWidth, btnWidth)];
    [menuControl setBackgroundColor:[UIColor clearColor]];
    menuControl.layer.cornerRadius = 6;
    menuControl.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    menuControl.layer.borderWidth = 0.6;
    
    menuControl.shareLabel = menuLabel;
    menuControl.shareImage = imageView;
    
    [menu_View addSubview:menuControl];
    menuControl.clickBackBlock = ^(){
        if(tag == 1){//发照片
            
            [self openPictures];
            
        }else if(tag ==2){// 照相机
            
            [self openCamera];
            
        }else if(tag == 3){//发送位置
            
            [self sendPositions];
            
        }
    };
    
    
    menuControl = nil;
    menuLabel = nil;
    imageView = nil;


    return menu_View;
    
    
}

//关闭输入
-(void)closeMsgInput{
    if(hasOpen){
        menuState = YES;
        [textView resignFirstResponder];
        [self bottomMenuControl];
    }
}


//初始化数据
-(void)initData{

    hasOpen = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quit2Main)  name:@"quitMsgPage" object:nil];//被T
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMsg)  name:@"update_sendMsgPage" object:nil];//刷新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(phone_coming)  name:@"phone_coming" object:nil]; //进入后台处理  比如来电话
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeMsgInput)  name:@"closeMsgInput" object:nil];//关闭输入

  
    lastMsgTime = 0;
    //wav录音名字和路径
    recordFilePath = [[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:@"tempRecord.wav"];

    
    maxPicWidth = SCREENWIDTH*0.4;
    maxPicHeight = SCREENWIDTH*0.4;
    
    msgUtil = [MainViewController sharedMain].msgUtil;
    
    _formatterDate=[[NSDateFormatter alloc]init];
    _formatterTime=[[NSDateFormatter alloc]init];
    [_formatterDate setLocale:[NSLocale currentLocale]];
    [_formatterTime setLocale:[NSLocale currentLocale]];
    [_formatterDate setDateFormat:@"yyyy-MM-dd"];
    [_formatterTime setDateFormat:@"HH:mm"];
   
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *todayDate = [_formatterDate stringFromDate:dat];
   
    [_formatterDate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *date = [_formatterDate dateFromString:[NSString stringWithFormat:@"%@%@",todayDate,@" 00:00:00"]];
    
    NSTimeInterval a=[date timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%f", a];
    todayUnixTime = [timeString integerValue];
    
    yesterdayUnixTime = todayUnixTime - 86400;
    
    [_formatterDate setDateFormat:@"MM-dd"];
    
    if(conversation == nil){
        return;
    }
    

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    
    //主体查询语句
    
    //l:msglist
    //c:msgcontent
    
     mainSqlQuery = [NSString stringWithFormat:@"select l.isread,l.sendStatus,l.createtime,c.content,l.msg_type,c.direction,c.fileName,c.big_url,c.thumb_url,c.filesize,c.voice_length,c.ttsString,c.orderid,c.addressString,c.address_lat,c.address_lon,l.msg_id,l.msg_uid,l.user,l.avatar,c.downloading,l.isLoaded as mid from MsgsList l left join MsgContents c on c.msg_id=l.msg_id  where l.username='%@' and l.groupid ='%ld' ",[AFN_util getUserId],(long)conversation.group_id];
    

    //先把消息设为已读
    NSString *updateListString= [NSString stringWithFormat:@"update MsgsList set isread = '0',isLoaded = '1' where groupid='%ld' and username = '%@';",(long)conversation.group_id,[AFN_util getUserId]];
    [[MainViewController getDatabase] execSql:updateListString];
    updateListString = nil;
    
    
    
    [self getMsgs:NO jump:YES];
    
    
    //半分钟自动刷新一次
    if(refreshTimer==nil){
        refreshTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(checkNewMsgs) userInfo:nil repeats:YES];
    }
    
    
}


-(void)checkNewMsgs{

    if(hasOpen){
         [msgUtil check_msgs];
    }
}




//db获取消息
/*
 
  数据从DB 按createtime 倒排取出，放入数组装载。倒转Table+再倒转cell 展示
 
 */
-(void)getMsgs:(BOOL)loadOld jump:(BOOL)jump{//loadOld向上滑 jump跳到最后一行
    lastMsgTime = 0;
    
    [MainViewController setMethod:@"getMsgs"];

    
    [MsgUtil updateSendingMsgs:NO];//更新发送中的消息结果
    

    NSInteger oldArray = 0;//老消息数量
    
    if(!loadOld){//正常首次加载
        dataList = [[NSMutableArray alloc] init];
        realMsgCount = 0;
        currentPage =0;
        
        totalCount = 0;//消息总条数   每次打开固定该值
        
        NSString *sqlCountQuery = [NSString stringWithFormat:@"select count(*) from MsgsList l left join MsgContents c on c.id=l.id  where l.username='%@' and l.groupid ='%ld';",[AFN_util getUserId],(long)conversation.group_id];
        
        FMResultSet *resultSet1 = [[MainViewController getDatabase] queryDatabase:sqlCountQuery];
        while ([resultSet1 next]) {
            totalCount = [resultSet1 intForColumnIndex:0];
            break;
        }
        [resultSet1 close];//清理资源
        resultSet1 = nil;
    }
    

    
    
    NSString *sqlQuery = [NSString stringWithFormat:@"%@order by l.createtime desc",mainSqlQuery];//时间从大到小
    
     NSInteger loadCount=0;//本次查询条数
    
    CGFloat onceLoad = 20;//一次20条;
    
    if(totalCount > onceLoad){//从后往前查
        
       
        NSInteger fromCount = 0;//起始位置

        
        if((totalCount - (currentPage+1)*onceLoad)>0){//还有更多的页
        
              realMsgCount +=onceLoad;
              loadCount = onceLoad;
              fromCount= onceLoad*currentPage+now_in_page_add_msgs;
            
            smsTableView.tableFooterView = tableFootView;
        
            
        }else{//最后一页
            
            loadCount = totalCount-currentPage*onceLoad;
            fromCount = currentPage*onceLoad+now_in_page_add_msgs;
            realMsgCount += loadCount;
            smsTableView.tableFooterView = nil;
            [smsTableView setContentOffset:CGPointMake(0, smsTableView.contentOffset.y+tableFootView.frame.size.height)];//最后一页会弹一下的处理
          
        }
        
        
        sqlQuery = [NSString stringWithFormat:@"%@ limit %ld ,%ld;",sqlQuery,(long)fromCount,(long)loadCount];
      
    }else{
    
        smsTableView.tableFooterView = nil;
        
        loadCount = totalCount;
        realMsgCount = totalCount;
        
        sqlQuery = [NSString stringWithFormat:@"%@;",sqlQuery];
    }

    
    
    FMResultSet *resultSet = [[MainViewController getDatabase] queryDatabase:sqlQuery];
    sqlQuery = nil;
    
    @try {
        NSInteger nextIndex = 0;
        while ([resultSet next]) {
            
            OneMsgEntity *oneMSg =  [self getOneMsgFromDb:resultSet];
            
            if(!loadOld && nextIndex == 0){
                
                lastMsgTime = oneMSg.createtime;//初始化第一个的时间
                
            }else{
                //时间
                OneMsgEntity *timeMsg =  [self getTimeMsg:oneMSg insertType:NO];
                if(timeMsg!=nil){
                    [dataList addObject:timeMsg];
                    if(loadOld){
                        oldArray++;
                    }
                }
                timeMsg = nil;
            }
            
    
            
            [dataList addObject:oneMSg];
            
            if(loadOld){
                oldArray++;
            }
            
            
            //顶上第一条需要自己的时间
            if((realMsgCount == totalCount) && nextIndex == loadCount-1){
                lastMsgTime = 0;
                OneMsgEntity *timeMsg =  [self getTimeMsg:oneMSg insertType:NO];
                [dataList addObject:timeMsg];
                if(loadOld){
                    oldArray++;
                }
                timeMsg = nil;
            }
            
            oneMSg = nil;
            nextIndex++;
        }
        
        [resultSet close];
        resultSet = nil;
        
        lastMsgTime = 0;
        
        if([dataList count]==0){
            noChatView.alpha=1;
        }else{
            noChatView.alpha=0;
        }
        
        if(!loadOld){//第一次加载
            
            [self setMsgListSummary];
            
            [smsTableView reloadData];
     
             [self checkFullOfTable:0];//检查一行高
        
            
        }else{
            //装填老数据
            
            NSMutableArray *cellArr = [[NSMutableArray alloc] init];
           
            //单独增加老消息刷新table
            NSInteger index = 0;
            for(int i=0;i<oldArray;i++){
                
                NSIndexPath *refreshCell = [NSIndexPath indexPathForRow:[dataList count]-oldArray+index inSection:0];
                [cellArr addObject:refreshCell];
                refreshCell = nil;
                index++;
            }
        
            [smsTableView insertRowsAtIndexPaths:cellArr  withRowAnimation:UITableViewRowAnimationNone];
            
            cellArr = nil;
      
            loadingOldMsg = NO;
        }
    

        if(jump){
            [self jump2LastLine:YES];
        }
        
    }@catch (NSException *exception) {
        NSLog(@"sendControl 异常 %@",exception);

    }
}


//从底部获取msg
-(OneMsgEntity*)getOneMsgFromDb:(FMResultSet*)resultSet{
    
        
        OneMsgEntity *oneMSg = [[OneMsgEntity alloc]init];
        oneMSg.isRead = [resultSet intForColumnIndex: 0];
        
        oneMSg.sendStatus = [resultSet intForColumnIndex: 1];
        
        oneMSg.createtime= [resultSet intForColumnIndex:2 ];
        
        oneMSg.content= [resultSet stringForColumnIndex: 3];
        
        oneMSg.type = [resultSet stringForColumnIndex: 4];
        
        oneMSg.imageDirection = [resultSet doubleForColumnIndex: 5];
        
        oneMSg.fileName = [resultSet stringForColumnIndex: 6];
        
        oneMSg.big_url = [resultSet stringForColumnIndex: 7];
        
        oneMSg.thumb_url = [resultSet stringForColumnIndex: 8];
        
        oneMSg.filesize = [resultSet intForColumnIndex:9 ];
        
        oneMSg.voice_length = [resultSet intForColumnIndex:10];
        
        oneMSg.ttsString = [resultSet stringForColumnIndex:11];
        
        oneMSg.orderId = [resultSet intForColumnIndex: 12];
        
        oneMSg.addressString = [resultSet stringForColumnIndex:13];
        
        oneMSg.address_lat = [resultSet doubleForColumnIndex: 14];
        
        oneMSg.address_lon = [resultSet doubleForColumnIndex: 15];
        
        oneMSg.msg_id = [resultSet stringForColumnIndex: 16];
        
        oneMSg.msg_uid = [resultSet intForColumnIndex: 17];
        
        oneMSg.user = [resultSet stringForColumnIndex: 18];
        
        oneMSg.avatar = [resultSet stringForColumnIndex: 19];
        
        oneMSg.downloading = [resultSet intForColumnIndex: 20];
    
        oneMSg.isLoaded = [resultSet intForColumnIndex: 21];

        
        if(oneMSg.content == nil || oneMSg.content.length == 0){
            oneMSg.content = @"        ";
        }
        
        
        if([oneMSg.type isEqualToString:@"text"]){
            
     
            oneMSg.textsize = [self getTextSize:oneMSg.content];
            
        }else if([oneMSg.type isEqualToString:@"broadcast"]){
            NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
            paragraph.alignment = NSLineBreakByWordWrapping;
            NSDictionary *attribute = @{NSFontAttributeName: [UIFont fontWithName:textDefaultFont size:13], NSParagraphStyleAttributeName: paragraph};
            
            
            CGSize size = [oneMSg.content boundingRectWithSize:CGSizeMake(SCREENWIDTH*0.73-58, MAXFLOAT) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
            
            paragraph = nil;
            attribute = nil;
            
            oneMSg.content_height = size.height;
            
        }
        
        
        oneMSg.sendWho = sendWho;
        oneMSg.group_id =conversation.group_id;
        
    
        return oneMSg;
}


//文本消息尺寸
-(CGSize)getTextSize:(NSString*)string{

    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSLineBreakByWordWrapping;
    
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont fontWithName:textDefaultFont size:13], NSParagraphStyleAttributeName: paragraph};
    
    CGSize size = [string boundingRectWithSize:CGSizeMake(SCREENWIDTH*0.6, MAXFLOAT) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;


    //如果有\r这些需要单独计算
    NSArray *array = [string componentsSeparatedByString:@"\r"];
    NSInteger special_word_count = [array count] - 1;
    if(special_word_count>0){
        size.height += oneLineHeight;
    }

    paragraph = nil;
    attribute = nil;
    
    return size;
}

//获取时间msg
-(OneMsgEntity*)getTimeMsg:(OneMsgEntity*)oneMSg insertType:(BOOL)insertType{//插入新消息类型

 
    if(abs(oneMSg.createtime - lastMsgTime) >=90){//超过3分钟就显示时间
        
        OneMsgEntity *lastMsg;
        
        if(!insertType){
            lastMsg = [dataList lastObject];//因为是颠倒的，所以需要的是上条消息的时间
            if([lastMsg.type isEqualToString:@"time"]){
                lastMsg = nil;
                return nil;
            }
        }else{
            lastMsg = oneMSg;//插入类型 当前时间
        }
        
        
        OneMsgEntity *msg = [[OneMsgEntity alloc]init];
        msg.createtime= lastMsg.createtime;
        
        NSTimeInterval _interval=msg.createtime;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
        
        if(msg.createtime < todayUnixTime && msg.createtime >= yesterdayUnixTime){
            msg.content = [NSString stringWithFormat:@"%@%@%@",@"昨天",@
                           "  ",[_formatterTime stringFromDate:date]];
            msg.sendStatus = 90;
        }else if(msg.createtime < yesterdayUnixTime){
            msg.content = [NSString stringWithFormat:@"%@%@%@",[_formatterDate stringFromDate:date],@
                           "  ",[_formatterTime stringFromDate:date]];
            msg.sendStatus = 90;
        }else{
            msg.content =  [_formatterTime stringFromDate:date];
            msg.sendStatus = 60;
        }
        
        date = nil;
        
        msg.msg_id = @"";
        msg.type = @"time";
        lastMsg =  nil;

        lastMsgTime = oneMSg.createtime;
        
        
        return msg;
    }else{
        return nil;
    }
}

//跳到最后一行
-(void)jump2LastLine:(BOOL)animated{

    if([dataList count]>0){
        [smsTableView setContentOffset:CGPointMake(0, 0) animated:animated];
    }
    
    if(smsTableView.alpha == 0){
        [UIView animateWithDuration:0.1f delay:0.2
                            options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState) animations:^(void) {
                                smsTableView.alpha =1;
                            }
                         completion:NULL];
    }
}


//不满一页高的处理
-(void)checkFullOfTable:(float)addHeight{
    
    float nowTableContentHeight = smsTableView.contentSize.height-(smsTableView.tableHeaderView==nil?0:smsTableView.tableHeaderView.frame.size.height) + addHeight;
    
    if(nowTableContentHeight < smsTableHeight){
        
        if(fillHeaderView == nil){
            fillHeaderView = [[UIView alloc] init];
//            [fillHeaderView setBackgroundColor:MAINRED];
        }
        
        
        if(keyboardOpened){//键盘打开中
            
            if(nowTableContentHeight > BODYHEIGHT-nowKeyboardHeight-menuViewHeight){//内容不满一页 但是被输入法遮盖
                [fillHeaderView setFrame:CGRectMake(0, 0, SCREENWIDTH, nowKeyboardHeight)];
            }else{
                //内容不满一页 但是没有被输入法遮盖
                [fillHeaderView setFrame:CGRectMake(0, 0, SCREENWIDTH, nowKeyboardHeight+(smsTableView.frame.size.height-nowKeyboardHeight-nowTableContentHeight))];
            }

        }else{
            [fillHeaderView setFrame:CGRectMake(0, 0, SCREENWIDTH, smsTableHeight-nowTableContentHeight)];
        }
        
        
        [self changeHeaderView:YES];
        
    }else{
        if(smsTableView.tableHeaderView!=nil){
            //如果菜单展开中切换 需要更新table y
            if(menuState && smsTableView.frame.origin.y!=-menuViewHeight){
                
                [smsTableView setFrame:CGRectMake(0, -menuViewHeight, SCREENWIDTH, smsTableHeight)];
                
            }else if(keyboardOpened && smsTableView.frame.origin.y!=-nowKeyboardHeight){
                //键盘打开中
                [smsTableView setFrame:CGRectMake(0, -nowKeyboardHeight, SCREENWIDTH, smsTableHeight)];
                 smsTableView.tableHeaderView = nil;
                return;
            }
            
            [self changeHeaderView:NO];
        }
        
    }
}

-(void)changeHeaderView:(BOOL)add{

    [smsTableView beginUpdates];
    if(add){
         smsTableView.tableHeaderView = fillHeaderView;
    }else{
        smsTableView.tableHeaderView = nil;
    }
    [smsTableView endUpdates];
}



#pragma UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataList.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    if([dataList count]==0){
        return 0;
    }else{
        OneMsgEntity *msg =  [dataList objectAtIndex:indexPath.row];
        CGFloat cellHeight = [self getCellHeight:msg];
        msg = nil;
        return  cellHeight;
    }

}



//消息高度
-(float)getCellHeight:(OneMsgEntity*)msg{
    

    
    float cellHeight = 0;
    
    @try {
        
        if(maxPicWidth == 0 || maxPicHeight == 0){
            maxPicWidth = SCREENWIDTH*0.4;
            maxPicHeight = SCREENWIDTH*0.4;
        }
        
        if(posWidth==0 || posheight==0){
            posWidth = SCREENWIDTH*0.65;
            posheight = posWidth*0.56;
        }
        
        
        if(fileImageHeight==0){
            fileImageHeight = posWidth*0.25;
        }
        
        if([msg.type isEqualToString:@"text"]){
            
            cellHeight = msg.textsize.height+60;
            
        }else if([msg.type isEqualToString:@"pic"]){
            
          
            cellHeight =  maxPicHeight+60;
            
        }else if([msg.type isEqualToString:@"time"]){
          
            cellHeight = 60;
            
        }else if([msg.type isEqualToString:@"voice"]){
            
            cellHeight = 70;
            
        }else if([msg.type isEqualToString:@"pos"]){
            
            
            cellHeight = posheight+60;
            
        }else if([msg.type isEqualToString:@"file"]){
           
            cellHeight = fileImageHeight+65;
            
            
        }else if([msg.type isEqualToString:@"broadcast"]){
            cellHeight =  80+msg.content_height;
       
            
        }else{
         
            cellHeight = 60;
        }
        
        
    } @catch (NSException *exception) {
        cellHeight = 60;
    }
    
    return  cellHeight;
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MsgCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    
    if (cell == nil) {
        cell = [[MsgCellTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }else{
        
        for (UIView *cellView in cell.subviews){
            [cellView removeFromSuperview];
        }
       
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setBackgroundColor:[UIColor clearColor]];
    
   
        OneMsgEntity *msg;
        @try {
            msg  = [dataList objectAtIndex:indexPath.row];
        }
        @catch (NSException *exception) {
            return cell;
        }
        
        cell.conversation = conversation;
        cell.index = indexPath.row;
        cell.myAvatarUrl = myAvatarUrl;
        cell.maxPicWidth = maxPicWidth;
        cell.maxPicHeight = maxPicHeight;
  
    __weak __typeof(cell)weakcell = cell;
    
    //更新删除回调
    cell.callBackBlock = ^(NSString *type){
        [tableView beginUpdates];
        //获取当前的indexpath
        NSIndexPath *indexPath=[tableView indexPathForCell:weakcell];
        @try {
            if([type isEqualToString:@"update"]){//更新
               
                NSInteger tempIndex = 0;
                NSInteger row = -1;
                for(OneMsgEntity *tempMsg in dataList){
                    if([tempMsg.msg_id integerValue] == [weakcell.msg.msg_id integerValue]){
                        row = tempIndex;
                    }
                    tempIndex++;
                }
                
                if(row>=0){
                    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:row inSection:0];
                    [dataList replaceObjectAtIndex:indexPath.row withObject:weakcell.msg];//刷新数组
                    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil]withRowAnimation:UITableViewRowAnimationNone];//刷新cell ui
                    indexPath = nil;
                }
            
            }else if([type isEqualToString:@"delete"]){//删除该条
                [dataList removeObjectAtIndex:indexPath.row];//删除数组数据
                NSMutableArray *indexPaths = [NSMutableArray arrayWithObject:indexPath];
                [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                indexPaths = nil;
            }
            
        } @catch (NSException *exception) {}
        [tableView endUpdates];
        indexPath = nil;
    };
    
    
    //长按回调
    cell.clickCallBackBlock = ^(MyBtnControl*control,NSString *type){
        @try {
            
            ready_handle_msg = weakcell.msg;
            
            
            
            if([type isEqualToString:@"copy_delete"]){//复制、删除
                
                [self.navigationController becomeFirstResponder];//必须加 不然打开图片一次就不能弹出
                
                menuController = [UIMenuController sharedMenuController];
                [menuController setMenuVisible:NO];
                
                NSIndexPath *indexPath=[tableView indexPathForCell:weakcell];
                ready_handle_msg.index_row = indexPath.row;
                indexPath = nil;
                
                //设置菜单
                UIMenuItem *menuItem1;
                if([ready_handle_msg.type isEqualToString:@"text"]){
                    menuItem1 = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(menuItem:)];
                }
                
                UIMenuItem *menuItem3 = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(menuItem3:)];
                
                
                if(menuItem1!=nil){
                    [menuController setMenuItems:[NSArray arrayWithObjects:menuItem1,menuItem3, nil]];
                }else{
                    [menuController setMenuItems:[NSArray arrayWithObjects:menuItem3, nil]];
                }
                
                
                //设置菜单栏位置
                CGRect containerFrame = control.frame;
                containerFrame.origin.y = control.frame.origin.y+4;
                [menuController setTargetRect:containerFrame inView:control.superview];
                
                
                [menuController setMenuVisible:YES animated:YES];

             
                menuItem1 = nil;
                menuItem3 = nil;
                
            }else if([type isEqualToString:@"open_pic"]){//看图
                
                [self leaveEditMode];
                [self picClicked:weakcell];
                
            }else if([type isEqualToString:@"open_position"]){//看地图
                
                [self leaveEditMode];
                
                MapShowViewController *secondView = [[MapShowViewController alloc] initWithLocation:ready_handle_msg.address_lon showLat:ready_handle_msg.address_lat label:[NSString stringWithFormat:@"位置:%@",ready_handle_msg.addressString]];
              
                [self.navigationController pushViewController:secondView animated:YES];
                secondView = nil;
                
            }
            
            
        } @catch (NSException *exception) {
            
        }
    };
    
   
    cell.msg = msg;

    
    return cell;
    
}




//tableview开始滚动滑动
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self leaveEditMode];
    menuState = YES;
    [self bottomMenuControl];
    user_scrolled = YES;
    
    
}

//tableview滑动中
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

    if((scrollView.contentOffset.y + smsTableHeight) >= scrollView.contentSize.height-tableFootView.frame.size.height && user_scrolled){
        if(totalCount > realMsgCount && !loadingOldMsg){
            loadingOldMsg = YES;
            [self performSelector:@selector(prepare2LoadOldMsg) withObject:nil afterDelay:1.0f];
        }
    }
}


-(void)prepare2LoadOldMsg{
    loadingOldMsg = YES;
    currentPage ++;
    [self getMsgs:YES jump:NO];
    NSLog(@"加载前20条消息");
}






//---------------------------文本输入


-(void) keyboardWillShow:(NSNotification *)note{
    
    keyboardOpened = YES;
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];

    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    nowKeyboardHeight = keyboardBounds.size.height;
    
    CGRect containerFrame = sendView.frame;
    containerFrame.origin.y = bodyView.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);

    CGRect containerMenuFrame = menuView.frame;
    containerMenuFrame.origin.y = bodyView.bounds.size.height;
    
    CGRect containerTableFrame = smsTableView.frame;
    

    
    //不满一页而且会被输入法遮住
   
    if(smsTableView.tableHeaderView !=nil && (smsTableView.contentSize.height-fillHeaderView.frame.size.height) > (BODYHEIGHT-keyboardBounds.size.height-containerMenuFrame.size.height)){
        
       [fillHeaderView setFrame:CGRectMake(0, 0, SCREENWIDTH, keyboardBounds.size.height)];
        
        [self changeHeaderView:YES];
        
    }else if(smsTableView.tableHeaderView == nil){
        containerTableFrame.origin.y= -keyboardBounds.size.height;
    }
    
   
    
     [self jump2LastLine:YES];
    [UIView animateWithDuration:0.3f delay:0
                        options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState) animations:^(void) {
                            
                            sendView.frame = containerFrame;
                            menuView.frame = containerMenuFrame;
                            smsTableView.frame = containerTableFrame;
                            [openMenuBtn.shareImage setImage:[UIImage imageNamed:@"type_select_btn_nor.png"]];

                            
                        }
                     completion:^(BOOL finished){
                         
                         menuState = NO;
                         
                     }];
    
}

-(void) keyboardWillHide:(NSNotification *)note{
        keyboardOpened = NO;
        CGRect containerFrame = sendView.frame;
        containerFrame.origin.y = bodyView.bounds.size.height - containerFrame.size.height;
        
        CGRect containerTableFrame = smsTableView.frame;
        containerTableFrame.origin.y = 0;
    
  
        if(smsTableView.tableHeaderView !=nil){
          
            [fillHeaderView setFrame:CGRectMake(0, 0, SCREENWIDTH, smsTableHeight-(smsTableView.contentSize.height-fillHeaderView.frame.size.height))];
            [self changeHeaderView:YES];
        }
    
        [UIView animateWithDuration:0.3f delay:0
                            options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState) animations:^(void) {
                                sendView.frame = containerFrame;
                                smsTableView.frame = containerTableFrame;
                                [openMenuBtn.shareImage setImage:[UIImage imageNamed:@"type_select_btn_nor.png"]];
                                
                            }
                         completion:^(BOOL finished){
                             menuState = YES;
                             [self jump2LastLine:YES];
                         }];
    
    
}


//textview变高后  sendview跟着变
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height{
    
    diff = (growingTextView.frame.size.height - height);

    CGRect r = sendView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    sendView.frame = r;

//    sendViewHeight = r.size.height;
    
    if(smsTableView.tableHeaderView !=nil&&(smsTableView.contentSize.height-fillHeaderView.frame.size.height) > r.origin.y){
        
        [fillHeaderView setFrame:CGRectMake(0, 0, SCREENWIDTH, BODYHEIGHT-r.origin.y-sendViewHeight)];
        [self changeHeaderView:YES];
        
    }else if(smsTableView.tableHeaderView ==nil){
        [smsTableView setFrame:CGRectMake(0, r.origin.y-smsTableHeight, SCREENWIDTH, smsTableHeight)];
    }
    

}

//判断输入的字是否是回车，即按下return
-(BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    [MainViewController setMethod:@"shouldChangeTextInRange"];
    
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
       
           
            NSInteger now = [[APPUtils GetCurrentTimeString] integerValue];
            
            if(now - clicktime >1){
                clicktime = now;
                [self sendTextMsg];
            }
    
       
        return NO;
    }
    
    return YES;

}



- (void)leaveEditMode {
    
    [textView resignFirstResponder];
   
}




//切换语言和文字
-(void)change_voice_text{
    if(voiceState){
        voiceState = NO;
        [changeVoiceBtn.shareImage setImage:[UIImage imageNamed:@"voice_btn_normal.png"]];
        
        textView.alpha=1;;
        sendVoiceBtn.alpha=0;
        
        [textView becomeFirstResponder];
        
        textView.text = [NSString stringWithFormat:@"%@",textView.text];
        
        
    }else{
        voiceState = YES;
        [changeVoiceBtn.shareImage setImage:[UIImage imageNamed:@"keyboard_btn_normal.png"]];
        textView.alpha=0;;
        sendVoiceBtn.alpha=1;
        
        if(menuState){
            [self bottomMenuControl];
        }else{
            [self leaveEditMode];
        }
        
        [smsTableView setFrame:CGRectMake(0, 0, SCREENWIDTH, BODYHEIGHT-sendViewHeight)];
        [sendView setFrame:CGRectMake(0, BODYHEIGHT-sendViewHeight, SCREENWIDTH, sendViewHeight)];
    }
}



//控制底部菜单的弹出弹入
-(void)bottomMenuControl{
    if(menuState){
        menuState = NO;
        [openMenuBtn.shareImage setImage:[UIImage imageNamed:@"type_select_btn_nor.png"]];

        
        [UIView animateWithDuration:0.3f delay:0
                            options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState) animations:^(void) {
                                
                                if(smsTableView.tableHeaderView!=nil){
                                    [self checkFullOfTable:0];
                                }else{
                                    [smsTableView setFrame:CGRectMake(0, 0, SCREENWIDTH, smsTableHeight)];
                                }
                                [sendView setFrame:CGRectMake(0, BODYHEIGHT-sendViewHeight, SCREENWIDTH, sendViewHeight)];
                                [menuView setFrame:CGRectMake(0, BODYHEIGHT, SCREENWIDTH, menuViewHeight)];
                                
                                
                                
                            }
                         completion:NULL];
        
    }else{
        
        menuState = YES;
        [self leaveEditMode];
        
        [openMenuBtn.shareImage setImage:[UIImage imageNamed:@"type_select_btn_sub.png"]];
        
        if(voiceState){
            voiceState = NO;
            [changeVoiceBtn.shareImage setImage:[UIImage imageNamed:@"voice_btn_normal.png"]];
            textView.alpha=1;;
            sendVoiceBtn.alpha=0;

        }
       
        [self jump2LastLine:YES];
        [UIView animateWithDuration:0.3f delay:0
                            options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState) animations:^(void) {
                                if(smsTableView.tableHeaderView!=nil && (smsTableView.contentSize.height-fillHeaderView.frame.size.height)>BODYHEIGHT-menuViewHeight-sendViewHeight){//不满一页高度 table-高度
                                   
                                    [fillHeaderView setFrame:CGRectMake(0, 0, SCREENWIDTH, menuViewHeight+sendViewHeight)];

                                    [self changeHeaderView:YES];
                                   
                                }else if(smsTableView.tableHeaderView == nil){
                                    [smsTableView setFrame:CGRectMake(0, -(menuViewHeight), SCREENWIDTH, smsTableHeight)];
                                }
                                
                                
                                [sendView setFrame:CGRectMake(0, BODYHEIGHT-sendViewHeight-menuViewHeight, SCREENWIDTH, sendViewHeight)];
                                [menuView setFrame:CGRectMake(0, BODYHEIGHT-menuViewHeight, SCREENWIDTH, menuViewHeight)];
                                
                            }
                         completion:NULL];
    }
}



-(void)closeBottomMenu{
    menuState = YES;
    [self bottomMenuControl];
}











//--------------------------------打开图片发消息
-(void)openPictures{

    LocalPhotoViewController *pick=[[LocalPhotoViewController alloc] init];
    pick.selectPhotoDelegate=self;
    
    [self.navigationController pushViewController:pick animated:YES];
    pick = nil;
}


-(void)getSelectedPhoto:(NSMutableArray *)photos{
   
    
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.myncic.gcd",DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(concurrentQueue, ^{
       
        NSLog(@"共选择%lu张照片,%@",(unsigned long)[photos count],photos);
        
        
        if([photos count]>0){
            NSMutableArray *sendArray = [[NSMutableArray alloc] init];
            
            for(int i=0;i<[photos count];i++){//增加时间间隔，避免block回调导致崩溃**
                
                ALAsset *asset= [photos objectAtIndex:i];
                ALAssetRepresentation* representation = [asset defaultRepresentation];
                
                
                UIImage *tempImg = [UIImage imageWithCGImage:representation.fullScreenImage];//全屏图 推荐使用
                
                
                NSString*tail=asset.defaultRepresentation.url.absoluteString;//获取文件后缀
                tail = [tail substringWithRange:NSMakeRange(tail.length-3,3)];
                tail = [tail lowercaseString];
                
                
                representation = nil;
                asset = nil;

                
                OneMsgEntity *msg = [self savePic2DB:tempImg tail:tail];//保存
                
                [self insertNews2Table:msg];//加入列表
                
                tempImg = nil;
                msg = nil;
                
                [NSThread sleepForTimeInterval:0.2];
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [ShowWaiting hideWaiting];

            });
            
            
            
            sendArray = nil;
        }
        
    });

}


//--------------------------------打开照相机
-(void)openCamera{
    if(makeAvatar == nil){
        makeAvatar = [[MakeAvatarTool alloc]init];
        makeAvatar.not_avatar = YES;
        __weak typeof(self) weakSelf = self;
        makeAvatar.callBackBlock = ^(UIImage *avatar_img){
            [weakSelf saveImg:avatar_img];
        };
    }
    [makeAvatar takePhoto];
}

//保存相机图片
-(void)saveImg:(UIImage*)saveImg{
    
    OneMsgEntity *msg = [self savePic2DB:saveImg tail:@"jpg"];//保存
    
    [self insertNews2Table:msg];//加入列表

}


//保存图片发送信息
-(OneMsgEntity*)savePic2DB:(UIImage*)tempImg tail:(NSString*)tail{


    NSString *msgId = [APPUtils getUniquenessString];
     NSString *fileName = [NSString stringWithFormat:@"%@.%@",msgId,tail];
  

        
    //            NSLog(@"realsize:%lld", [representation size]);
    NSData *bigImageData = UIImageJPEGRepresentation(tempImg, 0.7);
    NSData *smallImageData = UIImageJPEGRepresentation(tempImg, 0.1);
    //            NSLog(@"testdata:%ld", [testdata length]);
    
    if(bigImageData.length>500000){//只有剪裁 >500kb
        CGSize imageSize = tempImg.size;
        imageSize.width =  imageSize.width*0.4;
        imageSize.height = imageSize.height*0.4;//除4最合适 缩放
        
        tempImg = [APPUtils scaleToSize:tempImg size:imageSize];
        bigImageData = UIImageJPEGRepresentation(tempImg, 0.7);
        smallImageData = UIImageJPEGRepresentation(tempImg, 0.1);
    }
    
    //保存大小图到沙盒

    [bigImageData writeToFile: [[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:fileName] atomically:YES];
    [smallImageData writeToFile: [[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",fileName]] atomically:YES];
    
    float imgDirection = tempImg.size.width/tempImg.size.height;//图片宽高比
    NSInteger fileSize = [bigImageData length];//图片大小
        
        
    //插入数据库
    NSMutableDictionary *picDic = [[NSMutableDictionary alloc] init];
    [picDic setObject:fileName forKey:@"filename"];
    [picDic setObject:[NSString stringWithFormat:@"%ld",(long)fileSize] forKey:@"filesize"];
    [picDic setObject:fileName forKey:@"big_url"];
    [picDic setObject:[NSString stringWithFormat:@"thumb_%@",fileName] forKey:@"thumb_url"];
    [picDic setObject:[NSString stringWithFormat:@"%.2f",imgDirection] forKey:@"imageDirection"];
    [self insertOneMsg:@"pic" saveContentsDic:picDic msg_id:msgId];
    
    
    
    OneMsgEntity *thisMsg = [self getTempSendMsg:@"pic"];
    thisMsg.fileName = fileName;
    thisMsg.msg_id = msgId;
    thisMsg.imageDirection = imgDirection;
    thisMsg.filesize = fileSize;

    
    
    picDic = nil;
    bigImageData = nil;
    smallImageData = nil;
    fileName = nil;
    msgId = nil;
    
    return  thisMsg;

}




//点开图片
- (void)picClicked:(MsgCellTableViewCell*)cell{
    
    NSInteger now = [[APPUtils GetCurrentTimeString] integerValue];
    
    if(now - clicktime <=1){
        return;
    }
    clicktime = now;
    
    CLPhotoBrowser *imageBrower = [[CLPhotoBrowser alloc] init];
    imageBrower.msg_type = YES;
    imageBrower.photos = [NSMutableArray array];

    if(ready_handle_msg != nil&&dataList!=nil&&[dataList count]>0){
        
        NSInteger openPicIndex=-1;
      
        NSInteger imgMsgTotal = 0;//图片消息总数
        for(int i=[dataList count]-1;i>=0;i--){
            OneMsgEntity *tempmsg = [dataList objectAtIndex:i];
            if([tempmsg.type isEqualToString:@"pic"]){
                
                
                CLPhoto *photo = [[CLPhoto alloc] init];

                if(tempmsg.sendStatus==0){//对方发来的
                    photo.url = [NSString stringWithFormat:@"http://%@/%@",[AFN_util getIpadd],tempmsg.big_url];
                    photo.thumbUrl =[NSString stringWithFormat:@"http://%@/%@",[AFN_util getIpadd],tempmsg.thumb_url];
                }else{
                    //自己发送的
                    photo.local_img = [UIImage imageWithContentsOfFile:[[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:tempmsg.fileName]];
                    
                    if(photo.local_img == nil){
                        photo = nil;
                        continue;
                    }
                }
                
                
                if([ready_handle_msg.msg_id isEqualToString:tempmsg.msg_id]){
                    openPicIndex = imgMsgTotal;
                }
               
                UIImageView *sourceImageView = (UIImageView*)[cell viewWithTag:233];
                photo.scrRect = [sourceImageView convertRect:sourceImageView.bounds toView:nil];
                sourceImageView = nil;
                
                [imageBrower.photos addObject:photo];
                photo = nil;
                
                imgMsgTotal++;
            }
            
            tempmsg = nil;
            
        }

        if(openPicIndex>=0 && openPicIndex<imgMsgTotal){
            imageBrower.selectImageIndex = openPicIndex;
            [imageBrower show];
        }
        
        
        imageBrower = nil;
        
    }
    
}









//------------发送位置---------------------

-(void)sendPositions{

    SelectEndViewController *secondView = [[SelectEndViewController alloc] initWithSendPostion:MAINCOLOR];
    secondView.delegate = self;
    [self.navigationController pushViewController:secondView animated:YES];
    secondView = nil;
    
    
}


//位置获取回调
-(void)passValue:(NSMutableDictionary *)dic
{
    
    @try {
        
        NSString *passType = [dic objectForKey:@"type"];
        if(passType!= nil && passType.length>0){
        
            if([passType isEqualToString:@"location_ok"]){//发送位置
                
                UIImage *snapImage = [dic objectForKey:@"snap"];
                if(snapImage!=nil){
                    
                    
                    NSString *tempMsgId = [APPUtils getUniquenessString];
                    
                    NSData *snapImageData = UIImageJPEGRepresentation(snapImage, 0.7);
                    NSString *snapName = [NSString stringWithFormat:@"snap_%@.png",tempMsgId];
                    
                    [snapImageData writeToFile: [[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:snapName] atomically:YES];
                    
                    NSString *address_lat = [dic objectForKey:@"lat"];
                    NSString *address_lon = [dic objectForKey:@"lon"];
                    NSString *end_pos = [NSString stringWithFormat:@"%@%@",[dic objectForKey:@"address"],[dic objectForKey:@"poiname"]];
                    
                    NSMutableDictionary *posDic = [[NSMutableDictionary alloc] init];
                    [posDic setObject:snapName forKey:@"filename"];
                     [posDic setObject:@"" forKey:@"thumb_url"];
                    [posDic setObject:end_pos forKey:@"addressString"];
                    [posDic setObject:address_lat forKey:@"address_lat"];
                    [posDic setObject:address_lon forKey:@"address_lon"];
                    [self insertOneMsg:@"pos" saveContentsDic:posDic msg_id:tempMsgId];
                    posDic = nil;
                
                    
                    OneMsgEntity *thisMsg = [self getTempSendMsg:@"pos"];
                    thisMsg.msg_id = tempMsgId;
                    thisMsg.fileName = snapName;
                    thisMsg.addressString = end_pos;
                    thisMsg.address_lat = [address_lat floatValue];
                    thisMsg.address_lon = [address_lon floatValue];
                    
                    
                    [self insertNews2Table:thisMsg];//加入列表
                    
                    thisMsg = nil;
                    
                    tempMsgId = nil;
                    address_lon = nil;
                    address_lat = nil;
                
                    snapImageData = nil;
                 
                    
                }
            }
        }
        
        passType = nil;
        
    } @catch (NSException *exception) {
        
    }
    
}


//------------------------------------发送文本消息
-(void)sendTextMsg{

        NSString *tempMsgId=[APPUtils getUniquenessString];
        
        NSMutableDictionary *textDic = [[NSMutableDictionary alloc] init];
        [textDic setObject:textView.text forKey:@"content"];
        [self insertOneMsg:@"text" saveContentsDic:textDic msg_id:tempMsgId];
        textDic = nil;

        OneMsgEntity *thisMsg = [self getTempSendMsg:@"text"];
        thisMsg.msg_id = tempMsgId;
        thisMsg.content =textView.text;
        thisMsg.textsize = [self getTextSize:thisMsg.content];

    
        [self insertNews2Table:thisMsg];//加入列表
        thisMsg = nil;
    
        textView.text = @"";
        tempMsgId = nil;
    
}



//----------------语言信息----------
#pragma mark - 录音
- (void)record {
    
     [MainViewController setMethod:@"record"];
    
    
        //初始化录音
        recorder = [[AVAudioRecorder alloc]initWithURL:[NSURL fileURLWithPath:recordFilePath]
                                                   settings:[VoiceConverter GetAudioRecorderSettingDict]
                                                      error:nil];
        
        //准备录音
        if ([recorder prepareToRecord]){
            
            [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
            [[AVAudioSession sharedInstance] setActive:YES error:nil];
            recorder.meteringEnabled = YES;
            //开始录音
            if ([recorder record]){
                NSLog(@"开始录音");
              
                NSThread * sThread = [[NSThread alloc] initWithTarget:self
                                                             selector:@selector(updateMetersss)
                                                               object:nil];
                [sThread start];
            }
        }
    
}

//保存录音
-(NSString*)stopAndSaveRecord{

    
      [MainViewController setMethod:@"stopAndSaveRecord"];
    
    //停止录音
    [recorder stop];

    //开始转换格式
   
    NSString *amrName =  [NSString stringWithFormat:@"record_%@%@",[APPUtils getUniquenessString],@".amr"];
    NSString *amrPath = [[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:amrName];
    
    
    //wav转amr  amr用于保存 wav用于播放 每次播放需要先转换
    if ([VoiceConverter ConvertWavToAmr:recordFilePath amrSavePath:amrPath]){
    
        NSLog(@"录音保存成功");
      
        return  amrName;
    }else{
        NSLog(@"wav转amr失败");
 
        return  @"";
    }

}


- (void)updateMetersss{
    
      [MainViewController setMethod:@"updateMetersss"];
    
    

    NSInteger tempTT=-1;
    while (updatingRecordMeters) {
        if (recorder.isRecording){
            
            if(!cancelVoice){
                [recorder updateMeters];
                UIImage *nowMeter;
                
                float power= [recorder averagePowerForChannel:0];//取得第一个通道的音频，注意音频强度范围时-160到0
                
                if (power >= -40 && power < -30){
                    nowMeter = [UIImage imageNamed:@"speak1.png"];
                }else if (power >= -30 && power < -17 ){
                    nowMeter = [UIImage imageNamed:@"speak2.png"];
                }else if (power >= -17){
                    nowMeter = [UIImage imageNamed:@"speak3.png"];
                }else{
                    nowMeter = [UIImage imageNamed:@"speak0.png"];
                }
                
                [self performSelectorOnMainThread:@selector(updateUI:)withObject:nowMeter waitUntilDone:YES];
//                NSLog(@"updating%f",power);
                nowMeter = nil;
                //更新峰值
            }
            
            
            [NSThread sleepForTimeInterval:0.1];
            
            recordTime+=0.1;
            
            if(recordTime>=60){
                [self voiceUp];
            }else if(recordTime>=49){//49
                
                NSInteger tt = 60-recordTime;//60
                if(tempTT != tt){
                    tempTT = tt;
                    
                    [self performSelectorOnMainThread:@selector(updateTime:)withObject:[NSString stringWithFormat:@"%ld",(long)tt] waitUntilDone:YES];
                    
                }
            }
        }else{
            updatingRecordMeters = NO;
        }
    }
}

-(void)updateTime:(NSString*)time{
    
     [MainViewController setMethod:@"updateTime"];
    
    voiceShowImage.alpha=0;
    voiceTimeLabel.alpha=1;

    if([time isEqualToString:@"0"]){
        voiceTimeLabel.text = @"!";
        voiceShowLabel.text = @"录音时间过长!";
        [voiceShowLabelView setBackgroundColor:[UIColor getColor:@"F04639"]];
    }else{
        voiceTimeLabel.text = time;
    }
    
}

-(void)updateUI:(UIImage*)nowMeter{
  [voiceShowImage setImage:nowMeter];
}




-(void)voiceDown{
    
    [MainViewController setMethod:@"voicemsgDown"];
    
    
    if(voiceView == nil){
        
        recordUnderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        [self.view addSubview:recordUnderView];
        recordUnderView.alpha=0;
        
        
        voiceView = [[UIView alloc] initWithFrame:CGRectMake((SCREENWIDTH-SCREENWIDTH*0.4)/2, (SCREENHEIGHT-SCREENWIDTH*0.4)/2, SCREENWIDTH*0.4, SCREENWIDTH*0.4)];
        
        [voiceView setBackgroundColor:[UIColor blackColor]];
        voiceView.alpha = 0;
        voiceView.layer.cornerRadius = 4;
        [self.view addSubview:voiceView];
        
        voiceShowLabel =  [[UILabel alloc] initWithFrame:CGRectMake(0, 0, voiceView.frame.size.width-30, 25)];
        voiceShowLabel.textColor = [UIColor whiteColor];
        voiceShowLabel.font = [UIFont fontWithName:textDefaultBoldFont size:13];
        voiceShowLabel.textAlignment = NSTextAlignmentCenter;
      
        
        voiceShowLabelView = [[UIView alloc] initWithFrame:CGRectMake(15, voiceView.frame.size.height-35, voiceView.frame.size.width-30, 25)];
        [voiceShowLabelView setBackgroundColor:[UIColor clearColor]];
        voiceShowLabelView.layer.cornerRadius = 4;
        [voiceShowLabelView addSubview:voiceShowLabel];
        
        [voiceView addSubview:voiceShowLabelView];
        
        voiceShowImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, voiceView.frame.size.width-40, voiceView.frame.size.height-40)];
        
        [voiceView addSubview:voiceShowImage];
        
        
        voiceTimeLabel =  [[UILabel alloc] initWithFrame:CGRectMake(0, 0, voiceView.frame.size.width, voiceView.frame.size.height-25)];
        voiceTimeLabel.textColor = [UIColor whiteColor];
        voiceTimeLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:70];
        voiceTimeLabel.textAlignment = NSTextAlignmentCenter;
        voiceTimeLabel.alpha=0;
        [voiceView addSubview:voiceTimeLabel];
        
        
    }
    
    recordTime = 0;
    cancelVoice = NO;
    voiceShowImage.alpha=1;
    voiceTimeLabel.alpha=0;
    
    UIImage *voiceImage = [UIImage imageNamed:@"speak0.png"];
    [voiceShowImage setImage:voiceImage];
    voiceShowLabel.text = @"上滑取消录音";
    [voiceShowLabelView setBackgroundColor:[UIColor clearColor]];
    [voiceLabel setText:@"松开 结束"];
    sendVoiceBtn.backgroundColor = [UIColor getColor:@"c7c6cb"];
    updatingRecordMeters = YES;
    
    [self jump2LastLine:YES];
    
    [UIView animateWithDuration:0.2f delay:0
                        options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState) animations:^(void) {
                            recordUnderView.alpha  = 1;
                            voiceView.alpha=0.7;
                        }
                     completion:^(BOOL finished){
                         [msgUtil stopPlayer];
                         
                         if(updatingRecordMeters){
                             [self record];
                         }
                         
                     }];
    
   
    
}


-(void)voiceUp{
    
  
    [voiceLabel setText:@"按住 说话"];
    sendVoiceBtn.backgroundColor = [UIColor getColor:@"F3F3F6"];
    
    if(!updatingRecordMeters){
        [recorder stop];
        [self hideVoiceShow];
        return;
    }
    
    updatingRecordMeters = NO;
    
    if(!cancelVoice){
        if(recordTime<1.0){
            
            voiceShowImage.alpha=0;
            voiceTimeLabel.alpha=1;
            voiceTimeLabel.text = @"!";
            
            voiceShowLabel.text = @"录音时间太短";
            [voiceShowLabelView setBackgroundColor:[UIColor getColor:@"F04639"]];
            NSLog(@"录音已取消");
            [self performSelector:@selector(hideVoiceShow) withObject:nil afterDelay:0.4f];
        }else{
           
            [self hideVoiceShow];
            NSString *amrName = [self stopAndSaveRecord];
            
            if(amrName.length>0){
                
        
                NSString *tempMsgId = [APPUtils getUniquenessString];
                
                NSString *voice_length = [NSString stringWithFormat:@"%.0f",recordTime*1000];
                
                NSMutableDictionary *voiceDic = [[NSMutableDictionary alloc] init];
                [voiceDic setObject:amrName forKey:@"filename"];
                [voiceDic setObject:@"" forKey:@"thumb_url"];
                [voiceDic setObject:voice_length forKey:@"voice_length"];
                [self insertOneMsg:@"voice" saveContentsDic:voiceDic msg_id:tempMsgId];
                voiceDic = nil;
                
                
                OneMsgEntity *thisMsg = [self getTempSendMsg:@"voice"];
                thisMsg.msg_id = tempMsgId;
                thisMsg.fileName = amrName;
                thisMsg.voice_length = [voice_length integerValue];
         
    
                [self insertNews2Table:thisMsg];//加入列表
                thisMsg = nil;
              
                voice_length = nil;
                tempMsgId = nil;
           
            }else{
                voiceView.alpha=1;
                voiceShowImage.alpha=0;
                voiceTimeLabel.alpha=1;
            
                
                voiceTimeLabel.text = @"!";
                
                voiceShowLabel.text = @"录音失败";
                [voiceShowLabelView setBackgroundColor:[UIColor getColor:@"F04639"]];
                NSLog(@"录音已取消");
                [self performSelector:@selector(hideVoiceShow) withObject:nil afterDelay:0.4f];
            }
        }
        
    }else{
        
        [recorder stop];
        [self hideVoiceShow];
        
    
        NSLog(@"录音已取消");
    }
}

-(void)hideVoiceShow{
    [UIView animateWithDuration:0.2f delay:0
                        options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState) animations:^(void) {
                            recordUnderView.alpha = 0;
                            voiceView.alpha=0;
                        }
                     completion:NULL];

    
}


-(void)voiceDragExit{
    UIImage *voiceImage = [UIImage imageNamed:@"record_not_send.png"];
    [voiceShowImage setImage:voiceImage];
    voiceShowLabel.text = @"松开取消发送";
    [voiceShowLabelView setBackgroundColor:[UIColor getColor:@"F04639"]];
    cancelVoice = YES;
}

-(void)voiceDragEnter{
    UIImage *voiceImage = [UIImage imageNamed:@"speak0.png"];
    [voiceShowImage setImage:voiceImage];
    voiceShowLabel.text = @"上滑取消发送";
    [voiceShowLabelView setBackgroundColor:[UIColor clearColor]];
    cancelVoice = NO;
}




//----------------------发送处理

//插入准备发送的信息到DB  返回表里的
-(void)insertOneMsg:(NSString*)sendType saveContentsDic:(NSMutableDictionary*)saveContentsDic msg_id:(NSString*)msg_id{
    
    
    @try {
        
        NSMutableDictionary *msgDic = [[NSMutableDictionary alloc] init];
        
        [msgDic setObject:[NSString stringWithFormat:@"%ld",(long)conversation.group_id] forKey:@"gid"];
        [msgDic setObject:[AFN_util getUserId] forKey:@"uid"];//发送人id
        [msgDic setObject:nickName forKey:@"user"];//发送人id
        [msgDic setObject:sendType forKey:@"type"];
        [msgDic setObject:myAvatarUrl forKey:@"avatar"];
        [msgDic setObject:@"" forKey:@"read-type"];
        
        nowTime = [APPUtils GetCurrentTimeString];
        [msgDic setObject:nowTime forKey:@"createtime"];
        [msgDic setObject:msg_id forKey:@"id"];//缓存消息id  发成功了替换
        
        
        //存入list
        NSString *save2List = [MsgUtil getSave2MsgListSql:msgDic msgFrom:@"3"];
        msgDic = nil;
        if(save2List != nil && save2List.length>0){
            [[MainViewController getDatabase] execSql:save2List];
        }
        save2List = nil;
        
        //存入contents
        [saveContentsDic setObject:sendType forKey:@"type"];
        [saveContentsDic setObject:msg_id forKey:@"id"];
        [saveContentsDic setObject:[NSString stringWithFormat:@"%d",(int)(conversation.group_id)] forKey:@"gid"];
        
        NSString *save2Content = [MsgUtil getSave2MsgContentSql:saveContentsDic  fromMysefl:YES];
        if(save2Content != nil && save2Content.length>0){
            [[MainViewController getDatabase] execSql:save2Content];
        }
        save2Content = nil;
        
    }
    @catch (NSException *exception) {
        
        
    }
    
}


//获取准备发送的Msg
-(OneMsgEntity*)getTempSendMsg:(NSString*)type{

    OneMsgEntity *thisMsg = [[OneMsgEntity alloc] init];
    thisMsg.sendStatus = 3;
    thisMsg.type = type;
    thisMsg.sendWho= sendWho;
    thisMsg.msg_uid = [[AFN_util getUserId] integerValue];
    thisMsg.group_id= conversation.group_id;
    thisMsg.user = nickName;
    thisMsg.createtime =[[APPUtils GetCurrentTimeString] integerValue];
    thisMsg.avatar = myAvatarUrl;
    
    
    return thisMsg;
}



//发送消息 只刷新一条数据 效率提升
-(void)insertNews2Table:(OneMsgEntity*)msg{
    
    if(msg!=nil){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            float theseMsgHeight = 0;//本次插入消息总高度
            
            //插入时间
            if([dataList count]>0){
                OneMsgEntity *lastMsg = [dataList objectAtIndex:0];
                lastMsgTime = lastMsg.createtime;
                lastMsg = nil;
            }else{
                lastMsgTime = 0;
            }
            
            
            OneMsgEntity *timeMsg =  [self getTimeMsg:msg insertType:YES];
            
            if(timeMsg!=nil){
                NSIndexPath *refreshCell = [NSIndexPath indexPathForRow:0 inSection:0];
                NSArray *insertIndexPaths = [NSArray arrayWithObjects:refreshCell,nil];
                [dataList insertObject:timeMsg atIndex:0];
                [smsTableView insertRowsAtIndexPaths:insertIndexPaths  withRowAnimation:UITableViewRowAnimationNone];
                
                theseMsgHeight+=[self getCellHeight:timeMsg];
                 refreshCell = nil;
                insertIndexPaths = nil;
            }
            timeMsg = nil;
            
            
            [dataList insertObject:msg atIndex:0];
            now_in_page_add_msgs++;
            
            NSIndexPath *refreshCell = [NSIndexPath indexPathForRow:0 inSection:0];
            NSArray *insertIndexPaths = [NSArray arrayWithObjects:refreshCell,nil];
            [smsTableView insertRowsAtIndexPaths:insertIndexPaths  withRowAnimation:UITableViewRowAnimationRight];
            
            insertIndexPaths = nil;
            refreshCell = nil;
           

            noChatView.alpha=0;
            
            theseMsgHeight+=[self getCellHeight:msg];
            
            
            [self checkFullOfTable:theseMsgHeight];//检查一行高
            
            [self jump2LastLine:YES];
            
        });
        
    }
    
}





//-----------复制删除

#pragma mark - UIResponder
//能否更改FirstResponder,一般视图默认为NO,必须重写为YES
- (BOOL)canBecomeFirstResponder
{
    return YES;
}
- (BOOL)canPerformAction:(SEL)action withcontrol:(id)control
{
    if (action == @selector(menuItem:) || action == @selector(menuItem3:))
    {
         [menuController setMenuItems:nil];//必须清空
        return YES;
    }
    else
    {
        return NO;
    }
    
}


-(void)menuItem:(id)control{

        //得到剪切板
    @try {
        UIPasteboard *board = [UIPasteboard generalPasteboard];
        board.string = ready_handle_msg.content;
        
        [ToastView showToast:@"已复制到剪贴板"];
    } @catch (NSException *exception) {
        
    }
    
    
}



-(void)menuItem3:(id)control
{
    
    [self leaveEditMode];
     menuState = YES;
    [self bottomMenuControl];
    
    CCActionSheet *actionSheet = [[CCActionSheet alloc] initWithTitle:@"是否删除该条消息" clickedAtIndex:^(NSInteger index) {
        
        if(index == 0){
            @try {
                
                
                [MsgUtil updateSendingMsgs:NO];//必须更新一次 否则容易导致id不对 删除失败
                
                NSString *msgid = ready_handle_msg.msg_id;
                
                
                NSString *sql2 = [NSString stringWithFormat:@"delete from MsgContents where msg_id = '%@' and username = '%@';",msgid,[AFN_util getUserId]];
                [[MainViewController getDatabase] execSql:sql2];
                sql2 = nil;
                
                NSString *sql3 = [NSString stringWithFormat:@"delete from MsgsList where msg_id = '%@' and username = '%@';",msgid,[AFN_util getUserId]];
                [[MainViewController getDatabase] execSql:sql3];
                sql3 = nil;
                
                if(ready_handle_msg.sendStatus == 3){//发送中
                   
                    [APPUtils userDefaultsDelete:msgid];
                    
                }
                
                
                //清理文件
                NSFileManager * filemanager = [[NSFileManager alloc]init];
                if([ready_handle_msg.type isEqualToString:@"pic"]){//图片
                    
                    @try {
                        if([filemanager fileExistsAtPath:[[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:ready_handle_msg.fileName]]){
                            [filemanager removeItemAtPath:[[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:ready_handle_msg.fileName] error:nil];
                        }
                        
                        if([filemanager fileExistsAtPath:[[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",ready_handle_msg.imageName]]]){
                            [filemanager removeItemAtPath:[[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",ready_handle_msg.imageName]] error:nil];
                        }
                        
                        
                    } @catch (NSException *exception) {
                        
                    }
                    
                }else if([ready_handle_msg.type isEqualToString:@"voice"]){//语音
                    @try {
                        if([filemanager fileExistsAtPath:[[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:ready_handle_msg.fileName]]){
                            [filemanager removeItemAtPath:[[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:ready_handle_msg.fileName] error:nil];
                        }
                        if(ready_handle_msg!=nil&&[ready_handle_msg.msg_id isEqualToString:msgUtil.nowPlayingMsgId]&&msgUtil.voice_playing){//停止正在播放的语音
                            [msgUtil stopPlayer];
                        }
                    } @catch (NSException *exception) {
                        
                    }
                    
                }else if([ready_handle_msg.type isEqualToString:@"pos"]){//位置
                    @try {
                        if([filemanager fileExistsAtPath:[[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:ready_handle_msg.fileName]]){
                            [filemanager removeItemAtPath:[[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:ready_handle_msg.fileName] error:nil];
                        }
                    } @catch (NSException *exception) {
                        
                    }
                }
                filemanager = nil;
                
                
                
                //检查下一条是不是时间类型
                BOOL deleteTime=NO;
                float deleteTotalHeight = 0;
                if([dataList count]>1){
                    OneMsgEntity *nextMsg = [dataList objectAtIndex:ready_handle_msg.index_row+1];
                    if([nextMsg.type isEqualToString:@"time"]){
                        deleteTime = YES;
                        deleteTotalHeight+=[self getCellHeight:nextMsg];
                    }
                    nextMsg = nil;
                }
                
                NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
                [indexPaths addObject:[NSIndexPath indexPathForRow:ready_handle_msg.index_row inSection:0]];
                [dataList removeObjectAtIndex:ready_handle_msg.index_row];
                if(deleteTime){
                    [dataList removeObjectAtIndex:ready_handle_msg.index_row];
                    [indexPaths addObject:[NSIndexPath indexPathForRow:ready_handle_msg.index_row+1 inSection:0]];
                }
                
                [smsTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                indexPaths = nil;
                
                deleteTotalHeight+=[self getCellHeight:ready_handle_msg];
                now_in_page_add_msgs--;
                
                if([dataList count]==0){
                    noChatView.alpha=1;
                }else{
                    
                    OneMsgEntity *firstMsg = [dataList objectAtIndex:[dataList count]-1];
                    
                    if(![firstMsg.type isEqualToString:@"time"]){//如果删除最顶上一条后 新的顶上条加上时间
                        
                        lastMsgTime = 0;
                        OneMsgEntity *timeMsg =  [self getTimeMsg:firstMsg insertType:NO];
                        [dataList addObject:timeMsg];
                        
                        NSIndexPath *refreshCell = [NSIndexPath indexPathForRow:[dataList count]-1 inSection:0];
                        NSArray *insertIndexPaths = [NSArray arrayWithObjects:refreshCell,nil];
                        [smsTableView insertRowsAtIndexPaths:insertIndexPaths  withRowAnimation:UITableViewRowAnimationNone];
                        refreshCell = nil;
                        insertIndexPaths = nil;
                        
                        [self checkFullOfTable:-(deleteTotalHeight-[self getCellHeight:timeMsg])];
                        
                        timeMsg = nil;
                        
                        
                    }else{
                        [self checkFullOfTable:-deleteTotalHeight];
                    }
                    
                    firstMsg = nil;
                    
                }
                
                
            } @catch (NSException *exception) {
                
            }
        }
        
    } cancelButtonTitle:@"取消" otherButtonTitles:@"删除",nil];
    
    [actionSheet show];
    actionSheet = nil;
    

    
}



- (void)beBack{
    
    hasOpen = NO;
    
     [msgUtil stopPlayer];
 
    [MsgUtil updateSendingMsgs:NO];//更新发送中的消息结果
    
    if([dataList count]==0){
        //删除列表
        NSString *sql1 = [NSString stringWithFormat:@"delete from MsgGroupList where group_id = '%ld' and username = '%@';",(long)self.conversation.group_id,[AFN_util getUserId]];
        
        [[MainViewController getDatabase] execSql:sql1];
        sql1 = nil;
        
    }else{
        [self setMsgListSummary];
    }
    
    
    if(refreshTimer!=nil){
        [refreshTimer invalidate];
        refreshTimer = nil;
    }
    

    [[NSNotificationCenter defaultCenter] postNotificationName:@"sendMsgPageclosed" object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMsgList" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"1",@"update",nil]];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


//设置消息列表摘要
-(void)setMsgListSummary{

    
    if([dataList count]>0){
        
        OneMsgEntity *msg = [dataList objectAtIndex:0];
        NSString *show =@"";
        if([msg.type isEqualToString:@"text"]){
            show = msg.content;
        }else if([msg.type isEqualToString:@"pos"]){
            show = @"[位置]";
        }else if([msg.type isEqualToString:@"pic"]){
            show = @"[图片]";
        }else if([msg.type isEqualToString:@"voice"]){
            show = @"[语音]";
        }else if([msg.type isEqualToString:@"broadcast"]){
            show = @"[任务动态]";
        }
        
  
        show = [APPUtils fixString:show];
        NSString *updateString=[NSString stringWithFormat:@"update MsgGroupList set lastmsg = '%@', lasttime = '%ld',unread_news_count = '0' where group_id='%ld'",show,(long)msg.createtime,(long)conversation.group_id];
        [[MainViewController getDatabase] execSql:updateString];
        updateString = nil;
        
     
        
        msg = nil;
        
    }
    
   
}


-(void)phone_coming{
    
    [msgUtil stopPlayer];
    
    updatingRecordMeters = NO;
    [self voiceUp];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//注销
-(void)quit2Main{
    if(hasOpen){
        hasOpen = NO;
        [msgUtil stopPlayer];
        
        [self setMsgListSummary];
        
        [self.navigationController popToViewController: [self.navigationController.viewControllers objectAtIndex: ([self.navigationController.viewControllers count]-3)] animated:YES];
    }
    
}






-(void)dealloc {
    //取消注册广播
    hasOpen = NO;
    makeAvatar = nil;
   [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
     [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

    
    
    [[NSNotificationCenter  defaultCenter] removeObserver:self  name:@"quitMsgPage" object:nil];
    [[NSNotificationCenter  defaultCenter] removeObserver:self  name:@"update_sendMsgPage" object:nil];
    [[NSNotificationCenter  defaultCenter] removeObserver:self  name:@"phone_coming" object:nil];
    [[NSNotificationCenter  defaultCenter] removeObserver:self  name:@"closeMsgInput" object:nil];
    


}

@end

