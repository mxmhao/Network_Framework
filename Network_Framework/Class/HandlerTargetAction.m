//
//  HandlerTargetAction.m
//  Network_Framework
//
//  Created by min on 2018/10/14.
//  Copyright © 2018 mxm. All rights reserved.
//

#import "HandlerTargetAction.h"

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
