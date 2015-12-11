//
//  NSObject+GCD.h
//  CloudCamera
//
//  Created by mayuan on 15/6/10.
//  Copyright (c) 2015年 NetPower. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (GCD)

-(void) asyncTask:(dispatch_block_t)block;

//-(void) syncTask:(dispatch_block_t)block;

-(void) syncTaskOnMain:(dispatch_block_t)block;

-(void) asyncTask:(dispatch_block_t)block after:(NSTimeInterval)delay;

//-(void) syncTask:(dispatch_block_t)block after:(NSTimeInterval)delay;

-(void) syncTaskOnMain:(dispatch_block_t)block after:(NSTimeInterval)delay;

-(void) asyncTask:(dispatch_block_t)block returnOnMain:(dispatch_block_t)block2;

@end

void safe_dispatch_main_sync(dispatch_block_t block);

void safe_dispatch_main_async(dispatch_block_t block);