//
//  PriorityQueue.h
//  DCTimer
//
//  Created by meigen on 14-12-9.
//
//

#import <Foundation/Foundation.h>
#import "FullCube.h"

@interface PriorityQueue : NSObject

@property (strong, nonatomic) NSMutableArray *queue;

-(void) clear;
-(NSMutableArray *) toArray;
-(int) size;
-(FullCube *) poll;
-(BOOL) add:(FullCube *)e;

@end
