//
//  Center3.m
//  DCTimer
//
//  Created by meigen on 15/10/30.
//
//

#import "Center3.h"
#import "Util4.h"
/*
            0	1
            3	2
 4	5		0	1		0	1		4	5
 7	6		3	2		3	2		7	6
            4	5
            7	6
 */

@implementation Center3
unsigned short ctmove[35*35*12*2][20];
int pmove[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1};
char ct3prun[35*35*12*2];
int rl2std[] = {0, 9, 14, 23, 27, 28, 41, 42, 46, 55, 60, 69};
int std2rl[70];
extern int Cnk[25][25];

-(id) init {
    if (self = [super init]) {
        parity = 0;
    }
    return self;
}

+(void)initCent3 {
    for (int i=0; i<12; i++) {
        std2rl[rl2std[i]] = i;
    }
}

+(void)initMove {
    Center3 *c = [[Center3 alloc] init];
    for (int i=0; i<35*35*12*2; i++) {
        for (int m=0; m<20; m++) {
            [c setct:i];
            [c move:m];
            ctmove[i][m] = [c getct];
        }
    }
}

+(void)initPrun {
    for (int i=1; i<29400; i++) ct3prun[i] = -1;
    ct3prun[0] = 0;
    int depth = 0;
    int done = 1;
    while (depth < 10) {
        for (int i=0; i<29400; i++) {
            if (ct3prun[i] != depth) {
                continue;
            }
            for (int m=0; m<17; m++) {
                if (ct3prun[ctmove[i][m]] == -1) {
                    ct3prun[ctmove[i][m]] = depth + 1;
                    done++;
                }
            }
        }
        depth++;
        //NSLog(@"%d %d", depth, done);
    }
}

-(void)set:(CenterCube *)c ep:(int)eXc_parity {
    int p = (c->ct[0]%3 > c->ct[8]%3 ^ c->ct[8]%3 > c->ct[16]%3 ^ c->ct[0]%3 > c->ct[16]%3) ? 0 : 1;
    for (int i=0; i<8; i++) {
        ud[i] = (c->ct[i] / 3) ^ 1;
        fb[i] = (c->ct[i+8] / 3) ^ 1;
        rl[i] = (c->ct[i+16] / 3) ^ 1 ^ p;
    }
    self->parity = p ^ eXc_parity;
}

-(int)getct {
    int idx = 0;
    int r = 4;
    for (int i=6; i>=0; i--) {
        if (ud[i] != ud[7]) {
            idx += Cnk[i][r--];
        }
    }
    idx *= 35;
    r = 4;
    for (int i=6; i>=0; i--) {
        if (fb[i] != fb[7]) {
            idx += Cnk[i][r--];
        }
    }
    idx *= 12;
    int check = fb[7] ^ ud[7];
    int idxrl = 0;
    r = 4;
    for (int i=7; i>=0; i--) {
        if (rl[i] != check) {
            idxrl += Cnk[i][r--];
        }
    }
    return parity + 2 * (idx + std2rl[idxrl]);
}

-(void)setct:(int)idx {
    parity = idx & 1;
    idx >>= 1;
    int idxrl = rl2std[idx % 12];
    idx /= 12;
    int r = 4;
    for (int i=7; i>=0; i--) {
        rl[i] = 0;
        if (idxrl >= Cnk[i][r]) {
            idxrl -= Cnk[i][r--];
            rl[i] = 1;
        }
    }
    int idxfb = idx % 35;
    idx /= 35;
    r = 4;
    fb[7] = 0;
    for (int i=6; i>=0; i--) {
        if (idxfb >= Cnk[i][r]) {
            idxfb -= Cnk[i][r--];
            fb[i] = 1;
        } else {
            fb[i] = 0;
        }
    }
    r = 4;
    ud[7] = 0;
    for (int i=6; i>=0; i--) {
        if (idx >= Cnk[i][r]) {
            idx -= Cnk[i][r--];
            ud[i] = 1;
        } else {
            ud[i] = 0;
        }
    }
}

-(void) move:(int)i {
    parity ^= pmove[i];
    switch (i) {
        case 0:		//U
        case 1:		//U2
        case 2:		//U'
            [Util4 swap:ud a:0 b:1 c:2 d:3 k:i%3];
            break;
        case 3:		//R2
            [Util4 swap:rl a:0 b:1 c:2 d:3 k:1];
            break;
        case 4:		//F
        case 5:		//F2
        case 6:		//F'
            [Util4 swap:fb a:0 b:1 c:2 d:3 k:(i-1)%3];
            break;
        case 7:		//D
        case 8:		//D2
        case 9:		//D'
            [Util4 swap:ud a:4 b:5 c:6 d:7 k:(i-1)%3];
            break;
        case 10:	//L2
            [Util4 swap:rl a:4 b:5 c:6 d:7 k:1];
            break;
        case 11:	//B
        case 12:	//B2
        case 13:	//B'
            [Util4 swap:fb a:4 b:5 c:6 d:7 k:(i+1)%3];
            break;
        case 14:	//u2
            [Util4 swap:ud a:0 b:1 c:2 d:3 k:1];
            [Util4 swap:rl a:0 b:5 c:4 d:1 k:1];
            [Util4 swap:fb a:0 b:5 c:4 d:1 k:1];
            break;
        case 15:	//r2
            [Util4 swap:rl a:0 b:1 c:2 d:3 k:1];
            [Util4 swap:fb a:1 b:4 c:7 d:2 k:1];
            [Util4 swap:ud a:1 b:6 c:5 d:2 k:1];
            break;
        case 16:	//f2
            [Util4 swap:fb a:0 b:1 c:2 d:3 k:1];
            [Util4 swap:ud a:3 b:2 c:5 d:4 k:1];
            [Util4 swap:rl a:0 b:3 c:6 d:5 k:1];
            break;
        case 17:	//d2
            [Util4 swap:ud a:4 b:5 c:6 d:7 k:1];
            [Util4 swap:rl a:3 b:2 c:7 d:6 k:1];
            [Util4 swap:fb a:3 b:2 c:7 d:6 k:1];
            break;
        case 18:	//l2
            [Util4 swap:rl a:4 b:5 c:6 d:7 k:1];
            [Util4 swap:fb a:0 b:3 c:6 d:5 k:1];
            [Util4 swap:ud a:0 b:3 c:4 d:7 k:1];
            break;
        case 19:	//b2
            [Util4 swap:fb a:4 b:5 c:6 d:7 k:1];
            [Util4 swap:ud a:0 b:7 c:6 d:1 k:1];
            [Util4 swap:rl a:1 b:4 c:7 d:2 k:1];
            break;
    }
}
@end
