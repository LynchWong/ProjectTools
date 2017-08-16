//
//  AboutUsViewController.h
//  zpp
//
//  Created by Chuck on 16/7/14.
//  Copyright © 2016年 myncic.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AboutUsViewController : UIViewController{
    
    UIScrollView *bodyView;
    UIImage *icon;
    NSString *showYear;
}

- (id)initWithIcon:(UIImage*)img year:(NSString*)year;

@end
