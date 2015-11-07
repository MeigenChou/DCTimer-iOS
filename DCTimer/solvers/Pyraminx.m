//
//  Pyraminx.m
//  DCTimer Solvers
//
//  Created by MeigenChou on 12-11-3.
//  Copyright (c) 2012年 MeigenChou. All rights reserved.
//

#import "Pyraminx.h"
#import "Im.h"
#import "DCTUtils.h"
#import "stdlib.h"
#import "time.h"

@interface Pyraminx ()
@property (nonatomic, strong) NSArray *face;
@property (nonatomic, strong) NSArray *suf;
@property (nonatomic, strong) NSArray *tips;
@property (nonatomic, strong) NSMutableString *sol;
@end

@implementation Pyraminx
@synthesize face, suf, tips, sol;
char pyPerm[360];
short pyPermmv[360][4];
char pyTwst[2592];
char pyTwstmv[81][4];
char pyFlipmv[32][4];

int colmap[91];

- (int) getprmmv: (int)p m:(int)m  {
    int ps[6];
    [Im idxToEvenPerm:ps i:p l:6];
    if (m == 0) {
        [Im cir3:ps a:1 b:5 c:2];
    }
    else if (m == 1) {
        [Im cir3:ps a:0 b:2 c:4];
    }
    else if (m == 2) {
        [Im cir3:ps a:3 b:4 c:5];
    }
    else if (m == 3) {
        [Im cir3:ps a:0 b:3 c:1];
    }    
    return [Im evenPermToIdx:ps l:6];
}

- (int)gettwsmv: (int)p m:(int)m {
    int ps[4];
    [Im idxToOri:ps i:p n:3 l:4];
    if (m == 0) {
        ps[1]++; if (ps[1] == 3) ps[1] = 0;
    }
    else if (m == 1) {
        ps[2]++; if (ps[2] == 3) ps[2] = 0;
    }
    else if (m == 2) {
        ps[3]++; if (ps[3] == 3) ps[3] = 0;
    }
    else if (m == 3) {
        ps[0]++; if (ps[0] == 3) ps[0] = 0;
    }
    return [Im oriToIdx:ps n:3 l:4];
}

- (int) getflpmv:(int)p m:(int)m {
    int a, d=0;
    int ps[6];
    int q = p;
    for(a=0; a<=4; a++) {
        ps[a] = q & 1;
        q>>=1;
        d^=ps[a];
    }
    ps[5] = d;
    switch (m) {
		case 0:	//L
			[Im cir3:ps a:0 b:3 c:1];
            ps[1] ^= 1; ps[3] ^= 1;
			break;
		case 1:	//R
			[Im cir3:ps a:1 b:5 c:2];
            ps[2] ^= 1; ps[5] ^= 1;
			break;
		case 2:	//B
			[Im cir3:ps a:0 b:2 c:4];
            ps[0] ^= 1; ps[2] ^= 1;
			break;
		case 3:	//U
			[Im cir3:ps a:3 b:4 c:5];
            ps[3] ^= 1; ps[4] ^= 1;
			break;
    }
    //edge orientation
    for(a=4; a>=0; a--) {
        q=q*2+ps[a];
    }
    return q;
}

- (void) calcperm {
    for (int p = 0; p < 360; p++) {
        pyPerm[p] = -1;
        for (int m = 0; m < 4; m++) {
            pyPermmv[p][m] = [self getprmmv:p m:m];
        }
    }
    pyPerm[0] = 0;
    for (int l = 0; l <= 4; l++) {
        //int n = 0;
        for (int p = 0; p < 360; p++) {
            if (pyPerm[p] == l) {
                for (int m = 0; m < 4; m++) {
                    int q = p;
                    for (int c = 0; c < 2; c++) {
                        q = pyPermmv[q][m];
                        if (pyPerm[q] == -1) {
                            pyPerm[q] = l + 1;
                            //n++;
                        }
                    }
                }
            }
        }
        //NSLog(@"%d %d", l+1, n);
    }
    for (int p = 0; p < 81; p++) {
        for (int m = 0; m < 4; m++) {
            pyTwstmv[p][m] = [self gettwsmv:p m:m];
            if(p<32) pyFlipmv[p][m] = [self getflpmv:p m:m];
        }
    }
    for (int p = 0; p < 2592; p++) pyTwst[p] = -1;
    pyTwst[0] = 0;
    for (int l = 0; l <= 6; l++) {
        //int n = 0;
        for (int p = 0; p < 2592; p++) {
            if (pyTwst[p] == l) {
                for (int m = 0; m < 4; m++) {
                    int q = p>>5, r = p&31;
                    for (int c = 0; c < 2; c++) {
                        q = pyTwstmv[q][m]; r = pyFlipmv[r][m];
                        if (pyTwst[q<<5|r] == -1) {
                            pyTwst[q<<5|r] = l + 1;
                            //n++;
                        }
                    }
                }
            }
        }
        //NSLog(@"%d %d", l+1, n);
    }
}

- (Pyraminx *)init {
    if (self = [super init]) {
        [self calcperm];
        self.face = [[NSArray alloc] initWithObjects:@"U", @"L", @"R", @"B", nil];
        self.suf = [[NSArray alloc] initWithObjects:@"'", @"", nil];
        tips = [[NSArray alloc] initWithObjects:@"l", @"r", @"b", @"u", nil];
        srand((unsigned)time(0));
    }
    return self;
}

- (BOOL) search: (int)q t:(int)t l:(int)l lm:(int)lm {
    if (l == 0) return q == 0 && t == 0;
    if (pyPerm[q] > l || pyTwst[t] > l) return false;
    int p, s, a, m;
    for (m = 0; m < 4; m++) {
        if (m != lm) {
            p = q; s = t;
            for (a = 0; a < 2; a++) {
                p = pyPermmv[p][m];
                s = pyTwstmv[s>>5][m] << 5 | pyFlipmv[s&31][m];
                if ([self search:p t:s l:(l-1) lm:m]) {
                    [self.sol appendFormat:@"%@%@ ", [self.face objectAtIndex:m], [self.suf objectAtIndex:a]];
                    return true;
                }
            }
        }
    } 
    return false;
}

- (NSString *)scrPyrm {
    int t = rand()%2592, q = rand()%360, l;
    self.sol = [NSMutableString string];
    for(l=0; l<12; l++) {
        if([self search:q t:t l:l lm:-1]){
            for (int i = 0; i < 4; i++) {
                int j = rand() % 3;
                if (j < 2)
                    [sol appendFormat:@"%@%@ ", [tips objectAtIndex:i], [self.suf objectAtIndex:j]];
            }
            return sol;
        }
    }    
    return @"";
}

+ (void)rotate3:(int)v1 v2:(int)v2 v3:(int)v3 c:(int)clockwise {
    if(clockwise == 2)
        [Im cir3:colmap a:v3 b:v2 c:v1];
    else [Im cir3:colmap a:v1 b:v2 c:v3];
}

+ (void)picmove:(int)type d:(int)direction {
    switch (type) {
        case 0: //L
            [Pyraminx rotate3:14 v2:58 v3:18 c:direction];
            [Pyraminx rotate3:15 v2:57 v3:31 c:direction];
            [Pyraminx rotate3:16 v2:70 v3:32 c:direction];
        case 4: //l
            [Pyraminx rotate3:30 v2:28 v3:56 c:direction];
            break;
        case 1: //R
            [Pyraminx rotate3:32 v2:72 v3:22 c:direction];
            [Pyraminx rotate3:33 v2:59 v3:23 c:direction];
            [Pyraminx rotate3:20 v2:58 v3:24 c:direction];
        case 5: //r
            [Pyraminx rotate3:34 v2:60 v3:36 c:direction];
            break;
        case 2: //B
            [Pyraminx rotate3:14 v2:10 v3:72 c:direction];
            [Pyraminx rotate3:1 v2:11 v3:71 c:direction];
            [Pyraminx rotate3:2 v2:24 v3:70 c:direction];
        case 6: //b
            [Pyraminx rotate3:0 v2:12 v3:84 c:direction];
            break;
        case 3: //U
            [Pyraminx rotate3:2 v2:18 v3:22 c:direction];
            [Pyraminx rotate3:3 v2:19 v3:9 c:direction];
            [Pyraminx rotate3:16 v2:20 v3:10 c:direction];
        case 7: //u
            [Pyraminx rotate3:4 v2:6 v3:8 c:direction];
            break;
        default:
            break;
    }
}

+ (void)init_colors {
    int tempcol[91] = {1, 1, 1, 1, 1, 0, 2, 0, 3, 3, 3, 3, 3,
        0, 1, 1, 1, 0, 2, 2, 2, 0, 3, 3, 3, 0,
        0, 0, 1, 0, 2, 2, 2, 2, 2, 0, 3, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 4, 4, 4, 4, 4, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 4, 4, 4, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0};
    for(int i=0; i<91; i++) colmap[i] = tempcol[i];
}

+ (NSMutableArray *)imageString:(NSString *)scr {
    NSString *moveIdx = @"LRBUlrbu";
    NSArray *s = [scr componentsSeparatedByString:@" "];
    [Pyraminx init_colors];
    int turn, suff;
    for(int i=0; i<s.count; i++) {
        NSString *temp = [s objectAtIndex:i];
        suff = temp.length;
        if(suff > 0) {
            char i = [temp characterAtIndex:0];
            turn = [DCTUtils indexOf:moveIdx c:i];
            [self picmove:turn d:suff];
        }
    }
    NSMutableArray *img = [[NSMutableArray alloc] init];
    for(int x=0; x<91; x++)
        [img addObject:@(colmap[x] - 1)];
    return img;
}
@end
