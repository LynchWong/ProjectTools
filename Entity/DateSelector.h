//
//  DateSelector.h
//  wuneng
//
//  Created by Chuck on 2017/6/13.
//  Copyright © 2017年 myncic.com. All rights reserved. 日期选择器
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface DateSelector : UIView{
    NSString *title;
    UIControl *backCoverView;
    
    
    UIView *showDateView;
    NSDate *selectedDate;
    

}

- (id)initWithTitle:(NSString*)titleString;

-(void)show:(NSDate*)date;
-(void)show2:(double)date;
-(void)hide;


typedef void (^DateBlock)(NSDate *date);
@property (nonatomic,strong)DateBlock dateback;


@property (nonatomic,strong)NSString *formatString;
@property (nonatomic,strong) UIDatePicker *datePicker;

@end
