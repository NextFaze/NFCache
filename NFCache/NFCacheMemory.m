//
//  NFCacheMemory.m
//  NFCache
//
//  Created by Andrew Williams on 20/06/13.
//  Copyright (c) 2013 Andrew Williams. All rights reserved.
//

#import "NFCacheMemory.h"

@interface NFCacheMemory ()
@property (nonatomic, strong) NSMutableDictionary *dict;
@end

@implementation NFCacheMemory

- (id)init {
    self = [super init];
    if(self) {
        self.dict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)store:(id)key value:(id)value {
    @synchronized(self) {
        [self.dict setObject:value forKey:key];
    }
}

- (id)read:(id)key {
    @synchronized(self) {
        return [self.dict objectForKey:key];
    }
}

- (void)remove:(id)key {
    @synchronized(self) {
        [self.dict removeObjectForKey:key];
    }
}

@end
