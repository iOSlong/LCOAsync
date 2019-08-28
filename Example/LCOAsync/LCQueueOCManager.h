//
//  LCQueueOCManager.h
//  LCAsync
//
//  Created by lxw on 2019/8/2.
//  Copyright © 2019 lxw. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LCQueueOCManager : NSObject
- (void)dispatch_barrier_async:(void(^)(void))headTask barrierTask:(void(^)(void))barrierTask tailTask:(void(^)(void))tailTask;

- (void)dispatch_onceTask:(void(^)(void))onceTask;

@end

NS_ASSUME_NONNULL_END
