//
//  NFSDCache.h
//  NFCache
//
//  Created by Andrew Williams on 19/06/13.
//  Copyright (c) 2013 Andrew Williams. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NFCacheBase.h"

@interface NFCacheSD : NFCacheBase

@property (nonatomic, strong) NSString *path;

// return the path to data for the given key.
// if file exists, data has been cached
- (NSString *)cachePath:(id)key;

// read the cached data directly from the disk as NSData
- (NSData *)readData:(id)key;

@end
