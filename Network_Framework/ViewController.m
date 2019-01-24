//
//  ViewController.m
//  Network_Framework
//
//  Created by mxm on 2018/2/27.
//  Copyright © 2018年 mxm. All rights reserved.
//

#import "ViewController.h"
#import "HandlerTargetAction.h"
#import "AFHTTPSessionManager+TargetAction.h"

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
    NSLog(@"handleSuccess:\n%@", [[NSString alloc] initWithData:re encoding:NSUTF8StringEncoding]);
}

- (void)handleFailure:(id)re
{
    NSLog(@"handleFailure:%@", re);
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
    _showView = [UIView new];
//    NSLog(@"%p", _showView);
//    UIButton *btn;
//    [btn addTarget:self action:@selector(inief) forControlEvents:UIControlEventAllEvents];
//    UIControlTargetAction
//    [FileAPIManager fetchFilesWithDirectoryPath:@"/admin" sorting:@"time" successHandle:[HandlerTargetAction target:_showView action:@selector(handleSuccess:)] failureHandle:[HandlerTargetAction target:_showView action:@selector(handleFailure:)] progress:nil];
//    _showView = nil;
    
//    [NSURL URLWithString:@"test" relativeToURL:[NSURL URLWithString:@"https://www.baidu.com/"]];
    
    [AFHTTPSessionManager.shareManager callGet:@"https://www.baidu.com" params:nil dataHandler:nil successHandler:[HandlerTargetAction target:_showView action:@selector(handleSuccess:)] failureHandler:[HandlerTargetAction target:_showView action:@selector(handleFailure:)] progress:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
