//
//  ZppTitleView.m
//  zpp
//
//  Created by Chuck on 2017/5/3.
//  Copyright © 2017年 myncic.com. All rights reserved.
//

#import "ZppTitleView.h"
#import "MainViewController.h"
@implementation ZppTitleView
@synthesize titleLabel;

- (id)initWithTitle:(NSString*)titleString{
    self = [super init];
    if (self) {
        title = titleString;
        [self initView];
    }
    return self;
}

-(void)initView{
    
    [self setFrame:CGRectMake(0, 0, SCREENWIDTH, TITLE_HEIGHT)];
    [self setBackgroundColor:TITLECOLOR];
    
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 20, SCREENWIDTH-120, 44)];
    titleLabel.text = title;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont fontWithName:textDefaultBoldFont size:16];
    [self addSubview:titleLabel];
    
    [self addSubview:[APPUtils get_line:0 y:TITLE_HEIGHT-0.5 width:SCREENWIDTH]];
    
    

    UIControl *backControl = [[UIControl alloc] initWithFrame:CGRectMake(0, 20, 50, 44)];
    [backControl setBackgroundColor:[UIColor clearColor]];
    
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (44-18)/2, 18, 18)];
    UIImage *back = [UIImage imageNamed:@"goBack_white.png"];
    [backImageView setImage:back];
    [backImageView setContentMode:UIViewContentModeScaleAspectFill];
    [backControl addTarget:self action:@selector(beback) forControlEvents:UIControlEventTouchUpInside];
    [backControl addSubview:backImageView];
    [self addSubview:backControl];
    backImageView = nil;
}


/**
 *  获取父视图的控制器
 *
 *  @return 父视图的控制器
 */
- (UIViewController *)viewController
{
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}


-(void)beback{
    
    self.goback();
//    [[self viewController].navigationController popViewControllerAnimated:YES];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
