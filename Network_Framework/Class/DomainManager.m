//
//  DomainManager.m
//  Network_Framework
//
//  Created by mxm on 2018/3/1.
//  Copyright © 2018年 mxm. All rights reserved.
//

#import "DomainManager.h"

static NSString *const Domain1 = @"https://www.baidu.com/";

@implementation DomainManager

+ (NSString *)defaultDomain
{
    return Domain1;
}

+ (void)testTimeForDomain
{
    //可以用ping测试
}

+ (NSString *)fastestDomain
{
    return Domain1;
}

+ (NSString *)absoluteURLStringWithURLString:(NSString *)URLString
{
//    return [Domain1 stringByAppendingString:URLString];
    return URLString;
}

@end
