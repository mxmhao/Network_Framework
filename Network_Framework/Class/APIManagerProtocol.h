//
//  APIManagerProtocol.h
//  Network_Framework
//
//  Created by min on 2018/10/14.
//  Copyright © 2018 mxm. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol APIManagerProtocol <NSObject>
/** 取消请求 */
- (void)cancel;
/** 重试 */
- (void)retry;
@end

typedef NS_ENUM(NSInteger, RetryTag) {
    RetryTagNone,
    RetryTagGet,
    RetryTagHead,
    RetryTagPost,
    RetryTagPut,
    RetryTagPatch,
    RetryTagDelete
};

NS_ASSUME_NONNULL_END
