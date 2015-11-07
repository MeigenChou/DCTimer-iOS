//
//  PriorityQueue.m
//  DCTimer
//
//  Created by meigen on 14-12-9.
//
//

#import "PriorityQueue.h"

@interface PriorityQueue()
@property (strong, nonatomic) NSMutableArray *queue;
@end

@implementation PriorityQueue
@synthesize queue;

-(id) init {
    if (self = [super init]) {
        size = 0;
        modCount = 0;
        queue = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) clearQueue {
    modCount++;
    queue = [[NSMutableArray alloc] init];
    size = 0;
}
@end
