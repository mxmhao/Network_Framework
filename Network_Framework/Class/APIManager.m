//
//  APIManager.m
//  Network_Framework
//
//  Created by min on 2018/10/13.
//  Copyright © 2018 mxm. All rights reserved.
//

#import "APIManager.h"
#import "NetworkManager.h"
#import "XMLock.h"
#import "DomainManager.h"
#import "HandlerTargetAction.h"

@implementation APIManager
{
    NSString *_URLString;
    NetworkManager *_networkManager;
    NSDictionary *_params;
    HandlerTargetAction *_successHandler;
    HandlerTargetAction *_failureHandler;
    HandlerTargetAction *_dataHandler;
    void (^_progress)(NSProgress * _Nonnull);
    //取消时需要用到
    TaskId _taskId;
    //重试时需要用到
    RetryTag _retryTag;
}

static XMLock lock;
static NSMapTable<TaskId, APIManager *> *mdict = nil;
//创建保存当前网络请求的字典
+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mdict = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPointerPersonality valueOptions:NSPointerFunctionsStrongMemory];
        lock = XM_CreateLock();
    });
}

- (instancetype)initWithURLString:(NSString *)URLString
                   networkManager:(NetworkManager *)networkManager
                           params:(nullable NSDictionary *)params
                      dataHandler:(nullable HandlerTargetAction *)dataHandler
                   successHandler:(nullable HandlerTargetAction *)success
                   failureHandler:(nullable HandlerTargetAction *)failure
                         progress:(nullable void (^)(NSProgress * _Nonnull))progress
{
    self = [super init];
    if (self) {
        _URLString = URLString;
        if (nil == networkManager) {
            _networkManager = [NetworkManager shareManager];
        } else {
            _networkManager = networkManager;            
        }
        _params = params;
        _dataHandler = dataHandler;
        _successHandler = success;
        _failureHandler = failure;
        _progress = [progress copy];
        _retryTag = RetryTagNone;
//        NSProxy *pro;//测试
//        NSObject *obj;
        //给数据加签
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"%@ -- 释放", [self class]);
}

#pragma mark -
+ (instancetype)callGet:(NSString *)URLString
                 params:(nullable NSDictionary *)params
            dataHandler:(nullable HandlerTargetAction *)dataHandler
         successHandler:(nullable HandlerTargetAction *)success
         failureHandler:(nullable HandlerTargetAction *)failure
{
    return [self callGet:URLString networkManager:nil params:params dataHandler:dataHandler successHandler:success failureHandler:failure progress:nil];
}

+ (instancetype)callGet:(NSString *)URLString
                 params:(nullable NSDictionary *)params
            dataHandler:(nullable HandlerTargetAction *)dataHandler
         successHandler:(nullable HandlerTargetAction *)success
         failureHandler:(nullable HandlerTargetAction *)failure
               progress:(nullable void (^)(NSProgress * _Nonnull downloadProgress))downloadProgress
{
    return [self callGet:URLString networkManager:nil params:params dataHandler:dataHandler successHandler:success failureHandler:failure progress:nil];
}

+ (instancetype)callGet:(NSString *)URLString
         networkManager:(NetworkManager *)networkManager
                 params:(nullable NSDictionary *)params
            dataHandler:(nullable HandlerTargetAction *)dataHandler
         successHandler:(nullable HandlerTargetAction *)success
         failureHandler:(nullable HandlerTargetAction *)failure
               progress:(nullable void (^)(NSProgress * _Nonnull))downloadProgress
{
    //当前网络请求处理的保存者
    APIManager *aManager = [[self alloc] initWithURLString:URLString networkManager:networkManager params:params dataHandler:dataHandler successHandler:success failureHandler:failure progress:downloadProgress];
    //请求网络
    [aManager callGet];
    
    return aManager;
}

+ (instancetype)callPost:(NSString *)URLString
          networkManager:(NetworkManager *)networkManager
                  params:(NSDictionary *)params
             dataHandler:(nullable HandlerTargetAction *)dataHandler
          successHandler:(nullable HandlerTargetAction *)success
          failureHandler:(nullable HandlerTargetAction *)failure
                progress:(void (^)(NSProgress * _Nonnull))uploadProgress
{
    APIManager *aManager = [[self alloc] initWithURLString:URLString networkManager:networkManager params:params dataHandler:dataHandler successHandler:success failureHandler:failure progress:uploadProgress];
    [aManager callPost];
    
    return aManager;
}

+ (instancetype)callHead:(NSString *)URLString
          networkManager:(NetworkManager *)networkManager
                  params:(NSDictionary *)params
          successHandler:(HandlerTargetAction *)success
          failureHandler:(HandlerTargetAction *)failure
{
    APIManager *aManager = [[self alloc] initWithURLString:URLString networkManager:networkManager params:params dataHandler:nil successHandler:success failureHandler:failure progress:nil];
    [aManager callHead];
    
    return aManager;
}

+ (instancetype)callPut:(NSString *)URLString
         networkManager:(NetworkManager *)networkManager
                 params:(NSDictionary *)params
            dataHandler:(HandlerTargetAction *)dataHandler
         successHandler:(HandlerTargetAction *)success
         failureHandler:(HandlerTargetAction *)failure
{
    APIManager *aManager = [[self alloc] initWithURLString:URLString networkManager:networkManager params:params dataHandler:dataHandler successHandler:success failureHandler:failure progress:nil];
    [aManager callPut];
    
    return aManager;
}

+ (instancetype)callPatch:(NSString *)URLString
           networkManager:(NetworkManager *)networkManager
                   params:(NSDictionary *)params
              dataHandler:(HandlerTargetAction *)dataHandler
           successHandler:(HandlerTargetAction *)success
           failureHandler:(HandlerTargetAction *)failure
{
    APIManager *aManager = [[self alloc] initWithURLString:URLString networkManager:networkManager params:params dataHandler:dataHandler successHandler:success failureHandler:failure progress:nil];
    [aManager callPatch];
    
    return aManager;
}

+ (instancetype)callDelete:(NSString *)URLString
            networkManager:(NetworkManager *)networkManager
                    params:(NSDictionary *)params
               dataHandler:(HandlerTargetAction *)dataHandler
            successHandler:(HandlerTargetAction *)success
            failureHandler:(HandlerTargetAction *)failure
{
    APIManager *aManager = [[self alloc] initWithURLString:URLString networkManager:networkManager params:params dataHandler:dataHandler successHandler:success failureHandler:failure progress:nil];
    [aManager callDelete];
    
    return aManager;
}

#pragma mark -
- (void)callGet
{
    //一些数据加签或加密的工作
    _retryTag = RetryTagGet;
    __weak typeof(self) this = self;
    _taskId = [_networkManager callGet:[DomainManager absoluteURLStringWithURLString:_URLString] parameters:_params progress:_progress completionHandler:^(id _Nullable responseObject, NSError * _Nullable error) {
        [this responseObject:responseObject error:error];
    }];
    XM_OnThreadSafe(lock, [mdict setObject:self forKey:_taskId]);
}

- (void)callPost
{
    _retryTag = RetryTagPost;
    __weak typeof(self) this = self;
    _taskId = [_networkManager callPost:[DomainManager absoluteURLStringWithURLString:_URLString] parameters:_params progress:_progress completionHandler:^(id _Nullable responseObject, NSError * _Nullable error) {
        [this responseObject:responseObject error:error];
    }];
    XM_OnThreadSafe(lock, [mdict setObject:self forKey:_taskId]);
}

- (void)callHead
{
    _retryTag = RetryTagHead;
    __weak typeof(self) this = self;
    _taskId = [_networkManager callHead:[DomainManager absoluteURLStringWithURLString:_URLString] parameters:_params  completionHandler:^(NSURLResponse * _Nonnull response, NSError * _Nullable error) {
        [this responseObject:response error:error];
    }];
    XM_OnThreadSafe(lock, [mdict setObject:self forKey:_taskId]);
}

- (void)callPut
{
    _retryTag = RetryTagPut;
    __weak typeof(self) this = self;
    _taskId = [_networkManager callPut:[DomainManager absoluteURLStringWithURLString:_URLString] parameters:_params completionHandler:^(id _Nullable responseObject, NSError * _Nullable error) {
        [this responseObject:responseObject error:error];
    }];
    XM_OnThreadSafe(lock, [mdict setObject:self forKey:_taskId]);
}

- (void)callPatch
{
    _retryTag = RetryTagPatch;
    __weak typeof(self) this = self;
    _taskId = [_networkManager callPatch:[DomainManager absoluteURLStringWithURLString:_URLString] parameters:_params completionHandler:^(id _Nullable responseObject, NSError * _Nullable error) {
        [this responseObject:responseObject error:error];
    }];
    XM_OnThreadSafe(lock, [mdict setObject:self forKey:_taskId]);
}

- (void)callDelete
{
    _retryTag = RetryTagDelete;
    __weak typeof(self) this = self;
    _taskId = [_networkManager callDelete:[DomainManager absoluteURLStringWithURLString:_URLString] parameters:_params completionHandler:^(id _Nullable responseObject, NSError * _Nullable error) {
        [this responseObject:responseObject error:error];
    }];
    XM_OnThreadSafe(lock, [mdict setObject:self forKey:_taskId]);
}

- (void)responseObject:(id)responseObject error:(NSError *)error
{
    XM_OnThreadSafe(lock, [mdict removeObjectForKey:mdict]);
    
    if (error) {
        if (nil == _failureHandler) return;
        callTargetActionWithData(_failureHandler.target, _failureHandler.action, error);
    } else {
        if (_dataHandler) {
            responseObject = callTargetActionWithDataForResult(_dataHandler.target, _dataHandler.action, responseObject);
        }
        
        if (nil == _successHandler) return;
        callTargetActionWithData(_successHandler.target, _successHandler.action, responseObject);
    }
}

#pragma mark -
- (void)cancel
{
//    [_networkManager cancelTaskWithId:_taskId];
//    XM_OnThreadSafe(lock, [mdict removeObjectForKey:mdict]);
}

- (void)retry
{
    switch (_retryTag) {
        case RetryTagGet:
            [self callGet];
            break;
        case RetryTagPost:
            [self callPost];
            break;
        case RetryTagHead:
            [self callHead];
            break;
        case RetryTagPut:
            [self callPut];
            break;
        case RetryTagPatch:
            [self callPatch];
            break;
        case RetryTagDelete:
            [self callDelete];
            break;
        default:break;
    }
}

@end
