//
//  DomainManager.h
//  Network_Framework
//
//  Created by mxm on 2018/3/1.
//  Copyright © 2018年 mxm. All rights reserved.
//
//  域名管理工具类，自己改造，APIManager中用到了此类获取完整的URL
//  也可以写自己的DNS解析

#import <Foundation/Foundation.h>

//有些网站会有多个域名，或者不同的环境有不同的域名，所以用一个类来管理
@interface DomainManager : NSObject

/**
 获取默认域名

 @return 域名
 */
+ (NSString *)defaultDomain;

/**
 测试哪个域名的的延迟最少，然后保存最少的
 */
+ (void)testTimeForDomain;

/**
 获取延迟最少的域名

 @return 域名
 */
+ (NSString *)fastestDomain;

//拼装一个完整的URL
+ (NSString *)absoluteURLStringWithURLString:(NSString *)URLString;

@end
