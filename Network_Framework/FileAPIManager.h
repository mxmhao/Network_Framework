//
//  RequestManager.h
//  Network_Framework
//
//  Created by mxm on 2018/2/27.
//  Copyright © 2018年 mxm. All rights reserved.
//
//  组装请求参数，调用调用数据接口
//  同一个模块类的接口调用可以写在同一个类中（也可以按业务来分），方便维护
//  此类属于业务层了，由业务程序员去编写，下面的只是示例
//  本类一般由VC或者ViewModel调用

#import <Foundation/Foundation.h>
#import "DomainManager.h"

@class XMTargetAction;

NS_ASSUME_NONNULL_BEGIN

//类名改为FileService更适合
@interface FileAPIManager : NSObject

+ (NSURLSessionDataTask *)fetchFilesWithDirectoryPath:(NSString *)path
                                    sorting:(nullable NSString *)sorting
                              successHandle:(nullable XMTargetAction *)success
                              failureHandle:(nullable XMTargetAction *)failure
    progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress))uploadProgress;

+ (NSURLSessionDataTask *)deleteFile:(NSString *)file
             successHandle:(nullable XMTargetAction *)success
             failureHandle:(nullable XMTargetAction *)failure;

+ (NSURLSessionDataTask *)renameFile:(NSString *)oldName
                   newName:(NSString *)newName
             successHandle:(nullable XMTargetAction *)success
             failureHandle:(nullable XMTargetAction *)failure;

@end

NS_ASSUME_NONNULL_END
