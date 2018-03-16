//
//  APIManager.h
//  Network_Framework
//
//  Created by noontec on 2018/2/27.
//  Copyright © 2018年 mxm. All rights reserved.
//
//  接口的调用和回调，数据加密

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ParamsSignatureDelegate

+ (NSDictionary *)signature:(NSMutableDictionary *)params;

@end

@interface HandlerTargetAction : NSObject

@property (nonatomic, weak) id target;

/**
 回调成功action示例：
 - (void)success:(id)data
 
 回调失败action示例：
 - (void)failure:(NSError *)error
 
 回调数据处理action示例：
 - (id)dataHandler:(id)data//一般data是NSDictionary、NSArray, 返回值id可能是Model
 
 进度action示例：
 - (void)progress:(NSProgress *)progress
 */
@property (nonatomic, assign) SEL action;

+ (instancetype)target:(id)target action:(SEL)action;

@end

@interface APIManager : NSObject

/** 参数加签，使用的是类方法 */
@property (nonatomic, assign, class) Class<ParamsSignatureDelegate> delegate;

+ (instancetype)callGet:(NSString *)URLString
                 params:(nullable NSDictionary *)params
               progress:(nullable void (^)(NSProgress * _Nonnull downloadProgress))downloadProgress
         successHandler:(nullable HandlerTargetAction *)success
         failureHandler:(nullable HandlerTargetAction *)failure;

//做了硬着陆处理，不会因为HandlerTargetAction为nil或其变量为nil引起bug
+ (instancetype)callPost:(NSString *)URLString
                  params:(nullable NSDictionary *)params
                progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress))uploadProgress
          successHandler:(nullable HandlerTargetAction *)success
          failureHandler:(nullable HandlerTargetAction *)failure;

+ (instancetype)callPost:(NSString *)URLString
                  params:(nullable NSDictionary *)params
             dataHandler:(nullable HandlerTargetAction *)dataHandler
          successHandler:(nullable HandlerTargetAction *)success
          failureHandler:(nullable HandlerTargetAction *)failure
                progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress))uploadProgress;

/** 取消请求 */
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
