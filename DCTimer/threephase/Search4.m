//
//  Search4.m
//  DCTimer
//
//  Created by meigen on 15/10/30.
//
//

#import "Search4.h"
#import "Center1.h"
#import "Center2.h"
#import "Center3.h"
#import "Edge3.h"
#import "Util4.h"
#import "Moves.h"
#import "PriorityQueue.h"
#import "DCTUtils.h"
#import "Util.h"

@implementation Search4
@synthesize c, c1, c2;
@synthesize ct2, ct3, e12;
@synthesize tempe;
@synthesize cube3;
@synthesize solution;
@synthesize arr2;
@synthesize p1sols;

const int PHASE1_SOLUTIONS = 5000;
const int PHASE2_ATTEMPTS = 500;
const int PHASE2_SOLUTIONS = 50;
const int PHASE3_ATTEMPTS = 50;
static bool inited4 = false;

extern int ckmv[][36];
extern int ckmv2[][28];
extern int ckmv3[][20];
extern int skipAxis2[28];
extern int skipAxis3[20];
extern unsigned short ctmove[][20];
extern char ct3prun[];
extern int eraw2sym[];
extern int N_RAW;
extern unsigned short ctmv[][28];
extern int rlmv[70][28];
extern char ct2prun[];
extern int move2std[];
extern int move3std[];
extern int finish[48];
extern int fx1, bx3, ux1, dx3;
extern int symmove4[48][36];
extern int symmult4[48][48];
extern int ctsmv[][36];
extern char csprun[];
extern int eprun[];
extern int csym2raw[];
extern int craw2sym[];

-(id)init {
    if (self = [super init]) {
        c1 = [[FullCube alloc] init];
        c2 = [[FullCube alloc] init];
        ct2 = [[Center2 alloc] init];
        ct3 = [[Center3 alloc] init];
        e12 = [[Edge3 alloc] init];
        tempe = [[NSMutableArray alloc] init];
        for(int i=0; i<20; i++)
            [tempe addObject:[[Edge3 alloc] init]];
        cube3 = [[Search alloc] init];
        p1sols = [[PriorityQueue alloc] init];
    }
    return self;
}

+(void)initTable {
    if (inited4) return;
    [Util initCnk];
    [Moves initMoves];
    [CornerCube initMove];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSLog(@"init center1...");
    [Center1 initSym];
    NSString *pathc = [DCTUtils getFilePath:@"center.dat"];
    if ([fileMgr fileExistsAtPath:pathc]) {
        NSData *reader = [NSData dataWithContentsOfFile:pathc];
        [reader getBytes:&csym2raw length:62328];
        [reader getBytes:&craw2sym range:NSMakeRange(62328, 2941884)];
        [reader getBytes:&ctsmv range:NSMakeRange(3004212, 2243808)];
    } else {
        NSLog(@"init sym2raw...");
        [Center1 initSym2Raw];
        NSLog(@"init move...");
        [Center1 createMoveTable];
        NSMutableData *writer = [[NSMutableData alloc] init];
        [writer appendBytes:&csym2raw length:62328];
        [writer appendBytes:&craw2sym length:2941884];
        [writer appendBytes:&ctsmv length:2243808];
        [writer writeToFile:pathc atomically:YES];
    }
    [Center1 createPrun];
    
    NSLog(@"init center2...");
    [Center2 initRL];
    //NSLog(@"init move...");
    [Center2 initMove];
    //NSLog(@"init prun...");
    [Center2 initPrun];
    
    NSLog(@"init center3...");
    [Center3 initCent3];
    [Center3 initMove];
    //NSLog(@"init prun...");
    [Center3 initPrun];
    
    NSLog(@"init edge3...");
    [Edge3 initMvrot];
    [Edge3 initRaw2Sym];
    NSString *pathe = [DCTUtils getFilePath:@"edge.dat"];
    if ([fileMgr fileExistsAtPath:pathe]) {
        NSData *reader = [NSData dataWithContentsOfFile:pathe];
        [reader getBytes:&eprun length:7751520];
    } else {
        [Edge3 createPrun];
        NSMutableData *writer = [[NSMutableData alloc] init];
        [writer appendBytes:&eprun length:7751520];
        [writer writeToFile:pathe atomically:YES];
    }
    NSLog(@"OK");
    inited4 = true;
}

-(NSString *)randomMove {
    int moveseq[40];
    int lm = 36;
    for (int i=0; i<40; ) {
        int m = rand() % 27;
        if (!ckmv2[lm][m]) {
            moveseq[i++] = m;
            lm = m;
        }
    }
    return [self solve:moveseq len:40];
}

-(NSString *)randomState {
    c = [[FullCube alloc] initRandomCube];
    //[c print];
    [self doSearch];
    return solution;
}

-(NSString *) solution:(NSString *)facelet {
    int f[96];
    NSString *ts = @"URFDLB";
    for (int i=0; i<96; i++) {
        f[i] = [DCTUtils indexOf:ts c:[facelet characterAtIndex:i]];
    }
    c = [[FullCube alloc] initWithFacelet:f];
    [self doSearch];
    return solution;
}

-(NSString *)solve:(int[])moveseq len:(int)movelen {
    c = [[FullCube alloc] initWithMove:moveseq len:movelen];
    [self doSearch];
    return solution;
}

-(void)doSearch {
    solution = @"";
    int ud = [[[Center1 alloc] initCentUrf:[c getCenter] urf:0] getsym];
    int fb = [[[Center1 alloc] initCentUrf:[c getCenter] urf:1] getsym];
    int rl = [[[Center1 alloc] initCentUrf:[c getCenter] urf:2] getsym];
    int udprun = csprun[ud >> 6];
    int fbprun = csprun[fb >> 6];
    int rlprun = csprun[rl >> 6];
    
    p1SolsCnt = 0;
    arr2 = [[NSMutableArray alloc] init];
    [p1sols clear];
    for (length1 = MIN(MIN(udprun, fbprun), rlprun); length1<100; length1++) {
        if ((rlprun <= length1 && [self search1:rl>>6 sym:rl&0x3f maxl:length1 lm:-1 d:0])
            || (udprun <= length1 && [self search1:ud>>6 sym:ud&0x3f maxl:length1 lm:-1 d:0])
            || (fbprun <= length1 && [self search1:fb>>6 sym:fb&0x3f maxl:length1 lm:-1 d:0])) {
            break;
        }
    }
    NSMutableArray *p1solsArr = [p1sols toArray];
    [p1solsArr sortUsingComparator:^NSComparisonResult(FullCube *cube1, FullCube *cube2) {
        return cube1->value - cube2->value;
    }];
    
    int MAX_LENGTH2 = 9;
    int length12 = 0;
    do {
        FullCube *c0 = [p1solsArr objectAtIndex:0];
        for (length12=c0->value; length12<100; length12++) {
            for (int i=0; i<p1solsArr.count; i++) {
                FullCube *ci = [p1solsArr objectAtIndex:i];
                if (ci->value > length12)
                    break;
                if (length12 - ci->length1 > MAX_LENGTH2)
                    continue;
                [c1 copy:ci];
                [ct2 set:[c1 getCenter] ep:[[c1 getEdge] getParity]];
                int s2ct = [ct2 getct];
                int s2rl = [ct2 getrl];
                length1 = ci->length1;
                length2 = length12 - ci->length1;
                if ([self search2:s2ct rl:s2rl maxl:length2 lm:28 d:0]) {
                    goto OUT;
                }
            }
        }
    OUT:
        MAX_LENGTH2++;
    } while (length12 == 100);
    
    [arr2 sortUsingComparator:^NSComparisonResult(FullCube *cube1, FullCube *cube2) {
        return cube1->value - cube2->value;
    }];
    int length123, index = 0;
    int solcnt = 0;
    int MAX_LENGTH3 = 13;
    do {
        FullCube *arr0 = [arr2 objectAtIndex:0];
        for (length123=arr0->value; length123<100; length123++) {
            for (int i=0; i<MIN(PHASE2_SOLUTIONS, PHASE3_ATTEMPTS); i++) {
                FullCube *arri = [arr2 objectAtIndex:i];
                if (arri->value > length123)
                    break;
                int length3 = length123 - arri->length1 - arri->length2;
                if (length3 > MAX_LENGTH3)
                    continue;
                int eparity = [e12 setEdgeCube:[arri getEdge]];
                [ct3 set:[arri getCenter] ep:eparity ^ [[arri getCorner] getParity]];
                int ct = [ct3 getct];
                int edge = [e12 get:10];
                int prun = [Edge3 getprun:[e12 getsym]];
                int lm = 20;
                if (prun <= length3 && [self search3:edge ct:ct prun:prun maxl:length3 lm:lm d:0]) {
                    
                    solcnt++;
                    index = i;
                    goto OUT2;
                }
            }
        }
    OUT2:
        MAX_LENGTH3++;
    } while (length123 == 100);
    
    FullCube *solcube = [arr2 objectAtIndex:index];
    length1 = solcube->length1;
    length2 = solcube->length2;
    int length = length123 - length1 - length2;
    for (int i=0; i<length; i++) {
        [solcube move:move3std[move3[i]]];
    }
    NSString *facelet = [solcube to333Facelet];
    NSLog(@"cube 3x3: %@", facelet);
    NSString *sol333 = [cube3 solutionForFacelets:facelet md:21 nt:5000 tm:100 v:0];
    //NSLog(@"%@", sol333);
    if ([sol333 hasPrefix:@"Error"]) {
        solution = @"Error";
    } else {
        NSMutableArray *sol3 = [Util4 tomove:sol333];
        for (int i=0; i<sol3.count; i++) {
            [solcube move:[[sol3 objectAtIndex:i] intValue]];
        }
        solution = [solcube getMoveString:true rot:false];
    }
}

-(bool)search1:(int)ct sym:(int)sym maxl:(int)maxl lm:(int)lm d:(int)depth {
    if (ct==0 && maxl < 5) {
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
            ctx >>= 6;
            move1[depth] = m;
            if ([self search1:ctx sym:symx maxl:maxl-1 lm:axis d:depth+1]) {
                return true;
            }
        }
    }
    return false;
}

-(bool)init2:(int)sym lm:(int)lm {
    [c1 copy:c];
    for (int i=0; i<length1; i++) {
        [c1 move:move1[i]];
    }
    
    switch (finish[sym]) {
        case 0 :
            [c1 move:fx1];
            [c1 move:bx3];
            move1[length1] = fx1;
            move1[length1+1] = bx3;
            add1 = true;
            sym = 19;
            break;
        case 12869 :
            [c1 move:ux1];
            [c1 move:dx3];
            move1[length1] = ux1;
            move1[length1+1] = dx3;
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
    
    FullCube *next;
    p1SolsCnt++;
    if ([p1sols size] < PHASE2_ATTEMPTS) {
        next = [[FullCube alloc] initFullcube:c1];
    } else {
        next = [p1sols poll];
        if (next->value > c1->value)
            [next copy:c1];
    }
    [p1sols add:next];
    
    return p1SolsCnt == PHASE1_SOLUTIONS;
    //return true;
}

-(bool)search2:(int)ct rl:(int)rl maxl:(int)maxl lm:(int)lm d:(int)depth {
    if (ct==0 && ct2prun[rl] == 0 && maxl == 0) {
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
        if ([self search2:ctx rl:rlx maxl:maxl-1 lm:m d:depth+1]) {
            return true;
        }
    }
    return false;
}

-(bool)init3 {
    [c2 copy:c1];
    for (int i=0; i<length2; i++) {
        [c2 move:move2[i]];
    }
    if (![c2 checkEdge]) return false;
    
    int eparity = [e12 setEdgeCube:[c2 getEdge]];
    [ct3 set:[c2 getCenter] ep:eparity ^ [[c2 getCorner] getParity]];
    int ct = [ct3 getct];
    //int edge = [e12 get:10];
    int prun = [Edge3 getprun:[e12 getsym]];
    
    FullCube *next = [[FullCube alloc] initFullcube:c2];
    next->value = length1 + length2 + MAX(prun, ct3prun[ct]);
    next->length2 = length2;
    [arr2 addObject:next];
    return arr2.count == PHASE2_SOLUTIONS;
}

-(bool)search3:(int)edge ct:(int)ct prun:(int)prun maxl:(int)maxl lm:(int)lm d:(int)depth {
    if (maxl == 0) {
        return edge == 0 && ct == 0;
    }
    Edge3 *edged = [tempe objectAtIndex:depth];
    [edged set:edge];
    //[tempe replaceObjectAtIndex:depth withObject:edged];
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
        Edge3 *e = [tempe objectAtIndex:depth];
        int edgex = [Edge3 getmvrot:e->edge m:m<<3 e:10];
        
        int cord1x = edgex / N_RAW;
        int symcord1x = eraw2sym[cord1x];
        int symx = symcord1x & 0x7;
        symcord1x >>= 3;
        int cord2x = [Edge3 getmvrot:e->edge m:m<<3|symx e:10] % N_RAW;
        
        int prunx = [Edge3 getprun:symcord1x * N_RAW + cord2x prun:prun];
        if (prunx >= maxl) {
            if (prunx > maxl && m < 14) {
                m = skipAxis3[m];
            }
            continue;
        }
        
        if ([self search3:edgex ct:ctx prun:prunx maxl:maxl-1 lm:m d:depth+1]) {
            move3[depth] = m;
            return true;
        }
    }
    return false;
}
@end
