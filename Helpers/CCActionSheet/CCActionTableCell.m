//
//  CCActionTableCell.m
//  CCActionSheet
//
//  Created by maxmoo on 16/3/22.
//  Copyright © 2016年 maxmoo. All rights reserved.
//

#import "CCActionTableCell.h"
#import "MainViewController.h"
@interface CCActionTableCell()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIImageView *iconImageView;

@end

@implementation CCActionTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self initSubViews];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    
    _titleLabel.text = self.textString;
    if(_isCancel){
        [_titleLabel setTextColor:MAINRED];
        _titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
    }
}

- (void)initSubViews{
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, [UIScreen mainScreen].bounds.size.width -30,self.bounds.size.height )];
    _titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_titleLabel setTextColor:[UIColor getColor:@"64676E"]];
    [self.contentView addSubview:_titleLabel];
    
    
}

@end
