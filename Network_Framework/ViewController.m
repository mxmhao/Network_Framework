//
//  ViewController.m
//  Network_Framework
//
//  Created by mxm on 2018/2/27.
//  Copyright © 2018年 mxm. All rights reserved.
//

#import "ViewController.h"
#import "NetworkManager.h"
#import "APIManager.h"

@interface UIView (Hander)

- (void)handleSuccess:(id)re;
- (void)handleFailure:(id)re;

@end

@implementation UIView (Hander)
- (void)dealloc
{
    NSLog(@"UIView -- 释放: %p", self);
}
- (void)handleSuccess:(id)re
{
    NSLog(@"\n%@", [[NSString alloc] initWithData:re encoding:NSUTF8StringEncoding]);
}

- (void)handleFailure:(id)re
{
    NSLog(@"%@", re);
}
@end

@interface ViewController ()
{
    UIView *_showView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    _showView = [UIView new];
//    NSLog(@"%p", _showView);
//    UIButton *btn;
//    [btn addTarget:self action:@selector(inief) forControlEvents:UIControlEventAllEvents];
//    UIControlTargetAction
//    [FileAPIManager fetchFilesWithDirectoryPath:@"/admin" sorting:@"time" successHandle:[HandlerTargetAction target:_showView action:@selector(handleSuccess:)] failureHandle:[HandlerTargetAction target:_showView action:@selector(handleFailure:)] progress:nil];
    
//    AFHTTPSessionManager *hsm = [AFHTTPSessionManager manager];
//    [hsm POST:@"" parameters:nil progress:nil success:nil failure:nil];
//    [hsm GET:@"" parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
//        //
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        //
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        //
//    }];
    
//    [[NetworkManager shareManager] callGet:@"https://www.baidu.com" parameters:nil progress:nil completionHandler:^(TaskId  _Nullable taskId, id  _Nullable responseObject, NSError * _Nullable error) {
//        NSLog(@"-->\n%@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
//    }];
    
//    [APIManager callGet:@"https://www.baidu.com" params:nil dataHandler:nil successHandler:[HandlerTargetAction target:_showView action:@selector(handleSuccess:)] failureHandler:[HandlerTargetAction target:_showView action:@selector(handleFailure:)] progress:nil];
//    _showView = nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
