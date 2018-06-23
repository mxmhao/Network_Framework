//
//  RequestManager.m
//  Network_Framework
//
//  Created by mxm on 2018/2/27.
//  Copyright © 2018年 mxm. All rights reserved.
//
//  此类主要是组装请求参数，同一模块在一个类中写多个类方法，多个模块写成多个类，这个主要是有开发者自己去发挥，此类只是一个例子，此类相当于mvvm中的ViewModel

#import "FileAPIManager.h"

static NSString *const GetFilesAPI = @"api/getfilelist";
static NSString *const DeleteFileAPI = @"api/delete_file";
static NSString *const RenameFileAPI = @"api/rename_file";

@implementation FileAPIManager

+ (APIManager *)fetchFilesWithDirectoryPath:(NSString *)path
                            sorting:(nullable NSString *)sorting
                      successHandle:(nullable HandlerTargetAction *)success
                      failureHandle:(nullable HandlerTargetAction *)failure
       progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
{
    //先检查参数是否正确
    //拼装参数
    NSDictionary *params = @{
        @"path": path,
        @"sort": sorting
    };
    NSMutableDictionary *par = [NSMutableDictionary dictionaryWithObjectsAndKeys:
        path, @"path",
        sorting, @"sort",
    nil];
    return [APIManager callPost:GetFilesAPI params:params dataHandler:nil successHandler:success failureHandler:false progress:uploadProgress];
}

+ (APIManager *)deleteFile:(NSString *)file successHandle:(HandlerTargetAction *)success failureHandle:(HandlerTargetAction *)failure
{
    NSDictionary *params = @{@"path": file};
    NSMutableDictionary *par = [NSMutableDictionary dictionaryWithObjectsAndKeys:file, @"path", nil];
    return [APIManager callPost:DeleteFileAPI params:params dataHandler:nil successHandler:success failureHandler:failure progress:nil];
}

+ (APIManager *)renameFile:(NSString *)oldName newName:(NSString *)newName successHandle:(HandlerTargetAction *)success failureHandle:(HandlerTargetAction *)failure
{
    NSDictionary *params = @{
                             @"oldName": oldName,
                             @"newName": newName
                             };
    NSMutableDictionary *par = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                oldName, @"oldName",
                                newName, @"newName",
                                nil];
    return [APIManager callPost:RenameFileAPI params:params dataHandler:nil successHandler:success failureHandler:failure progress:nil];
}

@end
