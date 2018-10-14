//
//  APIManager.m
//  Network_Framework
//
//  Created by mxm on 2018/2/27.
//  Copyright © 2018年 mxm. All rights reserved.
//
//  此类做的操作：URLString加上域名，params加签，统一管理APIManager的保存和删除，把block换成target-action的方式

#import "SharedAPIManager.h"
#import "NetworkManager.h"
#import "XMLock.h"
#import "DomainManager.h"
#import "HandlerTargetAction.h"

@implementation SharedAPIManager
{
    NSString *_URLString;
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
static NSMutableDictionary<TaskId, SharedAPIManager *> *mdict = nil;
static NetworkManager *shareManager;
//创建保存当前网络请求的字典
+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mdict = [NSMutableDictionary dictionaryWithCapacity:3];
        lock = XM_CreateLock();
        shareManager = [NetworkManager shareManager];
    });
}

static Class<ParamsSignatureDelegate> _delegate;
+ (void)setDelegate:(Class<ParamsSignatureDelegate>)delegate
{
    _delegate = delegate;
}

+ (Class<ParamsSignatureDelegate>)delegate
{
    return _delegate;
}

- (instancetype)initWithURLString:(NSString *)URLString
                           params:(nullable NSDictionary *)params
                      dataHandler:(nullable HandlerTargetAction *)dataHandler
                   successHandler:(nullable HandlerTargetAction *)success
                   failureHandler:(nullable HandlerTargetAction *)failure
                         progress:(nullable void (^)(NSProgress * _Nonnull))progress
{
    self = [super init];
    if (self) {
        _URLString = URLString;
        _params = params;
        _dataHandler = dataHandler;
        _successHandler = success;
        _failureHandler = failure;
        _progress = [progress copy];
        _retryTag = RetryTagNone;
//        NSProxy *pro;//测试
//        NSObject *obj;
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
               progress:(nullable void (^)(NSProgress * _Nonnull))downloadProgress
{
    //当前网络请求处理的保存者
    SharedAPIManager *aManager = [[self alloc] initWithURLString:URLString params:params dataHandler:dataHandler successHandler:success failureHandler:failure progress:downloadProgress];
    //请求网络
    [aManager callGet];
    
    return aManager;
}

+ (instancetype)callPost:(NSString *)URLString
                  params:(NSDictionary *)params
             dataHandler:(nullable HandlerTargetAction *)dataHandler
          successHandler:(nullable HandlerTargetAction *)success
          failureHandler:(nullable HandlerTargetAction *)failure
                progress:(void (^)(NSProgress * _Nonnull))uploadProgress
{
    SharedAPIManager *aManager = [[self alloc] initWithURLString:URLString params:params dataHandler:dataHandler successHandler:success failureHandler:failure progress:uploadProgress];
    [aManager callPost];
    
    return aManager;
}

+ (instancetype)callHead:(NSString *)URLString
                  params:(NSDictionary *)params
          successHandler:(HandlerTargetAction *)success
          failureHandler:(HandlerTargetAction *)failure
{
    SharedAPIManager *aManager = [[self alloc] initWithURLString:URLString params:params dataHandler:nil successHandler:success failureHandler:failure progress:nil];
    [aManager callHead];
    
    return aManager;
}

+ (instancetype)callPut:(NSString *)URLString
                 params:(NSDictionary *)params
            dataHandler:(HandlerTargetAction *)dataHandler
         successHandler:(HandlerTargetAction *)success
         failureHandler:(HandlerTargetAction *)failure
{
    SharedAPIManager *aManager = [[self alloc] initWithURLString:URLString params:params dataHandler:dataHandler successHandler:success failureHandler:failure progress:nil];
    [aManager callPut];
    
    return aManager;
}

+ (instancetype)callPatch:(NSString *)URLString
                   params:(NSDictionary *)params
              dataHandler:(HandlerTargetAction *)dataHandler
           successHandler:(HandlerTargetAction *)success
           failureHandler:(HandlerTargetAction *)failure
{
    SharedAPIManager *aManager = [[self alloc] initWithURLString:URLString params:params dataHandler:dataHandler successHandler:success failureHandler:failure progress:nil];
    [aManager callPatch];
    
    return aManager;
}

+ (instancetype)callDelete:(NSString *)URLString
                    params:(NSDictionary *)params
               dataHandler:(HandlerTargetAction *)dataHandler
            successHandler:(HandlerTargetAction *)success
            failureHandler:(HandlerTargetAction *)failure
{
    SharedAPIManager *aManager = [[self alloc] initWithURLString:URLString params:params dataHandler:dataHandler successHandler:success failureHandler:failure progress:nil];
    [aManager callDelete];
    
    return aManager;
}

#pragma mark -
- (void)callGet
{
    //一些数据加签或加密的工作
    NSDictionary *sigParams = _params;
    if (nil != _delegate) {
        sigParams = [_delegate signature:[NSMutableDictionary dictionaryWithDictionary:_params]];//这里只是给个实例，具体的加签方式由开发者qq去另外实现
    }
    
    _retryTag = RetryTagGet;
    __weak typeof(self) this = self;
    _taskId = [shareManager callGet:[DomainManager absoluteURLStringWithURLString:_URLString] parameters:sigParams progress:_progress completionHandler:^(TaskId _Nullable taskId, id _Nullable responseObject, NSError * _Nullable error) {
        [this completionHandler:taskId responseObject:responseObject error:error];
    }];
    DictionaryThreadSecureSetObjectForKey(lock, mdict, _taskId, self);
}

- (void)callPost
{
    NSDictionary *sigParams = _params;
    if (nil != _delegate) {
        sigParams = [_delegate signature:[NSMutableDictionary dictionaryWithDictionary:_params]];
    }
    
    _retryTag = RetryTagPost;
    __weak typeof(self) this = self;
    _taskId = [shareManager callPost:[DomainManager absoluteURLStringWithURLString:_URLString] parameters:sigParams progress:_progress completionHandler:^(TaskId _Nullable taskId, id _Nullable responseObject, NSError * _Nullable error) {
        [this completionHandler:taskId responseObject:responseObject error:error];
    }];
    DictionaryThreadSecureSetObjectForKey(lock, mdict, _taskId, self);
}

- (void)callHead
{
    NSDictionary *sigParams = _params;
    if (nil != _delegate) {
        sigParams = [_delegate signature:[NSMutableDictionary dictionaryWithDictionary:_params]];
    }
    
    _retryTag = RetryTagHead;
    __weak typeof(self) this = self;
    _taskId = [shareManager callHead:[DomainManager absoluteURLStringWithURLString:_URLString] parameters:sigParams  completionHandler:^(TaskId _Nullable taskId, NSURLResponse * _Nonnull response, NSError * _Nullable error) {
        [this completionHandler:taskId responseObject:response error:error];
    }];
    DictionaryThreadSecureSetObjectForKey(lock, mdict, _taskId, self);
}

- (void)callPut
{
    NSDictionary *sigParams = _params;
    if (nil != _delegate) {
        sigParams = [_delegate signature:[NSMutableDictionary dictionaryWithDictionary:_params]];
    }
    
    _retryTag = RetryTagPut;
    __weak typeof(self) this = self;
    _taskId = [shareManager callPut:[DomainManager absoluteURLStringWithURLString:_URLString] parameters:sigParams completionHandler:^(TaskId _Nullable taskId, id _Nullable responseObject, NSError * _Nullable error) {
        [this completionHandler:taskId responseObject:responseObject error:error];
    }];
    DictionaryThreadSecureSetObjectForKey(lock, mdict, _taskId, self);
}

- (void)callPatch
{
    NSDictionary *sigParams = _params;
    if (nil != _delegate) {
        sigParams = [_delegate signature:[NSMutableDictionary dictionaryWithDictionary:_params]];
    }
    
    _retryTag = RetryTagPatch;
    __weak typeof(self) this = self;
    _taskId = [shareManager callPatch:[DomainManager absoluteURLStringWithURLString:_URLString] parameters:sigParams completionHandler:^(TaskId _Nullable taskId, id _Nullable responseObject, NSError * _Nullable error) {
        [this completionHandler:taskId responseObject:responseObject error:error];
    }];
    DictionaryThreadSecureSetObjectForKey(lock, mdict, _taskId, self);
}

- (void)callDelete
{
    NSDictionary *sigParams = _params;
    if (nil != _delegate) {
        sigParams = [_delegate signature:[NSMutableDictionary dictionaryWithDictionary:_params]];
    }
    
    _retryTag = RetryTagDelete;
    __weak typeof(self) this = self;
    _taskId = [shareManager callDelete:[DomainManager absoluteURLStringWithURLString:_URLString] parameters:sigParams completionHandler:^(TaskId _Nullable taskId, id _Nullable responseObject, NSError * _Nullable error) {
        [this completionHandler:taskId responseObject:responseObject error:error];
    }];
    DictionaryThreadSecureSetObjectForKey(lock, mdict, _taskId, self);
}

- (void)completionHandler:(TaskId)taskId responseObject:(id)responseObject error:(NSError *)error
{
    DictionaryThreadSecureDeleteObjectForKey(lock, mdict, taskId);
    
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
    [shareManager cancelTaskWithId:_taskId];
    DictionaryThreadSecureDeleteObjectForKey(lock, mdict, _taskId);
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
