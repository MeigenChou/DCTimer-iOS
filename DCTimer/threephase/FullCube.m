//
//  FullCube.m
//  DCTimer
//
//  Created by meigen on 15/10/31.
//
//
/*
Edge Cubies:
                    14	2
                1			15
                13			3
                    0	12
	1	13			0	12			3	15			2	14
 9			20	20			11	11			22	22			9
 21			8	8			23	23			10	10			21
	17	5			18	6			19	7			16	4
                    18	6
                5			19
                17			7
                    4	16
 
 Center Cubies:
            0	1
            3	2
 
 20	21		8	9		16	17		12	13
 23	22		11	10		19	18		15	14
 
            4	5
            7	6
 
            |************|
            |*U1**U2**U3*|
            |************|
            |*U4**U5**U6*|
            |************|
            |*U7**U8**U9*|
            |************|
************|************|************|************|
*L1**L2**L3*|*F1**F2**F3*|*R1**R2**F3*|*B1**B2**B3*|
************|************|************|************|
*L4**L5**L6*|*F4**F5**F6*|*R4**R5**R6*|*B4**B5**B6*|
************|************|************|************|
*L7**L8**L9*|*F7**F8**F9*|*R7**R8**R9*|*B7**B8**B9*|
************|************|************|************|
            |************|
            |*D1**D2**D3*|
            |************|
            |*D4**D5**D6*|
            |************|
            |*D7**D8**D9*|
            |************|
 
 
                |****************|
                |*u0**u1**u2**u3*|
                |****************|
                |*u4**u5**u6**u7*|
                |****************|
                |*u8**u9**ua**ub*|
                |****************|
                |*uc**ud**ue**uf*|
                |****************|
****************|****************|****************|****************|
*l0**l1**l2**l3*|*f0**f1**f2**f3*|*r0**r1**r2**r3*|*b0**b1**b2**b3*|
****************|****************|****************|****************|
*l4**l5**l6**l7*|*f4**f5**f6**f7*|*r4**r5**r6**r7*|*b4**b5**b6**b7*|
****************|****************|****************|****************|
*l8**l9**la**lb*|*f8**f9**fa**fb*|*r8**r9**ra**rb*|*b8**b9**ba**bb*|
****************|****************|****************|****************|
*lc**ld**le**lf*|*fc**fd**fe**ff*|*rc**rd**re**rf*|*bc**bd**be**bf*|
****************|****************|****************|****************|
                |****************|
                |*d0**d1**d2**d3*|
                |****************|
                |*d4**d5**d6**d7*|
                |****************|
                |*d8**d9**da**db*|
                |****************|
                |*dc**dd**de**df*|
                |****************|
 */

#import "FullCube.h"
#import "Center1.h"

@implementation FullCube
@synthesize edge, center, corner;
@synthesize rot2str, move2str;

const int u0 = 0x0;
const int u1 = 0x1;
const int u2 = 0x2;
const int u3 = 0x3;
const int u4 = 0x4;
const int u5 = 0x5;
const int u6 = 0x6;
const int u7 = 0x7;
const int u8 = 0x8;
const int u9 = 0x9;
const int ua = 0xa;
const int ub = 0xb;
const int uc = 0xc;
const int ud = 0xd;
const int ue = 0xe;
const int uf = 0xf;
const int r0 = 0x10;
const int r1 = 0x11;
const int r2 = 0x12;
const int r3 = 0x13;
const int r4 = 0x14;
const int r5 = 0x15;
const int r6 = 0x16;
const int r7 = 0x17;
const int r8 = 0x18;
const int r9 = 0x19;
const int ra = 0x1a;
const int rb = 0x1b;
const int rc = 0x1c;
const int rd = 0x1d;
const int re = 0x1e;
const int rf = 0x1f;
const int f0 = 0x20;
const int f1 = 0x21;
const int f2 = 0x22;
const int f3 = 0x23;
const int f4 = 0x24;
const int f5 = 0x25;
const int f6 = 0x26;
const int f7 = 0x27;
const int f8 = 0x28;
const int f9 = 0x29;
const int fa = 0x2a;
const int fb = 0x2b;
const int fc = 0x2c;
const int fd = 0x2d;
const int fe = 0x2e;
const int ff = 0x2f;
const int d0 = 0x30;
const int d1 = 0x31;
const int d2 = 0x32;
const int d3 = 0x33;
const int d4 = 0x34;
const int d5 = 0x35;
const int d6 = 0x36;
const int d7 = 0x37;
const int d8 = 0x38;
const int d9 = 0x39;
const int da = 0x3a;
const int db = 0x3b;
const int dc = 0x3c;
const int dd = 0x3d;
const int de = 0x3e;
const int df = 0x3f;
const int l0 = 0x40;
const int l1 = 0x41;
const int l2 = 0x42;
const int l3 = 0x43;
const int l4 = 0x44;
const int l5 = 0x45;
const int l6 = 0x46;
const int l7 = 0x47;
const int l8 = 0x48;
const int l9 = 0x49;
const int la = 0x4a;
const int lb = 0x4b;
const int lc = 0x4c;
const int ld = 0x4d;
const int le = 0x4e;
const int lf = 0x4f;
const int b0 = 0x50;
const int b1 = 0x51;
const int b2 = 0x52;
const int b3 = 0x53;
const int b4 = 0x54;
const int b5 = 0x55;
const int b6 = 0x56;
const int b7 = 0x57;
const int b8 = 0x58;
const int b9 = 0x59;
const int ba = 0x5a;
const int bb = 0x5b;
const int bc = 0x5c;
const int bd = 0x5d;
const int be = 0x5e;
const int bf = 0x5f;
extern int symmove4[48][36];
extern int symmult4[48][48];
extern int csyminv[48];
extern int dx1;

int centerFacelet[] = {u5, u6, ua, u9, d5, d6, da, d9, f5, f6, fa, f9, b5, b6, ba, b9, r5, r6, ra, r9, l5, l6, la, l9};
int edgeFacelet4[24][2] = {{ud, f1}, {u4, l1}, {u2, b1}, {ub, r1}, {dd, be}, {d4, le}, {d2, fe}, {db, re}, {lb, f8}, {l4, b7}, {rb, b8}, {r4, f7}, {f2, ue}, {l2, u8}, {b2, u1}, {r2, u7}, {bd, de}, {ld, d8}, {fd, d1}, {rd, d7}, {f4, l7}, {bb, l8}, {b4, r7}, {fb, r8}};
int cornerFacelet4[8][3] = { { uf, r0, f3 }, { uc, f0, l3 }, { u0, l0, b3 }, { u3, b0, r3 }, { d3, ff, rc }, { d0, lf, fc }, { dc, bf, lc }, { df, rf, bc } };

int move2rot[] = {35, 1, 34, 2, 4, 6, 22, 5, 19};

-(id)init {
    if (self = [super init]) {
        [self initVars];
        edge = [[EdgeCube alloc] init];
        center = [[CenterCube alloc] init];
        corner = [[CornerCube alloc] init];
    }
    return self;
}

-(void)initVars {
    value = 0;
    add1 = false;
    length1 = 0;
    length2 = 0;
    length3 = 0;
    moveLength = 0;
    edgeAvail = 0;
    centerAvail = 0;
    cornerAvail = 0;
    sym = 0;
    rot2str = [[NSArray alloc] initWithObjects:@"", @"y2", @"x", @"x y2", @"x2", @"z2", @"x'", @"x' y2", @"", @"", @"", @"", @"", @"", @"", @"",
               @"y z", @"y' z'", @"y2 z", @"z'", @"y' z", @"y z'", @"z", @"z y2", @"", @"", @"", @"", @"", @"", @"", @"",
               @"y' x'", @"y x", @"y'", @"y", @"y' x", @"y x'", @"y z2", @"y' z2", @"", @"", @"", @"", @"", @"", @"", @"", nil];
    move2str = [[NSArray alloc] initWithObjects:@"U", @"U2", @"U'", @"R", @"R2", @"R'", @"F", @"F2", @"F'",
                @"D", @"D2", @"D'", @"L", @"L2", @"L'", @"B", @"B2", @"B'",
                @"Uw", @"Uw2", @"Uw'", @"Rw", @"Rw2", @"Rw'", @"Fw", @"Fw2", @"Fw'",
                @"Dw", @"Dw2", @"Dw'", @"Lw", @"Lw2", @"Lw'", @"Bw", @"Bw2", @"Bw'", nil];
}

-(id)initWithFacelet:(int[])f {
    if (self = [super init]) {
        [self initVars];
        edge = [[EdgeCube alloc] init];
        center = [[CenterCube alloc] init];
        corner = [[CornerCube alloc] init];
        for (int i=0; i<24; i++) {
            center->ct[i] = f[centerFacelet[i]];
        }
        for (int i=0; i<24; i++) {
            for (int j=0; j<24; j++) {
                if (f[edgeFacelet4[i][0]] == edgeFacelet4[j][0]/16 && f[edgeFacelet4[i][1]] == edgeFacelet4[j][1]/16) {
                    edge->ep[i] = j;
                }
            }
        }
        int col1, col2, ori;
        for (int i=0; i<8; i++) {
            // get the colors of the cubie at corner i, starting with U/D
            for (ori = 0; ori < 3; ori++)
                if (f[cornerFacelet4[i][ori]] == u0/16 || f[cornerFacelet4[i][ori]] == d0/16)
                    break;
            col1 = f[cornerFacelet4[i][(ori + 1) % 3]];
            col2 = f[cornerFacelet4[i][(ori + 2) % 3]];
            
            for (int j=0; j<8; j++) {
                if (col1 == cornerFacelet4[j][1]/16 && col2 == cornerFacelet4[j][2]/16) {
                    // in cornerposition i we have cornercubie j
                    corner->cp[i] = j;
                    corner->co[i] = ori % 3;
                    break;
                }
            }
        }
    }
    return self;
}

-(id)initFullcube:(FullCube *)c {
    if (self = [super init]) {
        [self initVars];
        edge = [[EdgeCube alloc] init];
        center = [[CenterCube alloc] init];
        corner = [[CornerCube alloc] init];
        [self copy:c];
    }
    return self;
}

-(id)initRandomCube {
    if (self = [super init]) {
        [self initVars];
        edge = [[EdgeCube alloc] initRandomEdge];
        center = [[CenterCube alloc] initRandomCent];
        corner = [[CornerCube alloc] initRandomCorn];
    }
    return self;
}

-(id)initCorner:(int[])cp co:(int[])co {
    if (self = [super init]) {
        [self initVars];
        edge = [[EdgeCube alloc] initRandomEdge];
        center = [[CenterCube alloc] initRandomCent];
        corner = [[CornerCube alloc] initCorner:cp co:co];
    }
    return self;
}

-(void)toFacelet:(int[])f {
    for (int i=0; i<24; i++) {
        f[centerFacelet[i]] = center->ct[i];
    }
    for (int i=0; i<24; i++) {
        f[edgeFacelet4[i][0]] = edgeFacelet4[edge->ep[i]][0]/16;
        f[edgeFacelet4[i][1]] = edgeFacelet4[edge->ep[i]][1]/16;
    }
    for (int c=0; c<8; c++) {
        int j = corner->cp[c];
        int ori = corner->co[c];
        for (int n=0; n<3; n++)
            f[cornerFacelet4[c][(n + ori) % 3]] = cornerFacelet4[j][n]/16;
    }
}

-(NSString *)toString {
    [self getEdge];
    [self getCenter];
    [self getCorner];
    int f[96];
    NSMutableString *str = [NSMutableString string];
    char ts[] = {'U', 'R', 'F', 'D', 'L', 'B'};
    [self toFacelet:f];
    for (int i=0; i<96; i++) {
        [str appendFormat:@"%c", ts[f[i]]];
        if (i % 4 == 3) {
            [str appendString:@"\n"];
        }
        if (i % 16 == 15) {
            [str appendString:@"\n"];
        }
    }
    return str;
}

-(void)print {
    NSLog(@"edge: %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d", edge->ep[0], edge->ep[1], edge->ep[2], edge->ep[3], edge->ep[4], edge->ep[5], edge->ep[6], edge->ep[7], edge->ep[8], edge->ep[9], edge->ep[10], edge->ep[11], edge->ep[12], edge->ep[13], edge->ep[14], edge->ep[15], edge->ep[16], edge->ep[17], edge->ep[18], edge->ep[19], edge->ep[20], edge->ep[21], edge->ep[22], edge->ep[23]);
    NSLog(@"center: %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d", center->ct[0], center->ct[1], center->ct[2], center->ct[3], center->ct[4], center->ct[5], center->ct[6], center->ct[7], center->ct[8], center->ct[9], center->ct[10], center->ct[11], center->ct[12], center->ct[13], center->ct[14], center->ct[15], center->ct[16], center->ct[17], center->ct[18], center->ct[19], center->ct[20], center->ct[21], center->ct[22], center->ct[23]);
    NSLog(@"cp: %d, %d, %d, %d, %d, %d, %d, %d", corner->cp[0], corner->cp[1], corner->cp[2], corner->cp[3], corner->cp[4], corner->cp[5], corner->cp[6], corner->cp[7]);
    NSLog(@"co: %d, %d, %d, %d, %d, %d, %d, %d", corner->co[0], corner->co[1], corner->co[2], corner->co[3], corner->co[4], corner->co[5], corner->co[6], corner->co[7]);
}

-(int)compareTo:(FullCube *)c {
    return self->value - c->value;
}

-(void)copy:(FullCube *)c {
    [edge copy:c->edge];
    [center copy:c->center];
    [corner copy:c->corner];
    
    value = c->value;
    add1 = c->add1;
    length1 = c->length1;
    length2 = c->length2;
    length3 = c->length3;
    
    sym = c->sym;
    
    for (int i=0; i<60; i++) {
        moveBuffer[i] = c->moveBuffer[i];
    }
    moveLength = c->moveLength;
    edgeAvail = c->edgeAvail;
    centerAvail = c->centerAvail;
    cornerAvail = c->cornerAvail;
}

-(bool)checkEdge {
    return [[self getEdge] checkEdge];
}

//public String getMoveString(boolean inverse, boolean rotation)
-(NSString *)getMoveString:(bool)inverse rot:(bool)rotation {
    //int fixedMoves[] = new int[moveLength - (add1 ? 2 : 0)];
    NSMutableArray *fixedMoves = [[NSMutableArray alloc] init];
    
    for (int i=0; i<length1; i++) {
        [fixedMoves addObject:@(moveBuffer[i])];
    }
    int symm = self->sym;
    for (int i=length1 + (add1 ? 2 : 0); i<moveLength; i++) {
        if (symmove4[symm][moveBuffer[i]] >= dx1) {
            [fixedMoves addObject:@(symmove4[symm][moveBuffer[i]] - 9)];
            int rot = move2rot[symmove4[symm][moveBuffer[i]] - dx1];
            symm = symmult4[symm][rot];
        } else {
            [fixedMoves addObject:@(symmove4[symm][moveBuffer[i]])];
        }
    }
    int idx = (int)fixedMoves.count;
    int finishSym = symmult4[csyminv[symm]][[Center1 getSolvedSym:[self getCenter]]];
    NSMutableString *str = [NSMutableString string];
    symm = finishSym;
    if (inverse) {
        for (int i=idx-1; i>=0; i--) {
            int move = [[fixedMoves objectAtIndex:i] intValue];
            move = move / 3 * 3 + (2 - move % 3);
            if (symmove4[symm][move] >= dx1) {
                [str appendFormat:@"%@ ", [move2str objectAtIndex:symmove4[symm][move] - 9]];
                int rot = move2rot[symmove4[symm][move] - dx1];
                symm = symmult4[symm][rot];
            } else {
                [str appendFormat:@"%@ ", [move2str objectAtIndex:symmove4[symm][move]]];
            }
        }
        if (rotation) {
            [str appendString:[rot2str objectAtIndex:csyminv[symm]]];
        }
    } else {
        for (int i=0; i<idx; i++) {
            int move = [[fixedMoves objectAtIndex:i] intValue];
            [str appendFormat:@"%@ ", [move2str objectAtIndex:move]];
        }
        if (rotation) {
            [str appendString:[rot2str objectAtIndex:finishSym]];
        }
    }
    return str;
}

-(NSString *)to333Facelet {
    char ret[54];
    [[self getEdge] fill333Facelet:ret];
    [[self getCenter] fill333Facelet:ret];
    [[self getCorner] fill333Facelet:ret];
    return [[NSString alloc] initWithCString:(char*)ret encoding:NSASCIIStringEncoding];
}

-(void)move:(int)m {
    moveBuffer[moveLength++] = m;
}

-(void)doMove:(int)m {
    [[self getEdge] move:m];
    [[self getCenter] move:m];
    [[self getCorner] move:m % 18];
}

-(EdgeCube *)getEdge {
    while (edgeAvail < moveLength) {
        [edge move:moveBuffer[edgeAvail++]];
    }
    return edge;
}

-(CenterCube *)getCenter {
    while (centerAvail < moveLength) {
        [center move:moveBuffer[centerAvail++]];
    }
    return center;
}

-(CornerCube *)getCorner {
    while (cornerAvail < moveLength) {
        [corner move:moveBuffer[cornerAvail++] % 18];
    }
    return corner;
}

@end
