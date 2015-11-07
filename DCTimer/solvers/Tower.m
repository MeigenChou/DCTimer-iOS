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
unsigned short twrCpm[40320][4];
unsigned short twrEpm[6][4];
char twrCpd[40320];
char twrEpd[6];
int twrFaces[] = {3, 1, 1, 3};

- (Tower *) init {
    if(self = [super init]) {
        self.turn = [[NSArray alloc] initWithObjects:@"U", @"R", @"F", @"D", nil];
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
        for(j=0; j<4; j++) {
            [Im set8Perm:arr i:i];
            switch (j) {
                case 0:
                    [Im cir:arr a:0 b:3 c:2 d:1]; break;    //U
                case 3:
                    [Im cir:arr a:4 b:5 c:6 d:7]; break;	//D
                case 1:
                    [Im cir2:arr a:1 b:6 c:2 d:5]; break;	//R2
                case 2:
                    [Im cir2:arr a:3 b:6 c:2 d:7]; break;	//F2
            }
            twrCpm[i][j] = [Im get8Perm:arr];
        }
    }
    for(i=1; i<40320; i++) twrCpd[i] = -1;
    twrCpd[0] = 0;
    //int c = 1;
    for(int d=0; d<13; d++) {
        for(i=0; i<40320; i++) {
            //if(i % 403 == 0) NSLog(@"%d", i/403);
            if(twrCpd[i] == d)
                for(int k=0; k<4; k++) {
                    int y = i;
                    for(int m=0; m<twrFaces[k]; m++) {
                        y = twrCpm[y][k];
                        if(twrCpd[y] < 0) {
                            twrCpd[y] = d+1;
                            //c++;
                        }
                    }
                }
        }
        //NSLog(@"%d %d", d+1, c);
    }
    
    for(i=0; i<6; i++) {
        for(j=0; j<4; j++) {
            [Im idxToPerm:arr i:i l:3];
            switch (j) {
                case 1:
                    [Im cir:arr a:0 b:1]; break;	//R2
                case 2:
                    [Im cir:arr a:1 b:2]; break;	//F2
            }
            twrEpm[i][j] = [Im permToIdx:arr l:3];
        }
    }
    
    for(i=1; i<6; i++) twrEpd[i] = -1;
    twrEpd[0] = 0;
    //c = 1;
    for(int d=0; d<3; d++) {
        for(i=0; i<6; i++) {
            if(twrEpd[i] == d) {
                for(int k=1; k<3; k++) {
                    int next = twrEpm[i][k];
                    if(twrEpd[next] < 0) {
                        twrEpd[next] = d+1;
                        //c++;
                    }
                }
            }
        }
        //NSLog(@"%@", [NSString stringWithFormat:@"%d %d", d+1, c]);
    }
}

- (BOOL) search: (int)cp ep:(int)ep d:(int)d lf:(int)lf {
    if(d==0) return cp==0 && ep==0;
    if(twrCpd[cp]>d || twrEpd[ep]>d)return NO;
    int y, s;
    for(int i=0; i<4; i++)
        if(i!=lf) {
            y=cp; s=ep;
            for(int k=0; k<twrFaces[i]; k++) {
                y=twrCpm[y][i]; s=twrEpm[s][i];
                if([self search:y ep:s d:(d-1) lf:i]){
                    [self.sol appendFormat:@"%@%@ ", [self.turn objectAtIndex:i], twrFaces[i]==3 ? [self.suff objectAtIndex:k] : @"2"];
                    return YES;
                }
            }
        }
    return NO;
}

- (NSString *) scramble {
    int cp = rand() % 40320;
    int ep = rand() % 6;
    self.sol = [NSMutableString string];
    for(int d=0; ![self search:cp ep:ep d:d lf:-1]; d++);
    //NSLog(@"%@", s);
    return sol;
}
@end
