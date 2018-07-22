//
//  APIManager.h
//  Network_Framework
//
//  Created by mxm on 2018/2/27.
//  Copyright © 2018年 mxm. All rights reserved.
//
//  API接口的调用和回调，数据加密、加签，可以自己改造

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ParamsSignatureDelegate

+ (NSDictionary *)signature:(NSMutableDictionary *)params;

@end

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

//GET、HEAD、POST、PUT、PATCH、DELETE
/**
 方法中的URLString不用是完整的URL，内部用到了DomainManager来拼装完整的URL
 */
@interface APIManager : NSObject

/** 参数加签，使用的是类方法 */
@property (nonatomic, assign, class) Class<ParamsSignatureDelegate> delegate;

+ (instancetype)callGet:(NSString *)URLString
                 params:(nullable NSDictionary *)params
            dataHandler:(nullable HandlerTargetAction *)dataHandler
         successHandler:(nullable HandlerTargetAction *)success
         failureHandler:(nullable HandlerTargetAction *)failure
               progress:(nullable void (^)(NSProgress * _Nonnull downloadProgress))downloadProgress;

//做了硬着陆处理，不会因为HandlerTargetAction为nil或其变量为nil引起bug
+ (instancetype)callPost:(NSString *)URLString
                  params:(nullable NSDictionary *)params
             dataHandler:(nullable HandlerTargetAction *)dataHandler
          successHandler:(nullable HandlerTargetAction *)success
          failureHandler:(nullable HandlerTargetAction *)failure
                progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress))uploadProgress;

+ (instancetype)callHead:(NSString *)URLString
                  params:(nullable NSDictionary *)params
          successHandler:(nullable HandlerTargetAction *)success
          failureHandler:(nullable HandlerTargetAction *)failure;

+ (instancetype)callPut:(NSString *)URLString
                  params:(nullable NSDictionary *)params
             dataHandler:(nullable HandlerTargetAction *)dataHandler
          successHandler:(nullable HandlerTargetAction *)success
          failureHandler:(nullable HandlerTargetAction *)failure;


+ (instancetype)callPatch:(NSString *)URLString
                  params:(nullable NSDictionary *)params
             dataHandler:(nullable HandlerTargetAction *)dataHandler
          successHandler:(nullable HandlerTargetAction *)success
          failureHandler:(nullable HandlerTargetAction *)failure;

+ (instancetype)callDelete:(NSString *)URLString
                  params:(nullable NSDictionary *)params
             dataHandler:(nullable HandlerTargetAction *)dataHandler
          successHandler:(nullable HandlerTargetAction *)success
          failureHandler:(nullable HandlerTargetAction *)failure;

/** 取消请求 */
- (void)cancel;

/** 重试 */
- (void)retry;

@end

NS_ASSUME_NONNULL_END
