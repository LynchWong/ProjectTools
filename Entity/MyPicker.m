//
//  MyPicker.m
//  paopao
//
//  Created by Chuck on 2017/7/20.
//  Copyright © 2017年 myncic.com. All rights reserved.
//

#import "MyPicker.h"
#import "MainViewController.h"
@implementation MyPicker

- (id)initWithArr:(NSArray*)pArray index:(NSInteger)index{
    self = [super init];
    if (self) {
        [[[UIApplication sharedApplication].delegate window] addSubview:self];
        [self setFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        self.alpha=0;
        
        default_index = index;
        picker_arr = pArray;
    }
    return self;
}


-(void)resetPicker:(NSArray*)pArray index:(NSInteger)index{

    default_index = index;
    picker_arr = pArray;
    
}


-(void)showPicker:(NSInteger)index{
 
    default_index = index;
    [self showPicker];
}

-(void)showPicker{

    if(picker_View == nil){
        
        if(backCoverView == nil){
            backCoverView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
            [backCoverView setBackgroundColor:[UIColor blackColor]];
            backCoverView.alpha = 0.6;
            [backCoverView addTarget:self action:@selector(closePicker) forControlEvents:UIControlEventTouchDown];
            [self addSubview:backCoverView];
            
        };
        
        picker_View = [[UIView alloc]initWithFrame:CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, 200)];
        [picker_View setBackgroundColor:[UIColor getColor:@"fdfdfd"]];
        [self addSubview:picker_View];
        
        
        
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 40)];
        [picker_View addSubview:titleView];
        
        UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 3)];
        [topView setBackgroundColor:MAINCOLOR];
        [titleView addSubview:topView];
        topView = nil;
        
        UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, titleView.height/2-15, 80, 30)];
        [cancelBtn setTitle:@"取消      " forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize: 14.0];
        
        [cancelBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [cancelBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [titleView addSubview:cancelBtn];
        
        [cancelBtn addTarget:self action:@selector(closePicker) forControlEvents:UIControlEventTouchUpInside];
        cancelBtn = nil;
        
        UIButton *okBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH-80, titleView.height/2-15, 80, 30)];
        [okBtn setTitle:@"      确定" forState:UIControlStateNormal];
        okBtn.titleLabel.font = [UIFont systemFontOfSize: 14.0];
        
        [okBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [okBtn setTitleColor:MAINCOLOR forState:UIControlStateNormal];
        [titleView addSubview:okBtn];
        
        [okBtn addTarget:self action:@selector(selectPicker) forControlEvents:UIControlEventTouchUpInside];
        okBtn = nil;
        
        
        
        picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, titleView.height+10, SCREENWIDTH, picker_View.height-30-titleView.height)];
        picker.delegate = self;
        picker.dataSource = self;
        picker.showsSelectionIndicator = YES;
        [picker_View addSubview:picker];
        
        
    }
    
    
    [picker reloadAllComponents];
    [picker selectRow:default_index inComponent:0 animated:NO];
    

    [self bringSubviewToFront:backCoverView];
    [self bringSubviewToFront:picker_View];
    
    
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha=1;
        picker_View.y =SCREENHEIGHT-200;
    }];

}


-(void)closePicker{

    [UIView animateWithDuration:0.2 animations:^{
        self.alpha=0;
        picker_View.y =SCREENHEIGHT;
    }];
    
}

-(void)selectPicker{
    [self closePicker];
    self.callBackBlock(select_index);
    
}

//列数
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
    
//每列几行
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    return [picker_arr count];
}
    
-(NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    return [picker_arr objectAtIndex:row];
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    select_index = row;
    
}


//picker行高
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 35;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        // Setup label properties - frame, font, colors etc
        //adjustsFontSizeToFitWidth property to YES
        
        
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont systemFontOfSize:18]];
    }
    // Fill the label text here
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
