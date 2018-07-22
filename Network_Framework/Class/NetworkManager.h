//
//  APIManager.h
//  Network_Framework
//
//  Created by mxm on 2018/2/27.
//  Copyright © 2018年 mxm. All rights reserved.
//
//  请求网络，取消网络请求，本类只是一个简单的对AFN的封装

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSNumber* TaskId;

@interface NetworkManager : NSObject

/** 为方便用户而暴露的接口，shareManager示例返回的是nil */
@property (nonatomic, strong, readonly) AFHTTPSessionManager *httpManager;

/** 通用Manager，单例，
 若是有其它需求可自行创建其它实例使用([[NetworkManager alloc] init]) */
+ (instancetype)shareManager;

- (nullable TaskId)callGet:(NSString *)URLString
       parameters:(nullable id)parameters
         progress:(nullable void (^)(NSProgress *_Nonnull downloadProgress))downloadProgress
completionHandler:(nullable void (^)(TaskId _Nullable taskId, id _Nullable responseObject, NSError * _Nullable error))completionHandler;


- (nullable TaskId)callPost:(NSString *)URLString
        parameters:(nullable id)parameters
          progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress))uploadProgress
 completionHandler:(nullable void (^)(TaskId _Nullable taskId, id _Nullable responseObject, NSError * _Nullable error))completionHandler;


- (nullable TaskId)callHead:(NSString *)URLString
                 parameters:(nullable id)parameters
    completionHandler:(nullable void (^)(TaskId _Nullable taskId, NSURLResponse *response, NSError * _Nullable error))completionHandler;


- (nullable TaskId)callPut:(NSString *)URLString
                parameters:(nullable id)parameters
    completionHandler:(nullable void (^)(TaskId _Nullable taskId, id _Nullable responseObject, NSError * _Nullable error))completionHandler;


- (nullable TaskId)callPatch:(NSString *)URLString
                  parameters:(nullable id)parameters
    completionHandler:(nullable void (^)(TaskId _Nullable taskId, id _Nullable responseObject, NSError * _Nullable error))completionHandler;


- (nullable TaskId)callDelete:(NSString *)URLString
                   parameters:(nullable id)parameters
    completionHandler:(nullable void (^)(TaskId _Nullable taskId, id _Nullable responseObject, NSError * _Nullable error))completionHandler;


- (void)cancelTaskWithId:(TaskId)taskId;

@end

NS_ASSUME_NONNULL_END
