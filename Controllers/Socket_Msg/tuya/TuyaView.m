//
//  TuyaView.m
//  MedicalCenter
//
//  Created by 李狗蛋 on 15-7-16.
//  Copyright (c) 2015年 李狗蛋. All rights reserved.
//

#import "TuyaView.h"
#import "UIColor+additions.h"



@implementation TuyaView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.frame = frame;
    
    if (self) {

        
        
        if(self.lines == nil){
            self.lines = [[NSMutableArray array]init];
        }
        
        if(wordWidth==0){
            wordHeight = frame.size.width/6;
            CGFloat bili = frame.size.height/frame.size.width;
            wordWidth = wordHeight/bili;
            
            widthBili = frame.size.width/wordWidth;
            heightBili = frame.size.height/wordHeight;
            
            oneLineWordCount = frame.size.width/wordWidth;
            
            maxWords = oneLineWordCount * (int)(frame.size.height/wordHeight);
        }
        
     
        if(self.pointsArray == nil){
            self.pointsArray = [[NSMutableArray array]init];
        }

        
        if(wordsArray == nil){
            wordsArray = [[NSMutableArray array]init];
        }
        
        
        
    }
    return self;
}



-(void)last
{
    
    if(self.isWrite){
        if ([wordsArray lastObject])
        {
            
            [wordsArray removeObject:[wordsArray lastObject]];
            [self.lines removeAllObjects];
            
            [self setNeedsDisplay];
        }
    }else{
        if ([self.lines lastObject])
        {
            
            [self.lines removeObject:[self.lines lastObject]];
            
            [self setNeedsDisplay];
        }
    }
    
    
    
}

-(void)setBold:(CGFloat)ww{
    w = ww;
}


-(void)setColor:(NSString*)colorName{
    selectedColor = colorName;
}

-(void)tapClean
{
    
    if(self.isWrite){
        [wordsArray removeAllObjects];
    }
    
    [self.lines removeAllObjects];

    [self setBackgroundColor:[UIColor whiteColor]];
    [self setNeedsDisplay];
}




-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    writeOver = NO;
    
    if(timer != nil){
        [timer invalidate];
        timer = nil;
    }
    
    
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    
    
    TuyaView * l = [[TuyaView alloc]init];
    UIBezierPath * path = [UIBezierPath bezierPath];
    [path setLineWidth:w];
    [path moveToPoint:point];//去设置初始线段的起点
    
    l.path = path;
    l.colorValue = selectedColor;
    [self.lines addObject:l];

    
    if(self.isWrite){
         [l.pointsArray addObject:[NSValue valueWithCGPoint:point]];
    }

}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    TuyaView * l = [self.lines lastObject];
    
    if(self.isWrite){
         [l.pointsArray addObject:[NSValue valueWithCGPoint:point]];
    }
    
    [l.path addLineToPoint:point];//创建一个形状的线段。
    
    [self setNeedsDisplay];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if(self.isWrite){
    
        if(timer != nil){
            [timer invalidate];
            timer = nil;
        }
            
            timer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(putWord) userInfo:nil repeats:NO];
       
    }
    
    
}

- (void)drawRect:(CGRect)rect
{
    if(self.isWrite){
        
            for(int i=0;i<[wordsArray count];i++){
                NSMutableArray *oneWordArray = [wordsArray objectAtIndex:i];
                
                for(int j=0;j<[oneWordArray count];j++){
                    
                    TuyaView * l = [oneWordArray objectAtIndex:j];
                    [[UIColor getColor:l.colorValue] setStroke];
                    [l.path stroke];
                }
                oneWordArray = nil;
            }

            for (TuyaView * l in self.lines)
            {
                [[UIColor getColor:l.colorValue] setStroke];
                [l.path stroke];
            }

    }else{
        for (TuyaView * l in self.lines)
        {
            [[UIColor getColor:l.colorValue] setStroke];
            [l.path stroke];
        }
    }
    
}


-(void)putWord{
    
    
    if(timer != nil){
        [timer invalidate];
        timer = nil;
    }
    
    writeOver = YES;

    
    if([wordsArray count]>=maxWords){
        
        
        [self.lines removeAllObjects];
         [self setNeedsDisplay];
        return;
    }
    
    NSMutableArray *oneWordArray = [[NSMutableArray alloc]initWithArray:self.lines];//装分离的笔画
    
    [self.lines removeAllObjects];
    
    
    for(int j=0;j<[oneWordArray count];j++){
        
        TuyaView * l = [oneWordArray objectAtIndex:j];
        NSMutableArray *pArray = l.pointsArray;
        
        UIBezierPath * path = [UIBezierPath bezierPath];
        [path setLineWidth:w];
        
        for (int i=0;i<[pArray count];i++) {
            
            CGPoint nowPoint = [[pArray objectAtIndex:i] CGPointValue];
            
            CGFloat wordX = 0;
            CGFloat wordY = 0;
            
            
            wordX = nowPoint.x/widthBili+([wordsArray count]-[wordsArray count]/oneLineWordCount*oneLineWordCount)*wordWidth;
            wordY = nowPoint.y/heightBili +[wordsArray count]/oneLineWordCount*wordHeight;
            
            CGPoint wordPoint = CGPointMake(wordX, wordY);
            
            [pArray replaceObjectAtIndex:i withObject: [NSValue valueWithCGPoint:wordPoint]];
            
            if(i==0){
                [path moveToPoint:wordPoint];
            }else{
                [path addLineToPoint:wordPoint];
            }
        }
        
        l.path = path;
        l.pointsArray = pArray;
        
        pArray = nil;
        path = nil;
        
        [oneWordArray replaceObjectAtIndex:j withObject:l];
        l=nil;
    }
    
    [wordsArray addObject:oneWordArray];
    oneWordArray = nil;
    
    [self setNeedsDisplay];
    
}

-(NSInteger)getTotalLines{
    
    
    if([wordsArray count] %oneLineWordCount==0){
        return [wordsArray count]/oneLineWordCount;
    }else{
        return [wordsArray count]/oneLineWordCount+1;
    }
    
    
    
}

-(void)closeTimer{
    
    if(timer != nil){
        [timer invalidate];
        timer = nil;
    }
    
}

@end
