//
//  AFHTTPSessionManager+CompletionHandler.h
//  Network_Framework
//
//  Created by mxm on 2018/3/1.
//  Copyright © 2018年 mxm. All rights reserved.
//
//  AFN简化分类

#import <AFNetworking/AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^XM_AFCompletionHandler)(NSURLResponse *response, id _Nullable responseObject, NSError * _Nullable error);

@interface AFHTTPSessionManager (CompletionHandler)

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

//上传的另外写一个工具类
//- (nullable NSURLSessionUploadTask *)POST:(NSString *)URLString
//                    parameters:(id)parameters
// constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
//      progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
// completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject, NSError * _Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
