//
//  Skewb.m
//  DCTimer solvers
//
//  Created by MeigenChou on 13-2-20.
//  Copyright (c) 2013年 MeigenChou. All rights reserved.
//

#import "Skewb.h"
#import "DCTUtils.h"
#import "Util.h"
#import "stdlib.h"
#import "time.h"

@interface Skewb ()
@property (nonatomic, strong) NSArray *turn;
@property (nonatomic, strong) NSArray *suf;
@property (nonatomic, strong) NSMutableString *sol;
@end

@implementation Skewb
@synthesize turn, suf, sol;

-(void) initSkb {
    int arr[7];
    int i, j, k;
    // move tables
    for (i=0; i<360; i++)
        for (j=0; j<4; j++) {
            [Util idxToEvenPerm:arr i:i l:6];
            switch(j){
				case 0: [Util cir3:arr a:2 b:5 c:3]; break;
				case 1: [Util cir3:arr a:0 b:3 c:4]; break;
				case 2: [Util cir3:arr a:1 b:4 c:5]; break;
				case 3: [Util cir3:arr a:3 b:5 c:4]; break;
            }
            ctm[i][j] = [Util evenPermToIdx:arr l:6];
        }
    int arr2[3];
    for (i=0; i<12; i++) {
        for (j=0; j<3; j++) {
            for (k=0; k<4; k++) {
                [Util idxToEvenPerm:arr i:i l:4];
                [Util idxToEvenPerm:arr2 i:j l:3];
                switch (k) {
                    case 0:
                        [Util cir3:arr a:1 b:2 c:3]; break;
                    case 1:
                        [Util cir3:arr a:0 b:1 c:3]; break;
                    case 2:
                        [Util cir3:arr a:2 b:0 c:3]; break;
                    case 3:
                        [Util cir3:arr2 a:0 b:2 c:1]; break;
                }
                cpm[i*3+j][k] = [Util evenPermToIdx:arr l:4] * 3 + [Util evenPermToIdx:arr2 l:3];
            }
        }
    }
    for (i=0; i<2187; i++) {
        for (j=0; j<4; j++) {
            [Util idxToOri:arr i:i n:3 l:7];
            switch (j) {
                case 0:
                    [Util cir3:arr a:2 b:6 c:3];
                    arr[2] += 2; arr[3] += 2; arr[5]++; arr[6] += 2; break;
				case 1:
                    [Util cir3:arr a:1 b:2 c:3];
                    arr[0]++; arr[1] += 2; arr[2] += 2; arr[3] += 2; break;
				case 2:
                    [Util cir3:arr a:1 b:3 c:6];
                    arr[1] += 2; arr[3] += 2; arr[4]++; arr[6] += 2; break;
				case 3:
                    [Util cir3:arr a:0 b:5 c:4];
                    arr[0] += 2; arr[3]++; arr[4] += 2; arr[5] += 2; break;
            }
            com[i][j] = [Util oriToIdx:arr n:3 l:7];
        }
    }
    
    // distance table
    for (i = 0; i < 360; i++)
        ctd[i]=-1;
    for (j = 0; j < 2187; j++)
        for(k = 0; k < 36; k++)
            cd[j][k] = -1;
    ctd[0] = 0; cd[0][0] = 0;
    for(int d = 0; d < 5; d++) {
        //c = 0;
        for (i = 0; i < 360; i++)
            if (ctd[i] == d)
                for (int m = 0; m < 4; m++) {
                    int p = i;
                    for(int n = 0; n < 2; n++){
                        p = ctm[p][m];
                        if (ctd[p] == -1) {
                            ctd[p] = d + 1;
                            //c++;
                        }
                    }
                }
        //NSLog(@"%d %d", d+1, c);
    }
    //c = 1;
    for(int d = 0; d < 7; d++) {
        //c = 0;
        for (i=0; i<2187; i++)
            for (j=0; j<36; j++)
                if(cd[i][j] == d)
                    for (k=0; k<4; k++) {
                        int p = i, q = j;
                        for (int l=0; l<2; l++) {
                            p = com[p][k]; q = cpm[q][k];
                            if(cd[p][q] == -1) {
                                cd[p][q] = d+1;
                                //c++;
                            }
                        }
                    }
        //NSLog(@"%d %d", d+1, c);
    }
}

-(Skewb *) init {
    if(self = [super init]) {
        self.turn = [[NSArray alloc] initWithObjects:@"R", @"U", @"L", @"B", nil];
        self.suf = [[NSArray alloc] initWithObjects:@"'", @"", nil];
        [self initSkb];
        srand((unsigned)time(0));
    }
    return self;
}

-(bool) search:(int)fp cp:(int)cp co:(int)co d:(int)d l:(int)l {
    if(d==0)return ctd[fp] == 0 && cd[co][cp] == 0;
    if(ctd[fp] > d || cd[co][cp] > d)return false;
    for(int k = 0; k < 4; k++)
        if(k != l){
            int p=fp, q=cp, r=co;
            for(int m=0; m<2; m++){
                p=ctm[p][k]; q=cpm[q][k]; r=com[r][k];
                if([self search:p cp:q co:r d:d-1 l:k]) {
                    [self.sol appendFormat:@"%@%@ ", [self.turn objectAtIndex:k], [self.suf objectAtIndex:m]];
                    return true;
                }
            }
        }
    return false;
}

-(NSString *) scramble {
    int fp = rand()%360;
    int cp, co;
    do{
        cp = rand()%36;
        co = rand()%2187;
    }
    while (cd[co][cp] < 0);
    self.sol = [NSMutableString string];
    for (int d = 7; d < 13; d++) {
        if([self search:fp cp:cp co:co d:d l:-1]) {
            return self.sol;
        }
    }
    return @"";
}

+(void) initColor:(int[])img {
    for(int i=0; i<5; i++)
        for(int j=0; j<6; j++) img[j*5+i] = j;
}

+(void) move:(int[])arr turn:(int)turn {
    switch (turn) {
        case 0: //R
            [Util cir3:arr a:17 b:27 c:22];
            [Util cir3:arr a:19 b:29 c:23];
            [Util cir3:arr a:1 b:14 c:8];
            [Util cir3:arr a:20 b:18 c:28];
            [Util cir3:arr a:16 b:26 c:24];
            break;
        case 1: //U
            [Util cir3:arr a:2 b:22 c:7];
            [Util cir3:arr a:0 b:21 c:5];
            [Util cir3:arr a:3 b:20 c:8];
            [Util cir3:arr a:10 b:16 c:28];
            [Util cir3:arr a:6 b:1 c:24];
            break;
        case 2: //L
            [Util cir3:arr a:12 b:7 c:27];
            [Util cir3:arr a:13 b:9 c:25];
            [Util cir3:arr a:3 b:24 c:18];
            [Util cir3:arr a:10 b:8 c:26];
            [Util cir3:arr a:6 b:28 c:14];
            break;
        case 3: //B
            [Util cir3:arr a:22 b:27 c:7];
            [Util cir3:arr a:24 b:28 c:8];
            [Util cir3:arr a:0 b:19 c:13];
            [Util cir3:arr a:5 b:23 c:25];
            [Util cir3:arr a:21 b:29 c:9];
            break;
    }
}

+ (NSMutableArray *)image:(NSString *)scr {
    int arr[30];
    [Skewb initColor:arr];
    NSString *moveIdx = @"RULB";
    NSArray *s = [scr componentsSeparatedByString:@" "];
    for(int i=0; i<s.count; i++) {
        if([[s objectAtIndex:i] length] > 0) {
            int mov = [DCTUtils indexOf:moveIdx c:[[s objectAtIndex:i] characterAtIndex:0]];
            [Skewb move:arr turn:mov];
            if([[s objectAtIndex:i] length] > 1) [Skewb move:arr turn:mov];
        }
    }
    NSMutableArray *img = [[NSMutableArray alloc] init];
    for(int i=0; i<30; i++) [img addObject:@(arr[i])];
    return img;
}
@end
