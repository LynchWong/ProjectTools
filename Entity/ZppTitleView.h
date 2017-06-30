//
//  ZppTitleView.h
//  zpp
//
//  Created by Chuck on 2017/5/3.
//  Copyright © 2017年 myncic.com. All rights reserved. 标题栏
//

#import <UIKit/UIKit.h>

@interface ZppTitleView : UIView{

    NSString *title;
    BOOL close;
}



- (id)initWithTitle:(NSString*)titleString;//closeOpen 是否需要hasopen关闭
@property(nonatomic,strong)UILabel *titleLabel;

typedef void (^BackBlock)();
@property (nonatomic,strong)BackBlock goback;


@end
