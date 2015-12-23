//
//  PriorityQueue.m
//  DCTimer
//
//  Created by meigen on 15/10/31.
//
//

#import "PriorityQueue.h"
#import "FullCube.h"

@implementation PriorityQueue
@synthesize queue;

-(id) init {
    if (self = [super init]) {
        queue = [[NSMutableArray alloc] init];
        size = 0;
    }
    return self;
}

-(void) clear {
    [queue removeAllObjects];
    size = 0;
}

-(NSMutableArray *)toArray {
    if (queue.count > size) {
        for (int i=size; i<queue.count; i++)
            [queue removeObjectAtIndex:i];
    }
    return queue;
}

-(int)size {
    return size;
}

-(FullCube *) poll {
    if (queue.count == 0) {
        return nil;
    }
    int s = --size;
    FullCube *res = [queue objectAtIndex:0];
    FullCube *x = [queue objectAtIndex:s];
    int half = s >> 1;
    int k = 0;
    while(half > k) {
        int child = (k << 1) + 1;
        FullCube *c = [queue objectAtIndex:child];
        int right = child + 1;
        FullCube *cr = [queue objectAtIndex:right];
        if (right < s && c->value < cr->value)
            c = [queue objectAtIndex:(child = right)];
        if (x->value >= c->value) break;
        [queue replaceObjectAtIndex:k withObject:c];
        k = child;
    }
    [queue replaceObjectAtIndex:k withObject:x];
    return res;
}

-(BOOL) add:(FullCube *)x {
    if (x == nil) {
        return NO;
    }
    int k = size;
    if (k == 0)
        [queue addObject:x];
    else {
        while (k > 0) {
            int parent = (k - 1) >> 1;
            FullCube *e = [queue objectAtIndex:parent];
            if(x->value <= e->value) break;
            if (k >= queue.count)
                [queue addObject:e];
            else [queue replaceObjectAtIndex:k withObject:e];
            k = parent;
        }
        if (k >= queue.count)
            [queue addObject:x];
        else [queue replaceObjectAtIndex:k withObject:x];
    }
    size++;
    return YES;
}
@end
