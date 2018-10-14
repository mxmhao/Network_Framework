//
//  AFHTTPSessionManager+CompletionHandler.m
//  Network_Framework
//
//  Created by mxm on 2018/3/1.
//  Copyright © 2018年 mxm. All rights reserved.
//

#import "AFHTTPSessionManager+CompletionHandler.h"

@implementation AFHTTPSessionManager (CompletionHandler)

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

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
       URLString:(NSString *)URLString
      parameters:(nullable id)parameters
  uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
completionHandler:(nullable XM_AFCompletionHandler)completionHandler
{
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:URLString parameters:parameters error:&serializationError];
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
