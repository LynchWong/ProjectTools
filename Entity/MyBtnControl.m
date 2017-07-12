//
//  MyBtnControl.m
//  zpp
//
//  Created by Chuck on 2017/5/2.
//  Copyright © 2017年 myncic.com. All rights reserved.
//

#import "MyBtnControl.h"
#import "APPUtils.h"
@implementation MyBtnControl



-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        btnControl = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:btnControl];
        
        [btnControl addTarget:self action:@selector(btn_down) forControlEvents:UIControlEventTouchDown];
        [btnControl addTarget:self action:@selector(btn_up) forControlEvents:UIControlEventTouchUpInside];
        [btnControl addTarget:self action:@selector(restore) forControlEvents:UIControlEventTouchUpOutside];
        [btnControl addTarget:self action:@selector(restore) forControlEvents:UIControlEventTouchCancel];
    }
    return self;
}


- (void)setFrame:(CGRect)frame{

    [super setFrame:frame];
    
    if(btnControl==nil){
        btnControl = [[UIControl alloc] init];
    }
    [btnControl setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
}

//允许点击
-(void)setEnabled:(BOOL)enable{
    [btnControl setEnabled:enable];
}

-(void)setShareLabel:(UILabel *)label{
    _shareLabel = label;
    [self bringSubviewToFront:btnControl];
}
-(void)setShareImage:(UIImageView *)image{
    _shareImage= image;
    [self bringSubviewToFront:btnControl];
}

-(void)btn_down{
    @try {
        if(_back_highlight){
            self.superview.alpha=0.7;
        }
        
        if(_functype){
            shareImg_originalFrame = self.shareImage.frame;
            
            [UIView animateWithDuration:0.2f delay:0
                                options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState)animations:^(void) {
                                    [self.shareImage setFrame: _shareImg_clickFrame];
                                }completion:NULL];
        }else{
        
            if(!_not_ShareHighlight){
                self.shareImage.alpha=0.7;
                self.shareLabel.alpha=0.7;
                self.shareView.alpha=0.7;
            }
           
            
        }
        
    } @catch (NSException *exception) {
        
    }
    
    if(!_not_highlight){
        self.alpha=0.7;
    }
   
}
-(void)btn_up{
    [self performSelector:@selector(btn_action) withObject:nil afterDelay:0.1];
}
-(void)btn_action{
    [self restore];
   
    

    NSInteger timeString = [[APPUtils GetCurrentTimeString] integerValue];
    if(timeString-clicktime<1){
        return;
    }
    
    clicktime = timeString;
    
    if(!_no_single_click){
        self.clickBackBlock();
    }
   
}

//添加文字
-(void)addLabel:(NSString*)text color:(UIColor*)color font:(UIFont*)font{

    UILabel *lLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    lLabel.textColor = color;
    lLabel.textAlignment = NSTextAlignmentCenter;
    lLabel.font = font;
    lLabel.text = text;
    [self addSubview:lLabel];
    self.shareLabel = lLabel;
    [self bringSubviewToFront:btnControl];
    lLabel = nil;

}

//添加文字
-(void)addLabel:(NSString*)text color:(UIColor*)color font:(UIFont*)font txtAlignment:(NSInteger)txtAlignment x:(float)x{
    
    UILabel *lLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, self.width, self.height)];
    lLabel.textColor = color;
    lLabel.textAlignment = txtAlignment;
    lLabel.font = font;
    lLabel.text = text;
    [self addSubview:lLabel];
    self.shareLabel = lLabel;
    [self bringSubviewToFront:btnControl];
    lLabel = nil;
    
}

-(void)addLabel:(NSString*)text color:(UIColor*)color font:(UIFont*)font txtAlignment:(NSInteger)txtAlignment frame:(CGRect)frame{
    UILabel *lLabel = [[UILabel alloc] initWithFrame:frame];
    lLabel.textColor = color;
    lLabel.textAlignment = txtAlignment;
    lLabel.font = font;
    lLabel.text = text;
    [self addSubview:lLabel];
    self.shareLabel = lLabel;
    [self bringSubviewToFront:btnControl];
    lLabel = nil;
}


//添加图片
-(void)addImage:(UIImage*)img frame:(CGRect)frame{

    UIImageView *addImg = [[UIImageView alloc] initWithFrame:frame];
    [addImg setImage:img];
    [self addSubview:addImg];
    self.shareImage=addImg;
    self.shareImage.layer.shouldRasterize = YES;
    self.shareImage.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    [self bringSubviewToFront:btnControl];
    addImg = nil;
    
}

-(void)addImage2:(UIImage*)img frame:(CGRect)frame{

    UIImageView *addImg = [[UIImageView alloc] initWithFrame:frame];
    [addImg setImage:img];
    [self addSubview:addImg];
    self.shareImage2=addImg;
    self.shareImage2.layer.shouldRasterize = YES;
    self.shareImage2.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    [self bringSubviewToFront:btnControl];
    addImg = nil;
}

-(void)addImage:(UIImage*)img{
    UIImageView *addImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    [addImg setImage:img];
    [self addSubview:addImg];
    self.shareImage=addImg;
    self.shareImage.layer.shouldRasterize = YES;
    self.shareImage.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    [self bringSubviewToFront:btnControl];
    addImg = nil;
}


-(void)addImage:(UIImage*)img frame:(CGRect)frame url:(NSString*)url{
    UIImageView *addImg = [[UIImageView alloc] initWithFrame:frame];
    [addImg sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:img];
    [self addSubview:addImg];
    self.shareImage=addImg;
    self.shareImage.layer.shouldRasterize = YES;
    self.shareImage.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    [self bringSubviewToFront:btnControl];
    addImg = nil;
}



//添加长按效果
-(void)addLongclick{

    UILongPressGestureRecognizer *positionLongTap =[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longtap:)];
    [btnControl addGestureRecognizer:positionLongTap];
    positionLongTap = nil;
    
}


- (void)longtap:(UILongPressGestureRecognizer *)recognizer{
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.alpha=0.7;
        
        self.longClickBackBlock();
        
    }else if(recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled){
      
        self.alpha=1;
    }
}


-(void)restore{
    @try {
        if(_back_highlight){
            self.superview.alpha=1;
        }
        
        if(_functype){
        
            [UIView animateWithDuration:0.2f delay:0
                                options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState)animations:^(void) {
                                    [self.shareImage setFrame: shareImg_originalFrame];
                                }completion:NULL];
        }
        
        self.shareImage.alpha=1;
        self.shareLabel.alpha=1;
        self.shareView.alpha=1;
    } @catch (NSException *exception) {
        
    }
    
    if(!_not_highlight){
        self.alpha=1;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
