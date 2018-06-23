//
//  RequestManager.h
//  Network_Framework
//
//  Created by mxm on 2018/2/27.
//  Copyright © 2018年 mxm. All rights reserved.
//
//  组装请求参数，调用调用数据接口
//  同一个模块类的接口调用可以写在同一个类中（也可以按业务来分），方便维护
//  此类属于业务层了，由业务程序员去按下面的示例去编写了

#import <Foundation/Foundation.h>
#import "APIManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface FileAPIManager : NSObject

+ (APIManager *)fetchFilesWithDirectoryPath:(NSString *)path
                                    sorting:(nullable NSString *)sorting
                              successHandle:(nullable HandlerTargetAction *)success
                              failureHandle:(nullable HandlerTargetAction *)failure
    progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress))uploadProgress;

+ (APIManager *)deleteFile:(NSString *)file
             successHandle:(nullable HandlerTargetAction *)success
             failureHandle:(nullable HandlerTargetAction *)failure;

+ (APIManager *)renameFile:(NSString *)oldName
                   newName:(NSString *)newName
             successHandle:(nullable HandlerTargetAction *)success
             failureHandle:(nullable HandlerTargetAction *)failure;

@end

NS_ASSUME_NONNULL_END
