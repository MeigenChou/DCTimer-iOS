//
//  Search4.m
//  DCTimer
//
//  Created by MeigenChou on 14-8-17.
//
//

#import "Search4.h"
#import "FullCube.h"
#import "Center1.h"
#import "Center2.h"
#import "Center3.h"
#import "CenterCube.h"
#import "Edge3.h"
#import "PriorityQueue.h"

@interface Search4()
@property (nonatomic, strong) FullCube *c;
@property (nonatomic, strong) FullCube *c1;
@property (nonatomic, strong) FullCube *c2;
@property (nonatomic, strong) Center2 *ct2;
@property (nonatomic, strong) Center3 *ct3;
@property (nonatomic, strong) Edge3 *e12;
@property (nonatomic, strong) NSMutableArray *tempe;
@property (nonatomic, strong) NSMutableArray *arr2;
@property (nonatomic, strong) PriorityQueue *p1sols;
@end

@implementation Search4
@synthesize c, c1, c2;
@synthesize ct2;
@synthesize ct3;
@synthesize e12;
@synthesize tempe;
@synthesize arr2;
@synthesize p1sols;

const int PHASE1_SOLUTIONS = 5000;
const int PHASE2_ATTEMPTS = 500;
const int PHASE2_SOLUTIONS = 100;
const int PHASE3_ATTEMPTS = 100;

extern int ckmv2[][28];
extern int ckmv3[][20];
extern unsigned short ctmove[][20];
extern char ct3prun[];
extern int N_RAW;
extern int eraw2sym[];
extern int skipAxis2[];
extern int skipAxis3[];
extern char csprun[];
extern char ct2prun[];
extern int rlmv[][28];
extern unsigned short ctmv[][28];
extern int move2std[];
extern int move3std[];
extern int finish[];
extern int symmult4[][48];
extern int symmove4[][36];
extern int ctsmv[][36];
bool ini4 = false;
NSComparator cmpr;

-(id) init {
    if (self = [super init]) {
        c1 = [[FullCube alloc] init];
        c2 = [[FullCube alloc] init];
        ct2 = [[Center2 alloc] init];
        ct3 = [[Center3 alloc] init];
        e12 = [[Edge3 alloc] init];
        tempe = [[NSMutableArray alloc] init];
        for (int i=0; i<20; i++) {
            Edge3 *e = [[Edge3 alloc] init];
            [tempe addObject:e];
        }
        arr2 = [[NSMutableArray alloc] init];
        p1sols = [[PriorityQueue alloc] init];
        cmpr = ^(FullCube *obj1, FullCube *obj2) {
            if (obj1->value > obj2->value) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            if (obj1->value < obj2->value) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        };
    }
    return self;
}

-(NSString *) randomState {
    c = [[FullCube alloc] initRandomCube];
    [self doSearch];
    return solution;
}

-(void) doSearch {
    CenterCube *cent = [c getCenter];
    int ud = [[[Center1 alloc] initCentUrf:cent urf:0] getsym];
    int fb = [[[Center1 alloc] initCentUrf:cent urf:1] getsym];
    int rl = [[[Center1 alloc] initCentUrf:cent urf:2] getsym];
    int udprun = csprun[ud >> 6];
    int fbprun = csprun[fb >> 6];
    int rlprun = csprun[rl >> 6];
    p1SolsCnt = 0;
    arr2idx = 0;
    [p1sols clear];
    for (length1=MIN(MIN(udprun, fbprun), rlprun); length1<100; length1++) {
        if ((rlprun <= length1 && [self search1:rl>>6 sym:rl&0x3f m:length1 lm:-1 d:0]) || (udprun <= length1 && [self search1:ud>>6 sym:ud&0x3f m:length1 lm:-1 d:0]) || (fbprun <= length1 && [self search1:fb>>6 sym:fb&0x3f m:length1 lm:-1 d:0])) {
            break;
        }
    }
    
    NSMutableArray *p1SolsArr = [p1sols toArray];
    [p1SolsArr sortedArrayUsingComparator:cmpr];
    
    int MAX_LENGTH2 = 9;
    int length12;
    do {
        FullCube *c0 = [p1SolsArr objectAtIndex:0];
        for (length12=c0->value; length12<100; length12++) {
            for (int i=0; i<p1SolsArr.count; i++) {
                FullCube *ci = [p1SolsArr objectAtIndex:i];
                if (ci->value > length12) break;
                if (length12 - ci->length1 > MAX_LENGTH2) continue;
                [c1 copy:ci];
                [ct2 set:[c1 getCenter] ep:[[c1 getEdge] getParity]];
                int s2ct = [ct2 getct];
                int s2rl = [ct2 getrl];
                length1 = ci->length1;
                length2 = length12 - ci->length1;
                if ([self search2:s2ct rl:s2rl m:length2 lm:28 d:0]) {
                    goto OUT;
                }
            }
        }
    OUT:
        MAX_LENGTH2++;
    } while (length12 == 100);
    [arr2 sortedArrayUsingComparator:cmpr];
    int length123, index = 0;
    int solcnt = 0;
    
    int MAX_LENGTH3 = 13;
    do {
        FullCube *a0 = [arr2 objectAtIndex:0];
        for (length123=a0->value; length123<100; length123++) {
            for (int i=0; i<MIN(arr2idx, PHASE3_ATTEMPTS); i++) {
                FullCube *ai = [arr2 objectAtIndex:i];
                if (ai->value > length123) break;
                if (length123 - ai->length1 - ai->length2 > MAX_LENGTH3) continue;
                int eparity = [e12 setEdgeCube:[ai getEdge]];
                [ct3 set:[ai getCenter] ep:eparity ^ [[ai getCorner] getParity]];
                int ct = [ct3 getct];
                int edge = [e12 get:10];
                int prun = [Edge3 getprun:[e12 getsym]];
                int lm = 20;
                if (prun <= length123 - ai->length1 - ai->length2 && [self search3:edge ct:ct p:prun m:length123-ai->length1-ai->length2 lm:lm d:0]) {
                    solcnt++;
                    index = i;
                    goto OUT2;
                }
            }
        }
    OUT2:
        MAX_LENGTH3++;
    } while (length123 == 100);
    
    FullCube *solcube = [[FullCube alloc] initCube:[arr2 objectAtIndex:index]];
    length1 = solcube->length1;
    length2 = solcube->length2;
    int length = length123 - length1 - length2;
    for (int i=0; i<length; i++) {
        [solcube move:move3std[move3[i]]];
    }
    
    NSString *facelet = [solcube to333Facelet];
    NSLog(@"%d %d %d", length1, length2, length);
    
    solution = facelet;
    //NSLog(@"%@", facelet);
}

-(bool) search1:(int)ct sym:(int)sym m:(int)maxl lm:(int)lm d:(int)depth {
    if (ct == 0) {
        return maxl == 0 && [self init2:sym lm:lm];
    }
    for (int axis=0; axis<27; axis+=3) {
        if (axis == lm || axis == lm - 9 || axis == lm - 18) {
            continue;
        }
        for (int power=0; power<3; power++) {
            int m = axis + power;
            int ctx = ctsmv[ct][symmove4[sym][m]];
            int prun = csprun[ctx>>6];
            if (prun >= maxl) {
                if (prun > maxl) {
                    break;
                }
                continue;
            }
            int symx = symmult4[sym][ctx&0x3f];
            ctx>>=6;
            move1[depth] = m;
            if ([self search1:ctx sym:symx m:maxl-1 lm:axis d:depth+1]) {
                return true;
            }
        }
    }
    return false;
}

-(bool) init2:(int)sym lm:(int)lm {
    [c1 copy:c];
    for (int i=0; i<length1; i++) {
        [c1 move:move1[i]];
    }
    switch (finish[sym]) {
		case 0 :
            [c1 move:24];
			[c1 move:35];
			move1[length1] = 24;
			move1[length1+1] = 35;
			add1 = true;
			sym = 19;
			break;
		case 12869 :
            [c1 move:18];
			[c1 move:29];
			move1[length1] = 18;
			move1[length1+1] = 29;
			add1 = true;
			sym = 34;
			break;
		case 735470 :
			add1 = false;
			sym = 0;
    }
    [ct2 set:[c1 getCenter] ep:[[c1 getEdge] getParity]];
    int s2ct = [ct2 getct];
    int s2rl = [ct2 getrl];
    int ctp = ct2prun[s2ct*70+s2rl];
    c1->value = ctp + length1;
    c1->length1 = length1;
    c1->add1 = add1;
    c1->sym = sym;
    p1SolsCnt++;
    
    FullCube *next;
    if ([p1sols size] < PHASE2_ATTEMPTS) {
        next = [[FullCube alloc] initCube:c1];
    } else {
        next = [p1sols poll];
        if (next->value > c1->value) {
            [next copy:c1];
        }
    }
    [p1sols add:next];
    return p1SolsCnt == PHASE1_SOLUTIONS;
}

-(bool) search2:(int)ct rl:(int)rl m:(int)maxl lm:(int)lm d:(int)depth {
    if (ct==0 && ct2prun[rl]==0) {
        return maxl == 0 && [self init3];
    }
    for (int m=0; m<23; m++) {
        if (ckmv2[lm][m]) {
            m = skipAxis2[m];
            continue;
        }
        int ctx = ctmv[ct][m];
        int rlx = rlmv[rl][m];
        
        int prun = ct2prun[ctx * 70 + rlx];
        if (prun >= maxl) {
            if (prun > maxl) {
                m = skipAxis2[m];
            }
            continue;
        }
        move2[depth] = move2std[m];
        if ([self search2:ctx rl:rlx m:maxl-1 lm:m d:depth+1]) {
            return true;
        }
    }
    return false;
}

-(bool) init3 {
    [c2 copy:c1];
    for (int i=0; i<length2; i++) {
        [c2 move:move2[i]];
    }
    if (![c2 checkEdge]) {
        return false;
    }
    int eparity = [e12 setEdgeCube:[c2 getEdge]];
    [ct3 set:[c2 getCenter] ep:eparity ^ [[c2 getCorner] getParity]];
    int ct = [ct3 getct];
    //int edge = [e12 get:10];
    int prun = [Edge3 getprun:[e12 getsym]];
    
    FullCube *fc = [[FullCube alloc] initCube:c2];
    fc->value = length1 + length2 + MAX(prun, ct3prun[ct]);
    fc->length2 = length2;
    [arr2 addObject:fc];
    arr2idx++;
    return arr2idx == PHASE2_SOLUTIONS;
}

-(bool) search3:(int)edge ct:(int)ct p:(int)prun m:(int)maxl lm:(int)lm d:(int)depth {
    if (maxl == 0) {
        return edge == 0 && ct == 0;
    }
    Edge3 *te = [tempe objectAtIndex:depth];
    [te set:edge];
    for (int m=0; m<17; m++) {
        if (ckmv3[lm][m]) {
            m = skipAxis3[m];
            continue;
        }
        int ctx = ctmove[ct][m];
        int prun1 = ct3prun[ctx];
        if (prun1 >= maxl) {
            if (prun1 > maxl && m < 14) {
                m = skipAxis3[m];
            }
            continue;
        }
        
        int edgex = [Edge3 getmvrot:te->edge m:m<<3 e:10];
        
        int cord1x = edgex / N_RAW;
        int symcord1x = eraw2sym[cord1x];
        int symx = symcord1x & 0x7;
        symcord1x >>= 3;
        int cord2x = [Edge3 getmvrot:te->edge m:m<<3|symx e:10] % N_RAW;
        
        int prunx = [Edge3 getprun:symcord1x * N_RAW + cord2x p:prun];
        if (prunx >= maxl) {
            if (prunx > maxl && m < 14) {
                m = skipAxis3[m];
            }
            continue;
        }
        
        if ([self search3:edgex ct:ctx p:prunx m:maxl-1 lm:m d:depth+1]) {
            move3[depth] = m;
            return true;
        }
    }
    return false;
}
@end
