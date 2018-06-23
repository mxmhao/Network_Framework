//
//  APIManager.m
//  Network_Framework
//
//  Created by mxm on 2018/2/27.
//  Copyright © 2018年 mxm. All rights reserved.
//
//  此类做的操作：URLString加上域名，params加签，统一管理APIManager的保存和删除，把block换成target-action的方式

#import "APIManager.h"
#import "NetworkManager.h"
#import "XMLock.h"
#import "DomainManager.h"

typedef NS_ENUM(NSInteger, RetryTag) {
    RetryTagGet,
    RetryTagHead,
    RetryTagPost,
    RetryTagPut,
    RetryTagPatch,
    RetryTagDelete
};
//typedef struct objc_selector *SEL; 这个是SEL的定义
NS_INLINE
void callTargetActionWithData(id target, SEL action, id data)
{
//    if (nil == target || NULL == action) return;
    IMP imp = [target methodForSelector:action];
//    void (*func)(id, SEL, id) = (void *)imp;    //前两个参数是固定的
//    void (*func)(__strong id, SEL, ...) = (void (*)(__strong id, SEL, ...))imp;//网上搜到是这么写的
    void (*func)(__strong id, SEL, ...) = (void (*)(__strong id, SEL, ...))imp;//这么写好点
    func(target, action, data);
    
    //上面的方式，应该比下面的方式更快
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Warc-performSelector-leaks" //消除警告
//    [_target performSelector:_action withObject:data];//此方式调用会产生警告
//#pragma clang diagnostic pop
}

NS_INLINE
id callTargetActionWithDataForResult(id target, SEL action, id data)
{
//    if (nil == target || NULL == action) return nil;
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
    NSString *_URLString;
    NSDictionary *_params;
    void (^_progress)(NSProgress * _Nonnull);
    //
    TaskId _taskId;
    HandlerTargetAction *_successHandler;
    HandlerTargetAction *_failureHandler;
    HandlerTargetAction *_dataHandler;
    RetryTag _retryTag;
}

static XMLock lock;
static NSMutableDictionary<TaskId, APIManager *> *mdict = nil;
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

#pragma mark -
+ (instancetype)callGet:(NSString *)URLString
                  params:(nullable NSDictionary *)params
            dataHandler:(nullable HandlerTargetAction *)dataHandler
          successHandler:(nullable HandlerTargetAction *)success
          failureHandler:(nullable HandlerTargetAction *)failure
               progress:(nullable void (^)(NSProgress * _Nonnull))downloadProgress
{
    //当前网络请求处理的保存者
    APIManager *aManager = [[self alloc] initWithSuccessHandler:success failureHandler:failure];
    aManager->_params = params;
    aManager->_dataHandler = dataHandler;
    aManager->_progress = [downloadProgress copy];
    //开始请求网络
    [aManager callGet];
    
    return aManager;
}

+ (instancetype)callHead:(NSString *)URLString
                  params:(NSDictionary *)params
          successHandler:(HandlerTargetAction *)success
          failureHandler:(HandlerTargetAction *)failure
{
    APIManager *aManager = [[self alloc] initWithSuccessHandler:success failureHandler:failure];
    aManager->_params = params;
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
    APIManager *aManager = [[self alloc] initWithSuccessHandler:success failureHandler:failure];
    aManager->_params = params;
    aManager->_dataHandler = dataHandler;
    aManager->_progress = [uploadProgress copy];
    [aManager callPost];
    
    return aManager;
}

+ (instancetype)callPut:(NSString *)URLString
                 params:(NSDictionary *)params
            dataHandler:(HandlerTargetAction *)dataHandler
         successHandler:(HandlerTargetAction *)success
         failureHandler:(HandlerTargetAction *)failure
{
    APIManager *aManager = [[self alloc] initWithSuccessHandler:success failureHandler:failure];
    aManager->_params = params;
    aManager->_dataHandler = dataHandler;
    [aManager callPut];
    
    return aManager;
}

+ (instancetype)callPatch:(NSString *)URLString
                   params:(NSDictionary *)params
              dataHandler:(HandlerTargetAction *)dataHandler
           successHandler:(HandlerTargetAction *)success
           failureHandler:(HandlerTargetAction *)failure
{
    APIManager *aManager = [[self alloc] initWithSuccessHandler:success failureHandler:failure];
    aManager->_params = params;
    aManager->_dataHandler = dataHandler;
    [aManager callPatch];
    
    return aManager;
}

+ (instancetype)callDelete:(NSString *)URLString
                    params:(NSDictionary *)params
               dataHandler:(HandlerTargetAction *)dataHandler
            successHandler:(HandlerTargetAction *)success
            failureHandler:(HandlerTargetAction *)failure
{
    APIManager *aManager = [[self alloc] initWithSuccessHandler:success failureHandler:failure];
    aManager->_params = params;
    aManager->_dataHandler = dataHandler;
    [aManager callDelete];
    
    return aManager;
}

#pragma mark -
- (void)callGet
{
    //一些数据加签或加密的工作
    NSDictionary *sigParams = _params;
    if (nil != _delegate) {
        sigParams = [_delegate signature:[NSMutableDictionary dictionaryWithDictionary:_params]];
    }
    
    _retryTag = RetryTagGet;
    __weak typeof(self) this = self;
    //开始请求网络
    _taskId = [shareManager callGet:[DomainManager absoluteURLStringWithURLString:_URLString] parameters:sigParams progress:_progress completionHandler:^(TaskId _Nullable taskId, id _Nullable responseObject, NSError * _Nullable error) {
        [this completionHandler:taskId responseObject:responseObject error:error];
    }];
    DictionaryThreadSecureSetObjectForKey(lock, mdict, _taskId, self);
}

- (void)callHead
{
    //一些数据加签或加密的工作
    NSDictionary *sigParams = _params;
    if (nil != _delegate) {
        sigParams = [_delegate signature:[NSMutableDictionary dictionaryWithDictionary:_params]];
    }
    
    _retryTag = RetryTagHead;
    __weak typeof(self) this = self;
    //开始请求网络
    _taskId = [shareManager callHead:[DomainManager absoluteURLStringWithURLString:_URLString] parameters:sigParams  completionHandler:^(TaskId _Nullable taskId, NSURLResponse * _Nonnull response, NSError * _Nullable error) {
        [this completionHandler:taskId responseObject:response error:error];
    }];
    DictionaryThreadSecureSetObjectForKey(lock, mdict, _taskId, self);
}

- (void)callPost
{
    //一些数据加签或加密的工作
    NSDictionary *sigParams = _params;
    if (nil != _delegate) {
        sigParams = [_delegate signature:[NSMutableDictionary dictionaryWithDictionary:_params]];
    }
    
    _retryTag = RetryTagPost;
    __weak typeof(self) this = self;
    _taskId = [shareManager callPost:[DomainManager absoluteURLStringWithURLString:_URLString] params:sigParams progress:_progress completionHandler:^(TaskId _Nullable taskId, id _Nullable responseObject, NSError * _Nullable error) {
        [this completionHandler:taskId responseObject:responseObject error:error];
    }];
    DictionaryThreadSecureSetObjectForKey(lock, mdict, _taskId, self);
}

- (void)callPut
{
    //一些数据加签或加密的工作
    NSDictionary *sigParams = _params;
    if (nil != _delegate) {
        sigParams = [_delegate signature:[NSMutableDictionary dictionaryWithDictionary:_params]];
    }
    
    _retryTag = RetryTagPut;
    __weak typeof(self) this = self;
    //开始请求网络
    _taskId = [shareManager callPut:[DomainManager absoluteURLStringWithURLString:_URLString] parameters:sigParams completionHandler:^(TaskId _Nullable taskId, id _Nullable responseObject, NSError * _Nullable error) {
        [this completionHandler:taskId responseObject:responseObject error:error];
    }];
    DictionaryThreadSecureSetObjectForKey(lock, mdict, _taskId, self);
}

- (void)callPatch
{
    //一些数据加签或加密的工作
    NSDictionary *sigParams = _params;
    if (nil != _delegate) {
        sigParams = [_delegate signature:[NSMutableDictionary dictionaryWithDictionary:_params]];
    }
    
    _retryTag = RetryTagPatch;
    
    __weak typeof(self) this = self;
    //开始请求网络
    _taskId = [shareManager callPatch:[DomainManager absoluteURLStringWithURLString:_URLString] parameters:sigParams completionHandler:^(TaskId _Nullable taskId, id _Nullable responseObject, NSError * _Nullable error) {
        [this completionHandler:taskId responseObject:responseObject error:error];
    }];
    DictionaryThreadSecureSetObjectForKey(lock, mdict, _taskId, self);
}

- (void)callDelete
{
    //一些数据加签或加密的工作
    NSDictionary *sigParams = _params;
    if (nil != _delegate) {
        sigParams = [_delegate signature:[NSMutableDictionary dictionaryWithDictionary:_params]];
    }
    
    _retryTag = RetryTagDelete;
    __weak typeof(self) this = self;
    //开始请求网络
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
        callTargetActionWithData(_failureHandler.target, _failureHandler.action, error);//方式二
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
