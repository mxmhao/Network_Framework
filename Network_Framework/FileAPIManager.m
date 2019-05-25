//
//  RequestManager.m
//  Network_Framework
//
//  Created by mxm on 2018/2/27.
//  Copyright © 2018年 mxm. All rights reserved.
//
//  此类主要是组装请求参数，同一模块在一个类中写多个类方法，多个模块写成多个类，这个主要是有开发者自己去发挥，此类只是一个例子

#import "FileAPIManager.h"
#import "AFHTTPSessionManager+TargetAction.h"

static NSString *const GetFilesAPI = @"api/getfilelist";
static NSString *const DeleteFileAPI = @"api/delete_file";
static NSString *const RenameFileAPI = @"api/rename_file";

@implementation FileAPIManager

+ (NSURLSessionDataTask *)fetchFilesWithDirectoryPath:(NSString *)path
                            sorting:(nullable NSString *)sorting
                      successHandle:(nullable XMTargetAction *)success
                      failureHandle:(nullable XMTargetAction *)failure
       progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
{
    //先检查参数是否正确
    //拼装参数
    NSDictionary *params = @{
        @"path": path,
        @"sort": sorting
    };
    //数据加密可以放在这里
    return [AFHTTPSessionManager.shareManager callPost:[DomainManager absoluteURLStringWithURLString:GetFilesAPI] params:params dataHandler:nil successHandler:success failureHandler:false progress:uploadProgress];
}

+ (NSURLSessionDataTask *)deleteFile:(NSString *)file successHandle:(XMTargetAction *)success failureHandle:(XMTargetAction *)failure
{
    NSDictionary *params = @{@"path": file};
    return [AFHTTPSessionManager.shareManager callPost:[DomainManager absoluteURLStringWithURLString:DeleteFileAPI] params:params dataHandler:nil successHandler:success failureHandler:failure progress:nil];
}

+ (NSURLSessionDataTask *)renameFile:(NSString *)oldName newName:(NSString *)newName successHandle:(XMTargetAction *)success failureHandle:(XMTargetAction *)failure
{
    NSDictionary *params = @{
        @"oldName": oldName,
        @"newName": newName
    };
    return [AFHTTPSessionManager.shareManager callPost:[DomainManager absoluteURLStringWithURLString:RenameFileAPI] params:params dataHandler:nil successHandler:success failureHandler:failure progress:nil];
}

@end
