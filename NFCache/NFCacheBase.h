//
//  NFCacheBase.h
//  NFCache
//
//  Created by Andrew Williams on 19/06/13.
//  Copyright (c) 2013 Andrew Williams. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NFCacheBaseDefaultMaxSize (1024 * 1024 * 1024)  // 1 GB

typedef unsigned long long NFCacheSize;

@interface NFCacheBase : NSObject {
    NFCacheSize _size;
}

@property (nonatomic, assign) NFCacheSize  maximumSize;
@property (nonatomic, readonly) NFCacheSize size;
@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, strong) NSError *error;

- (void)store:(id)key value:(id<NSCoding>)value;
- (id)read:(id)key;
- (void)remove:(id)key;

@end
