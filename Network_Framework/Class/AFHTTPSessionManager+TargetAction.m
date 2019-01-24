//
//  AFHTTPSessionManager+TargetAction.m
//  Network_Framework
//
//  Created by mxm on 2018/3/1.
//  Copyright © 2018年 mxm. All rights reserved.
//

#import "AFHTTPSessionManager+TargetAction.h"
#import "HandlerTargetAction.h"
//#import <objc/runtime.h>
#import <objc/message.h>

NS_INLINE
void msgSendTargetActionWithData(id target, SEL action, id data) {
    ((void (*)(id, SEL, id))objc_msgSend)(target, action, data);
}

NS_INLINE
id msgSendTargetActionWithDataForResult(id target, SEL action, id data) {
    return ((id (*)(id, SEL, id))objc_msgSend)(target, action, data);
}

@implementation AFHTTPSessionManager (CompletionHandler)

static AFHTTPSessionManager *shareManager = nil;
+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [self new];
        //shareManager->_manager//不会暴露到外面，所以一些定制参数在这里添加
        //共享的最大并发数设置
        shareManager.operationQueue.maxConcurrentOperationCount = 3;
        shareManager.responseSerializer = [AFHTTPResponseSerializer serializer];//测试
//        ((AFJSONResponseSerializer *)shareManager.responseSerializer).removesKeysWithNullValues = YES;
//        ((AFJSONResponseSerializer *)shareManager.responseSerializer).readingOptions = NSJSONReadingMutableContainers;
    });
    return shareManager;
}

#pragma mark -
- (nullable NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
        URLString:(NSString *)URLString
       parameters:(nullable id)parameters
   uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
 downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
      dataHandler:(HandlerTargetAction *)dataHandler
   successHandler:(HandlerTargetAction *)success
   failureHandler:(HandlerTargetAction *)failure
{
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:URLString parameters:parameters error:&serializationError];
    if (serializationError) {
        if (failure) {
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                msgSendTargetActionWithData(failure.target, failure.action, serializationError);
            });
        }
        
        return nil;
    }
    
    NSURLSessionDataTask *task = [self dataTaskWithRequest:request
        uploadProgress:uploadProgress
      downloadProgress:downloadProgress
     completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
         if (MethodHead == method) {//HEAD方式特殊处理一下
             responseObject = response;
         }
         [AFHTTPSessionManager dataHandler:dataHandler successHandler:success failureHandler:failure responseObject:responseObject error:error];
    }];
    [task resume];
    return task;
}

+ (void)dataHandler:(HandlerTargetAction *)dataHandler
     successHandler:(HandlerTargetAction *)success
     failureHandler:(HandlerTargetAction *)failure
     responseObject:(id)responseObject
              error:(NSError *)error
{
    if (error) {
        if (nil == failure) return;
        msgSendTargetActionWithData(failure.target, failure.action, error);
    } else {
        if (dataHandler) {
            responseObject = msgSendTargetActionWithDataForResult(dataHandler.target, dataHandler.action, responseObject);
        }
        
        if (nil == success) return;
        msgSendTargetActionWithData(success.target, success.action, responseObject);
    }
}

- (NSURLSessionDataTask *)callGet:(NSString *)URLString params:(NSDictionary *)params dataHandler:(HandlerTargetAction *)dataHandler successHandler:(HandlerTargetAction *)success failureHandler:(HandlerTargetAction *)failure progress:(void (^)(NSProgress * _Nonnull))downloadProgress
{
    return [self dataTaskWithHTTPMethod:@"GET" URLString:URLString parameters:params
                         uploadProgress:nil
                       downloadProgress:downloadProgress
                            dataHandler:dataHandler
                         successHandler:success
                         failureHandler:failure];
}

static NSString *const MethodHead = @"HEAD";
- (NSURLSessionDataTask *)callHead:(NSString *)URLString params:(NSDictionary *)params successHandler:(HandlerTargetAction *)success failureHandler:(HandlerTargetAction *)failure
{
    return [self dataTaskWithHTTPMethod:MethodHead URLString:URLString parameters:params
                         uploadProgress:nil
                       downloadProgress:nil
                            dataHandler:nil
                         successHandler:success
                         failureHandler:failure];
}

- (NSURLSessionDataTask *)callPost:(NSString *)URLString params:(NSDictionary *)params dataHandler:(HandlerTargetAction *)dataHandler successHandler:(HandlerTargetAction *)success failureHandler:(HandlerTargetAction *)failure progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
{
    return [self dataTaskWithHTTPMethod:@"POST" URLString:URLString parameters:params
                         uploadProgress:uploadProgress
                       downloadProgress:nil
                            dataHandler:dataHandler
                         successHandler:success
                         failureHandler:failure];
}

- (NSURLSessionDataTask *)callPut:(NSString *)URLString params:(NSDictionary *)params dataHandler:(HandlerTargetAction *)dataHandler successHandler:(HandlerTargetAction *)success failureHandler:(HandlerTargetAction *)failure
{
    return [self dataTaskWithHTTPMethod:@"PUT" URLString:URLString parameters:params
                         uploadProgress:nil
                       downloadProgress:nil
                            dataHandler:dataHandler
                         successHandler:success
                         failureHandler:failure];
}

- (nullable NSURLSessionDataTask *)callPatch:(NSString *)URLString
                                      params:(nullable NSDictionary *)params
                                 dataHandler:(nullable HandlerTargetAction *)dataHandler
                              successHandler:(nullable HandlerTargetAction *)success
                              failureHandler:(nullable HandlerTargetAction *)failure
{
    return [self dataTaskWithHTTPMethod:@"PATCH" URLString:URLString parameters:params
                         uploadProgress:nil
                       downloadProgress:nil
                            dataHandler:dataHandler
                         successHandler:success
                         failureHandler:failure];
}

- (nullable NSURLSessionDataTask *)callDelete:(NSString *)URLString
                                       params:(nullable NSDictionary *)params
                                  dataHandler:(nullable HandlerTargetAction *)dataHandler
                               successHandler:(nullable HandlerTargetAction *)success
                               failureHandler:(nullable HandlerTargetAction *)failure
{
    return [self dataTaskWithHTTPMethod:@"DELETE" URLString:URLString parameters:params
                         uploadProgress:nil
                       downloadProgress:nil
                            dataHandler:dataHandler
                         successHandler:success
                         failureHandler:failure];
}

//----------------------------------------------------------------------
#pragma mark -
- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                     progress:(void (^)(NSProgress * _Nonnull))downloadProgress
            completionHandler:(XM_AFCompletionHandler)completionHandler
{
    return [self dataTaskWithHTTPMethod:@"GET" URLString:URLString parameters:parameters uploadProgress:nil downloadProgress:downloadProgress completionHandler:completionHandler];
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
                      progress:(void (^)(NSProgress * _Nonnull))uploadProgress
             completionHandler:(XM_AFCompletionHandler)completionHandler
{
    return [self dataTaskWithHTTPMethod:@"POST" URLString:URLString parameters:parameters uploadProgress:uploadProgress downloadProgress:nil completionHandler:completionHandler];
}

- (NSURLSessionDataTask *)HEAD:(NSString *)URLString
                    parameters:(id)parameters
             completionHandler:(XM_AFCompletionHandler)completionHandler
{
    return [self dataTaskWithHTTPMethod:@"HEAD" URLString:URLString parameters:parameters uploadProgress:nil downloadProgress:nil completionHandler:completionHandler];
}

- (NSURLSessionDataTask *)PUT:(NSString *)URLString
                   parameters:(id)parameters
            completionHandler:(XM_AFCompletionHandler)completionHandler
{
    return [self dataTaskWithHTTPMethod:@"PUT" URLString:URLString parameters:parameters uploadProgress:nil downloadProgress:nil completionHandler:completionHandler];
}

- (NSURLSessionDataTask *)PATCH:(NSString *)URLString
                     parameters:(id)parameters
              completionHandler:(XM_AFCompletionHandler)completionHandler
{
    return [self dataTaskWithHTTPMethod:@"PATCH" URLString:URLString parameters:parameters uploadProgress:nil downloadProgress:nil completionHandler:completionHandler];
}

- (NSURLSessionDataTask *)DELETE:(NSString *)URLString
                      parameters:(id)parameters
               completionHandler:(XM_AFCompletionHandler)completionHandler
{
    return [self dataTaskWithHTTPMethod:@"DELETE" URLString:URLString parameters:parameters uploadProgress:nil downloadProgress:nil completionHandler:completionHandler];
}

- (nullable NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
    URLString:(NSString *)URLString
    parameters:(nullable id)parameters
    uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
    downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
    completionHandler:(nullable XM_AFCompletionHandler)completionHandler
{
    //数据加密也可以放在这里
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:URLString parameters:parameters error:&serializationError];
    if (serializationError) {
        if (completionHandler) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                completionHandler(nil, nil, serializationError);
            });
#pragma clang diagnostic pop
        }
        
        return nil;
    }
    
    NSURLSessionDataTask *task = [self dataTaskWithRequest:request
                                            uploadProgress:uploadProgress
                                          downloadProgress:downloadProgress
                                         completionHandler:completionHandler];
    [task resume];
    return task;
}

/*
- (NSURLSessionUploadTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
 constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
  progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
 completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject, NSError * _Nullable error))completionHandler
{
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:URLString parameters:parameters constructingBodyWithBlock:block error:&serializationError];
    if (serializationError) {
        if (completionHandler) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                completionHandler(nil, nil, serializationError);
            });
#pragma clang diagnostic pop
        }
        
        return nil;
    }
    
    NSURLSessionUploadTask *task = [self uploadTaskWithStreamedRequest:request progress:uploadProgress completionHandler:completionHandler];
    [task resume];
    return task;
}//*/

@end
