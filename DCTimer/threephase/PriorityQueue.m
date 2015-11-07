//
//  PriorityQueue.m
//  DCTimer
//
//  Created by meigen on 14-12-9.
//
//

#import "PriorityQueue.h"
#import "FullCube.h"

@implementation PriorityQueue
@synthesize queue;

-(id) init {
    if (self = [super init]) {
        queue = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) clear {
    [queue removeAllObjects];
}

-(NSMutableArray *) toArray {
    return queue;
}

-(int) size {
    return (int)queue.count;
}

-(FullCube *) poll {
    if (queue.count == 0) {
        return nil;
    }
    int s = (int)queue.count - 1;
    FullCube *res = (FullCube *)[queue objectAtIndex:0];
    FullCube *x = (FullCube *)[queue objectAtIndex:s];
    [queue removeObjectAtIndex:s];
    if (s != 0)
        [self siftDown:0 x:x];
    return res;
}

-(void) siftDown:(int)k x:(FullCube *)x {
    int half = (int)queue.count >> 1;
    while (k < half) {
        int child = (k << 1) + 1;
        FullCube *c = (FullCube *)[queue objectAtIndex:child];
        int right = child + 1;
        FullCube *cr = (FullCube *)[queue objectAtIndex:right];
        if (right < queue.count && [c compareTo:cr] > 0)
            c = (FullCube *)[queue objectAtIndex:(child = right)];
        if ([x compareTo:c] <= 0)
            break;
        [queue replaceObjectAtIndex:k withObject:c];
        k = child;
    }
    [queue replaceObjectAtIndex:k withObject:x];
}

-(BOOL) add:(FullCube *)e {
    if (e == nil) {
        return NO;
    }
    int i = (int)queue.count;
    if (i == 0)
        [queue addObject:e];
    else
        [self siftUp:i x:e];
    return YES;
}

-(void) siftUp:(int)k x:(FullCube *)x {
    while (k > 0) {
        int parent = (k - 1) >> 1;
        FullCube *e = (FullCube *)[queue objectAtIndex:parent];
        if ([x compareTo:e] >= 0)
            break;
        if (k >= queue.count)
            [queue addObject:e];
        else [queue replaceObjectAtIndex:k withObject:e];
        k = parent;
    }
    if (k >= queue.count)
        [queue addObject:x];
    else [queue replaceObjectAtIndex:k withObject:x];
}

@end
