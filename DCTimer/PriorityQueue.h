//
//  PriorityQueue.h
//  DCTimer
//
//  Created by meigen on 14-12-9.
//
//

#import <Foundation/Foundation.h>

@interface PriorityQueue : NSObject {
    int size;
    int modCount;
}

-(void) poll;
-(void) clearQueue;

@end
