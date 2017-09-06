//
//  MyMsgViewController.m
//  MedicalCenter
//
//  Created by 李狗蛋 on 15-3-20.
//  Copyright (c) 2015年 李狗蛋. All rights reserved.
//

#import "MyMsgViewController.h"
#import "MainViewController.h"
#import "SendMsgViewController.h"
#import "OneMsgEntity.h"



@interface MyMsgViewController ()

@end

@implementation MyMsgViewController
@synthesize dataList;
@synthesize searchBar;
@synthesize tableCoverView;

- (id)initWithTitle:(BOOL)title{
    self = [super init];
    if (self) {
        noTitle = title;
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    
    if([APPUtils isTheSameColor2:TITLE_WORD_COLOR anotherColor:[UIColor whiteColor]]){//标题是白色
        return UIStatusBarStyleLightContent;
    }else{
        return UIStatusBarStyleDefault;
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    hasOpen = YES;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMsgList:)  name:@"refreshMsgList" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendMsgPageclosed)  name:@"sendMsgPageclosed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quit2Main)  name:@"quitMsgPage" object:nil];//被T

    [self initController];
    [self getGroups];
    
}




-(void)initController{

    [APPUtils setMethod:@"MyMsgViewController -> initController"];
    
    [[UITextField appearance] setTintColor:MAINCOLOR];

    [self.view setBackgroundColor:MAINGRAY];
    
    
    if(!noTitle){
        ZppTitleView *titletView = [[ZppTitleView alloc] initWithTitle:@"我的消息"];
        [self.view addSubview:titletView];
        titletView.goback = ^(){
            [self beback];
        };
    }
    
    
    bodyView = [[UIView alloc] initWithFrame:CGRectMake(0, (noTitle?0:TITLE_HEIGHT), SCREENWIDTH, (noTitle?BODYHEIGHT:PAGEHEIGHT))];
    [self.view addSubview:bodyView];
    
    
    _smsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, bodyView.height)];
    self.edgesForExtendedLayout = UIRectEdgeNone;//tableView 上会多出20个像素 去掉 *
    [_smsTable setBackgroundColor:[UIColor clearColor]];
    [bodyView addSubview:_smsTable];
    self.smsTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; //隐藏tableview多余行数的线条
    [self.smsTable setBounces:YES];
    _smsTable.delegate = self;//调用delegate
    _smsTable.dataSource=self;
    _smsTable.separatorStyle = UITableViewCellSeparatorStyleNone; //去掉table分割线
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl setTintColor:MAINCOLOR];
    [refreshControl setAlpha:0.7];
    [refreshControl addTarget:self action:@selector(refreshMsgs) forControlEvents:UIControlEventValueChanged];
    [_smsTable addSubview:refreshControl];


    
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 41)];
    [bodyView addSubview:searchBar];
    
    searchBar.delegate = self;
    [searchBar setPlaceholder:@"搜索名字"];
    searchBar.alpha=0;
    tableCoverView = [[UIControl alloc] initWithFrame:CGRectMake(0, 41, SCREENWIDTH, SCREENHEIGHT)];
    [tableCoverView setBackgroundColor:[UIColor blackColor]];
    tableCoverView.alpha = 0.6;
    [tableCoverView addTarget:self action:@selector(clickCover:) forControlEvents:UIControlEventTouchDown];
    [tableCoverView setHidden:YES];
    [bodyView addSubview:tableCoverView];
    

   
    _formatterDate=[[NSDateFormatter alloc]init];
    _formatterTime=[[NSDateFormatter alloc]init];
    [_formatterDate setLocale:[NSLocale currentLocale]];
    [_formatterTime setLocale:[NSLocale currentLocale]];
    [_formatterDate setDateFormat:@"yyyy-MM-dd"];
    [_formatterTime setDateFormat:@"HH:mm"];
    
 
    
    if(noTitle){
        //未登录显示登录按钮
        noLogin = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, PAGEHEIGHT)];
        [noLogin setBackgroundColor:MAINGRAY];
        noLogin.alpha=0;
        [self.view addSubview:noLogin];
        
        UILabel *noLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (PAGEHEIGHT-30)/2-20, SCREENWIDTH, 30)];
        noLabel.textColor = [UIColor lightGrayColor];
        noLabel.font = [UIFont fontWithName:textDefaultFont size:13];
        noLabel.textAlignment = NSTextAlignmentCenter;
        noLabel.numberOfLines = 0;
        noLabel.text = @"点击登录后即可使用消息功能";
        [noLogin addSubview:noLabel];
        
        
        
        MyBtnControl *loginBtn = [[MyBtnControl alloc] initWithFrame:CGRectMake((SCREENWIDTH-80)/2, noLabel.y+noLabel.height+10, 80, 35)];
        [loginBtn setBackgroundColor:MAINCOLOR];
        loginBtn.layer.cornerRadius = loginBtn.height/2;
        [loginBtn.layer setMasksToBounds:YES];
        [noLogin addSubview:loginBtn];
        [loginBtn addLabel:@"点击登录" color:[UIColor whiteColor] font:[UIFont fontWithName:textDefaultBoldFont size:13]];
        loginBtn.clickBackBlock = ^(){
        
            [[MainViewController sharedMain]openLogin];
        };
        noLabel = nil;
    }
}

//显示未登录
-(void)showNoLogin:(BOOL)show{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(show){
           noLogin.alpha=1;
        }else{
           noLogin.alpha=0;
        }
       
    });
}

//刷新新消息
-(void)refreshMsgs{
    [[MainViewController sharedMain].msgUtil check_msgs];
}


//获取本地消息
-(void)getGroups{
    
 
    if(![AFN_util isLogin]){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            noLogin.alpha=1;
            [dataList removeAllObjects];
            isEmpty = YES;
            [_smsTable reloadData];
        });
     
        return;
    }
    
    
    noLogin.alpha=0;
    
    [APPUtils setMethod:@"MyMsgViewController -> getGroups"];
    
    if(groupGetting){
        return;
    }
    groupGetting = YES;
   

    if([[MainViewController sharedMain].msgUtil getMsgChecking]){
        return;
    }

    if(todayUnixTime == 0){
        
        NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
        NSString *todayDate = [_formatterDate stringFromDate:dat];
        
        [_formatterDate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSDate *date = [_formatterDate dateFromString:[NSString stringWithFormat:@"%@%@",todayDate,@" 00:00:00"]];
        
        NSTimeInterval a=[date timeIntervalSince1970];
        NSString *timeString = [NSString stringWithFormat:@"%f", a];
        todayUnixTime = [timeString integerValue];
        yesterdayUnixTime = todayUnixTime - 86400;
        
        todayDate = nil;
        date = nil;
        [_formatterDate setDateFormat:@"M-d"];
    }
    
    

        
        
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //db会崩溃？
        //        NSString *updateString3=[NSString stringWithFormat:@"update MsgList set isread = '0' where sendStatus!='0' and ipadd = '%@';",[AFN_util getIpadd]];
        //        [[MainViewController getDatabase] execSql:updateString3];
        //        updateString3 = nil;
        
        dataList = [[NSMutableArray alloc] init];
        
        
        NSString *sqlQuery = [NSString stringWithFormat:@"select * from MsgGroupsList where username='%@' and ipadd = '%@' order by lasttime desc",[AFN_util getUserId],[AFN_util getIpadd]];
        
        
        FMResultSet *resultSet = [[MainViewController getDatabase] queryDatabase:sqlQuery];
        
        while ([resultSet next]) {
            
            Conversation *conv = [[Conversation alloc] init];
            
            conv.lastAvatar =[resultSet stringForColumn:@"lastavatar"];
            conv.lasttime = [resultSet intForColumn:@"lasttime"];
            conv.group = [resultSet stringForColumn:@"groups"];
            conv.lastmsg = [resultSet stringForColumn:@"lastmsg"];
            conv.gname = [resultSet stringForColumn:@"gname"];
            conv.otheruid = [resultSet intForColumn:@"otheruid"];
            conv.people = [resultSet intForColumn:@"people"];
            conv.master = [resultSet intForColumn:@"master"];
            conv.unread_news_count = [resultSet intForColumn:@"unread_news_count"];
            
            
            
            double unixTimeStamp = conv.lasttime;
            NSTimeInterval _interval=unixTimeStamp;
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
            
            if(unixTimeStamp < todayUnixTime && unixTimeStamp >= yesterdayUnixTime){
                conv.showTime = @"昨天";
                
            }else if(unixTimeStamp < yesterdayUnixTime){
                conv.showTime  = [NSString stringWithFormat:@"%@",[_formatterDate stringFromDate:date]];
            }else{
                conv.showTime  = [_formatterTime stringFromDate:date];
                
            }
            
            
            [dataList addObject:conv];
            conv = nil;
        }
        
        [resultSet close];//清理资源
        resultSet = nil;
        
        NSLog(@"读取消息列表完毕：%lu",(unsigned long)[dataList count]);
        
        
        if(self.searchBar.text.length > 0){
            
            [self loadFilterArr];
        }
        
        if([dataList count]>0){
            isEmpty = NO;
        }else{
            isEmpty = YES;
        }
        
        [[MainViewController sharedMain] setUnreadMsgs:NO];
        
        [UIView transitionWithView:_smsTable duration: 0.1f options: UIViewAnimationOptionTransitionCrossDissolve
                        animations: ^(void){
                            [_smsTable reloadData];
                            
                        }completion: ^(BOOL isFinished){
                            [self refreshOver];
                            groupGetting = NO;
                        }];
    });
  
 
    
}


//-----------------------------数据列表-----------------------------------------

//绑定searchbar和tableview
- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated
{
    [_smsTable scrollRectToVisible:searchBar.frame animated:animated];
}

//点击搜索框后
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    
   
    
    self.searchBar.showsCancelButton = YES;
    
    //cancel 颜色
    for(UIView *view in  [[[self.searchBar subviews] objectAtIndex:0] subviews]) {
        
        if([view isKindOfClass:[NSClassFromString(@"UINavigationButton") class]]) {
            UIButton * cancel =(UIButton *)view;
            [cancel setTitle:@"取消" forState:UIControlStateNormal];
            [cancel setTintColor:[UIColor whiteColor]];
            
        }
    }
    
    
    if(self.searchBar.text.length == 0){
        [tableCoverView setHidden:NO];
    }else{
        [tableCoverView setHidden:YES];
    }
    
    return YES;
}


//开始输入搜索条件
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    

    
   
    if(self.searchBar.text.length == 0){
        [tableCoverView setHidden:NO];
    }else{
        [tableCoverView setHidden:YES];
    }
    filteredContact = nil;
    
    
    if(searchText.length>0){
        [self loadFilterArr];
        [_smsTable reloadData];
    }else{
        [self getGroups];
    }

}


//装载搜索数据
-(void)loadFilterArr{
    
    [APPUtils setMethod:@"MyMsgViewController -> loadFilterArr"];
    
    filteredContact = [[NSMutableArray alloc] init];
    @try {
        for(int j=0;j<[dataList count];j++){
            Conversation *conv = [dataList objectAtIndex:j];
            
            NSString *tempName = conv.gname;
            if(tempName == nil||tempName.length==0){
                conv = nil;
                continue;
            }
            
            CFStringRef aCFString = (__bridge CFStringRef)[tempName substringWithRange:NSMakeRange(0,1)];
            CFMutableStringRef letter = CFStringCreateMutableCopy(NULL, 0, aCFString);
            CFStringTransform(letter, NULL, kCFStringTransformMandarinLatin, NO);
            CFStringTransform(letter, NULL, kCFStringTransformStripDiacritics, NO);
            NSString *b = [NSString stringWithFormat:@"%@",letter];
            
            NSRange range = [b rangeOfString:[self.searchBar.text substringWithRange:NSMakeRange(0,1)]];
            
            
            if (range.location != NSNotFound) {
                [filteredContact addObject:conv];
            }
            conv = nil;
            tempName = nil;
        }
        
    } @catch (NSException *exception) {
        
    }

}

- (void)searchDisplayControllerWillBeginSearch:(UISearchController *)controller

{
    filteredContact = dataList;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchController *)controller
{
    filteredContact = nil;
}

- (BOOL)searchDisplayController:(UISearchController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSArray *tempArray = [dataList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains[cd] %@", searchString]];
    
    filteredContact = [tempArray copy];
    return YES;
}

//通过失焦searchbar隐藏输入法，但是这样cancel按钮也会失焦，所以把cancel按钮找到让它变成可用
-(void)hideInput{
    [self.searchBar resignFirstResponder];
    
    for(UIView *view in  [[[self.searchBar subviews] objectAtIndex:0] subviews]) {
        
        if([view isKindOfClass:[NSClassFromString(@"UINavigationButton") class]]) {
            UIButton * cancel =(UIButton *)view;
            cancel.enabled=YES;
        }
    }
}

//点击键盘的搜索按钮后
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self hideInput];
    
    [tableCoverView setHidden:YES];
}

//点击搜索的cancel按钮
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    self.searchBar.showsCancelButton = NO;
    [self.searchBar resignFirstResponder];
    [tableCoverView setHidden:YES];
    self.searchBar.text = @"";
    [self getGroups];
}

- (IBAction)clickCover:(id)sender {
    
    [self hideInput];
    
    [tableCoverView setHidden:YES];
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self getGroups];
}



//tableview 开始滑动
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}


-(void)refreshOver{
    
    [APPUtils setMethod:@"MyMsgViewController -> refreshOver"];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:0.3f
                              delay:0
                            options:(UIViewAnimationOptionAllowUserInteraction|
                                     UIViewAnimationOptionBeginFromCurrentState)
                         animations:^(void) {
                             
                             CGRect containerFrame = _smsTable.frame;
                             if(isEmpty){
                                 searchBar.alpha=0;
                                 containerFrame.origin.y = 0;
                                 containerFrame.size.height = BODYHEIGHT;
                             }else{
                                 searchBar.alpha=1;
                                 containerFrame.origin.y = 41;
                                 containerFrame.size.height = BODYHEIGHT-41;
                             }
                             _smsTable.frame = containerFrame;
                             
                             
                         }
                         completion:^(BOOL finished) {
                             
                             [refreshControl endRefreshing];
                             
                         }];
        
    });

}



//显示tableview 的章节数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

//显示多少cells
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(isEmpty){
        return 1;
    }else{
        if (self.searchBar.text.length == 0) {
            return [dataList count];
        } else {
            return filteredContact.count;
        }
    }
    
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
     [APPUtils setMethod:@"MyMsgViewController -> cellForRowAtIndexPath"];
    //定义个静态字符串为了防止与其他类的tableivew重复
 
    static NSString *CellIdentifier = @"CellIndentifer_sms";

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
    

    if(isEmpty){
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
            UIImageView *noChatView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREENWIDTH-ERROR_STATE_BACKGROUND_WIDTH)/2, (SCREENHEIGHT-ERROR_STATE_BACKGROUND_WIDTH)/2-TITLE_HEIGHT+20, ERROR_STATE_BACKGROUND_WIDTH, ERROR_STATE_BACKGROUND_WIDTH)];
            [noChatView setImage:[UIImage imageNamed:@"no_msgs.png"]];
            [cell addSubview: noChatView];
        
       
            noChatView = nil;
    }else{
        NSUInteger row = [indexPath row];
        Conversation *conv;
        
        @try {
            if(self.searchBar.text.length == 0){
                conv  = [dataList objectAtIndex:row];
            }else{
                conv  = [filteredContact objectAtIndex:row];
            }
        } @catch (NSException *exception) {
            return cell;
        }
        
        
        UIScrollView *cellScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 65)];
        [cellScrollview setBackgroundColor:[UIColor clearColor]];
        [cellScrollview setPagingEnabled:YES];
        [cellScrollview setShowsHorizontalScrollIndicator:NO];
        [cellScrollview setShowsVerticalScrollIndicator:NO];
        [cellScrollview setScrollEnabled:YES];
        cellScrollview.tag = 11;
        [cellScrollview setContentSize:CGSizeMake(SCREENWIDTH+160, 65)];
        [cellScrollview setContentOffset:CGPointMake(0, 0) animated:YES];
        [cell addSubview:cellScrollview];
        
        
        
        
        UIImageView *asynImgView = [[UIImageView alloc] init];
        asynImgView.frame = CGRectMake(15, 9, 47, 47);
        [asynImgView sd_setImageWithURL:[NSURL URLWithString:conv.lastAvatar] placeholderImage:[UIImage imageNamed:@"defaultHead.png"]];
        [asynImgView.layer setCornerRadius:(asynImgView.height/2)];
        [asynImgView.layer setMasksToBounds:YES];//圆角不被盖住
        [asynImgView setContentMode:UIViewContentModeScaleAspectFill];
        [asynImgView setClipsToBounds:YES];//减掉超出部分
        asynImgView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        asynImgView.layer.borderWidth = 0.2f;
        asynImgView.backgroundColor = [UIColor whiteColor];
        
        [cellScrollview addSubview:asynImgView];
        
 
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(73, 10, SCREENWIDTH-73-71, 23)];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        nameLabel.textColor = TEXTGRAY;
        

        
        nameLabel.font = [UIFont fontWithName:textDefaultFont size:14];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.numberOfLines = 1;
        nameLabel.text = conv.gname;
        
        [cellScrollview addSubview:nameLabel];
        nameLabel = nil;
        
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH-71, 11, 50, 23)];
        [timeLabel setBackgroundColor:[UIColor clearColor]];
        timeLabel.textColor = [UIColor lightGrayColor];
        timeLabel.font = [UIFont fontWithName:textDefaultFont size:12];
        timeLabel.textAlignment = NSTextAlignmentRight;
        timeLabel.numberOfLines = 1;
        timeLabel.text = conv.showTime;
        [cellScrollview addSubview:timeLabel];
        timeLabel = nil;
        
        
        
        UILabel *shortLabel = [[UILabel alloc] initWithFrame:CGRectMake(73, 35, SCREENWIDTH-73-15, 23)];
        [shortLabel setBackgroundColor:[UIColor clearColor]];
        shortLabel.textColor = [UIColor lightGrayColor];
        shortLabel.font = [UIFont fontWithName:textDefaultFont size:12];
        shortLabel.textAlignment = NSTextAlignmentLeft;
        shortLabel.numberOfLines = 1;
        shortLabel.text = conv.lastmsg;
        [cellScrollview addSubview:shortLabel];
        shortLabel = nil;
        
        
        
        UIView *unreadView = [[UIView alloc] initWithFrame:CGRectMake(50, 6, 17, 17)];
        [unreadView setBackgroundColor:MAINRED];
        [unreadView.layer setCornerRadius:(unreadView.height/2)];
        [unreadView.layer setMasksToBounds:YES];//圆角不被盖住
        [unreadView setContentMode:UIViewContentModeScaleAspectFill];
        [unreadView setClipsToBounds:YES];//减掉超出部分
        [cellScrollview addSubview:unreadView];
        
        
        UILabel *unreadLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 17, 17)];
        [unreadLabel setBackgroundColor:[UIColor clearColor]];
        unreadLabel.textColor = [UIColor whiteColor];
        unreadLabel.font = [UIFont fontWithName:textDefaultFont size:9];
        unreadLabel.textAlignment = NSTextAlignmentCenter;
        
        [unreadView addSubview:unreadLabel];
        
        
        if(conv.unread_news_count!= 0){
            
            
            [unreadView setHidden:NO];
            [cellScrollview bringSubviewToFront:unreadView];
            NSInteger unreadCount = conv.unread_news_count;
            
            if(unreadCount<100 && unreadCount>9){
                [unreadView setFrame:CGRectMake(48, 4, 17+6, 16)];
                [unreadLabel setText:[NSString stringWithFormat:@"%d",(int)unreadCount]];
            }else if(unreadCount<10){
                
                [unreadView setFrame:CGRectMake(50, 6, 17, 17)];
                [unreadLabel setText:[NSString stringWithFormat:@"%d",(int)unreadCount]];
            }else{
                [unreadView setFrame:CGRectMake(46, 4, 17+10, 17)];
                [unreadLabel setText:@"99+"];
            }
            
            [unreadView.layer setCornerRadius:(unreadView.height/2)];
            [unreadLabel setFrame:CGRectMake(0, 0, unreadView.width, unreadView.height)];
            
        }else{
            [unreadView setHidden:YES];
        }
        
        unreadView = nil;
        unreadLabel = nil;
        
        UIImageView *titleLine;
        BOOL last = NO;
        if(self.searchBar.text.length == 0){
            if(indexPath.row == [dataList count]-1){
                last = YES;
            }
        }else{
            if(indexPath.row == [filteredContact count]-1){
                last = YES;
            }
        }

        if(last){
           titleLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64.5, cellScrollview.contentSize.width, 0.5)];
        }else{
            titleLine = [[UIImageView alloc] initWithFrame:CGRectMake(15, 64.5, cellScrollview.contentSize.width-15, 0.5)];
        }
       
        [titleLine setBackgroundColor:[UIColor lightGrayColor]];
        titleLine.alpha = 0.5;
        [cellScrollview addSubview:titleLine];
        titleLine = nil;
        
        
        MyBtnControl *normalControl = [[MyBtnControl alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 65)];
        [cellScrollview addSubview:normalControl];
        normalControl.back_highlight = YES;
        normalControl.clickBackBlock = ^(){
            [self performSelector:@selector(openSendPage:) withObject:[NSString stringWithFormat:@"%d",(int)indexPath.row] afterDelay:0.1f];
        };
        
        normalControl = nil;
        
        
        MyBtnControl *readControl = [[MyBtnControl alloc] initWithFrame:CGRectMake(SCREENWIDTH, 0, 80, 65)];
        [readControl setBackgroundColor:[UIColor getColor:@"cccccc"]];
        [cellScrollview addSubview:readControl];
        
   
        [readControl addLabel:@"标记已读" color:[UIColor whiteColor] font:[UIFont fontWithName:textDefaultBoldFont size:14]];
        
        readControl.clickBackBlock = ^(){
            [self setIsRead:conv.group includeVoice:YES];
            conv.unread_news_count = 0;
            [tableView beginUpdates];
            [dataList replaceObjectAtIndex:indexPath.row withObject:conv];//刷新数组
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[tableView indexPathForCell:cell],nil]withRowAnimation:UITableViewRowAnimationNone];//刷新cell ui
            [tableView endUpdates];
        };
        
        readControl = nil;
   
        
        
        
        MyBtnControl *deleteControl = [[MyBtnControl alloc] initWithFrame:CGRectMake(SCREENWIDTH+80, 0, 80, 65)];
        [deleteControl setBackgroundColor:MAINRED];
        [deleteControl setTag:indexPath.row];
        [cellScrollview addSubview:deleteControl];
        
        [deleteControl addLabel:@"删除" color:[UIColor whiteColor] font:[UIFont fontWithName:textDefaultBoldFont size:14]];
       
        
        deleteControl.clickBackBlock = ^(){
            
            NSFileManager* fileManager=[NSFileManager defaultManager];
            
            
            NSString *sql1 = [NSString stringWithFormat:@"delete from MsgGroupsList where groups = '%@' and username = '%@' and ipadd = '%@';",conv.group,[AFN_util getUserId],[AFN_util getIpadd]];
            [[MainViewController getDatabase] execSql:sql1];
            sql1 = nil;
      
      
            //删除文件
            NSString *sqlQuery3 = [NSString stringWithFormat:@"select big_url,thumb_url from MsgsContents where groups='%@' and ipadd = '%@';",conv.group,[AFN_util getIpadd]];
            
            FMResultSet *resultSet3 = [[MainViewController getDatabase] queryDatabase:sqlQuery3];
            
            while ([resultSet3 next]) {
                
                NSString *big_url = [resultSet3 stringForColumnIndex:0];
                NSString *thumb_url = [resultSet3 stringForColumnIndex:1];
                if(big_url!=nil && big_url.length>0){
                    NSString *tempFilePath1 = [[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:big_url];
                    if ([APPUtils fileExist:tempFilePath1]) {
                        [fileManager removeItemAtPath:tempFilePath1 error:nil];
                    }
                    tempFilePath1 = nil;
                }
                big_url = nil;
                
                if(thumb_url!=nil && thumb_url.length>0){
                    NSString *tempFilePath1 = [[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:thumb_url];
                    if ([APPUtils fileExist:tempFilePath1]) {
                        [fileManager removeItemAtPath:tempFilePath1 error:nil];
                    }
                    tempFilePath1 = nil;
                }
                thumb_url = nil;
                
            }
            
            [resultSet3 close];//清理资源
            resultSet3=nil;
            sqlQuery3 = nil;
         
            
            NSString *sql2 = [NSString stringWithFormat:@"delete from MsgsContents where groups = '%@' and username = '%@' and ipadd = '%@';",conv.group,[AFN_util getUserId],[AFN_util getIpadd]];
            [[MainViewController getDatabase] execSql:sql2];
            sql2 = nil;
            
            NSString *sql3  = [NSString stringWithFormat:@"delete from MsgList where groups = '%@' and username = '%@' and ipadd = '%@';",conv.group,[AFN_util getUserId],[AFN_util getIpadd]];
            [[MainViewController getDatabase] execSql:sql3];
            sql3 = nil;
            
            fileManager = nil;
            
            [[MainViewController sharedMain] setUnreadMsgs:NO];
            
       
            [ToastView showToast:@"删除成功"];
            
            @try {
                if(self.searchBar.text.length == 0){
                    [dataList removeObjectAtIndex:indexPath.row];
                    
                }else{
                    [filteredContact removeObjectAtIndex:indexPath.row];
                }
                
                NSMutableArray *indexPaths = [NSMutableArray arrayWithObject:[tableView indexPathForCell:cell]];
                [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                indexPaths = nil;
            } @catch (NSException *exception) {
                
            }
            
            
            if([dataList count]==0){
                isEmpty = YES;
                [self refreshOver];
                [tableView reloadData];
            }
        
        };
        
        
        deleteControl = nil;
      
        
        asynImgView = nil;
        cellScrollview = nil;
    }
    
    
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [APPUtils setMethod:@"MyMsgViewController -> heightForRowAtIndexPath"];
    
    
    if(isEmpty){
        return bodyView.height;
    }else{
        return 65.0;
    }
    
}




-(void)openSendPage:(NSString*)index{
  
     [APPUtils setMethod:@"MyMsgViewController -> openSendPage"];
    
    @try {
        if(![[MainViewController sharedMain].msgUtil getMsgChecking]){
            intoSendMsgPage = YES;
            Conversation *conv = [dataList objectAtIndex:[index integerValue]];
            
            [self setIsRead:conv.group includeVoice:NO];
            
            SendMsgViewController *secondView = [[SendMsgViewController alloc] initWithConversation:conv show:!_hideSend];
            
            
            if(noTitle){
                [[MainViewController sharedMain].navigationController pushViewController:secondView animated:YES];
            }else{
                [self.navigationController pushViewController:secondView animated:YES];
            }
            secondView = nil;
            
            conv = nil;
        }
        
    } @catch (NSException *exception) {}
    

}

//标为已读
-(void)setIsRead:(NSString*)groupId includeVoice:(BOOL)includeVoice{//包含语音
    
    [APPUtils setMethod:@"MyMsgViewController -> setIsRead"];
    
    NSString *updateString=[NSString stringWithFormat:@"update MsgGroupsList set unread_news_count = '0' where groups='%@' and username = '%@' and ipadd = '%@';",groupId,[AFN_util getUserId],[AFN_util getIpadd]];
    
    [[MainViewController getDatabase] execSql:updateString];
    updateString = nil;
    
    NSString *updateString2=@"";
    
    if(includeVoice){
        updateString2=[NSString stringWithFormat:@"update MsgList set isread = '0' where groups='%@' and username = '%@' and ipadd = '%@'",groupId,[AFN_util getUserId],[AFN_util getIpadd]];
    }else{
        updateString2 = [NSString stringWithFormat:@"update MsgList set isread = '0' where groups='%@' and username = '%@' and msg_type!='voice' and ipadd = '%@';",groupId,[AFN_util getUserId],[AFN_util getIpadd]];
    }
    
    [[MainViewController getDatabase] execSql:updateString2];
    updateString2 = nil;
    
}



- (void)refreshMsgList:(NSNotification*)notification{
    
    [APPUtils setMethod:@"MyMsgViewController -> refreshMsgList"];
    
    if(hasOpen){
        if(notification!=nil){
            NSDictionary *userDic = [notification userInfo];
            NSInteger update = [[userDic objectForKey:@"update"] integerValue];
            
            if((update==1 || [dataList count] ==0)){
                [self getGroups];
            }
            userDic = nil;
        }
        [self refreshOver];
      
    }
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)beback{
    
    self.callBackBlock();
    hasOpen = NO;

    if(noTitle){
        [self performSelector:@selector(getGroups) withObject:nil afterDelay:0.5f];
    }else{
          [self.navigationController popViewControllerAnimated:YES];
    }
  

}

-(void)sendMsgPageclosed{
    intoSendMsgPage = NO;
}

//注销
-(void)quit2Main{
    
    if(!intoSendMsgPage&&hasOpen){
        [self beback];
    }
}


-(void)dealloc {
    //取消注册广播
    hasOpen = NO;

    [[NSNotificationCenter  defaultCenter] removeObserver:self  name:@"quitMsgPage" object:nil];
    [[NSNotificationCenter  defaultCenter] removeObserver:self  name:@"refreshMsgList" object:nil];
     [[NSNotificationCenter  defaultCenter] removeObserver:self  name:@"sendMsgPageclosed" object:nil];
}




@end



