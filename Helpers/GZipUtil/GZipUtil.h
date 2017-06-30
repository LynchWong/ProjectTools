//
//  GZipUtil.h
//  Elderly_langlang
//
//  Created by 胡廷廷 on 14-8-29.
//  Copyright (c) 2014年 langlangit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GZipUtil : NSObject

+(NSData*) gzipData:(NSData*)pUncompressedData;  //压缩
+(NSData*) ungzipData:(NSData *)compressedData;  //解压缩
@end
