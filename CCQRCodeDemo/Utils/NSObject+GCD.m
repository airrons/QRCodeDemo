//
//  NSObject+GCD.m
//  CloudCamera
//
//  Created by mayuan on 15/6/10.
//  Copyright (c) 2015年 NetPower. All rights reserved.
//

#import "NSObject+GCD.h"

@implementation NSObject (GCD)

-(void)asyncTask:(dispatch_block_t)block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

//-(void)syncTask:(dispatch_block_t)block {
//    dispatch_async(dispatch_get_current_queue(), block);
//}

-(void)syncTaskOnMain:(dispatch_block_t)block {
    dispatch_async(dispatch_get_main_queue(), block);
}

-(void) asyncTask:(dispatch_block_t)block after:(NSTimeInterval)delay {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC),
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

//-(void) syncTask:(dispatch_block_t)block after:(NSTimeInterval)delay {
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC),
//                   dispatch_get_current_queue(), block);
//}

-(void) syncTaskOnMain:(dispatch_block_t)block after:(NSTimeInterval)delay {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC),
                   dispatch_get_main_queue(), block);
}

-(void)asyncTask:(dispatch_block_t)block returnOnMain:(dispatch_block_t)block2 {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        block();
        dispatch_async(dispatch_get_main_queue(), block2);
    });
    
}

@end

void safe_dispatch_main_sync(dispatch_block_t block) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

void safe_dispatch_main_async(dispatch_block_t block) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}
