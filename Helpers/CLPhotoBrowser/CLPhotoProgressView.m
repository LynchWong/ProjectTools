//
//  CLPhotoProgressView.m
//  李码哥Demo
//
//  Created by chengzi on 16/3/31.
//  Copyright © 2016年 ufutx. All rights reserved.
//

#import "CLPhotoProgressView.h"
@interface CLPhotoProgressView()
@property(nonatomic,strong)UILabel *pct;
@property(nonatomic,strong)UIImageView *animation;
@end
@implementation CLPhotoProgressView

- (void)dealloc
{
    [_animation.layer removeAnimationForKey:@"rotationAnimation"];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6]];
        self.layer.cornerRadius = 4;
        _animation = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        _animation.center = self.center;
        [_animation setImage:[UIImage imageNamed:@"dialog_load.png"]];
        [self addSubview:_animation];
        
        _pct = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80,80)];
        [_pct setTextAlignment:NSTextAlignmentCenter];
        [_pct setTextColor:[UIColor whiteColor]];
        [_pct setFont:[UIFont fontWithName:@"HelveticaNeue" size: 12]];
        [_pct setCenter:self.center];
        [self addSubview:_pct];
        
        [self startAnimating];
    }
    return self;
}

-(void)startAnimating
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 1.3;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = MAXFLOAT;
    [_animation.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)setProgress:(CGFloat)progress 
{
    dispatch_async(dispatch_get_main_queue(), ^{
        int num = floorf(progress*100);
        NSString *text = [NSString stringWithFormat:@"%d%%",num];
        text = [text stringByReplacingOccurrencesOfString:@"-" withString:@""];
        [_pct setText:text];
        if (num == 100) {
            self.hidden = YES;
        }else{
            self.hidden = NO;
        }

    });
    
  
}


@end
