//
//  AFHTTPSessionManager+TargetAction.h
//  Network_Framework
//
//  Created by mxm on 2018/3/1.
//  Copyright © 2018年 mxm. All rights reserved.
//
//  AFN简化分类，自从用了HandlerTargetAction妈妈再也不用担心我的引用循环了

#import <AFNetworking/AFNetworking.h>

@class XMTargetAction;

typedef void(^XM_AFCompletionHandler)(NSURLResponse * _Nonnull response, id _responseObject, NSError * _error);

@interface AFHTTPSessionManager (TargetAction)

+ (instancetype)shareManager;

//当block的代码有很多行时，请使用以下方法
//做了硬着陆处理，不会因为HandlerTargetAction为nil或其变量为nil引起bug
#pragma mark -
- (NSURLSessionDataTask *)callGet:(nonnull NSString *)URLString
                           params:(NSDictionary *)params
                           target:(id)target
                      dataHandler:(SEL)dataHandler
                          success:(SEL)success
                          failure:(SEL)failure
                         progress:(void (^)(NSProgress * _Nonnull downloadProgress))downloadProgress;

- (NSURLSessionDataTask *)callPost:(nonnull NSString *)URLString
                            params:(NSDictionary *)params
                            target:(id)target
                       dataHandler:(SEL)dataHandler
                           success:(SEL)success
                           failure:(SEL)failure
                          progress:(void (^)(NSProgress * _Nonnull uploadProgress))uploadProgress;

- (NSURLSessionDataTask *)callHead:(nonnull NSString *)URLString
                            params:(NSDictionary *)params
                            target:(id)target
                           success:(SEL)success
                           failure:(SEL)failure;

- (NSURLSessionDataTask *)callPut:(nonnull NSString *)URLString
                           params:(NSDictionary *)params
                           target:(id)target
                      dataHandler:(SEL)dataHandler
                          success:(SEL)success
                          failure:(SEL)failure;

- (NSURLSessionDataTask *)callPatch:(nonnull NSString *)URLString
                             params:(NSDictionary *)params
                             target:(id)target
                        dataHandler:(SEL)dataHandler
                            success:(SEL)success
                            failure:(SEL)failure;

- (NSURLSessionDataTask *)callDelete:(nonnull NSString *)URLString
                              params:(NSDictionary *)params
                              target:(id)target
                         dataHandler:(SEL)dataHandler
                             success:(SEL)success
                             failure:(SEL)failure;


#pragma mark -
- (NSURLSessionDataTask *)callGet:(nonnull NSString *)URLString
                 params:(NSDictionary *)params
            dataHandler:(XMTargetAction *)dataHandler
         successHandler:(XMTargetAction *)success
         failureHandler:(XMTargetAction *)failure
               progress:(void (^)(NSProgress * _Nonnull downloadProgress))downloadProgress;

- (NSURLSessionDataTask *)callPost:(nonnull NSString *)URLString
                  params:(NSDictionary *)params
             dataHandler:(XMTargetAction *)dataHandler
          successHandler:(XMTargetAction *)success
          failureHandler:(XMTargetAction *)failure
                progress:(void (^)(NSProgress * _Nonnull uploadProgress))uploadProgress;

- (NSURLSessionDataTask *)callHead:(nonnull NSString *)URLString
                  params:(NSDictionary *)params
          successHandler:(XMTargetAction *)success
          failureHandler:(XMTargetAction *)failure;

- (NSURLSessionDataTask *)callPut:(nonnull NSString *)URLString
                 params:(NSDictionary *)params
            dataHandler:(XMTargetAction *)dataHandler
         successHandler:(XMTargetAction *)success
         failureHandler:(XMTargetAction *)failure;

- (NSURLSessionDataTask *)callPatch:(nonnull NSString *)URLString
                   params:(NSDictionary *)params
              dataHandler:(XMTargetAction *)dataHandler
           successHandler:(XMTargetAction *)success
           failureHandler:(XMTargetAction *)failure;

- (NSURLSessionDataTask *)callDelete:(nonnull NSString *)URLString
                    params:(NSDictionary *)params
               dataHandler:(XMTargetAction *)dataHandler
            successHandler:(XMTargetAction *)success
            failureHandler:(XMTargetAction *)failure;


//get和post有进度，其他的没有
- (NSURLSessionDataTask *)GET:(nonnull NSString *)URLString
        parameters:(id)parameters
          progress:(void (^)(NSProgress *_Nonnull downloadProgress))downloadProgress
 completionHandler:(XM_AFCompletionHandler)completionHandler;


- (NSURLSessionDataTask *)POST:(nonnull NSString *)URLString
         parameters:(id)parameters
           progress:(void (^)(NSProgress * _Nonnull uploadProgress))uploadProgress
  completionHandler:(XM_AFCompletionHandler)completionHandler;


//head请求是没有responseObject返回
- (NSURLSessionDataTask *)HEAD:(nonnull NSString *)URLString
                    parameters:(id)parameters
             completionHandler:(XM_AFCompletionHandler)completionHandler;


- (NSURLSessionDataTask *)PUT:(nonnull NSString *)URLString
                   parameters:(id)parameters
            completionHandler:(XM_AFCompletionHandler)completionHandler;


- (NSURLSessionDataTask *)PATCH:(nonnull NSString *)URLString
                     parameters:(id)parameters
              completionHandler:(XM_AFCompletionHandler)completionHandler;


- (NSURLSessionDataTask *)DELETE:(nonnull NSString *)URLString
                      parameters:(id)parameters
               completionHandler:(XM_AFCompletionHandler)completionHandler;

@end
