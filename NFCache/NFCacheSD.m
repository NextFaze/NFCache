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
        
    NSError *error = nil;
    NSString *path = [self cachePath:key];
    NFCacheSize size = [self fileSize:path];
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    if(error) self.error = error;
    
    _size -= size;
}

- (void)clean {
    // copied from SDWebImage cleanDisk
    // https://github.com/rs/SDWebImage
    
    NSURL *diskCacheURL = [NSURL fileURLWithPath:self.path isDirectory:YES];
    NSArray *resourceKeys = @[NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey];
    
    NSFileManager *fileManager = [NSFileManager new];
    
    // This enumerator prefetches useful properties for our cache files.
    NSDirectoryEnumerator *fileEnumerator = [fileManager enumeratorAtURL:diskCacheURL
                                              includingPropertiesForKeys:resourceKeys
                                                                 options:NSDirectoryEnumerationSkipsHiddenFiles
                                                            errorHandler:NULL];
    
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-self.maxCacheAge];
    NSMutableDictionary *cacheFiles = [NSMutableDictionary dictionary];
    NSUInteger currentCacheSize = 0;
    
    // Enumerate all of the files in the cache directory.  This loop has two purposes:
    //
    //  1. Removing files that are older than the expiration date.
    //  2. Storing file attributes for the size-based cleanup pass.
    NSMutableArray *urlsToDelete = [[NSMutableArray alloc] init];
    for (NSURL *fileURL in fileEnumerator) {
        NSDictionary *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:NULL];
        
        // Skip directories.
        if ([resourceValues[NSURLIsDirectoryKey] boolValue]) {
            continue;
        }
        
        // Remove files that are older than the expiration date;
        NSDate *modificationDate = resourceValues[NSURLContentModificationDateKey];
        if ([[modificationDate laterDate:expirationDate] isEqualToDate:expirationDate]) {
            [urlsToDelete addObject:fileURL];
            continue;
        }
        
        // Store a reference to this file and account for its total size.
        NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
        currentCacheSize += [totalAllocatedSize unsignedIntegerValue];
        [cacheFiles setObject:resourceValues forKey:fileURL];
    }
    
    for (NSURL *fileURL in urlsToDelete) {
        [fileManager removeItemAtURL:fileURL error:nil];
    }
    
    // If our remaining disk cache exceeds a configured maximum size, perform a second
    // size-based cleanup pass.  We delete the oldest files first.
    if (self.maxCacheSize > 0 && currentCacheSize > self.maxCacheSize) {
        // Target half of our maximum cache size for this cleanup pass.
        const NSUInteger desiredCacheSize = self.maxCacheSize / 2;
        
        // Sort the remaining cache files by their last modification time (oldest first).
        NSArray *sortedFiles = [cacheFiles keysSortedByValueWithOptions:NSSortConcurrent
                                                        usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                                            return [obj1[NSURLContentModificationDateKey] compare:obj2[NSURLContentModificationDateKey]];
                                                        }];
        
        // Delete files until we fall below our desired cache size.
        for (NSURL *fileURL in sortedFiles) {
            if ([fileManager removeItemAtURL:fileURL error:nil]) {
                NSDictionary *resourceValues = cacheFiles[fileURL];
                NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
                currentCacheSize -= [totalAllocatedSize unsignedIntegerValue];
                
                if (currentCacheSize < desiredCacheSize) {
                    break;
                }
            }
        }
    }
    
    _size = currentCacheSize;
}

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
    CC_MD5(valueData.bytes, (CC_LONG) valueData.length, r);

    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02x", r[i]];
    
    return result;
}

@end
