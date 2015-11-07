//
//  Tower.m
//  DCTimer Solvers
//
//  Created by MeigenChou on 12-11-3.
//  Copyright (c) 2012年 MeigenChou. All rights reserved.
//

#import "Tower.h"
#import "Im.h"
#import "stdlib.h"
#import "time.h"

@interface Tower()
@property (nonatomic, strong) NSArray *turn;
@property (nonatomic, strong) NSArray *suff;
@property (nonatomic, strong) NSMutableString *sol;
@end

@implementation Tower
@synthesize turn, suff, sol;
unsigned short towCpm[40320][6];
unsigned short towEpm[24][6];
char towCpd[40320];
char towEpd[24];
char faces[] = {3,3,1,1,1,1};

- (Tower *) init {
    if(self = [super init]) {
        self.turn = [[NSArray alloc] initWithObjects:@"U", @"D", @"L", @"R", @"F", @"B", nil];
        self.suff = [[NSArray alloc] initWithObjects:@"'", @"2", @"", nil];
        [self initTower];
        srand((unsigned)time(0));
    }
    return self;
}

- (void) initTower {
    int arr[8];
    int i, j;
    for(i=0; i<40320; i++) {
        for(j=0; j<6; j++) {
            [Im set8Perm:arr i:i];
            switch (j) {
                case 0:
                    [Im cir:arr a:0 b:3 c:2 d:1]; break;    //U
                case 1:
                    [Im cir:arr a:4 b:5 c:6 d:7]; break;	//D
                case 2:
                    [Im cir2:arr a:0 b:7 c:3 d:4]; break;	//L
                case 3:
                    [Im cir2:arr a:1 b:6 c:2 d:5]; break;	//R
                case 4:
                    [Im cir2:arr a:3 b:6 c:2 d:7]; break;	//F
                case 5:
                    [Im cir2:arr a:0 b:5 c:1 d:4]; break;	//B
            }
            towCpm[i][j] = [Im get8Perm:arr];
        }
    }
    for(i=1; i<40320; i++) towCpd[i] = -1;
    towCpd[0] = 0;
    int c;
    for(int d=0; d<13; d++) {
        //c = 0;
        for(i=0; i<40320; i++)
            if(towCpd[i] == d)
                for(int k=0; k<6; k++) {
                    int y = i;
                    for(int m=0; m<faces[k]; m++) {
                        y = towCpm[y][k];
                        if(towCpd[y] < 0) {
                            towCpd[y] = d+1;
                            //c++;
                        }
                    }
                }
        //NSLog(@"%@", [NSString stringWithFormat:@"%d", c]);
    }
    
    for(i=0; i<24; i++) {
        for(j=0; j<6; j++) {
            if(j<2) towEpm[i][j]=i;
            else {
                [Im idxToPerm:arr i:i l:4];
                switch (j) {
                    case 2:
                        [Im cir:arr a:0 b:3]; break;	//L
                    case 3:
                        [Im cir:arr a:1 b:2]; break;	//R
                    case 4:
                        [Im cir:arr a:3 b:2]; break;	//F
                    case 5:
                        [Im cir:arr a:1 b:0]; break;	//B
                }
                towEpm[i][j] = [Im permToIdx:arr l:4];
            }
        }
    }
    
    for(i=1; i<24; i++) towEpd[i] = -1;
    towEpd[0] = 0;
    for(int d=0; d<4; d++) {
        c=0;
        for(i=0; i<24; i++) {
            if(towEpd[i] == d) {
                for(int k=2; k<6; k++) {
                    int next = towEpm[i][k];
                    if(towEpd[next] < 0) {
                        towEpd[next] = d+1;
                        c++;
                    }
                }
            }
        }
        //NSLog(@"%@", [NSString stringWithFormat:@"%d", c]);
    }
}

- (BOOL) searchTow: (int)cp ep:(int)ep d:(int)d lf:(int)lf {
    if(d==0) return cp==0 && ep==0;
    if(towCpd[cp]>d || towEpd[ep]>d)return NO;
    int y, s;
    for(int i=0; i<6; i++)
        if(i!=lf) {
            y=cp; s=ep;
            for(int k=0; k<faces[i]; k++) {
                y=towCpm[y][i]; s=towEpm[s][i];
                if([self searchTow:y ep:s d:(d-1) lf:i]){
                    [self.sol appendFormat:@"%@%@ ", [self.turn objectAtIndex:i], i<2 ? [self.suff objectAtIndex:k] : @"2"];
                    return YES;
                }
            }
        }
    return NO;
}

- (NSString *) scrTow {
    int cp = rand() % 40320;
    int ep = rand() % 24;
    self.sol = [NSMutableString string];
    for(int d=0; ![self searchTow:cp ep:ep d:d lf:-1]; d++);
    //NSLog(@"%@", s);
    return sol;
}
@end
