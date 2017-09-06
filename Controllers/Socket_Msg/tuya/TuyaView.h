//
//  TuyaView.h
//  MedicalCenter
//
//  Created by 李狗蛋 on 15-7-16.
//  Copyright (c) 2015年 李狗蛋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface TuyaView : UIView{
    CGFloat w;
    NSString *selectedColor;
    
    NSTimer *timer;
    
    CGFloat wordWidth;
    CGFloat wordHeight;
    
    CGFloat widthBili;
    CGFloat heightBili;
    

    
    NSMutableArray *wordsArray;
    int oneLineWordCount;//一行几个字
    BOOL writeOver;//一个字写完
    int maxWords;
  
}



@property(nonatomic,strong) NSString *colorValue;

@property(nonatomic,strong)UIBezierPath * path;

@property(nonatomic,strong)NSMutableArray * lines;

@property(nonatomic,strong)NSMutableArray * pointsArray;

@property(assign,nonatomic)BOOL isWrite;

-(NSInteger)getTotalLines;

-(void)tapClean;
-(void)last;
-(void)setBold:(CGFloat)ww;

-(void)setColor:(NSString*)colorName;

-(void)closeTimer;
@end
