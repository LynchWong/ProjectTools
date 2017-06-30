//
//  PassValueDelegate.h
//  PassValueByDelegate
//
//  Created by 李狗蛋 on 15-1-23.
//

#import <Foundation/Foundation.h>


@protocol PassValueDelegate <NSObject>

-(void)passValue:(NSObject *)value;

@end
