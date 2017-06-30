

#import "UIColor+additions.h"

static NSMutableArray * colorArray;



@implementation UIColor (additions)

+ (UIColor *)randomColor
{
    
    if(colorArray == nil){
        [self addColor];
    }
//    CGFloat hue = (arc4random() % 256 / 256.0);
//    CGFloat saturation = (arc4random() % 128 / 256.0) + 0.5;
//    CGFloat brightness = (arc4random() % 128 / 256.0) + 0.5;
//    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.9];
    int r = arc4random() % arc4random() % ([colorArray count]);
    return [colorArray objectAtIndex:r];
}

+(void) addColor{
    colorArray = [[NSMutableArray alloc]init];
    UIColor *color1 = [self getColor:@"FF0097"];//red
    [colorArray addObject:color1];
    UIColor *color2 = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];//blue
    [colorArray addObject:color2];

//    UIColor *color4 = [self getColor:@"5cb85c"];//green
//    [colorArray addObject:color4];
    UIColor *color5 = [self getColor:@"d9534f"];//dark red
    [colorArray addObject:color5];
    UIColor *color6 = [self getColor:@"567e95"];//blue grey
    [colorArray addObject:color6];
    UIColor *color7 = [self getColor:@"b433ff"];//purple
    [colorArray addObject:color7];

//    UIColor *color9 = [self getColor:@"e51400"];//real red
//    [colorArray addObject:color9];
    UIColor *color10 = [self getColor:@"8cbf26"];//grass green
    [colorArray addObject:color10];
    UIColor *color11 = [self getColor:@"4a4a4a"]; //dark grey
    [colorArray addObject:color11];
    UIColor *color12 = [self getColor:@"5859b9"]; //dark purple
    [colorArray addObject:color12];
   
}

+ (UIColor *)getColor:(NSString*)hexColor
{
    unsigned int red,green,blue;
    NSRange range;
    range.length = 2;
    
    range.location = 0;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]]scanHexInt:&red];
    
    range.location = 2;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]]scanHexInt:&green];
    
    range.location = 4;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]]scanHexInt:&blue];
    
    return [UIColor colorWithRed:(float)(red/255.0f)green:(float)(green / 255.0f) blue:(float)(blue / 255.0f)alpha:1.0f];
}

+(CGFloat)getFontSize:(CGFloat)pxSize{
    if(pxSize <= 6){
        return 5;
    }else if(pxSize >6 && pxSize <=7){
         return 5.5;
    }else if(pxSize >7 && pxSize <=8){
        return 6.5;
    }else if(pxSize >8 && pxSize <=10){
        return 7.5;
    }else if(pxSize >10 && pxSize <=12){
        return 9;
    }else if(pxSize >12 && pxSize <=14){
        return 10.5;
    }else if(pxSize >14 && pxSize <=16){
        return 12;
    }else if(pxSize >16 && pxSize <=18){
        return 14;
    }else if(pxSize >18 && pxSize <=20){
        return 15;
    }else if(pxSize >20 && pxSize <=21){
        return 16;
    }else if(pxSize >21 && pxSize <=24){
        return 18;
    }else if(pxSize >24 && pxSize <=29){
        return 22;
    }else if(pxSize >24 && pxSize <=29){
        return 22;
    }else if(pxSize >29 && pxSize <=32){
        return 24;
    }else if(pxSize >32 && pxSize <=34){
        return 26;
    }else if(pxSize >34 && pxSize <=48){
        return 36;
    }else if(pxSize >48 && pxSize <=56){
        return 42;
    }else{
        return -1;
    }

}


@end
