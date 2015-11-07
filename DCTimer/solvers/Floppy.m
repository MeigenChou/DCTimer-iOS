//
//  Floppy.m
//  DCTimer solvers
//
//  Created by MeigenChou on 13-3-14.
//  Copyright (c) 2013年 MeigenChou. All rights reserved.
//

#import "Floppy.h"
#import "Im.h"
#import "stdlib.h"
#import "time.h"

@interface Floppy ()
@property (nonatomic, strong) NSArray *turn;
@end

@implementation Floppy
@synthesize turn;
char distance[24][16];

- (void) cornMove:(int[])cp m:(int)m {
    switch (m) {
        case 0:
            [Im cir:cp a:0 b:1]; break;
        case 1:
            [Im cir:cp a:1 b:2]; break;
        case 2:
            [Im cir:cp a:2 b:3]; break;
        case 3:
            [Im cir:cp a:0 b:3]; break;
    }
}

- (void) initf {
    for (int i = 0; i < 24; i++)
        for (int j = 0; j < 16; j++)
            distance[i][j] = -1;
    distance[0][0] = 0;
    int nVisited = 1;
    int depth = 0;
    int cp[4];
    int eo[4];
    while (nVisited > 0) {
        nVisited = 0;
        for (int i = 0; i < 24; i++)
            for (int j = 0; j < 16; j++)
                if (distance[i][j] == depth)
                    for(int k=0; k<4; k++) {
                        [Im idxToPerm:cp i:i l:4];
                        [Im idxToOri:eo i:j n:2 l:4];
                        [self cornMove:cp m:k];
                        eo[k] ^= 1;
                        int cpi = [Im permToIdx:cp l:4];
                        int eoi = [Im oriToIdx:eo n:2 l:4];
                        if (distance[cpi][eoi] == -1) {
                            distance[cpi][eoi] = depth + 1;
                            nVisited++;
                        }
                    }
        depth++;
    }
}

- (id) init {
    if(self = [super init]) {
        self.turn = [[NSArray alloc] initWithObjects:@"U ", @"R ", @"D ", @"L ", nil];
        [self initf];
        srand((unsigned)time(0));
    }
    return self;
}

- (NSString *) scrFlopy {
    for (;;) {
        int cpi = rand()%24;
        int eoi = rand()%16;
        if (distance[cpi][eoi] > 0) {
            NSMutableString *sb = [NSMutableString string];
            while(distance[cpi][eoi] != 0) {
                int cp[4];
                int eo[4];
                for (int i=0; i<4; i++) {
                    [Im idxToPerm:cp i:cpi l:4];
                    [Im idxToOri:eo i:eoi n:2 l:4];
                    [self cornMove:cp m:i];
                    eo[i] ^= 1;
                    int nextCpi = [Im permToIdx:cp l:4];
                    int nextEoi = [Im oriToIdx:eo n:2 l:4];
                    if (distance[nextCpi][nextEoi] == distance[cpi][eoi] - 1) {
                        [sb insertString:[self.turn objectAtIndex:i] atIndex:0];
                        cpi = nextCpi;
                        eoi = nextEoi;
                        break;
                    }
                }
            }
            return sb;
        }
    }
}

@end
