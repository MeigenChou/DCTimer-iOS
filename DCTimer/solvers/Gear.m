//
//  Gear.m
//  DCTimer solvers
//
//  Created by MeigenChou on 13-3-3.
//  Copyright (c) 2013年 MeigenChou. All rights reserved.
//

#import "Gear.h"
#import "Im.h"
#import "stdlib.h"
#import "time.h"

@interface Gear ()
@property (nonatomic, strong) NSArray *turn;
@property (nonatomic, strong) NSArray *suff;
@property (nonatomic, strong) NSMutableString *sol;
@end

@implementation Gear
@synthesize turn, suff, sol;

-(void) initGear {
    int arr[4];
    for(int i = 0; i < 24; i++) {
        for(int j = 0; j < 3; j++) {
            [Im idxToPerm:arr i:i l:4];
            [Im cir:arr a:3 b:j];
            cpm[i][j] = [Im permToIdx:arr l:4];
        }
    }
    for(int i = 0; i < 24; i++){
        for(int j = 0; j < 3; j++){
            [Im idxToPerm:arr i:i l:4];
            switch(j){
				case 0: [Im cir:arr a:0 b:3 c:2 d:1]; break;
				case 1: [Im cir:arr a:0 b:1]; break;
				case 2: [Im cir:arr a:1 b:2]; break;
            }
            epm[i][j] = [Im permToIdx:arr l:4];
        }
    }
    //arr = new int[3];
    for(int i = 0; i < 27; i++){
        for(int j = 0; j < 3; j++){
            [Im idxToOri:arr i:i n:3 l:3];
            arr[j] = (arr[j] + 1) % 3;
            eom[i][j] = [Im oriToIdx:arr n:3 l:3];
        }
    }
    //int n;
    for (int i = 0; i < 3; i++) {
        for(int j = 1; j < 576; j++)pd[i][j] = -1;
        pd[i][0] = 0;
        for(int d = 0; d < 5; d++) {
            //n = 0;
            for(int j = 0; j < 576; j++)
                if(pd[i][j] == d)
                    for (int k = 0; k < 3; k++) {
                        int p = j;
                        for (int m = 0; m < 11; m++) {
                            int e = p % 24;
                            p = p / 24;
                            p = cpm[p][k];
                            e = epm[e][(k + i) % 3];
                            p = 24 * p + e;
                            if(pd[i][p] == -1){
                                pd[i][p] = d + 1;
                                //n++;
                            }
                        }
                    }
            //System.out.println(d+" "+n);
        }
    }
}

-(id) init {
    if(self = [super init]) {
        self.turn = [[NSArray alloc] initWithObjects:@"U", @"R", @"F", nil];
        self.suff = [[NSArray alloc] initWithObjects:@"'", @"2'", @"3'", @"4'", @"5'", @"6", @"5", @"4", @"3", @"2", @"", nil];
        [self initGear];
        srand((unsigned)time(0));
    }
    return self;
}

-(BOOL) search:(int)cp ep1:(int)ep1 ep2:(int)ep2 ep3:(int)ep3 eo:(int)eo d:(int)d l:(int)l {
    if (d == 0) return cp == 0 && ep1 == 0 && ep2 == 0 && ep3 == 0 && eo == 0;
    if (MAX(MAX(pd[0][24 * cp + ep1], pd[1][24 * cp + ep2]), pd[2][24 * cp + ep3]) > d) return NO;
    for (int n = 0; n < 3; n++)
        if (n != l) {
            int cn = cp, e1n = ep1, e2n = ep2, e3n = ep3, en = eo;
            for (int m = 0; 11 > m; m++){
                cn = cpm[cn][n]; e1n = epm[e1n][n]; e2n = epm[e2n][(n + 1) % 3];
                e3n = epm[e3n][(n + 2) % 3]; en = eom[en][n];
                if ([self search:cn ep1:e1n ep2:e2n ep3:e3n eo:en d:d-1 l:n]){
                    [self.sol appendFormat:@"%@%@ ", [self.turn objectAtIndex:n], [self.suff objectAtIndex:m]];
                    return YES;
                }
            }
        }
    return NO;
}

-(NSString *) scramble {
    int cp = rand()%24;
    int ep[3];
    for(int i = 0; i < 3; i++){
        do ep[i] = rand()%24;
        while (pd[i][24 * cp + ep[i]] < 0);
    }
    int eo = rand()%27;
    self.sol = [NSMutableString string];
    for (int d = 4; d<7; d++) {
        if([self search:cp ep1:ep[0] ep2:ep[1] ep3:ep[2] eo:eo d:d l:-1]) {
            return self.sol;
        }
    }
    return @"";
}

@end
