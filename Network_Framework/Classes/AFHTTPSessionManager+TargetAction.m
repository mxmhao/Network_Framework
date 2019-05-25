//
//  AFHTTPSessionManager+TargetAction.m
//  Network_Framework
//
//  Created by mxm on 2018/3/1.
//  Copyright © 2018年 mxm. All rights reserved.
//

#import "AFHTTPSessionManager+TargetAction.h"
#import "XMTargetAction.h"

@implementation AFHTTPSessionManager (TargetAction)

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

- (NSURLSessionDataTask *)callGet:(nonnull NSString *)URLString
                           params:(NSDictionary *)params
                           target:(id)target
                      dataHandler:(SEL)dataHandler
                          success:(SEL)success
                          failure:(SEL)failure
                         progress:(void (^)(NSProgress * _Nonnull downloadProgress))downloadProgress
{
    return [self callGet:URLString params:params
             dataHandler:XMCreateTA(target, dataHandler)
          successHandler:XMCreateTA(target, success)
          failureHandler:XMCreateTA(target, failure)
                progress:downloadProgress];
}

- (NSURLSessionDataTask *)callPost:(nonnull NSString *)URLString
                            params:(NSDictionary *)params
                            target:(id)target
                       dataHandler:(SEL)dataHandler
                           success:(SEL)success
                           failure:(SEL)failure
                          progress:(void (^)(NSProgress * _Nonnull uploadProgress))uploadProgress
{
    return [self callPost:URLString params:params
              dataHandler:XMCreateTA(target, dataHandler)
           successHandler:XMCreateTA(target, success)
           failureHandler:XMCreateTA(target, failure)
                 progress:uploadProgress];
}

- (NSURLSessionDataTask *)callHead:(nonnull NSString *)URLString
                            params:(NSDictionary *)params
                            target:(id)target
                           success:(SEL)success
                           failure:(SEL)failure
{
    return [self callHead:URLString params:params
           successHandler:XMCreateTA(target, success)
           failureHandler:XMCreateTA(target, failure)];
}

- (NSURLSessionDataTask *)callPut:(nonnull NSString *)URLString
                           params:(NSDictionary *)params
                           target:(id)target
                      dataHandler:(SEL)dataHandler
                          success:(SEL)success
                          failure:(SEL)failure
{
    return [self callPut:URLString params:params
             dataHandler:XMCreateTA(target, dataHandler)
          successHandler:XMCreateTA(target, success)
          failureHandler:XMCreateTA(target, failure)];
}

- (NSURLSessionDataTask *)callPatch:(nonnull NSString *)URLString
                             params:(NSDictionary *)params
                             target:(id)target
                        dataHandler:(SEL)dataHandler
                            success:(SEL)success
                            failure:(SEL)failure
{
    return [self callPatch:URLString params:params
               dataHandler:XMCreateTA(target, dataHandler)
            successHandler:XMCreateTA(target, success)
            failureHandler:XMCreateTA(target, failure)];
}

- (NSURLSessionDataTask *)callDelete:(nonnull NSString *)URLString
                              params:(NSDictionary *)params
                              target:(id)target
                         dataHandler:(SEL)dataHandler
                             success:(SEL)success
                             failure:(SEL)failure
{
    return [self callDelete:URLString params:params
                dataHandler:XMCreateTA(target, dataHandler)
             successHandler:XMCreateTA(target, success)
             failureHandler:XMCreateTA(target, failure)];
}

#pragma mark -
- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(nonnull NSString *)method
        URLString:(nonnull NSString *)URLString
       parameters:(id)parameters
   uploadProgress:(void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
 downloadProgress:(void (^)(NSProgress * _Nonnull downloadProgress)) downloadProgress
      dataHandler:(XMTargetAction *)dataHandler
   successHandler:(XMTargetAction *)success
   failureHandler:(XMTargetAction *)failure
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
     completionHandler:^(NSURLResponse * _Nonnull response, id responseObject, NSError *error) {
         if (MethodHead == method) {//HEAD方式特殊处理一下
             responseObject = response;
         }
         [AFHTTPSessionManager dataHandler:dataHandler successHandler:success failureHandler:failure responseObject:responseObject error:error];
    }];
    [task resume];
    return task;
}

+ (void)dataHandler:(XMTargetAction *)dataHandler
     successHandler:(XMTargetAction *)success
     failureHandler:(XMTargetAction *)failure
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

#pragma mark -
- (NSURLSessionDataTask *)callGet:(nonnull NSString *)URLString
                           params:(NSDictionary *)params
                      dataHandler:(XMTargetAction *)dataHandler
                   successHandler:(XMTargetAction *)success
                   failureHandler:(XMTargetAction *)failure
                         progress:(void (^)(NSProgress * _Nonnull))downloadProgress
{
    return [self dataTaskWithHTTPMethod:@"GET"
                              URLString:URLString
                             parameters:params
                         uploadProgress:nil
                       downloadProgress:downloadProgress
                            dataHandler:dataHandler
                         successHandler:success
                         failureHandler:failure];
}

- (NSURLSessionDataTask *)callPost:(nonnull NSString *)URLString
                            params:(NSDictionary *)params
                       dataHandler:(XMTargetAction *)dataHandler
                    successHandler:(XMTargetAction *)success
                    failureHandler:(XMTargetAction *)failure
                          progress:(void (^)(NSProgress * _Nonnull))uploadProgress
{
    return [self dataTaskWithHTTPMethod:@"POST"
                              URLString:URLString
                             parameters:params
                         uploadProgress:uploadProgress
                       downloadProgress:nil
                            dataHandler:dataHandler
                         successHandler:success
                         failureHandler:failure];
}

static NSString *const MethodHead = @"HEAD";
- (NSURLSessionDataTask *)callHead:(nonnull NSString *)URLString
                            params:(NSDictionary *)params
                    successHandler:(XMTargetAction *)success
                    failureHandler:(XMTargetAction *)failure
{
    return [self dataTaskWithHTTPMethod:MethodHead
                              URLString:URLString
                             parameters:params
                         uploadProgress:nil
                       downloadProgress:nil
                            dataHandler:nil
                         successHandler:success
                         failureHandler:failure];
}

- (NSURLSessionDataTask *)callPut:(nonnull NSString *)URLString
                           params:(NSDictionary *)params
                      dataHandler:(XMTargetAction *)dataHandler
                   successHandler:(XMTargetAction *)success
                   failureHandler:(XMTargetAction *)failure
{
    return [self dataTaskWithHTTPMethod:@"PUT"
                              URLString:URLString
                             parameters:params
                         uploadProgress:nil
                       downloadProgress:nil
                            dataHandler:dataHandler
                         successHandler:success
                         failureHandler:failure];
}

- (NSURLSessionDataTask *)callPatch:(nonnull NSString *)URLString
                             params:(NSDictionary *)params
                        dataHandler:(XMTargetAction *)dataHandler
                     successHandler:(XMTargetAction *)success
                     failureHandler:(XMTargetAction *)failure
{
    return [self dataTaskWithHTTPMethod:@"PATCH"
                              URLString:URLString
                             parameters:params
                         uploadProgress:nil
                       downloadProgress:nil
                            dataHandler:dataHandler
                         successHandler:success
                         failureHandler:failure];
}

- (NSURLSessionDataTask *)callDelete:(nonnull NSString *)URLString
                              params:(NSDictionary *)params
                         dataHandler:(XMTargetAction *)dataHandler
                      successHandler:(XMTargetAction *)success
                      failureHandler:(XMTargetAction *)failure
{
    return [self dataTaskWithHTTPMethod:@"DELETE"
                              URLString:URLString
                             parameters:params
                         uploadProgress:nil
                       downloadProgress:nil
                            dataHandler:dataHandler
                         successHandler:success
                         failureHandler:failure];
}

//----------------------------------------------------------------------
#pragma mark -
- (NSURLSessionDataTask *)GET:(nonnull NSString *)URLString
                   parameters:(id)parameters
                     progress:(void (^)(NSProgress * _Nonnull))downloadProgress
            completionHandler:(XM_AFCompletionHandler)completionHandler
{
    return [self dataTaskWithHTTPMethod:@"GET" URLString:URLString parameters:parameters uploadProgress:nil downloadProgress:downloadProgress completionHandler:completionHandler];
}

- (NSURLSessionDataTask *)POST:(nonnull NSString *)URLString
                    parameters:(id)parameters
                      progress:(void (^)(NSProgress * _Nonnull))uploadProgress
             completionHandler:(XM_AFCompletionHandler)completionHandler
{
    return [self dataTaskWithHTTPMethod:@"POST" URLString:URLString parameters:parameters uploadProgress:uploadProgress downloadProgress:nil completionHandler:completionHandler];
}

- (NSURLSessionDataTask *)HEAD:(nonnull NSString *)URLString
                    parameters:(id)parameters
             completionHandler:(XM_AFCompletionHandler)completionHandler
{
    return [self dataTaskWithHTTPMethod:@"HEAD" URLString:URLString parameters:parameters uploadProgress:nil downloadProgress:nil completionHandler:completionHandler];
}

- (NSURLSessionDataTask *)PUT:(nonnull NSString *)URLString
                   parameters:(id)parameters
            completionHandler:(XM_AFCompletionHandler)completionHandler
{
    return [self dataTaskWithHTTPMethod:@"PUT" URLString:URLString parameters:parameters uploadProgress:nil downloadProgress:nil completionHandler:completionHandler];
}

- (NSURLSessionDataTask *)PATCH:(nonnull NSString *)URLString
                     parameters:(id)parameters
              completionHandler:(XM_AFCompletionHandler)completionHandler
{
    return [self dataTaskWithHTTPMethod:@"PATCH" URLString:URLString parameters:parameters uploadProgress:nil downloadProgress:nil completionHandler:completionHandler];
}

- (NSURLSessionDataTask *)DELETE:(nonnull NSString *)URLString
                      parameters:(id)parameters
               completionHandler:(XM_AFCompletionHandler)completionHandler
{
    return [self dataTaskWithHTTPMethod:@"DELETE" URLString:URLString parameters:parameters uploadProgress:nil downloadProgress:nil completionHandler:completionHandler];
}

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(nonnull NSString *)method
    URLString:(nonnull NSString *)URLString
    parameters:(id)parameters
    uploadProgress:(void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
    downloadProgress:(void (^)(NSProgress * _Nonnull downloadProgress)) downloadProgress
    completionHandler:(XM_AFCompletionHandler)completionHandler
{
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
- (NSURLSessionUploadTask *)POST:(nonnull NSString *)URLString
                    parameters:(id)parameters
 constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
  progress:(void (^)(NSProgress * _Nonnull))uploadProgress
 completionHandler:(void (^)(NSURLResponse *response, id _responseObject, NSError * _error))completionHandler
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
