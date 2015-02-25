//
//  NFCacheBase.m
//  NFCache
//
//  Created by Andrew Williams on 19/06/13.
//  Copyright (c) 2013 Andrew Williams. All rights reserved.
//

#import "NFCacheBase.h"
#import <malloc/malloc.h>

@implementation NFCacheBase

- (id)init {
    self = [super init];
    if(self) {
        self.maximumSize = NFCacheBaseDefaultMaxSize;
    }
    return self;
}

- (void)store:(id)key value:(id)value {
    NSLog(@"Abstract method - this needs to be implemented by a subclass.");
    abort();
}

- (id)read:(id)key {
    NSLog(@"Abstract method - this needs to be implemented by a subclass.");
    abort();
}

- (void)remove:(id)key {
    NSLog(@"Abstract method - this needs to be implemented by a subclass.");
    abort();
}

- (void)clean {
    NSLog(@"Abstract method - this needs to be implemented by a subclass.");
    abort();
}

@end
