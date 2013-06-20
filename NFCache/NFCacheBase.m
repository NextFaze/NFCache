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
    
}

- (id)read:(id)key {
    return nil;
}

- (void)remove:(id)key {
}

@end
