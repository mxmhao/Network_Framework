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
//#import <CoreFoundation/CoreFoundation.h>

/*
//测试内存释放
@interface NSURLSessionTask (Test)
- (void)dealloc;
@end
@implementation NSURLSessionTask (Test)
- (void)dealloc
{
    NSLog(@"NSURLSessionDataTask -- 释放: %p", self);
}
@end//*/

@implementation NetworkManager
{
    AFHTTPSessionManager *_manager;
    //保存任务，以便取消
    NSMutableDictionary<TaskId, NSURLSessionTask *> *_taskDic;
    XMLock _lock;
}

static NetworkManager *shareManager = nil;
+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [self new];
        //shareManager->_manager不会暴露到外面，所以一些定制参数在这里添加
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
        _manager.requestSerializer.timeoutInterval = 15;
        _taskDic = [NSMutableDictionary dictionaryWithCapacity:5];
        _lock = XM_CreateLock();
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
completionHandler:(void (^)(TaskId _Nonnull, id _Nullable, NSError * _Nullable))completionHandler
{
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];//测试
    __weak typeof(self) weakSelf = self;
    //这里必须用__block，不然下面block中的task可能为nil
    __block NSURLSessionDataTask *task = nil;
    task = [_manager GET:URLString parameters:parameters progress:downloadProgress completionHandler:^(NSURLResponse * _Nonnull response, id _Nullable responseObject, NSError * _Nullable error) {
        TaskId tid = @(task.taskIdentifier);
        if (completionHandler) {
            completionHandler(tid, responseObject, error);
        }
        __strong typeof(weakSelf) self = weakSelf;
        DictionaryThreadSecureDeleteObjectForKey(self->_lock, self->_taskDic, tid);//实验证明，此操作之后会释放task
    }];
    
    TaskId tid = @(task.taskIdentifier);
    DictionaryThreadSecureSetObjectForKey(_lock, _taskDic, tid, task);
    return tid;
}

- (TaskId)callHead:(NSString *)URLString parameters:(id)parameters completionHandler:(void (^)(TaskId _Nullable, NSURLResponse *, NSError * _Nullable))completionHandler
{
    __weak typeof(self) weakSelf = self;
    //这里必须用__block，不然下面block中的task可能为nil
    __block NSURLSessionDataTask *task = nil;
    task = [_manager HEAD:URLString parameters:parameters completionHandler:^(NSURLResponse * _Nonnull response, NSError * _Nullable error) {
        TaskId tid = @(task.taskIdentifier);
        if (completionHandler) {
            completionHandler(tid, response, error);
        }
        __strong typeof(weakSelf) self = weakSelf;
        DictionaryThreadSecureDeleteObjectForKey(self->_lock, self->_taskDic, tid);//实验证明，此操作之后会释放task
    }];
    
    TaskId tid = @(task.taskIdentifier);
    DictionaryThreadSecureSetObjectForKey(_lock, _taskDic, tid, task);
    return tid;
}

- (TaskId)callPost:(NSString *)URLString
            params:(nullable NSDictionary *)params
          progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
 completionHandler:(nullable void (^)(TaskId _Nullable taskId, id _Nullable responseObject, NSError * _Nullable error))completionHandler
{
    __weak typeof(self) weakSelf = self;
    __block NSURLSessionDataTask *task = nil;
    task = [_manager POST:URLString parameters:params progress:uploadProgress completionHandler:^(NSURLResponse *response, id _Nullable responseObject, NSError * _Nullable error) {
        TaskId tid = @(task.taskIdentifier);
        if (completionHandler) {
            completionHandler(tid, responseObject, error);
        }
        __strong typeof(weakSelf) self = weakSelf;
        DictionaryThreadSecureDeleteObjectForKey(self->_lock, self->_taskDic, tid);
    }];
    
    TaskId tid = @(task.taskIdentifier);
    DictionaryThreadSecureSetObjectForKey(_lock, _taskDic, tid, task);
    return tid;
}

- (TaskId)callPut:(NSString *)URLString parameters:(id)parameters completionHandler:(void (^)(TaskId _Nullable, id _Nullable, NSError * _Nullable))completionHandler
{
    __weak typeof(self) weakSelf = self;
    //这里必须用__block，不然下面block中的task可能为nil
    __block NSURLSessionDataTask *task = nil;
    task = [_manager PUT:URLString parameters:parameters completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        TaskId tid = @(task.taskIdentifier);
        if (completionHandler) {
            completionHandler(tid, responseObject, error);
        }
        __strong typeof(weakSelf) self = weakSelf;
        DictionaryThreadSecureDeleteObjectForKey(self->_lock, self->_taskDic, tid);//实验证明，此操作之后会释放task
    }];
    
    TaskId tid = @(task.taskIdentifier);
    DictionaryThreadSecureSetObjectForKey(_lock, _taskDic, tid, task);
    return tid;
}

- (TaskId)callPatch:(NSString *)URLString parameters:(id)parameters completionHandler:(void (^)(TaskId _Nullable, id _Nullable, NSError * _Nullable))completionHandler
{
    __weak typeof(self) weakSelf = self;
    //这里必须用__block，不然下面block中的task可能为nil
    __block NSURLSessionDataTask *task = nil;
    task = [_manager PATCH:URLString parameters:parameters completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        TaskId tid = @(task.taskIdentifier);
        if (completionHandler) {
            completionHandler(tid, responseObject, error);
        }
        __strong typeof(weakSelf) self = weakSelf;
        DictionaryThreadSecureDeleteObjectForKey(self->_lock, self->_taskDic, tid);//实验证明，此操作之后会释放task
    }];
    
    TaskId tid = @(task.taskIdentifier);
    DictionaryThreadSecureSetObjectForKey(_lock, _taskDic, tid, task);
    return tid;
}



- (TaskId)callDelete:(NSString *)URLString parameters:(id)parameters completionHandler:(void (^)(TaskId _Nullable, id _Nullable, NSError * _Nullable))completionHandler
{
    __weak typeof(self) weakSelf = self;
    //这里必须用__block，不然下面block中的task可能为nil
    __block NSURLSessionDataTask *task = nil;
    task = [_manager DELETE:URLString parameters:parameters completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        TaskId tid = @(task.taskIdentifier);
        if (completionHandler) {
            completionHandler(tid, responseObject, error);
        }
        __strong typeof(weakSelf) self = weakSelf;
        DictionaryThreadSecureDeleteObjectForKey(self->_lock, self->_taskDic, tid);//实验证明，此操作之后会释放task
    }];
    
    TaskId tid = @(task.taskIdentifier);
    DictionaryThreadSecureSetObjectForKey(_lock, _taskDic, tid, task);
    return tid;
}

//上传应该单独写一个工具类
/*
- (TaskId)callUpload:(NSString *)URLString
            params:(NSDictionary *)params
constructingBodyWithBlock:(nullable void (^)(id <AFMultipartFormData> formData))block
  progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
   completionHandler:(nullable void (^)(TaskId _Nullable taskId, id _Nullable responseObject, NSError * _Nullable error))completionHandler
{
    __weak typeof(self) weakSelf = self;
    __block NSURLSessionDataTask *task = nil;
    task = [_manager POST:URLString parameters:params constructingBodyWithBlock:block progress:uploadProgress completionHandler:^(NSURLResponse * _Nonnull response, id _Nullable responseObject, NSError * _Nullable error) {
        TaskId tid = @(task.taskIdentifier);
        if (completionHandler) {
            completionHandler(tid, responseObject, error);
        }
        __strong typeof(weakSelf) self = weakSelf;
        DictionaryThreadSecureDeleteObjectForKey(self->_lock, self->_taskDic, tid);
    }];
    
    TaskId tid = @(task.taskIdentifier);
    DictionaryThreadSecureSetObjectForKey(_lock, _taskDic, tid, task);
    return tid;
}//*/

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
