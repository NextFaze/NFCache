//
//  NFSDCache.m
//  NFCache
//
//  Created by Andrew Williams on 19/06/13.
//  Copyright (c) 2013 Andrew Williams. All rights reserved.
//

#import "NFCacheSD.h"
#import <CommonCrypto/CommonDigest.h>

@interface NFCacheSD ()
@property (nonatomic, assign) BOOL createdPath;
@end

@implementation NFCacheSD

- (NFCacheSize)fileSize:(NSString *)path {
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
    return [fileSizeNumber unsignedLongLongValue];
}

#pragma mark -

// store data on disk
// if type is NSData, store as raw bytes on disk.
// otherwise, use NSKeyedArchiver
- (void)store:(id)key value:(id)value {
    if(key == nil) return;
    
    [super store:key value:value];
    
    NSError *error = nil;
    if(!self.createdPath) {
        [[NSFileManager defaultManager] createDirectoryAtPath:self.path withIntermediateDirectories:YES attributes:nil error:&error];
        if(error) self.error = error;
        self.createdPath = YES;
    }
    
    NSString *path = [self cachePath:key];
    NFCacheSize originalSize = [self fileSize:path];
        
    if([value isKindOfClass:[NSData class]]) {
        // store on disk as bytes - so it can be read directly
        NSData *data = value;
        [data writeToFile:path atomically:YES];
    }
    else {
        [NSKeyedArchiver archiveRootObject:value toFile:path];
    }
    
    _size += [self fileSize:path] - originalSize;
    //NFLog(@"size: %lld", _size);
}

- (id)read:(id)key {
    if(key == nil) return nil;
    
    NSString *path = [self cachePath:key];
    NSData *data = nil;
    
    @try {
        data = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    }
    @catch (NSException *e) {
        // return raw data
        return [self readData:key];
    }
    
    return data;
}

- (NSData *)readData:(id)key {
    NSError *error = nil;
    NSString *path = [self cachePath:key];

    NSData *data = [NSData dataWithContentsOfFile:path options:0 error:&error];
    if(error) self.error = error;
    
    return data;
}

- (void)remove:(id)key {
    if(key == nil) return;
    
    [super remove:key];
    
    NSError *error = nil;
    NSString *path = [self cachePath:key];
    NFCacheSize size = [self fileSize:path];
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    if(error) self.error = error;
    
    _size -= size;
}

// delete cache
- (void)clear {
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:self.path error:&error];
    if(error) self.error = error;
    _size = 0;
}

#pragma mark -

- (NSString *)cachePath:(id)key {
    if(key == nil) return nil;
    
    NSString *keyPath = [self md5:key];
    NSString *path = [self.path stringByAppendingPathComponent:keyPath];
    return path;
}
 
- (NSString *)md5:(id)value
{
    NSData *valueData = [NSKeyedArchiver archivedDataWithRootObject:value];
    unsigned char r[CC_MD5_DIGEST_LENGTH + 1];
    NSMutableString *result = [NSMutableString stringWithCapacity:2 * CC_MD5_DIGEST_LENGTH];
    CC_MD5(valueData.bytes, valueData.length, r);

    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02x", r[i]];
    
    return result;
}

@end
