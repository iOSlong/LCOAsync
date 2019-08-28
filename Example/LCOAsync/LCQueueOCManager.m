//
//  LCQueueOCManager.m
//  LCAsync
//
//  Created by lxw on 2019/8/2.
//  Copyright © 2019 lxw. All rights reserved.
//

#import "LCQueueOCManager.h"

@implementation LCQueueOCManager

#pragma mark 8. barrier_async
/**
 * 栅栏方法 dispatch_barrier_async
 * 在执行完栅栏前面的操作之后，才执行栅栏操作，最后再执行栅栏后边的操作。
 */
- (void)dispatch_barrier_async:(void(^)(void))headTask barrierTask:(void(^)(void))barrierTask tailTask:(void(^)(void))tailTask{
    dispatch_queue_t queue = dispatch_queue_create("net.my.testQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, headTask);
    
//    dispatch_async(queue, barrierTask); //打开对比效果。
    dispatch_barrier_async(queue,barrierTask);
    
    dispatch_async(queue, tailTask);
}
/**
 * 一次性代码（只执行一次）dispatch_once
 */
- (void)dispatch_onceTask:(void(^)(void))onceTask {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
            // 只执行1次的代码(这里面默认是线程安全的)
        onceTask();
    });
}

@end
