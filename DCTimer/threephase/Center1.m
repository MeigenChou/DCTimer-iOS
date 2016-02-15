//
//  Center1.m
//  DCTimer
//
//  Created by meigen on 15/10/30.
//
//

#import "Center1.h"
#import "CenterCube.h"
#import "Util4.h"
#import "DCTUtils.h"
/*
            0	1
            3	2
 
 20	21		8	9		16	17		12	13
 23	22		11	10		19	18		15	14
 
            4	5
            7	6
 */
@implementation Center1
int ctsmv[15582][36];
int csym2raw[15582];
char csprun[15582];

int symmult4[48][48];
int symmove4[48][36];
int csyminv[48];
int finish[48];

//int *raw2sym;
int craw2sym[735471];

extern int Cnk[25][25];
extern int ux2, dx2, rx1, lx3, ux1, dx3, fx1, bx3;
extern int centerFacelet[];

+(void)initSym2Raw {
    Center1 *c = [[Center1 alloc] init];
    int occ[22984];
    int count = 0;
    for (int i=0; i<22984; i++) occ[i] = 0;
    for (int i=0; i<735471; i++) {
        if ((occ[i>>5]&(1<<(i&0x1f))) == 0) {
            [c set:i];
            for (int j=0; j<48; j++) {
                int idx = [c get];
                occ[idx >> 5] |= (1<<(idx&0x1f));
                craw2sym[idx] = (count << 6) | csyminv[j];
                [c rot:0];
                if (j%2==1) [c rot:1];
                if (j%8==7) [c rot:2];
                if (j%16==15) [c rot:3];
            }
            csym2raw[count++] = i;
        }
    }
}

+(void)createPrun {
    for (int i=1; i<15582; i++) csprun[i] = -1;
    csprun[0] = 0;
    int depth = 0;
    int done = 1;
    while (depth < 8) {
        bool inv = depth > 4;
        int select = inv ? -1 : depth;
        int check = inv ? depth : -1;
        depth++;
        for (int i=0; i<15582; i++) {
            if (csprun[i] == select) {
                for (int m=0; m<27; m++) {
                    int idx = ctsmv[i][m] >> 6;
                    if (csprun[idx] != check) {
                        continue;
                    }
                    ++done;
                    if (inv) {
                        csprun[i] = depth;
                        break;
                    } else {
                        csprun[idx] = depth;
                    }
                }
            }
        }
        //NSLog(@"%d %d", depth, done);
    }
}

+(void)createMoveTable {
    Center1 *c = [[Center1 alloc] init];
    Center1 *d = [[Center1 alloc] init];
    for (int i=0; i<15582; i++) {
        [d set:csym2raw[i]];
        for (int m=0; m<36; m++) {
            [c setCent:d];
            [c move:m];
            ctsmv[i][m] = [c getsym];
        }
    }
}

-(id)init {
    if (self = [super init]) {
        for (int i=0; i<8; i++)
            ct[i] = 1;
        for (int i=8; i<24; i++)
            ct[i] = 0;
    }
    return self;
}

-(id)initCenter:(int[])c {
    if (self = [super init]) {
        for (int i=0; i<24; i++)
            ct[i] = c[i];
    }
    return self;
}

//Center1(CenterCube c, int urf)
-(id) initCentUrf:(CenterCube *)c urf:(int)urf {
    if (self = [super init]) {
        for (int i=0; i<24; i++)
            self->ct[i] = (c->ct[i]%3 == urf) ? 1 : 0;
    }
    return self;
}

-(void)move:(int)m {
    int key = m % 3;
    m /= 3;
    switch (m) {
        case 6:	//u
            [Util4 swap:ct a:8 b:20 c:12 d:16 k:key];
            [Util4 swap:ct a:9 b:21 c:13 d:17 k:key];
        case 0:	//U
            [Util4 swap:ct a:0 b:1 c:2 d:3 k:key];
            break;
        case 7:	//r
            [Util4 swap:ct a:1 b:15 c:5 d:9 k:key];
            [Util4 swap:ct a:2 b:12 c:6 d:10 k:key];
        case 1:	//R
            [Util4 swap:ct a:16 b:17 c:18 d:19 k:key];
            break;
        case 8:	//f
            [Util4 swap:ct a:2 b:19 c:4 d:21 k:key];
            [Util4 swap:ct a:3 b:16 c:5 d:22 k:key];
        case 2:	//F
            [Util4 swap:ct a:8 b:9 c:10 d:11 k:key];
            break;
        case 9:	//d
            [Util4 swap:ct a:10 b:18 c:14 d:22 k:key];
            [Util4 swap:ct a:11 b:19 c:15 d:23 k:key];
        case 3:	//D
            [Util4 swap:ct a:4 b:5 c:6 d:7 k:key];
            break;
        case 10:    //l
            [Util4 swap:ct a:0 b:8 c:4 d:14 k:key];
            [Util4 swap:ct a:3 b:11 c:7 d:13 k:key];
        case 4:	//L
            [Util4 swap:ct a:20 b:21 c:22 d:23 k:key];
            break;
        case 11:    //b
            [Util4 swap:ct a:1 b:20 c:7 d:18 k:key];
            [Util4 swap:ct a:0 b:23 c:6 d:17 k:key];
        case 5:	//B
            [Util4 swap:ct a:12 b:13 c:14 d:15 k:key];
            break;
    }
}

-(void)set:(int)idx {
    int r = 8;
    for (int i=23; i>=0; i--) {
        ct[i] = 0;
        if (idx >= Cnk[i][r]) {
            idx -= Cnk[i][r--];
            ct[i] = 1;
        }
    }
}

-(int)get {
    int idx = 0;
    int r = 8;
    for (int i=23; i>=0; i--) {
        if (ct[i] == 1) {
            idx += Cnk[i][r--];
        }
    }
    return idx;
}

-(int)getsym {
    return craw2sym[[self get]];
    /*
    for (int j=0; j<48; j++) {
        int cord = [Center1 raw2sym:[self get]];
        if (cord != -1)
            return cord << 6 | j;
        [self rot:0];
        if (j%2==1) [self rot:1];
        if (j%8==7) [self rot:2];
        if (j%16==15) [self rot:3];
    }
    return -1;*/
}

+(int) raw2sym:(int)n {
    int m = [DCTUtils binarySearch:csym2raw ti:15582 key:n];
    return m>=0 ? m : -1;
}

-(void) setCent:(Center1 *)c {
    for (int i=0; i<24; i++) {
        self->ct[i] = c->ct[i];
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
            [Util4 swap:ct a:16 b:19 c:21 d:22 k:1];
            [Util4 swap:ct a:17 b:18 c:20 d:23 k:1];
            break;
        case 3:
            [self move:ux1];
            [self move:dx3];
            [self move:fx1];
            [self move:bx3];
            break;
    }
}

-(void) rotate:(int)r {
    for (int j=0; j<r; j++) {
        [self rot:0];
        if (j%2==1) [self rot:1];
        if (j%8==7) [self rot:2];
        if (j%16==15) [self rot:3];
    }
}

+(int) getSolvedSym:(CenterCube *)cube {
    Center1 *c = [[Center1 alloc] initCenter:cube->ct];
    for (int j=0; j<48; j++) {
        bool check = true;
        for (int i=0; i<24; i++) {
            if (c->ct[i] != centerFacelet[i] / 16) {
                check = false;
                break;
            }
        }
        if (check) {
            return j;
        }
        [c rot:0];
        if (j%2==1) [c rot:1];
        if (j%8==7) [c rot:2];
        if (j%16==15) [c rot:3];
    }
    return -1;
}

-(bool) equals:(Center1 *)c {
    for (int i=0; i<24; i++) {
        if (self->ct[i] != c->ct[i]) {
            return false;
        }
    }
    return true;
}

+(void)initSym {
    Center1 *c = [[Center1 alloc] init];
    for (int i=0; i<24; i++)
        c->ct[i] = i;
    Center1 *d = [[Center1 alloc] initCenter:c->ct];
    Center1 *e = [[Center1 alloc] initCenter:c->ct];
    Center1 *f = [[Center1 alloc] initCenter:c->ct];
    for (int i=0; i<48; i++) {
        for (int j=0; j<48; j++) {
            for (int k=0; k<48; k++) {
                if ([c equals:d]) {
                    symmult4[i][j] = k;
                    if (k==0) csyminv[i] = j;
                }
                [d rot:0];
                if (k%2==1) [d rot:1];
                if (k%8==7) [d rot:2];
                if (k%16==15) [d rot:3];
            }
            [c rot:0];
            if (j%2==1) [c rot:1];
            if (j%8==7) [c rot:2];
            if (j%16==15) [c rot:3];
        }
        [c rot:0];
        if (i%2==1) [c rot:1];
        if (i%8==7) [c rot:2];
        if (i%16==15) [c rot:3];
    }
    for (int i=0; i<48; i++) {
        [c setCent:e];
        [c rotate:csyminv[i]];
        for (int j=0; j<36; j++) {
            [d setCent:c];
            [d move:j];
            [d rotate:i];
            for (int k=0; k<36; k++) {
                [f setCent:e];
                [f move:k];
                if ([f equals:d]) {
                    symmove4[i][j] = k;
                    break;
                }
            }
        }
    }
    [c set:0];
    for (int i=0; i<48; i++) {
        finish[csyminv[i]] = [c get];
        [c rot:0];
        if(i%2 == 1) [c rot:1];
        if(i%8 == 7) [c rot:2];
        if(i%16 == 15) [c rot:3];
    }
}
@end
