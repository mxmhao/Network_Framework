//
//  AFHTTPSessionManager+TargetAction.h
//  Network_Framework
//
//  Created by mxm on 2018/3/1.
//  Copyright © 2018年 mxm. All rights reserved.
//
//  AFN简化分类

#import <AFNetworking/AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN

@class HandlerTargetAction;

typedef void(^XM_AFCompletionHandler)(NSURLResponse *response, id _Nullable responseObject, NSError * _Nullable error);

@interface AFHTTPSessionManager (CompletionHandler)

+ (instancetype)shareManager;

//当block的代码有很多行时，请使用以下方法
//做了硬着陆处理，不会因为HandlerTargetAction为nil或其变量为nil引起bug
- (nullable NSURLSessionDataTask *)callGet:(NSString *)URLString
                 params:(nullable NSDictionary *)params
            dataHandler:(nullable HandlerTargetAction *)dataHandler
         successHandler:(nullable HandlerTargetAction *)success
         failureHandler:(nullable HandlerTargetAction *)failure
               progress:(nullable void (^)(NSProgress * _Nonnull downloadProgress))downloadProgress;

- (nullable NSURLSessionDataTask *)callPost:(NSString *)URLString
                  params:(nullable NSDictionary *)params
             dataHandler:(nullable HandlerTargetAction *)dataHandler
          successHandler:(nullable HandlerTargetAction *)success
          failureHandler:(nullable HandlerTargetAction *)failure
                progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress))uploadProgress;

- (nullable NSURLSessionDataTask *)callHead:(NSString *)URLString
                  params:(nullable NSDictionary *)params
          successHandler:(nullable HandlerTargetAction *)success
          failureHandler:(nullable HandlerTargetAction *)failure;

- (nullable NSURLSessionDataTask *)callPut:(NSString *)URLString
                 params:(nullable NSDictionary *)params
            dataHandler:(nullable HandlerTargetAction *)dataHandler
         successHandler:(nullable HandlerTargetAction *)success
         failureHandler:(nullable HandlerTargetAction *)failure;

- (nullable NSURLSessionDataTask *)callPatch:(NSString *)URLString
                   params:(nullable NSDictionary *)params
              dataHandler:(nullable HandlerTargetAction *)dataHandler
           successHandler:(nullable HandlerTargetAction *)success
           failureHandler:(nullable HandlerTargetAction *)failure;

- (nullable NSURLSessionDataTask *)callDelete:(NSString *)URLString
                    params:(nullable NSDictionary *)params
               dataHandler:(nullable HandlerTargetAction *)dataHandler
            successHandler:(nullable HandlerTargetAction *)success
            failureHandler:(nullable HandlerTargetAction *)failure;


//get和post有进度，其他的没有
- (nullable NSURLSessionDataTask *)GET:(NSString *)URLString
                            parameters:(nullable id)parameters
                              progress:(nullable void (^)(NSProgress *_Nonnull downloadProgress))downloadProgress
                     completionHandler:(nullable XM_AFCompletionHandler)completionHandler;


- (nullable NSURLSessionDataTask *)POST:(NSString *)URLString
                             parameters:(nullable id)parameters
                               progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress))uploadProgress
                      completionHandler:(nullable XM_AFCompletionHandler)completionHandler;


//head请求是没有responseObject返回
- (nullable NSURLSessionDataTask *)HEAD:(NSString *)URLString
                             parameters:(nullable id)parameters
                      completionHandler:(nullable XM_AFCompletionHandler)completionHandler;


- (nullable NSURLSessionDataTask *)PUT:(NSString *)URLString
                            parameters:(nullable id)parameters
                     completionHandler:(nullable XM_AFCompletionHandler)completionHandler;


- (nullable NSURLSessionDataTask *)PATCH:(NSString *)URLString
                              parameters:(nullable id)parameters
                       completionHandler:(nullable XM_AFCompletionHandler)completionHandler;


- (nullable NSURLSessionDataTask *)DELETE:(NSString *)URLString
                               parameters:(nullable id)parameters
                        completionHandler:(nullable XM_AFCompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
