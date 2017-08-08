//
//  MyPicker.h
//  paopao
//
//  Created by Chuck on 2017/7/20.
//  Copyright © 2017年 myncic.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyPicker : UIView<UIPickerViewDataSource,UIPickerViewDelegate>{

    NSInteger default_index;
    
    UIView *picker_View;
    UIControl *backCoverView;
    UIPickerView *picker;
    NSArray *picker_arr;
    NSInteger select_index;//选中
    UILabel *nearLabel;
    
}


- (id)initWithArr:(NSArray*)pArray index:(NSInteger)index;

-(void)resetPicker:(NSArray*)pArray index:(NSInteger)index;
-(void)showPicker;
-(void)showPicker:(NSInteger)index;


typedef void (^PickerBlock)(NSInteger select);
@property (nonatomic,strong)PickerBlock callBackBlock;


@end
