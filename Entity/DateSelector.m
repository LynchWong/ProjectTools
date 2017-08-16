//
//  DateSelector.m
//  wuneng
//
//  Created by Chuck on 2017/6/13.
//  Copyright © 2017年 myncic.com. All rights reserved.
//

#import "DateSelector.h"
#import "MainViewController.h"
@implementation DateSelector
@synthesize datePicker;

- (id)initWithTitle:(NSString*)titleString{
    self = [super init];
    if (self) {
        title = titleString;
        selectedDate = [NSDate date];
        _formatString = @"yyyy-MM-dd";
        [self initView];
    }
    return self;
}

-(void)initView{

    [[[UIApplication sharedApplication].delegate window] addSubview:self];
    [self setFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    self.alpha=0;
    
    backCoverView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    [backCoverView setBackgroundColor:[UIColor blackColor]];
    backCoverView.alpha = 0;
    [backCoverView addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchDown];
    [self addSubview:backCoverView];
    
    
    showDateView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, 260)];
    [showDateView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:showDateView];
    
    [showDateView addSubview:[APPUtils get_line:0 y:0 width:SCREENWIDTH]];
    
    
    UIView *dateChooseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0.5, SCREENWIDTH, 40)];
    [dateChooseView setBackgroundColor:[UIColor whiteColor]];
    [showDateView addSubview:dateChooseView];
    
    [showDateView addSubview:[APPUtils get_line:0 y:dateChooseView.height+dateChooseView.y width:SCREENWIDTH]];
    
    
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, dateChooseView.height)];
    [cancelBtn setTitle:@"取消     " forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont fontWithName:textDefaultFont size:13];
    
    [cancelBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [cancelBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [dateChooseView addSubview:cancelBtn];
    
    [cancelBtn addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *okBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH-80, 0, 80, dateChooseView.height)];
    [okBtn setTitle:@"     确定" forState:UIControlStateNormal];
    okBtn.titleLabel.font = [UIFont fontWithName:textDefaultBoldFont size:13];
    
    [okBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [okBtn setTitleColor:MAINCOLOR forState:UIControlStateNormal];
    [dateChooseView addSubview:okBtn];
    
    [okBtn addTarget:self action:@selector(chooseDate) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, dateChooseView.height)];
    dateLabel.text = title;
    dateLabel.textAlignment = NSTextAlignmentCenter;
    dateLabel.textColor = TEXTGRAY;
    dateLabel.font = [UIFont fontWithName:textDefaultBoldFont size:15];
    [dateChooseView addSubview:dateLabel];
    
    if([title isEqualToString:@"转到今天"]){
        MyBtnControl *today = [[MyBtnControl alloc] initWithFrame:CGRectMake((SCREENWIDTH-100)/2, 0, 100, dateChooseView.height)];
        [dateChooseView addSubview:today];
        today.shareLabel = dateLabel;
        today.not_highlight = YES;
        today.clickBackBlock = ^(){
           
            selectedDate = [NSDate date];
            [datePicker setDate:selectedDate animated:YES];
        };
        today = nil;
        
    }
    
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, dateChooseView.height+dateChooseView.y+0.5, SCREENWIDTH, 220)];
    [datePicker setTimeZone:[NSTimeZone timeZoneWithName:@"GMT+8"]];
    // 设置当前显示
    
    // 显示模式
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    [datePicker setBackgroundColor:[UIColor whiteColor]];
    
    
    
    // 回调的方法由于UIDatePicker 是UIControl的子类 ,可以在UIControl类的通知结构中挂接一个委托
    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    [showDateView addSubview:datePicker];
    

   

}

-(void)show2:(double)date{
    
    NSDate *d;
    if(date>0){
        NSDateFormatter *formatterDate  =  [[NSDateFormatter alloc]init];
        [formatterDate setDateFormat:_formatString];
        NSTimeInterval _interval=date;
        d = [NSDate dateWithTimeIntervalSince1970:_interval];
        formatterDate = nil;
        
    }else{
        d  = [NSDate date];
    }

    [self show:d];
    d = nil;
    
}


-(void)show:(NSDate*)date{
    
    if(date!=nil){
        selectedDate = date;
    }
    self.alpha=1;
    [datePicker setDate:selectedDate animated:NO];
    
    [[[UIApplication sharedApplication].delegate window] bringSubviewToFront:self];
    [UIView animateWithDuration:0.3 animations:^{
        
        // 设置view弹出来的位置
        backCoverView.alpha=0.6;
        showDateView.frame = CGRectMake(0, SCREENHEIGHT-showDateView.height, showDateView.width, showDateView.height);
    }];
}


-(void)datePickerValueChanged:(UIDatePicker*)sender
{
    selectedDate = [datePicker date];
}


-(void)chooseDate{
    
    [self hide];    
    self.dateback(selectedDate);

}



-(void)hide{
    
    if(showDateView!=nil){
        [UIView animateWithDuration:0.3 animations:^{
            backCoverView.alpha=0;
            [showDateView setFrame:CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, showDateView.height)];
        } completion:^(BOOL finished){
            self.alpha=0;
        }];
    }
    
}

@end
