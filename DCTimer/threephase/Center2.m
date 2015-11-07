//
//  Center2.m
//  DCTimer
//
//  Created by MeigenChou on 14-8-14.
//
//

#import "Center2.h"
#import "CenterCube.h"
#import "Util4.h"


@implementation Center2
int rlmv[70][28];
unsigned short ctmv[6435][28];
int rlrot[70][16];
unsigned short ctrot[6435][16];
char ct2prun[6435 * 35 * 2];

extern int Cnk[25][25];
extern int ux2, dx2, rx1, lx3;
extern int move2std[];

int c2pmv[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1,
    0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0};

+(void) initCent2 {
    NSLog(@"init cent2..");
    Center2 *c = [[Center2 alloc] init];
    for (int i=0; i<35*2; i++) {
        for (int m=0; m<28; m++) {
            [c setrl:i];
            [c move:move2std[m]];
            rlmv[i][m] = [c getrl];
        }
    }
    for (int i=0; i<70; i++) {
        [c setrl:i];
        for (int j=0; j<16; j++) {
            rlrot[i][j] = [c getrl];
            [c rot:0];
            if (j%2==1) [c rot:1];
            if (j%8==7) [c rot:2];
        }
    }
    for (int i=0; i<6435; i++) {
        [c setct:i];
        for (int j=0; j<16; j++) {
            ctrot[i][j] = [c getct];
            [c rot:0];
            if (j%2==1) [c rot:1];
            if (j%8==7) [c rot:2];
        }
    }
    for (int i=0; i<6435; i++) {
        for (int m=0; m<28; m++) {
            [c setct:i];
            [c move:move2std[m]];
            ctmv[i][m] = [c getct];
        }
    }
    for(int i=1; i<450450; i++)
        ct2prun[i] = -1;
    ct2prun[0] = ct2prun[18] = ct2prun[28] = ct2prun[46] = ct2prun[54] = ct2prun[56] = 0;
    int depth = 0;
    int done = 6;
    while (depth < 9) {
        for (int i=0; i<450450; i++) {
            if (ct2prun[i] != depth) {
                continue;
            }
            int ct = i / 70;
            int rl = i % 70;
            for (int m=0; m<23; m++) {
                int ctx = ctmv[ct][m];
                int rlx = rlmv[rl][m];
                int idx = ctx * 70 + rlx;
                if (ct2prun[idx] == -1) {
                    ct2prun[idx] = depth + 1;
                    done++;
                }
            }
        }
        depth++;
        //NSLog(@"%d %d", depth, done);
    }
    NSLog(@"OK");
}

-(id) init {
    if (self = [super init]) {
        parity = 0;
    }
    return self;
}

-(id) initCenter:(CenterCube *)c {
    if (self = [super init]) {
        parity = 0;
        for (int i=0; i<16; i++) {
			ct[i] = c->ct[i] / 2;
		}
		for (int i=0; i<8; i++) {
			rl[i] = c->ct[i+16];
		}
    }
    return self;
}

-(void) set:(CenterCube *)c ep:(int)edgeParity {
    for (int i=0; i<16; i++) {
        ct[i] = c->ct[i] / 2;
    }
    for (int i=0; i<8; i++) {
        rl[i] = c->ct[i+16];
    }
    parity = edgeParity;
}

-(int) getrl {
    int idx = 0;
    int r = 4;
    for (int i=6; i>=0; i--) {
        if (rl[i] != rl[7]) {
            idx += Cnk[i][r--];
        }
    }
    return idx * 2 + parity;
}

-(void) setrl:(int)idx {
    parity = idx & 1;
    idx >>= 1;
    int r = 4;
    rl[7] = 0;
    for (int i=6; i>=0; i--) {
        if (idx >= Cnk[i][r]) {
            idx -= Cnk[i][r--];
            rl[i] = 1;
        } else {
            rl[i] = 0;
        }
    }
}

-(int) getct {
    int idx = 0;
    int r = 8;
    for (int i=14; i>=0; i--) {
        if (ct[i] != ct[15]) {
            idx += Cnk[i][r--];
        }
    }
    return idx;
}

-(void) setct:(int)idx {
    int r = 8;
    ct[15] = 0;
    for (int i=14; i>=0; i--) {
        if (idx >= Cnk[i][r]) {
            idx -= Cnk[i][r--];
            ct[i] = 1;
        } else {
            ct[i] = 0;
        }
    }
}

-(void) rot:(int)r {
    switch (r) {
		case 0:
            [self move:ux2];
			[self move:dx2];
			break;
		case 1:
            [self move:rx1];
			[self move:lx3];
			break;
		case 2:
            [Util4 swap:ct a:0 b:3 c:1 d:2 k:1];
			[Util4 swap:ct a:8 b:11 c:9 d:10 k:1];
			[Util4 swap:ct a:4 b:7 c:5 d:6 k:1];
			[Util4 swap:ct a:12 b:15 c:13 d:14 k:1];
			[Util4 swap:rl a:0 b:3 c:5 d:6 k:1];
			[Util4 swap:rl a:1 b:2 c:4 d:7 k:1];
			break;
    }
}

-(void) move:(int)m {
    parity ^= c2pmv[m];
    int key = m % 3;
    m /= 3;
    switch (m) {
        case 6:		//u
            [Util4 swap:rl a:0 b:5 c:4 d:1 k:key];
            [Util4 swap:ct a:8 b:9 c:12 d:13 k:key];
		case 0:		//U
            [Util4 swap:ct a:0 b:1 c:2 d:3 k:key];
			break;
        case 7:		//r
            [Util4 swap:ct a:1 b:15 c:5 d:9 k:key];
            [Util4 swap:ct a:2 b:12 c:6 d:10 k:key];
		case 1:		//R
            [Util4 swap:rl a:0 b:1 c:2 d:3 k:key];
			break;
        case 8:		//f
            [Util4 swap:rl a:0 b:3 c:6 d:5 k:key];
            [Util4 swap:ct a:3 b:2 c:5 d:4 k:key];
		case 2:		//F
            [Util4 swap:ct a:8 b:9 c:10 d:11 k:key];
			break;
        case 9:		//d
            [Util4 swap:rl a:3 b:2 c:7 d:6 k:key];
            [Util4 swap:ct a:11 b:10 c:15 d:14 k:key];
		case 3:		//D
            [Util4 swap:ct a:4 b:5 c:6 d:7 k:key];
			break;
        case 10:	//l
            [Util4 swap:ct a:0 b:8 c:4 d:14 k:key];
            [Util4 swap:ct a:3 b:11 c:7 d:13 k:key];
		case 4:		//L
            [Util4 swap:rl a:4 b:5 c:6 d:7 k:key];
			break;
        case 11:	//b
            [Util4 swap:rl a:1 b:4 c:7 d:2 k:key];
            [Util4 swap:ct a:1 b:0 c:7 d:6 k:key];
		case 5:		//B
            [Util4 swap:ct a:12 b:13 c:14 d:15 k:key];
			break;
    }
}
@end
