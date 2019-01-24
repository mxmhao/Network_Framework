//
//  APIManager.h
//  Network_Framework
//
//  Created by min on 2018/10/13.
//  Copyright © 2018 mxm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIManagerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class HandlerTargetAction, NetworkManager;

//做了硬着陆处理，不会因为HandlerTargetAction为nil或其变量为nil引起bug
@interface APIManager : NSObject <APIManagerProtocol>

+ (instancetype)callGet:(NSString *)URLString
                 params:(nullable NSDictionary *)params
            dataHandler:(nullable HandlerTargetAction *)dataHandler
         successHandler:(nullable HandlerTargetAction *)success
         failureHandler:(nullable HandlerTargetAction *)failure;

+ (instancetype)callGet:(NSString *)URLString
                 params:(nullable NSDictionary *)params
            dataHandler:(nullable HandlerTargetAction *)dataHandler
         successHandler:(nullable HandlerTargetAction *)success
         failureHandler:(nullable HandlerTargetAction *)failure
               progress:(nullable void (^)(NSProgress * _Nonnull downloadProgress))downloadProgress;

+ (instancetype)callGet:(NSString *)URLString
         networkManager:(nullable NetworkManager *)networkManager
                 params:(nullable NSDictionary *)params
            dataHandler:(nullable HandlerTargetAction *)dataHandler
         successHandler:(nullable HandlerTargetAction *)success
         failureHandler:(nullable HandlerTargetAction *)failure
               progress:(nullable void (^)(NSProgress * _Nonnull downloadProgress))downloadProgress;

+ (instancetype)callPost:(NSString *)URLString
          networkManager:(nullable NetworkManager *)networkManager
                  params:(nullable NSDictionary *)params
             dataHandler:(nullable HandlerTargetAction *)dataHandler
          successHandler:(nullable HandlerTargetAction *)success
          failureHandler:(nullable HandlerTargetAction *)failure
                progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress))uploadProgress;

+ (instancetype)callHead:(NSString *)URLString
          networkManager:(nullable NetworkManager *)networkManager
                  params:(nullable NSDictionary *)params
          successHandler:(nullable HandlerTargetAction *)success
          failureHandler:(nullable HandlerTargetAction *)failure;

+ (instancetype)callPut:(NSString *)URLString
         networkManager:(nullable NetworkManager *)networkManager
                 params:(nullable NSDictionary *)params
            dataHandler:(nullable HandlerTargetAction *)dataHandler
         successHandler:(nullable HandlerTargetAction *)success
         failureHandler:(nullable HandlerTargetAction *)failure;

+ (instancetype)callPatch:(NSString *)URLString
           networkManager:(nullable NetworkManager *)networkManager
                   params:(nullable NSDictionary *)params
              dataHandler:(nullable HandlerTargetAction *)dataHandler
           successHandler:(nullable HandlerTargetAction *)success
           failureHandler:(nullable HandlerTargetAction *)failure;

+ (instancetype)callDelete:(NSString *)URLString
            networkManager:(nullable NetworkManager *)networkManager
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
