//
//  NFCacheBase.h
//  NFCache
//
//  Created by Andrew Williams on 19/06/13.
//  Copyright (c) 2013 Andrew Williams. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NFCacheBaseDefaultMaxSize (1024 * 1024 * 1024)  // 1 GB
#define NFCacheBaseDefaultMaxAge (60 * 60 * 24 * 7)  // 1 week

typedef unsigned long long NFCacheSize;

@interface NFCacheBase : NSObject {
    NFCacheSize _size;
}


/**
 * The maximum size of the cache, in bytes.
 */
@property (assign, nonatomic) NFCacheSize maxCacheSize;

@property (nonatomic, readonly) NFCacheSize size;

/**
 * The maximum length of time to keep a file in the cache, in seconds.
 */
@property (nonatomic, assign) NSInteger maxCacheAge;

@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, strong) NSError *error;

- (void)store:(id)key value:(id<NSCoding>)value;
- (id)read:(id)key;
- (void)remove:(id)key;
- (void)clean;

@end
