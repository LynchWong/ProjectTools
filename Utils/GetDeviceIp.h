//
//  GetDeviceIp.h
//  zpp
//
//  Created by Chuck on 2017/8/3.
//  Copyright © 2017年 myncic.com. All rights reserved. 获得ip地址
//

#import <Foundation/Foundation.h>

#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

@interface GetDeviceIp : NSObject


//公网ip
+ (NSString *)getPubIPAddress;
//获取设备当前网络IP地址
+ (NSString *)getIPAddress:(BOOL)preferIPv4;
//获取所有相关IP信息
+ (NSDictionary *)getIPAddresses;

@end
