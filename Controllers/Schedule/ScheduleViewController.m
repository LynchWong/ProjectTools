//
//  ScheduleViewController.m
//  zmams
//
//  Created by 李狗蛋 on 15-7-28.
//  Copyright (c) 2015年 李狗蛋. All rights reserved.
//

#import "ScheduleViewController.h"

@interface ScheduleViewController ()

@end

@implementation ScheduleViewController


- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    [self initData];
    [self initViews];
    [self getAlarms];

}

-(void)initData{
    hasOpen = YES;
    cellHeight = 80;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSchedules:)  name:@"refreshSchedules" object:nil];
}

-(void)initViews{
    
    [self.view setBackgroundColor:MAINGRAY];
    
    ZppTitleView *titletView = [[ZppTitleView alloc] initWithTitle:@"日程提醒"];
    [self.view addSubview:titletView];
    titletView.goback = ^(){
        [self beBack];
    };
    
    
    [ShowWaiting showWaiting:@"日程获取中,请稍后"];
    
    UIView *bodyView = [[UIView alloc] initWithFrame:CGRectMake(0, TITLE_HEIGHT, SCREENWIDTH, BODYHEIGHT)];
    [self.view addSubview:bodyView];
    
    
    
    
    MyBtnControl *addAlarm = [[MyBtnControl alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 55)];
    [addAlarm setBackgroundColor:[UIColor getColor:@"eaeaea"]];
    [bodyView addSubview:addAlarm];
    [addAlarm addImage:[UIImage imageNamed:@"add_alarm.png"] frame:CGRectMake(SCREENWIDTH/2-80, (addAlarm.height-30)/2, 30, 30)];
    [addAlarm addLabel:@"添加日程" color:MAINCOLOR font:[UIFont fontWithName:textDefaultBoldFont size:16]];
    [addAlarm addSubview:[APPUtils get_line:0 y:addAlarm.height-0.5 width:SCREENWIDTH]];
    addAlarm.clickBackBlock = ^{
        
        AddScheduleViewController *secondView = [[AddScheduleViewController alloc] init];
        [self.navigationController pushViewController:secondView animated:YES];
        secondView.delegate = self;
        secondView = nil;

    };
    
    alarmTable = [[UITableView alloc] initWithFrame:CGRectMake(0, addAlarm.height, SCREENWIDTH, BODYHEIGHT-addAlarm.height)];
    alarmTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; //隐藏tableview多余行数的线条
    [alarmTable setBounces:YES];
    [alarmTable setBackgroundColor:[UIColor clearColor]];
    alarmTable.delegate = self;//调用delegate
    alarmTable.dataSource=self;
    alarmTable.showsVerticalScrollIndicator = YES;
    [bodyView addSubview:alarmTable];
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl setTintColor:MAINCOLOR];
    [refreshControl addTarget:self action:@selector(getAlarms) forControlEvents:UIControlEventValueChanged];
    [alarmTable addSubview:refreshControl];
    
    
}

//登录刷新
-(void)refreshSchedules:(NSNotification*)notification{

    if(hasOpen){
        NSDictionary *userDic = [notification userInfo];
        dataList = [userDic objectForKey:@"list"];
        [alarmTable reloadData];
    }
}

//获得我的闹钟
-(void)getAlarms{
   
    
    if(![AFN_util isLogin]){
        [[MainViewController sharedMain]openLogin];
    }else{
    
        if(_reloading){
            return;
        }
        _reloading = YES;
        
        NSString *sendString = [NSString stringWithFormat:@"[\"getschedule\",\"%@\",\"%@\",\"%@\"]\r\n]",[AFN_util getUserId],[AFN_util getScode],[AFN_util getUserId]];

        
        SocketUtils *st2 = [[SocketUtils alloc] init];
        st2.not_show_fail = YES;
        st2.socketResult = ^(NSInteger succeed, NSString *resultString){
            
            if(succeed == 1){
                
                @try {
                    
                    dataList = [[NSMutableArray alloc] init];
                    
                    NSArray *alarmsArr = [APPUtils getArrByJson:resultString];
                    
                    NSMutableArray *deleteArr = [[NSMutableArray alloc] init];
                    
                    for(NSDictionary *dic in alarmsArr){
                        AlarmEntity *alarm = [ScheduleViewController getAlarmEntity:dic];
                        if(alarm!=nil){
                            if(alarm.outOfDate){
                                [deleteArr addObject:alarm];
                            }else{
                                [dataList addObject:alarm];
                            }
                            
                        }
                        alarm = nil;
                        
                    }
                    
                    //自动清理
                    if([deleteArr count]>0){
                        [self deleteOutOfDate:deleteArr];
                    }
                    
                    
                    
                } @catch (NSException *exception) {}
            }
            
            
            [self refreshOver];
        };
        [st2 send:sendString];
        st2= nil;
        sendString = nil;
        
    }
}

//自动删除过期日程
-(void)deleteOutOfDate:(NSMutableArray*)arr{
    if(deleteing){
        return;
    }
    deleteing = YES;
    
    if([arr count]>0){
    
        NSString *sendString = [NSString stringWithFormat:@"[\"delschedule\",\"%@\",\"%@\",\"%@\"]\r\n]",[AFN_util getUserId],[AFN_util getScode],((AlarmEntity*)[arr objectAtIndex:0]).alarmId];
        
        SocketUtils *st2 = [[SocketUtils alloc] init];
        st2.socketResult = ^(NSInteger succeed, NSString *resultString){
            
            if(succeed == 1){
                deleteing = NO;
                [arr removeObjectAtIndex:0];
                [self deleteOutOfDate:arr];
            }
        };
        [st2 send:sendString];
        st2= nil;
        sendString = nil;
        
    }else{
        deleteing = NO;
        NSLog(@"自动删除过期日程完毕");
    }
    
   
    
}

//刷新完成
-(void)refreshOver{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if([dataList count]==0){
            isEmpty = YES;
        }else{
            isEmpty = NO;
            
            [ScheduleViewController resetSchedules:dataList];//检查注册
        }
        
        [UIView transitionWithView:alarmTable duration: 0.1 options: UIViewAnimationOptionTransitionCrossDissolve
                        animations: ^(void){
                            [alarmTable reloadData];
                        }completion: NULL];
        
        [ShowWaiting hideWaiting];
        [refreshControl endRefreshing];
        _reloading = NO;
    });
    
}



//显示tableview 的章节数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

//显示多少cells
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(!isEmpty){
        return [dataList count];
    }else{
        return 1;
    }
    
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    //定义个静态字符串为了防止与其他类的tableivew重复
    
    static NSString *CellIdentifier = @"CellIndentifer_alarm";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        
    }else{
        for (UIView *cellView in cell.subviews){
            [cellView removeFromSuperview];
        }
    }
    
    cell.backgroundColor = [UIColor whiteColor];
     cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if(!isEmpty){
    
       //cell选中变灰
        
        NSUInteger row = [indexPath row];
        AlarmEntity * alarm  = [dataList objectAtIndex:row];
        

        MyBtnControl *alarmBtn = [[MyBtnControl alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, cellHeight)];
        [cell addSubview:alarmBtn];
        
        [alarmBtn addImage:[UIImage imageNamed:@"alarm.png"] frame:CGRectMake(25, (cellHeight-30)/2, 30, 30)];
        
        [alarmBtn addLabel:alarm.tempTime color:TEXTGRAY font:[UIFont fontWithName:textDefaultBoldFont size:20] txtAlignment:NSTextAlignmentLeft frame:CGRectMake(alarmBtn.shareImage.x*2+alarmBtn.shareImage.width, 0, 200, cellHeight*0.68)];
        
        [alarmBtn addLabel:alarm.repeatword color:[UIColor getColor:@"808080"] font:[UIFont fontWithName:textDefaultFont size:12] txtAlignment:NSTextAlignmentLeft frame:CGRectMake(alarmBtn.shareLabel.x, cellHeight-40, SCREENWIDTH-(alarmBtn.shareLabel.x+30), 25)];
        
         [alarmBtn addLabel:alarm.labelshow color:[UIColor lightGrayColor] font:[UIFont fontWithName:textDefaultFont size:11] txtAlignment:NSTextAlignmentLeft frame:CGRectMake(alarmBtn.shareLabel.x, cellHeight-22, alarmBtn.shareLabel.width, 20)];
        
         [alarmBtn addSubview:[APPUtils get_line:0 y:cellHeight-0.5 width:SCREENWIDTH]];
         [alarmBtn addSubview:[APPUtils get_forward:cellHeight x:SCREENWIDTH-30]];
    
        alarmBtn.clickBackBlock = ^{
         
            AddScheduleViewController *secondView = [[AddScheduleViewController alloc] initWithAlarm:alarm];
            [self.navigationController pushViewController:secondView animated:YES];
            secondView.delegate = self;
            secondView = nil;
           
        };
        
        alarmBtn = nil;
        alarm = nil;

    }else{
    
        UIImageView *no_mission_imageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREENWIDTH-ERROR_STATE_BACKGROUND_WIDTH)/2, (BODYHEIGHT-ERROR_STATE_BACKGROUND_WIDTH)/2-50, ERROR_STATE_BACKGROUND_WIDTH, ERROR_STATE_BACKGROUND_WIDTH)];
        [no_mission_imageView setImage:[UIImage imageNamed:@"no_schedules.png"]];
        [cell addSubview:no_mission_imageView];
        no_mission_imageView = nil;
    }
    
        return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(isEmpty){
        return  tableView.height;
    }else{
        
       return cellHeight;
        
    }
   
}



//操作回调
-(void)passValue:(NSString *)value{
    
    if([value isEqualToString:@"refresh_alarms"]){
        [self getAlarms];
    }
}



//---------闹钟设定

+(void)resetSchedules:(NSMutableArray*)alarmArr{

    @try {
        
        NSString *arr_key = [NSString stringWithFormat:@"schedules_%@",[AFN_util getUserId]];
        NSMutableArray *schedulesArr = [[APPUtils getUserDefault] objectForKey:arr_key];
        
        @try {
            if(schedulesArr!=nil && ![schedulesArr isEqual:[NSNull null]]  && [schedulesArr count]>0){
                //解除全部本地推送
                UIApplication *app = [UIApplication sharedApplication];
                NSArray *localArray = [app scheduledLocalNotifications];
                
                for (UILocalNotification *noti in localArray) {
                    
                    NSDictionary *dict = noti.userInfo;
                    
                    if (dict) {
                        
                        NSString *inKey = [dict objectForKey:@"alarmId"];
                        
                        for(NSString *alarmId in schedulesArr){
                        
                            if ([inKey isEqualToString:alarmId]) {
                                NSLog(@"解除闹钟:%@",alarmId);
                                [app cancelLocalNotification:noti];
                                break;
                            }
                            
                        }
                        
                    }
                    dict = nil;
                }
                localArray = nil;
                app = nil;
                
            }
        } @catch (NSException *exception) {}
       
        
        schedulesArr = [[NSMutableArray alloc] init];
        
        if(alarmArr!=nil && [alarmArr count]>0){
            //注册闹钟
            
            NSDate* now = [NSDate date];
            NSInteger nowTime  = [[APPUtils GetCurrentTimeString] integerValue];
            NSMutableDictionary *alarmDic = [[NSMutableDictionary alloc] init];
            
            for(AlarmEntity *alarm in alarmArr){
            
                
                    if(alarm.repeatType == 0){
                        
                        if(alarm.alarmTime<=nowTime){
                            continue;
                        }else{
                            
                            [ScheduleViewController registerAlarm:[now dateByAddingTimeInterval:alarm.alarmTime-nowTime] labelshow:alarm.labelshow alarmId:alarm.alarmId repeatType:0];//不重复
                            [schedulesArr addObject:alarm.alarmId];
                       
                        }
                       
                    }else{
                        if(alarm.everyDay){
                            
                            [ScheduleViewController registerAlarm:alarm.alarmDate labelshow:alarm.labelshow alarmId:alarm.alarmId repeatType:kCFCalendarUnitDay];//每天重复
                            [schedulesArr addObject:alarm.alarmId];
                        
                        }else{
                        
                            NSArray * daysArray = [alarm.repeatDays componentsSeparatedByString:@","];
                            NSDateComponents *comps  = [APPUtils getDateInfo:now];
                            
                            int nowWeek = [comps weekday]-1; //今天星期几  星期日是数字1，星期一时数字2
                            if(nowWeek == 0){
                                nowWeek = 7;
                            }
                            
                            
                            for(int i=0;i<[daysArray count];i++){
                                
                                int dayWeek = [[daysArray objectAtIndex:i] integerValue];//星期几响铃
                                NSDate *nextdate;//下一次响铃时间
                                
                                //如果是今天
                                if(dayWeek == nowWeek){
                                    
                                    nextdate = alarm.alarmDate;
                                    
                                }else{//不是今天
                                    NSInteger nextDaySaveTime = 0;
                                    if(dayWeek>nowWeek){
                                        nextDaySaveTime = alarm.alarmTime + 86400*(dayWeek-nowWeek);//加n天的秒数
                                        
                                    }else{
                                        nextDaySaveTime = alarm.alarmTime + 86400*(dayWeek+7-nowWeek);//加n天的秒数
                                    }
                                    
                                    nextdate = [APPUtils unixTime2Date:nextDaySaveTime];
                                    
                                }
                                
                                [ScheduleViewController registerAlarm:nextdate labelshow:alarm.labelshow alarmId:[NSString stringWithFormat:@"%@_%d",alarm.alarmId,(int)i] repeatType:NSCalendarUnitWeekOfYear];//一周一次
                                
                                [schedulesArr addObject:[NSString stringWithFormat:@"%@_%d",alarm.alarmId,(int)i]];
                                
                                nextdate = nil;
                                
                            }
                            
                            daysArray = nil;
                        }
                        
                    }
          
                alarmDic = nil;
        
            }
        }
        
        [[APPUtils getUserDefault] setObject:schedulesArr forKey:arr_key];
        
    } @catch (NSException *exception) {}
}


//注册
+(void)registerAlarm:(NSDate*)fireDate labelshow:(NSString*)labelshow alarmId:(NSString*)alarmId repeatType:(NSInteger)repeatType{

    UILocalNotification *notification=[[UILocalNotification alloc] init];
    if (notification!=nil){
        
        notification.repeatInterval = repeatType;//不重复
        notification.fireDate=fireDate;//距现在多久后触发代理方法
        
        notification.timeZone=[NSTimeZone timeZoneWithName:@"GMT+8"];
        notification.soundName = @"alarmring.mp3"; //控制横幅的显示时长 只能通过铃声的时长来控制
        notification.alertBody = labelshow;
        
        NSDictionary *infoDic = [NSDictionary dictionaryWithObjectsAndKeys:alarmId,@"alarmId",notification.alertBody,@"show",nil];
        notification.userInfo = infoDic;
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        
        NSLog( @"注册闹钟:%@",alarmId);
    }
    
}

- (void)beBack{
    //退回到第一个窗口
    hasOpen = NO;
    [self.navigationController popViewControllerAnimated:YES];
}


//获取日程单例
+(AlarmEntity*)getAlarmEntity:(NSDictionary*)dic{
    
    AlarmEntity *alarm = [[AlarmEntity alloc] init];
    @try {
        
        alarm.alarmId = [dic objectForKey:@"id"];
        alarm.repeatType = [[APPUtils fixString:[dic objectForKey:@"repeat"]] isEqualToString:@"week"]?1:0;
        alarm.uid = [dic objectForKey:@"uid"];
        alarm.labelshow = [APPUtils fixString:[dic objectForKey:@"content"]];
        
        NSDateFormatter *formater  =  [[NSDateFormatter alloc]init];
        [formater setDateFormat:@"yyyy-MM-dd HH:mm"];
        
        //重复的年月日是0
        int year = [[dic objectForKey:@"year"] integerValue];
        int month = [[dic objectForKey:@"month"] integerValue];
        int day = [[dic objectForKey:@"day"] integerValue];
        
        if(year == 0){
            
            NSDateComponents *d = [APPUtils getDateInfo:[NSDate date]];
            
            year = d.year;
            month = d.month;
            day = d.day;
        }
        
        
        NSString *s = [NSString stringWithFormat:@"%d-%d-%d %@:%@",year,month,day,[dic objectForKey:@"hour"],[dic objectForKey:@"minute"]];
        alarm.alarmDate = [formater dateFromString:s];
        
        alarm.alarmTime = [APPUtils date2Unixtime:alarm.alarmDate];
        
        [formater setDateFormat:@"hh:mm a"];
        alarm.tempTime = [formater stringFromDate:alarm.alarmDate];
        
        [formater setDateFormat:@"yyyy-MM-dd"];
        alarm.tempDate = [formater stringFromDate:alarm.alarmDate];
        
        if(alarm.repeatType==0){
            alarm.repeatword = @"单次响铃";
            
            if(alarm.alarmTime<=[[APPUtils GetCurrentTimeString] integerValue]){
                alarm.outOfDate = YES;
            }
            
        }else{
            NSArray *mondayArray = [NSArray arrayWithObjects:@"周一",@"周二",@"周三",@"周四",@"周五",@"周六",@"周日", nil];
            NSArray *daysArray = [NSArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7", nil];
            NSArray *repeatsArr =  [[dic objectForKey:@"week"] componentsSeparatedByString:@","];
            NSMutableString *weekString = [[NSMutableString alloc] init];
            NSInteger exist = 0;
            for(NSString *s in repeatsArr){
    
                [weekString appendString:[NSString stringWithFormat:@"%@%@",(exist==0?@"":@","),[mondayArray objectAtIndex:[daysArray indexOfObject:s]]]];
                exist++;
            }
            if(exist == 7){
                alarm.repeatword = @"每日响铃";
                alarm.everyDay = YES;
            }else{
                alarm.repeatword = [NSString stringWithFormat:@"%@",weekString];
            }
            alarm.repeatDays = [dic objectForKey:@"week"];
            
            weekString = nil;
            repeatsArr = nil;
            mondayArray = nil;
            daysArray = nil;
        }
        
        formater = nil;
        
        return alarm;
    } @catch (NSException *exception) {}
    
    return nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)dealloc {
    
    [[NSNotificationCenter  defaultCenter] removeObserver:self  name:@"refreshSchedules" object:nil];
}


@end
