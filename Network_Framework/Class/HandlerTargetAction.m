//
//  HandlerTargetAction.m
//  Network_Framework
//
//  Created by min on 2018/10/14.
//  Copyright © 2018 mxm. All rights reserved.
//

#import "HandlerTargetAction.h"

@implementation HandlerTargetAction

+ (instancetype)target:(id)target action:(SEL)action
{
    HandlerTargetAction *hta = [self new];
    hta.target = target;
    hta.action = action;
    return hta;
}

- (void)dealloc
{
    NSLog(@"HandlerTargetAction -- 释放");
}

@end

HandlerTargetAction * CreateHandler(id target, SEL action)
{
    return [HandlerTargetAction target:target action:action];
}

void callTargetActionWithData(id target, SEL action, id data)
{
    if (nil == target) return;//action不存在时会报错误原因，这里就不判断nil了
    IMP imp = [target methodForSelector:action];
//    void (*func)(id, SEL, id) = (void *)imp;    //前两个参数是固定的
//    void (*func)(__strong id, SEL, ...) = (void (*)(__strong id, SEL, ...))imp;//网上搜到是这么写的
    void (*func)(__strong id, SEL, ...) = (void (*)(__strong id, SEL, ...))imp;//这么写好点
    func(target, action, data);//IMP方式调用时target要判断nil，否则会崩溃，而且不报错误原因，objc_msgSend方式调用时不用判断
    //IMP方式比objc_msgSend所用时间要少
    
    //上面的方式，应该比下面的方式更快
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Warc-performSelector-leaks" //消除警告
//    [_target performSelector:_action withObject:data];//此方式调用会产生警告
//#pragma clang diagnostic pop
}

id callTargetActionWithDataForResult(id target, SEL action, id data)
{
    if (nil == target) return nil;
    id (*func)(id, SEL, ...) = (id (*)(id, SEL, ...))[target methodForSelector:action];
    return func(target, action, data);
}
