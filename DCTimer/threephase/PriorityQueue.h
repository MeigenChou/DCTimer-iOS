//
//  PriorityQueue.h
//  DCTimer
//
//  Created by meigen on 15/10/31.
//
//

#import <Foundation/Foundation.h>
#import "FullCube.h"

@interface PriorityQueue : NSObject {
    int size;
}

@property (nonatomic, strong) NSMutableArray *queue;

-(int)size;
-(void)clear;
-(FullCube *)poll;
-(BOOL)add:(FullCube *)e;
-(NSMutableArray *)toArray;

@end
