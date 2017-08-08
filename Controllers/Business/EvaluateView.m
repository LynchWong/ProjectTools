//
//  AddTips.m
//  zpp
//
//  Created by Chuck on 16/7/5.
//  Copyright © 2016年 myncic.com. All rights reserved.
//

#import "EvaluateView.h"
#import "MainViewController.h"
#import "ToastView.h"
@implementation EvaluateView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */


- (id)initWithOrder:(NSString*)orderId{
    self = [super init];
    if (self) {
        [self setOrderId:orderId];
        [self initData];
        
    }
    return self;
}


-(void)initData{
    evaString = @"";
    goodrate = 0;
    [[UITextField appearance] setTintColor:MAINCOLOR];
    
    
}

-(void)setOrderId:(NSString*)orderId{
    _checkOrderId = orderId;
    defaultString = @"(点击写评价)";
    evaString = @"";
    evaLabel.text = defaultString;
    goodrate = 5;
    [starView setImage:[UIImage imageNamed:@"eva_star_click5.png"]];
    [evaLabel setTextColor:[UIColor lightGrayColor]];
}


-(void)init_views{
    
    self.alpha=0;
    if(blackCoverView == nil){
        blackCoverView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        [blackCoverView setBackgroundColor:[UIColor blackColor]];
        blackCoverView.alpha=0;
        [self addSubview:blackCoverView];
        
        [blackCoverView addTarget:self action:@selector(closePage) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    if(evaluate_view == nil){
        
        evaluate_view = [[UIView alloc] init];
        [evaluate_view setBackgroundColor:[UIColor whiteColor]];
        [evaluate_view setFrame:CGRectMake((SCREENWIDTH-SCREENWIDTH*0.8)/2, (SCREENHEIGHT-265)/2, SCREENWIDTH*0.8, 255)];
        [evaluate_view.layer setCornerRadius:7];
        [evaluate_view.layer setMasksToBounds:YES];//圆角不被盖住
        [evaluate_view setClipsToBounds:YES];//减掉超出部分
        evaluate_view.alpha=0;
        [self addSubview:evaluate_view];
        
        UILabel *evaluate_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, evaluate_view.width, 50)];
        evaluate_titleLabel.text = @"评价";
        evaluate_titleLabel.textAlignment = NSTextAlignmentCenter;
        evaluate_titleLabel.textColor = TEXTGRAY;
        evaluate_titleLabel.font = [UIFont fontWithName:textDefaultBoldFont size:16];
        [evaluate_view addSubview:evaluate_titleLabel];
        evaluate_titleLabel = nil;
        
        UIImageView *brokenLine1 = [[UIImageView alloc]initWithFrame:CGRectMake(5, 40, evaluate_view.width-10, 10)];
        
        UIGraphicsBeginImageContext(brokenLine1.frame.size);   //开始画线
        [brokenLine1.image drawInRect:CGRectMake(0, 0, brokenLine1.width, brokenLine1.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);  //设置线条终点形状
        
        CGFloat lengths[] = {4,2}; //虚实线长度
        CGContextRef line = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(line, LINECOLOR2.CGColor);
        
        CGContextSetLineDash(line, 0, lengths, 2);  //画虚线
        CGContextMoveToPoint(line, 0.0, 10);    //开始画线
        CGContextAddLineToPoint(line, SCREENWIDTH, 10);
        CGContextStrokePath(line);
        brokenLine1.image = UIGraphicsGetImageFromCurrentImageContext();
        [evaluate_view addSubview:brokenLine1];
        
        
        evaView = [[UIView alloc] initWithFrame:CGRectMake(0, brokenLine1.y+15, evaluate_view.width, 60)];
        [evaluate_view addSubview:evaView];
        
        
        
        starView = [[UIImageView alloc] initWithFrame:CGRectMake((evaluate_view.width-evaluate_view.width*0.55)/2, 10, evaluate_view.width*0.55, evaluate_view.width*0.55*0.154)];
        [starView setImage:[UIImage imageNamed:@"eva_star_click0.png"]];
        [evaView addSubview:starView];
        
        
        //
        
        MyBtnControl *evaControl1 = [[MyBtnControl alloc] initWithFrame:CGRectMake(0, 0, evaView.width*0.21, evaView.height)];
        [evaView addSubview:evaControl1];
        //        [evaControl1 setBackgroundColor:MAINCOLOR];
        //        evaControl1.alpha=0.2;
        evaControl1.clickBackBlock = ^(){
            [self setStar:0];
        };
        
        
        MyBtnControl *evaControl2 = [[MyBtnControl alloc] initWithFrame:CGRectMake(evaControl1.width, 0, evaView.width*0.12, evaView.height)];
        [evaView addSubview:evaControl2];
        //        [evaControl2 setBackgroundColor:MAINRED];
        //        evaControl2.alpha=0.2;
        evaControl2.clickBackBlock = ^(){
            [self setStar:1];
        };
        
        MyBtnControl *evaControl3 = [[MyBtnControl alloc] initWithFrame:CGRectMake(evaControl2.width+evaControl2.x, 0, evaView.width*0.11, evaView.height)];
        [evaView addSubview:evaControl3];
        //        [evaControl3 setBackgroundColor:[UIColor greenColor]];
        //        evaControl3.alpha=0.2;
        evaControl3.clickBackBlock = ^(){
            [self setStar:2];
        };
        
        MyBtnControl *evaControl4 = [[MyBtnControl alloc] initWithFrame:CGRectMake(evaControl3.width+evaControl3.x, 0, evaView.width*0.12, evaView.height)];
        [evaView addSubview:evaControl4];
        //        [evaControl4 setBackgroundColor:[UIColor blueColor]];
        //        evaControl4.alpha=0.2;
        evaControl4.clickBackBlock = ^(){
            [self setStar:3];
        };
        
        MyBtnControl *evaControl5 = [[MyBtnControl alloc] initWithFrame:CGRectMake(evaControl4.width+evaControl4.x, 0, evaView.width*0.11, evaView.height)];
        [evaView addSubview:evaControl5];
        //        [evaControl5 setBackgroundColor:[UIColor blackColor]];
        //        evaControl5.alpha=0.2;
        evaControl5.clickBackBlock = ^(){
            [self setStar:4];
        };
        
        MyBtnControl *evaControl6 = [[MyBtnControl alloc] initWithFrame:CGRectMake(evaControl5.width+evaControl5.x, 0, evaView.width*0.2, evaView.height)];
        [evaView addSubview:evaControl6];
        //        [evaControl6 setBackgroundColor:[UIColor orangeColor]];
        //        evaControl6.alpha=0.2;
        evaControl6.clickBackBlock = ^(){
            [self setStar:5];
        };
        
        
        
        evaControl1 = nil;
        evaControl2 = nil;
        evaControl3 = nil;
        evaControl4 = nil;
        evaControl5 = nil;
        evaControl6 = nil;
        
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, evaView.height+evaView.y, evaluate_view.width, 80)];
        [evaluate_view addSubview:contentView];
        
        evaLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, contentView.width-30, contentView.height)];
        evaLabel.text = defaultString;
        evaLabel.textAlignment = NSTextAlignmentCenter;
        evaLabel.textColor = [UIColor lightGrayColor];
        evaLabel.font = [UIFont fontWithName:textDefaultFont size:13];
        evaLabel.numberOfLines = 0;
        [contentView addSubview:evaLabel];
        
        MyBtnControl *eva_contentControl = [[MyBtnControl alloc] initWithFrame:CGRectMake(0, 0, contentView.width, contentView.height)];
        [contentView addSubview:eva_contentControl];
        eva_contentControl.shareLabel = evaLabel;
        eva_contentControl.clickBackBlock = ^(){
      
            [setText show:@""];
        };
        eva_contentControl = nil;
        
        
        
        
        UIView *line1 = [APPUtils get_line: 0 y:contentView.height+contentView.y+15 width:contentView.width];
        [evaluate_view addSubview:line1];
        
        
        [evaluate_view addSubview:[APPUtils get_line2:CGRectMake(evaluate_view.width/2, contentView.height+contentView.y+15, 0.5, evaluate_view.height-(line1.y+0.5))]];
        
        
        MyBtnControl *cancelControl = [[MyBtnControl alloc] initWithFrame:CGRectMake(0, line1.y+0.5, evaluate_view.width/2, evaluate_view.height-(line1.y+0.5))];
        [evaluate_view addSubview:cancelControl];
        cancelControl.clickBackBlock = ^(){
            [self closePage];
        };
        
        
        [cancelControl addLabel:@"取消" color:[UIColor lightGrayColor] font:[UIFont fontWithName:textDefaultFont size:14]];
        
        
        
        
        MyBtnControl *evaControl = [[MyBtnControl alloc] initWithFrame:CGRectMake(evaluate_view.width/2, line1.y+0.5, evaluate_view.width/2, evaluate_view.height-(line1.y+0.5))];
        
        evaControl.clickBackBlock = ^(){
            [UIView animateWithDuration:0.1f
                                  delay:0
                                options:(UIViewAnimationOptionAllowUserInteraction|
                                         UIViewAnimationOptionBeginFromCurrentState)
                             animations:^(void) {
                                 
                                 self.alpha=0;
                                 
                                 
                                 evaLabel.text = defaultString;
                                 [evaLabel setTextColor:[UIColor lightGrayColor]];
                             }
                             completion:^(BOOL finished) {
                                 
                                 if(goodrate==0){
                                     goodrate = 5;
                                 }
                                 AFN_util *afn = [[AFN_util alloc] initWithAfnTag:@"eva_order"];
                                 
                                 afn.afnResult = ^(NSString *afn_tag,NSString*resultString){
                                     if([afn_tag isEqualToString:@"eva_order"]){
                                         self.callBackBlock(YES);
                                     }else{
                                         self.callBackBlock(NO);
                                     }
                                 };
                                 [afn eva_order:_checkOrderId goodrate:goodrate evaString:evaString];
                                 afn = nil;
                                 
                                 
                                 evaString = @"";
                             }];
        };
        
        [evaControl addLabel:@"发表评价" color:TEXTGRAY font:[UIFont fontWithName:textDefaultBoldFont size:14]];
        
        
        [evaluate_view addSubview:evaControl];
        evaControl = nil;
        line1 = nil;
        
        
        
        __weak typeof(self) weakSelf = self;
        setText = [[SetTextview alloc] initWithTitle:@"填写评价"];
        [setText setMaxLength:300];
        setText.setback = ^(NSString *titleString,NSString *contentString){
            [weakSelf saveReason:contentString];
        };
        
        
    }
    
    //默认5星
    goodrate = 5;
    [starView setImage:[UIImage imageNamed:@"eva_star_click5.png"]];
    
    
    [UIView animateWithDuration:0.2f
                          delay:0
                        options:(UIViewAnimationOptionAllowUserInteraction|
                                 UIViewAnimationOptionBeginFromCurrentState)
                     animations:^(void) {
                         
                         evaluate_view.alpha=1;
                         blackCoverView.alpha=0.6;
                         
                     }
                     completion:NULL];
    
}


//设置星星
-(void)setStar:(NSInteger)index{
    
    goodrate = index;
    [starView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"eva_star_click%d.png",(int)index]]];
    
}


-(void)closePage{
    [UIView animateWithDuration:0.2f
                          delay:0
                        options:(UIViewAnimationOptionAllowUserInteraction|
                                 UIViewAnimationOptionBeginFromCurrentState)
                     animations:^(void) {
                         
                         self.alpha=0;
                         
                     }
                     completion:NULL];
}

-(void)saveReason:(NSString*)eString{
    evaString = eString;
    evaLabel.text = [NSString stringWithFormat:@"评价:%@",evaString];
    [evaLabel setTextColor:TEXTGRAY];
}




@end
