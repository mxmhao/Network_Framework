//
//  ViewController.m
//  Network_Framework
//
//  Created by mxm on 2018/2/27.
//  Copyright © 2018年 mxm. All rights reserved.
//

#import "ViewController.h"
#import "XMTargetAction.h"
#import "AFHTTPSessionManager+TargetAction.h"

@interface UIView (Hander)

- (void)handleGetSuccess:(id)re;
- (void)handleHeadSuccess:(NSHTTPURLResponse *)re;
- (void)handleFailure:(id)re;

@end

@implementation UIView (Hander)
- (void)dealloc
{
    NSLog(@"UIView -- 释放: %p", self);
}

- (void)handleHeadSuccess:(NSHTTPURLResponse *)re
{
//    NSLog(@"handleSuccess:\n%@", [[NSString alloc] initWithData:re encoding:NSUTF8StringEncoding]);
    NSLog(@"handleSuccess:\n%@", re.allHeaderFields);
}

- (void)handleGetSuccess:(id)re
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
//    [FileAPIManager fetchFilesWithDirectoryPath:@"/admin" sorting:@"time" successHandle:[HandlerTargetAction target:_showView action:@selector(handleSuccess:)] failureHandle:[HandlerTargetAction target:_showView action:@selector(handleFailure:)] progress:nil];
//    _showView = nil;
    
    NSLog(@"%@", [NSURL URLWithString:@"/test" relativeToURL:[NSURL URLWithString:@"https://www.baidu.com/wokao/"]].absoluteString);
    
    [AFHTTPSessionManager.shareManager callHead:@"https://www.baidu.com" params:nil successHandler:XMCreateTA(_showView, @selector(handleHeadSuccess:)) failureHandler:XMCreateTA(_showView, @selector(handleFailure:))];
    
    [AFHTTPSessionManager.shareManager callGet:@"https://www.baidu.com" params:nil dataHandler:nil successHandler:[XMTargetAction target:_showView action:@selector(handleGetSuccess:)] failureHandler:[XMTargetAction target:_showView action:@selector(handleFailure:)] progress:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
