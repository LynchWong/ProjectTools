//
//  AddScheduleViewController.m
//  zmams
//
//  Created by 李狗蛋 on 15-8-6.
//  Copyright (c) 2015年 李狗蛋. All rights reserved.
//

#import "AddScheduleViewController.h"
#import "ZJSwitch.h"


@interface AddScheduleViewController ()

@end

@implementation AddScheduleViewController
@synthesize myAlarm;

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


- (id)initWithAlarm:(AlarmEntity*)alarm{
    self = [super init];
    if (self) {
        
        myAlarm = [alarm copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initDatas];
    [self initViews];

    
}

-(void)initDatas{
    
    if(myAlarm==nil){
        isAdd = YES;
        myAlarm = [[AlarmEntity alloc] init];
    }
   
    
    formatterTime  =  [[NSDateFormatter alloc]init];
    [formatterTime setDateFormat:@"hh:mm a"];
    
    formatterDate  =  [[NSDateFormatter alloc]init];
    [formatterDate setDateFormat:@"yyyy-MM-dd"];
    
    
    if(isAdd){
        
        myAlarm.alarmDate = [NSDate date];
        myAlarm.repeatword = @"单次响铃";
        myAlarm.tempDate = [formatterDate stringFromDate:myAlarm.alarmDate];
        myAlarm.tempTime = [formatterTime stringFromDate:myAlarm.alarmDate];
    }
    
    
    
    
    
    dateSelector = [[DateSelector alloc] initWithTitle:@"转到今天"];
    
   
    
    
}

-(void)initViews{

    
    [self.view setBackgroundColor:MAINGRAY];
  
    
    ZppTitleView *titletView = [[ZppTitleView alloc] initWithTitle:isAdd?@"添加日程":@"编辑日程"];
    [self.view addSubview:titletView];
    titletView.goback = ^(){
        [self beBack];
    };
    
    
    
    MyBtnControl *saveBtn = [[MyBtnControl alloc] initWithFrame:CGRectMake(SCREENWIDTH-70, 20, 70, 44)];
    [saveBtn addLabel:@"保存日程" color:[UIColor whiteColor] font:[UIFont fontWithName:textDefaultBoldFont size:12]];
    [titletView addSubview:saveBtn];
    saveBtn.clickBackBlock = ^{
        [self saveAlarm];
    };
    
    
    
    UIView *bodyView = [[UIView alloc] initWithFrame:CGRectMake(0, TITLE_HEIGHT, SCREENWIDTH, BODYHEIGHT)];
    [bodyView setBackgroundColor:MAINGRAY];
    [self.view addSubview:bodyView];

    
    lastY = 20;
    

    [bodyView addSubview: [self getColumn:@"时间" show:[formatterTime stringFromDate:myAlarm.alarmDate] index:0]];
    [bodyView addSubview: [self getColumn:@"重复" show:myAlarm.repeatword index:1]];
    [bodyView addSubview: [self getColumn:@"响铃日期" show:[formatterDate stringFromDate:myAlarm.alarmDate] index:2]];
    [bodyView addSubview: [self getColumn:@"提醒内容" show:[APPUtils fixString:myAlarm.labelshow] index:3]];
    
    

    
    if(!isAdd){
        //删除
        MyBtnControl *deleteBtn = [[MyBtnControl alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT-50, SCREENWIDTH, 50)];
        [deleteBtn setBackgroundColor:MAINRED];
        [deleteBtn addLabel:@"删除该日程" color:[UIColor whiteColor] font:[UIFont fontWithName:textDefaultBoldFont size:13]];
        [deleteBtn addSubview:[APPUtils get_line:0 y:0 width:SCREENWIDTH]];
        [self.view addSubview: deleteBtn];
        deleteBtn.clickBackBlock = ^{
            
            CCActionSheet *actionSheet = [[CCActionSheet alloc] initWithTitle:@"确认删除该日程？" clickedAtIndex:^(NSInteger index) {
                
                if(index == 0){
                    [self deleteAlarm:NO];
                }
                
            } cancelButtonTitle:@"取消" otherButtonTitles:@"立即删除",nil];
            
            [actionSheet show];
            actionSheet = nil;
            
            
        };
    }

}


-(MyBtnControl*)getColumn:(NSString*)name show:(NSString*)show index:(NSInteger)index{

    float btnHeight = 55;
    float x = 20;
    float fontSize = 13;
    
    MyBtnControl *columnControl = [[MyBtnControl alloc] initWithFrame:CGRectMake(0, lastY, SCREENWIDTH, (index==3)?btnHeight*1.5:btnHeight)];
    columnControl.not_highlight = YES;
    [columnControl setBackgroundColor:[UIColor whiteColor]];
    [columnControl addLabel:name color:TEXTGRAY font:[UIFont fontWithName:textDefaultBoldFont size:fontSize+1] txtAlignment:NSTextAlignmentLeft x:x];
    [columnControl addSubview:[APPUtils get_line:0 y:0 width:SCREENWIDTH]];
    columnControl.shareLabel2 = columnControl.shareLabel;
    
  
        
    [columnControl addSubview:[APPUtils get_forward:columnControl.height x:SCREENWIDTH-20]];
    
    if(index == 3){
        [columnControl addLabel:(show.length==0)?@"点击设置":show color:(show.length==0)?[UIColor lightGrayColor]:TEXTGRAY font:[UIFont fontWithName:textDefaultFont size:fontSize] txtAlignment:NSTextAlignmentRight frame:CGRectMake(80, 0, SCREENWIDTH-80-x, columnControl.height)];
        [columnControl addSubview:[APPUtils get_line:0 y:columnControl.height-0.5 width:SCREENWIDTH]];
        columnControl.shareLabel.numberOfLines=3;
    }else{
        [columnControl addLabel:show color:MAINCOLOR font:[UIFont fontWithName:textDefaultFont size:fontSize] txtAlignment:NSTextAlignmentRight x:-x];
        
    }
      
    
    
    __weak typeof(self) weakSelf = self;
    __weak __typeof(MyBtnControl*)weakBtn = columnControl;
    
    __block NSDate *tempDate = myAlarm.alarmDate;
    columnControl.clickBackBlock = ^{
        
    if(index ==0){//时间
        

            dateSelector.dateback = ^(NSDate* date){
                
                tempDate = date;
                myAlarm.tempTime = [formatterTime stringFromDate:date];
                [weakBtn.shareLabel setText:myAlarm.tempTime];
            };
            
            [dateSelector show:tempDate dateType:UIDatePickerModeTime];
            
        }else if(index ==1){//重复
            
            [weakSelf chooseWeek:weakBtn];
            
        }else if(index ==2){//日期
            
            dateSelector.dateback = ^(NSDate* date){
                
                tempDate = date;
                myAlarm.tempDate = [formatterDate stringFromDate:date];
                [weakBtn.shareLabel setText:myAlarm.tempDate];
            };
            [dateSelector show:tempDate dateType:UIDatePickerModeDate];
            
        }else if(index ==3){//内容
            
            if(desText == nil){
                
                desText = [[SetTextview alloc] initWithTitle:@"设置提醒内容"];
                
                [desText setKeyType:UIKeyboardTypeDefault];
                desText.setback = ^(NSString *titleString,NSString *contentString){
                    
            
                    if(contentString.length>0){
                        weakSelf.myAlarm.labelshow = contentString;
                        weakBtn.shareLabel.textColor = TEXTGRAY;
                    }else{
                        weakSelf.myAlarm.labelshow = @"点击设置";
                        weakBtn.shareLabel.textColor = [UIColor lightGrayColor];
                    }
                    
                    weakBtn.shareLabel.text = weakSelf.myAlarm.labelshow;
                    
                };
            
            }
             [desText setMaxLength:50];
             [desText show: [weakBtn.shareLabel.text stringByReplacingOccurrencesOfString:@"点击设置" withString:@""]];
            
        }
        
    };
    
    
    lastY+=btnHeight;
    
    if(index==2){
        alarmDateBtn = columnControl;
        if(myAlarm.repeatType==1){
            lastY-=btnHeight;
        }
    }else if(index == 3){
        alertBtn = columnControl;
    }
    
    return columnControl;
}





//选择重复
-(void)chooseWeek:(MyBtnControl*)repeatBtn{
    
    if(chooseWeekView == nil){
        
        chooseWeekView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        chooseWeekView.alpha=0;
        [self.view addSubview:chooseWeekView];
        
        NSMutableArray *selectWeekArr = [[NSMutableArray alloc] initWithObjects:@"0",@"0",@"0",@"0",@"0",@"0",@"0", nil];
        NSArray *mondayArray = [NSArray arrayWithObjects:@"周一",@"周二",@"周三",@"周四",@"周五",@"周六",@"周日", nil];
        
        
        MyBtnControl *closeWeek = [[MyBtnControl alloc] initWithFrame:chooseWeekView.frame];
        closeWeek.alpha=0.6;
        closeWeek.not_ShareHighlight = YES;
        [closeWeek setBackgroundColor:[UIColor blackColor]];
        [chooseWeekView addSubview:closeWeek];
        closeWeek.clickBackBlock = ^{
          
            NSMutableString *weeks = [[NSMutableString alloc] init];
            NSMutableString *days = [[NSMutableString alloc] init];
            NSInteger i=0;
            NSInteger exist = 0;
            for(NSString *s in selectWeekArr){
                
                if([s integerValue] == 1){
                    [weeks appendString:[NSString stringWithFormat:@"%@%@",(exist==0?@"":@","),[mondayArray objectAtIndex:i]]];
                    [days appendString:[NSString stringWithFormat:@"%@%d",(exist==0?@"":@","),(int)i+1]];
                    exist++;
                }
                i++;
            }
            NSString *repeatWord = [NSString stringWithFormat:@"%@",weeks];
            
            if(repeatWord.length==0){
                repeatWord = @"单次响铃";
                myAlarm.repeatType = 0;
            }else{
                myAlarm.repeatType = 1;
                if(exist == [mondayArray count]){
                    repeatWord = @"每天响铃";
                }
                myAlarm.repeatDays = days;
            }
            
            myAlarm.repeatword = repeatWord;
            
            repeatBtn.shareLabel.text = repeatWord;
            
            [UIView animateWithDuration:0.3 animations:^{
                chooseWeekView.alpha=0;
                if(myAlarm.repeatType==1){
                    alertBtn.y = alarmDateBtn.y;
                }else{
                    alertBtn.y = alarmDateBtn.y+alarmDateBtn.height;
                }
            }];
        };
        
        
        
        CGFloat yHeight = 50;
        CGFloat cWidth = SCREENWIDTH*0.8;
        
       
        
        
        
        UIView *weekView = [[UIView alloc] initWithFrame:CGRectMake((SCREENWIDTH- cWidth)/2, (SCREENHEIGHT-yHeight*8)/2, cWidth, yHeight*8)];
        [weekView setBackgroundColor:[UIColor whiteColor]];
        weekView.layer.cornerRadius = 4;
        [weekView.layer setMasksToBounds:YES];//圆角不被盖住
        [chooseWeekView addSubview:weekView];
      
    
 
        UILabel *menuLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cWidth, yHeight)];
        menuLabel.text = @"设置重复";
        menuLabel.textAlignment = NSTextAlignmentCenter;
        menuLabel.textColor = MAINCOLOR;
        menuLabel.font = [UIFont fontWithName:textDefaultBoldFont size:15];
        [weekView addSubview:menuLabel];
        menuLabel = nil;
        
    
        
        for(int i=0;i<[mondayArray count];i++){
         
            NSArray *existweek;
            if(myAlarm.repeatType==1){
                existweek = [myAlarm.repeatword componentsSeparatedByString:@","];
            }
            
            MyBtnControl *weekBtn = [[MyBtnControl alloc] initWithFrame:CGRectMake(0, (i+1)*yHeight, cWidth, yHeight)];
            [weekBtn addLabel:[mondayArray objectAtIndex:i] color:TEXTGRAY font:[UIFont fontWithName:textDefaultFont size:14] txtAlignment:NSTextAlignmentLeft x:20];
            
      
            [weekBtn addSubview:[APPUtils get_line:0 y:0 width:cWidth]];
            
            
            UIImage *selectImg = [UIImage imageNamed:@"img_isselect_refuse.png"];
            if(myAlarm.repeatType==1){
            
                BOOL exist = NO;
                if(myAlarm.everyDay){
                    exist = YES;
                }else{
                    for(NSString *week in existweek){
                        if([week isEqualToString:[mondayArray objectAtIndex:i]]){
                            exist = YES;
                            break;
                        }
                    }
                }
                
                if(exist){
                    selectImg = [UIImage imageNamed:@"img_isselect.png"];
                    [selectWeekArr replaceObjectAtIndex:i withObject:@"1"];
                    weekBtn.choosed = YES;
                }
                
               
            }
            
            __weak __typeof(MyBtnControl*)weakBtn = weekBtn;
            [weekBtn addImage:selectImg frame:CGRectMake(cWidth-40, (yHeight-20)/2, 20, 20)];
            weekBtn.clickBackBlock = ^{
                weakBtn.choosed = !weakBtn.choosed;
                
                [weakBtn.shareImage setImage:(weakBtn.choosed?[UIImage imageNamed:@"img_isselect.png"]:[UIImage imageNamed:@"img_isselect_refuse.png"])];
                
                [selectWeekArr replaceObjectAtIndex:i withObject:(weakBtn.choosed?@"1":@"0")];
            };
            [weekView addSubview:weekBtn];
        }
    
    }


    [UIView animateWithDuration:0.3 animations:^{
        chooseWeekView.alpha=1;
    }];
    
}



//保存
-(void)saveAlarm{

    NSDateFormatter *formater  =  [[NSDateFormatter alloc]init];
    [formater setDateFormat:@"yyyy-MM-dd hh:mm a"];
    
    myAlarm.alarmDate = [formater dateFromString:[NSString stringWithFormat:@"%@ %@",myAlarm.tempDate,myAlarm.tempTime]];
    NSInteger alarmUnix = [APPUtils date2Unixtime:myAlarm.alarmDate];
    
    if(myAlarm.repeatType==0 && alarmUnix<= [[APPUtils GetCurrentTimeString] integerValue]){
        [ToastView showToast:@"不能设置过去时间!"];
        return;
    }
    
    
    [ShowWaiting showWaiting:@"同步中,请稍后"];
    
    if(isAdd){
        [self save2Server];
    }else{
        [self deleteAlarm:YES];
    }
    
    formater = nil;
    
}


//上传服务器
-(void)save2Server{

    NSDateComponents *comps  = [APPUtils getDateInfo:myAlarm.alarmDate];
    
    int year = [comps year];
    int month = [comps month];
    int day = [comps day];
    int hour = [comps hour];
    int min = [comps minute];
    
  
    
    NSString *jsonString = [NSString stringWithFormat:@"[{\"repeat\":\"%@\",\"id\":\"%@\",\"uid\":\"%@\",\"year\":\"%d\",\"month\":%d,\"day\":%d,\"week\":\"%@\",\"hour\":%d,\"minute\":%d,\"content\":\"%@\"}]",(myAlarm.repeatType==1?@"week":@""),[APPUtils fixString:myAlarm.alarmId],[AFN_util getUserId],(int)year,(int)month,(int)day,[APPUtils fixString:myAlarm.repeatDays],hour,min,[APPUtils fixString:myAlarm.labelshow].length==0?@"自定义":[APPUtils fixString:myAlarm.labelshow]];
    jsonString = [APPUtils urlEncode:jsonString];
    
    NSString *sendString = [NSString stringWithFormat:@"[\"saveschedule\",\"%@\",\"%@\",\"%@\"]\r\n]",[AFN_util getUserId],[AFN_util getScode],jsonString];
    
    SocketUtils *st2 = [[SocketUtils alloc] init];
    st2.socketResult = ^(NSInteger succeed, NSString *resultString){
        
        if(succeed == 1){
      
            [ToastView showToast:@"同步成功"];
            [self.delegate passValue:@"refresh_alarms"];
            [self beBack];
        }else{
             [ToastView showToast:@"同步错误，请重试"];
        }
        
    };
    [st2 send:sendString];
    st2= nil;
    sendString = nil;
}


//删除 （是否是修改）
-(void)deleteAlarm:(BOOL)add{
    
    NSString *sendString = [NSString stringWithFormat:@"[\"delschedule\",\"%@\",\"%@\",\"%@\"]\r\n]",[AFN_util getUserId],[AFN_util getScode],myAlarm.alarmId];
    
    SocketUtils *st2 = [[SocketUtils alloc] init];
    st2.socketResult = ^(NSInteger succeed, NSString *resultString){
        
        if(succeed == 1){
            
            if(add){
                [self save2Server];
            }else{
                 [ShowWaiting showWaiting:@"同步中,请稍后"];
                 [ToastView showToast:@"删除成功"];
                 [self.delegate passValue:@"refresh_alarms"];
                 [self beBack];
            }
        }else{
            [ToastView showToast:@"操作异常，请重试"];
        }
    };
    [st2 send:sendString];
    st2= nil;
    sendString = nil;
}

- (void)beBack{
    dispatch_async(dispatch_get_main_queue(), ^{
         [self.navigationController popViewControllerAnimated:YES];
    });
   
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
