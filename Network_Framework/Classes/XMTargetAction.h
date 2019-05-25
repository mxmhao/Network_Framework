//
//  HandlerTargetAction.h
//  Network_Framework
//
//  Created by min on 2018/10/14.
//  Copyright © 2018 mxm. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XMTargetAction : NSObject

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

- (instancetype)initWithTarget:(id)target action:(SEL)action;

@end

FOUNDATION_EXTERN_INLINE
XMTargetAction * XMCreateTA(id target, SEL action);

//typedef struct objc_selector *SEL; 这个是SEL的定义
FOUNDATION_EXTERN_INLINE
void msgSendTargetActionWithData(id target, SEL action, id data);

FOUNDATION_EXTERN_INLINE
id msgSendTargetActionWithDataForResult(id target, SEL action, id data);

NS_ASSUME_NONNULL_END
