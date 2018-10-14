//
//  HandlerTargetAction.h
//  Network_Framework
//
//  Created by min on 2018/10/14.
//  Copyright © 2018 mxm. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HandlerTargetAction : NSObject

@property (nonatomic, weak) id target;

/**
 回调成功action示例：
 - (void)success:(id)data//一般data是由JSON序列化后得到的NSDictionary、NSArray等，或者是-dataHandler:的返回值，callHead方法返回的是NSURLResponse或者其子类
 
 回调失败action示例：
 - (void)failure:(NSError *)error
 
 回调数据处理action示例：
 - (id)dataHandler:(id)data//一般data是由JSON序列化后得到的NSDictionary、NSArray等；返回值是对data的处理，如：data转成Model然后返回
 
 进度action示例：
 - (void)progress:(NSProgress *)progress
 */
@property (nonatomic, assign) SEL action;

+ (instancetype)target:(id)target action:(SEL)action;

@end

NS_INLINE
HandlerTargetAction * CreateHandler(id target, SEL action)
{
    return [HandlerTargetAction target:target action:action];
}

//typedef struct objc_selector *SEL; 这个是SEL的定义
NS_INLINE
void callTargetActionWithData(id target, SEL action, id data)
{
//    if (nil == target || NULL == action) return;
    IMP imp = [target methodForSelector:action];
//    void (*func)(id, SEL, id) = (void *)imp;    //前两个参数是固定的
//    void (*func)(__strong id, SEL, ...) = (void (*)(__strong id, SEL, ...))imp;//网上搜到是这么写的
    void (*func)(__strong id, SEL, ...) = (void (*)(__strong id, SEL, ...))imp;//这么写好点
    if (NULL == func) {
        @throw [NSException exceptionWithName:@"方法调用失败" reason:[NSString stringWithFormat:@"方法\"%@\"不存在", NSStringFromSelector(action)] userInfo:nil];
    }
    func(target, action, data);
    
//上面的方式，应该比下面的方式更快
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Warc-performSelector-leaks" //消除警告
//    [_target performSelector:_action withObject:data];//此方式调用会产生警告
//#pragma clang diagnostic pop
}

NS_INLINE
id callTargetActionWithDataForResult(id target, SEL action, id data)
{
    //    if (nil == target || NULL == action) return nil;
    id (*func)(id, SEL, ...) = (id (*)(id, SEL, ...))[target methodForSelector:action];
    if (NULL == func) {
        @throw [NSException exceptionWithName:@"方法调用失败" reason:[NSString stringWithFormat:@"方法\"%@\"不存在", NSStringFromSelector(action)] userInfo:nil];
    }
    return func(target, action, data);
}

NS_ASSUME_NONNULL_END
