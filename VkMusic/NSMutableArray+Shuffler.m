//
//  NSMutableArray+Shuffler.m
//  VkMusic
//
//  Created by keepcoder on 21.04.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "NSMutableArray+Shuffler.h"

@implementation NSMutableArray (Shuffler)
- (void)shuffle
{
    NSUInteger count = [self count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = count - i;
        NSInteger n = (arc4random() % nElements) + i;
        [self exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}
@end
