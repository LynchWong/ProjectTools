//
//  ActivityView.h
//  zpp
//
//  Created by Chuck on 2017/4/27.
//  Copyright © 2017年 myncic.com. All rights reserved. 活动软文
//

#import <UIKit/UIKit.h>

@interface ActivityView : UIView<UIScrollViewDelegate>{
    
    NSInteger clickTime;
    NSMutableArray *activityViewArray;
    UIView *activityMainView;//活动底层
    UIScrollView *activityScrollView;
    UIPageControl *activityPageControl;
    
    NSString *originalUrl;
}


@property(nonatomic,strong) NSMutableArray *activityArray;

- (id)initActivity:(NSString*)url;
//处理数据
-(void)handleActivity:(NSString*)dataString;
//创建活动显示view
-(void)makeActivityView;
//显示活动view
-(void)showNewActivity;
//关闭活动view
-(void)closeNewActivity;
//清理数据
-(void)clearData;
@end


@interface Activity : NSObject//活动
@property (copy, nonatomic) NSString *activity_id;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *icon;
@property (copy, nonatomic) NSString *icon_s;
@property (copy, nonatomic) NSString *activity_description;
@property (copy, nonatomic) NSString *endtime;
@property (copy, nonatomic) NSString *image_size;
@property (assign, nonatomic) NSInteger cost;
@property (assign, nonatomic) NSInteger enable;
@property (assign, nonatomic) BOOL getted;
@end
