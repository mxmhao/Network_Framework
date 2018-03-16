//
//  APIManager.m
//  Network_Framework
//
//  Created by noontec on 2018/2/27.
//  Copyright © 2018年 mxm. All rights reserved.
//
//  此类做的操作：URLString加上域名，params加签，统一管理APIManager的保存和删除，把block换成target-action的方式

#import "APIManager.h"
#import "NetworkManager.h"
#import "XMLock.h"
#import "DomainManager.h"

typedef NS_ENUM(NSInteger, RetryTag) {
    RetryTagGet,
    RetryTagPost,
    RetryTagUpload,
};

NS_INLINE
void callTargetActionWithData(id target, SEL action, id data)
{
    IMP imp = [target methodForSelector:action];
//    void (*func)(id, SEL, id) = (void *)imp;    //前两个参数是固定的
//    void (*func)(__strong id, SEL, ...) = (void (*)(__strong id, SEL, ...))imp;//网上搜到是这么写的
    void (*func)(__strong id, SEL, ...) = (void (*)(__strong id, SEL, ...))imp;//这么写好点
    func(target, action, data);
    
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Warc-performSelector-leaks" //消除警告
//    [_target performSelector:_action withObject:data];//此方式调用会产生警告
//#pragma clang diagnostic pop
}

NS_INLINE
id callTargetActionWithDataForResult(id target, SEL action, id data)
{
    id (*func)(id, SEL, ...) = (id (*)(id, SEL, ...))[target methodForSelector:action];
    return func(target, action, data);
}

@implementation HandlerTargetAction

+ (instancetype)target:(id)target action:(SEL)action
{
    HandlerTargetAction *hta = [self new];
    hta.target = target;
    hta.action = action;
    return hta;
}

- (void)dealloc
{
    NSLog(@"HandlerTargetAction -- 释放");
}

@end

@implementation APIManager
{
    TaskId _taskId;
    HandlerTargetAction *_successHandler;
    HandlerTargetAction *_failureHandler;
    HandlerTargetAction *_dataHandler;
    RetryTag _retryTag;
}

static XMLock lock;
static NSMutableDictionary *mdic = nil;
static NetworkManager *shareManager;
//创建保存当前网络请求的字典
+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mdic = [NSMutableDictionary dictionary];
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

- (instancetype)initWithSuccessHandler:(nullable HandlerTargetAction *)success
                        failureHandler:(nullable HandlerTargetAction *)failure
{
    self = [super init];
    if (self) {
        _successHandler = success;
        _failureHandler = failure;
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"%@ -- 释放", [self class]);
}

+ (void)sig
{
//    NSProxy *pro;
//    NSObject *obj;
}

+ (instancetype)callGet:(NSString *)URLString
                  params:(nullable NSDictionary *)params
                progress:(nullable void (^)(NSProgress * _Nonnull))downloadProgress
          successHandler:(nullable HandlerTargetAction *)success
          failureHandler:(nullable HandlerTargetAction *)failure
{
    //downloadProgress
    //一些数据加签或加密的工作
    NSDictionary *sigParams = params;
    if (nil != _delegate) {
        sigParams = [_delegate signature:[NSMutableDictionary dictionaryWithDictionary:params]];
    }
    
    //当前网络请求处理的保存者
    APIManager *aManager = [[self alloc] initWithSuccessHandler:success failureHandler:failure];
//    aManager->_successHandler = success;
//    aManager->_failureHandler = failure;
    aManager->_retryTag = RetryTagGet;
    //开始请求网络
    aManager->_taskId = [shareManager callGet:[DomainManager absoluteURLStringWithURLString:URLString] parameters:sigParams progress:downloadProgress completionHandler:^(TaskId _Nullable taskId, id _Nullable responseObject, NSError * _Nullable error) {
        APIManager *manager = mdic[taskId];
        DictionaryThreadSecureDeleteObjectForKey(lock, mdic, taskId);
        if (nil == manager->_failureHandler.target) return;
        if (error) {
//            [manager->_failureHandler.target performSelector:manager->_failureHandler.action withObject:error];
            callTargetActionWithData(manager->_failureHandler.target, manager->_failureHandler.action, error);
        } else {
//            [manager->_successHandler.target performSelector:manager->_successHandler.action withObject:responseObject];
            callTargetActionWithData(manager->_successHandler.target, manager->_successHandler.action, responseObject);
        }
    }];
    DictionaryThreadSecureSetObjectForKey(lock, mdic, aManager->_taskId, aManager);
    
    return aManager;
}

+ (instancetype)callPost:(NSString *)URLString
                  params:(nullable NSDictionary *)params
    progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
          successHandler:(nullable HandlerTargetAction *)success
          failureHandler:(nullable HandlerTargetAction *)failure
{
    //一些数据加签或加密的工作
    NSDictionary *sigParams = params;
    if (nil != _delegate) {
        sigParams = [_delegate signature:[NSMutableDictionary dictionaryWithDictionary:params]];
    }
    
    //当前网络请求处理的保存者
    APIManager *aManager = [[self alloc] initWithSuccessHandler:success failureHandler:failure];
//    aManager->_successHandler = success;
//    aManager->_failureHandler = failure;
    //开始请求网络
    aManager->_taskId = [shareManager callPost:[DomainManager absoluteURLStringWithURLString:URLString] params:sigParams progress:uploadProgress completionHandler:^(TaskId _Nullable taskId, id _Nullable responseObject, NSError * _Nullable error) {
        APIManager *manager = mdic[taskId];
        DictionaryThreadSecureDeleteObjectForKey(lock, mdic, taskId);
        if (nil == manager->_failureHandler.target) return;
        if (error) {
//            [manager->_failureHandler.target performSelector:manager->_failureHandler.action withObject:error];
            callTargetActionWithData(manager->_failureHandler.target, manager->_failureHandler.action, error);
        } else {
//            [manager->_successHandler.target performSelector:manager->_successHandler.action withObject:responseObject];
            callTargetActionWithData(manager->_successHandler.target, manager->_successHandler.action, responseObject);
        }
    }];
    DictionaryThreadSecureSetObjectForKey(lock, mdic, aManager->_taskId, aManager);
    
    return aManager;
}

+ (instancetype)callPost:(NSString *)URLString
                  params:(NSDictionary *)params
             dataHandler:(HandlerTargetAction *)dataHandler
          successHandler:(HandlerTargetAction *)success
          failureHandler:(HandlerTargetAction *)failure
                progress:(void (^)(NSProgress * _Nonnull))uploadProgress
{
    //一些数据加签或加密的工作
    NSDictionary *sigParams = params;
    if (nil != _delegate) {
        sigParams = [_delegate signature:[NSMutableDictionary dictionaryWithDictionary:params]];
    }
    
    //当前网络请求处理的保存者
    APIManager *aManager = [[self alloc] initWithSuccessHandler:success failureHandler:failure];
    aManager->_dataHandler = dataHandler;
    //开始请求网络
    aManager->_taskId = [shareManager callPost:[DomainManager absoluteURLStringWithURLString:URLString] params:sigParams progress:uploadProgress completionHandler:^(TaskId _Nullable taskId, id _Nullable responseObject, NSError * _Nullable error) {
        APIManager *manager = mdic[taskId];
        DictionaryThreadSecureDeleteObjectForKey(lock, mdic, taskId);
        if (nil == manager->_failureHandler.target) return;
        if (error) {
//            [manager->_failureHandler.target performSelector:manager->_failureHandler.action withObject:error];
            callTargetActionWithData(manager->_failureHandler.target, manager->_failureHandler.action, error);
        } else {
            if (manager->_dataHandler) {
//                responseObject = [manager->_dataHandler.target performSelector:manager->_dataHandler.action withObject:responseObject];
                responseObject = callTargetActionWithDataForResult(manager->_dataHandler.target, manager->_dataHandler.action, responseObject);
            }
//            [manager->_successHandler.target performSelector:manager->_successHandler.action withObject:responseObject];
            callTargetActionWithData(manager->_successHandler.target, manager->_successHandler.action, responseObject);
        }
    }];
    DictionaryThreadSecureSetObjectForKey(lock, mdic, aManager->_taskId, aManager);
    
    return aManager;
}

- (void)cancel
{
    [shareManager cancelTaskWithId:_taskId];
    DictionaryThreadSecureDeleteObjectForKey(lock, mdic, _taskId);
}

- (void)retry
{
    switch (_retryTag) {
        case RetryTagGet:
            //
            break;
        case RetryTagPost:
            //
            break;
        case RetryTagUpload:
            //
            break;
    }
}

@end
