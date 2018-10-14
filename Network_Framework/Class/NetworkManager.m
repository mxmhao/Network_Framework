//
//  APIManager.m
//  Network_Framework
//
//  Created by mxm on 2018/2/27.
//  Copyright © 2018年 mxm. All rights reserved.
//
//  此类实现了使用AFNetworking发起请求，统一管理NSURLSessionTask

#import "NetworkManager.h"
#import "XMLock.h"
#import "AFHTTPSessionManager+CompletionHandler.h"

/*
//测试内存释放
@interface NSURLSessionTask (Test)
- (void)dealloc;
@end
@implementation NSURLSessionTask (Test)
- (void)dealloc
{
    NSLog(@"%@ -- 释放: %p", [self class], self);
}
@end */

NS_INLINE
TaskId ThreadSecureSaveTask(XMLock lock, NSMutableDictionary<TaskId, NSURLSessionTask *> *taskDic, NSURLSessionTask *task)
{
    TaskId tid = nil;
    if (nil != task) {
        tid = @(task.taskIdentifier);
        DictionaryThreadSecureSetObjectForKey(lock, taskDic, tid, task);
    }
    return tid;
}

//NS_INLINE
//void ThreadSecureDeleteTask(NetworkManager *networkManager, id responseObject, NSError * error, NSMutableDictionary<TaskId, NSURLSessionTask *> *taskDic, NSURLSessionTask *task, NMCompletionHandler completionHandler)
//{
//    TaskId tid = nil;
//    if (nil != task) {
//        tid = @(task.taskIdentifier);
////        __strong typeof(networkManager) this = networkManager;
////        DictionaryThreadSecureDeleteObjectForKey(self->_lock, self->_taskDic, tid);
//    }
//    if (completionHandler) {
//        completionHandler(tid, responseObject, error);
//    }
//}

@implementation NetworkManager
{
    AFHTTPSessionManager *_manager;
    NSMutableDictionary<TaskId, NSURLSessionTask *> *_taskDic;//保存任务，以便取消
    XMLock _lock;
//    XM_AFCompletionHandler _completionHandler;
}

static NetworkManager *shareManager = nil;
+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [self new];
        //shareManager->_manager//不会暴露到外面，所以一些定制参数在这里添加
        //共享的最大并发数设置
        shareManager->_manager.operationQueue.maxConcurrentOperationCount = 3;
    });
    return shareManager;
}

- (instancetype)init
{
    if (self == shareManager && nil != _manager) {
        return self;//不允许重复初始化shareManager
    }
    self = [super init];
    if (self) {
        _manager = [AFHTTPSessionManager manager];
//        _manager.requestSerializer.timeoutInterval = 30;//超时时间用默认的
        ((AFJSONResponseSerializer *)_manager.responseSerializer).removesKeysWithNullValues = YES;
        _taskDic = [NSMutableDictionary dictionaryWithCapacity:5];
        _lock = XM_CreateLock();
        NSLog(@"shareManager -- init");
    }
    return self;
}

- (AFHTTPSessionManager *)httpManager
{
    if (self == shareManager) {
        return nil;
    } else {
        return _manager;
    }
}

- (TaskId)callGet:(NSString *)URLString
       parameters:(id)parameters
         progress:(void (^)(NSProgress * _Nonnull))downloadProgress
completionHandler:(NMCompletionHandler)completionHandler
{
//    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];//测试
    __weak typeof(self) weakSelf = self;
    //这里必须用__block，不然下面block中的task可能为nil
    __block NSURLSessionDataTask *task = nil;
    task = [_manager GET:URLString parameters:parameters progress:downloadProgress completionHandler:^(NSURLResponse * _Nonnull response, id _Nullable responseObject, NSError * _Nullable error) {
//        NSLog(@"%p", task);
        TaskId tid = nil;
        if (nil != task) {
            tid = @(task.taskIdentifier);
            __strong typeof(weakSelf) self = weakSelf;
            DictionaryThreadSecureDeleteObjectForKey(self->_lock, self->_taskDic, tid);//实验证明，此操作之后会释放task
        }
        if (completionHandler) {
            completionHandler(tid, responseObject, error);
        }
    }];
    
//    NSLog(@"%p", task);
    return ThreadSecureSaveTask(_lock, _taskDic, task);
}

- (TaskId)callPost:(NSString *)URLString
        parameters:(id)parameters
          progress:(void (^)(NSProgress * _Nonnull))uploadProgress
 completionHandler:(NMCompletionHandler)completionHandler
{
    __weak typeof(self) weakSelf = self;
    __block NSURLSessionDataTask *task = nil;
    task = [_manager POST:URLString parameters:parameters progress:uploadProgress completionHandler:^(NSURLResponse *response, id _Nullable responseObject, NSError * _Nullable error) {
        TaskId tid = nil;
        if (nil != task) {
            tid = @(task.taskIdentifier);
            __strong typeof(weakSelf) self = weakSelf;
            DictionaryThreadSecureDeleteObjectForKey(self->_lock, self->_taskDic, tid);
        }
        if (completionHandler) {
            completionHandler(tid, responseObject, error);
        }
    }];
    
    return ThreadSecureSaveTask(_lock, _taskDic, task);
}

- (TaskId)callHead:(NSString *)URLString parameters:(id)parameters completionHandler:(void (^)(TaskId _Nullable, NSURLResponse *, NSError * _Nullable))completionHandler
{
    __weak typeof(self) weakSelf = self;
    //这里必须用__block，不然下面block中的task可能为nil
    __block NSURLSessionDataTask *task = nil;
    task = [_manager HEAD:URLString parameters:parameters completionHandler:^(NSURLResponse * _Nonnull response, id _Nullable responseObject, NSError * _Nullable error) {
        TaskId tid = nil;
        if (nil != task) {
            tid = @(task.taskIdentifier);
            __strong typeof(weakSelf) self = weakSelf;
            DictionaryThreadSecureDeleteObjectForKey(self->_lock, self->_taskDic, tid);//实验证明，此操作之后会释放task
        }
        if (completionHandler) {
            completionHandler(tid, response, error);
        }
    }];
    
    return ThreadSecureSaveTask(_lock, _taskDic, task);
}

- (TaskId)callPut:(NSString *)URLString parameters:(id)parameters completionHandler:(NMCompletionHandler)completionHandler
{
    __weak typeof(self) weakSelf = self;
    //这里必须用__block，不然下面block中的task可能为nil
    __block NSURLSessionDataTask *task = nil;
    task = [_manager PUT:URLString parameters:parameters completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        TaskId tid = nil;
        if (nil != task) {
            tid = @(task.taskIdentifier);
            __strong typeof(weakSelf) self = weakSelf;
            DictionaryThreadSecureDeleteObjectForKey(self->_lock, self->_taskDic, tid);//实验证明，此操作之后会释放task
        }
        if (completionHandler) {
            completionHandler(tid, responseObject, error);
        }
    }];
    
    return ThreadSecureSaveTask(_lock, _taskDic, task);
}

- (TaskId)callPatch:(NSString *)URLString parameters:(id)parameters completionHandler:(NMCompletionHandler)completionHandler
{
    __weak typeof(self) weakSelf = self;
    //这里必须用__block，不然下面block中的task可能为nil
    __block NSURLSessionDataTask *task = nil;
    task = [_manager PATCH:URLString parameters:parameters completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        TaskId tid = nil;
        if (nil != task) {
            tid = @(task.taskIdentifier);
            __strong typeof(weakSelf) self = weakSelf;
            DictionaryThreadSecureDeleteObjectForKey(self->_lock, self->_taskDic, tid);//实验证明，此操作之后会释放task
        }
        if (completionHandler) {
            completionHandler(tid, responseObject, error);
        }
    }];
    
    return ThreadSecureSaveTask(_lock, _taskDic, task);
}


- (TaskId)callDelete:(NSString *)URLString parameters:(id)parameters completionHandler:(NMCompletionHandler)completionHandler
{
    __weak typeof(self) weakSelf = self;
    //这里必须用__block，不然下面block中的task可能为nil
    __block NSURLSessionDataTask *task = nil;
    task = [_manager DELETE:URLString parameters:parameters completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        TaskId tid = nil;
        if (nil != task) {
            tid = @(task.taskIdentifier);
            __strong typeof(weakSelf) self = weakSelf;
            DictionaryThreadSecureDeleteObjectForKey(self->_lock, self->_taskDic, tid);//实验证明，此操作之后会释放task
        }
        if (completionHandler) {
            completionHandler(tid, responseObject, error);
        }
    }];
    
    return ThreadSecureSaveTask(_lock, _taskDic, task);
}

- (void)cancelTaskWithId:(TaskId)taskId
{
    NSURLSessionTask *task = _taskDic[taskId];
    if (task) {
        [task cancel];
        DictionaryThreadSecureDeleteObjectForKey(_lock, _taskDic, taskId);
    }
}

@end

//    NSLog(@"add task: %@, %ld", [aTask valueForKey:@"retainCount"], CFGetRetainCount((__bridge CFTypeRef)(aTask)));//查看引用计数的两种方式
