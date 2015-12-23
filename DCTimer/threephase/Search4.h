//
//  Search4.h
//  DCTimer
//
//  Created by meigen on 15/10/30.
//
//

#import <Foundation/Foundation.h>
#import "FullCube.h"
#import "Center2.h"
#import "Center3.h"
#import "Edge3.h"
#import "Search.h"
#import "PriorityQueue.h"

@interface Search4 : NSObject {
    int move1[15];
    int move2[20];
    int move3[20];
    int length1;
    int length2;
    int maxlength2;
    bool add1;
    int valid1;
    int p1SolsCnt;
}

@property (nonatomic, strong) FullCube *c;
@property (nonatomic, strong) FullCube *c1;
@property (nonatomic, strong) FullCube *c2;
@property (nonatomic, strong) Center2 *ct2;
@property (nonatomic, strong) Center3 *ct3;
@property (nonatomic, strong) Edge3 *e12;
@property (nonatomic, strong) Search *cube3;
@property (nonatomic, strong) NSMutableArray *tempe;
@property (nonatomic, strong) NSString *solution;
@property (nonatomic, strong) NSMutableArray *arr2;
@property (nonatomic, strong) PriorityQueue *p1sols;

+(void)initTable;
-(NSString *)randomState;

@end
