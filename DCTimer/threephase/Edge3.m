//
//  Edge3.m
//  DCTimer
//
//  Created by meigen on 15/10/30.
//
//

#import "Edge3.h"
/*
                    13	1
                4			17
                16			5
                    0	12
	4	16			0	12			5	17			1	13
 9			20	20			11	11			22	22			9
 21			8	8			23	23			10	10			21
	19	7			15	3			18	6			14	2
                    15	3
                7           18
                19			6
                    2	14
 */
@implementation Edge3
const int N_SYM = 1538;
const int N_RAW = 20160;
const int N_EPRUN = N_SYM * N_RAW;
const int MAX_DEPTH = 10;
int prunValues[] = {1, 4, 16, 55, 324, 1922, 12275, 77640, 485359, 2778197, 11742425, 27492416, 31002941, 31006080};
int eprun[N_EPRUN / 16];

int sym2raw[N_SYM];
unsigned short symstate[N_SYM];
int eraw2sym[11880];

int esyminv[] = {0, 1, 6, 3, 4, 5, 2, 7};

int mvrot[160][12];
int mvroto[160][12];

int factX[] = {1, 1, 2/2, 6/2, 24/2, 120/2, 720/2, 5040/2, 40320/2, 362880/2, 3628800/2, 39916800/2, 479001600/2};
int FullEdgeMap[] = {0, 2, 4, 6, 1, 3, 7, 5, 8, 9, 10, 11};

-(id)init {
    if (self = [super init]) {
        isStd = true;
    }
    return self;
}

+(void)initMvrot {
    Edge3 *e = [[Edge3 alloc] init];
    for (int m=0; m<20; m++) {
        for (int r=0; r<8; r++) {
            [e set:0];
            [e move:m];
            [e rotate:r];
            for (int i=0; i<12; i++) {
                mvrot[m<<3|r][i] = e->edge[i];
            }
            [e std];
            for (int i=0; i<12; i++) {
                mvroto[m<<3|r][i] = e->temp[i];
            }
        }
    }
}

+(void)initRaw2Sym {
    Edge3 *e = [[Edge3 alloc] init];
    short occ[1485];
    int count = 0;
    for (int i=0; i<1485; i++) occ[i] = 0;
    for (int i=0; i<11880; i++) {
        if ((occ[i>>3]&(1<<(i&7))) == 0) {
            [e set:(i * factX[8])];
            for (int j=0; j<8; j++) {
                int idx = [e get:4];
                if (idx == i) {
                    symstate[count] |= (1 << j);
                }
                occ[idx>>3] |= (1<<(idx&7));
                eraw2sym[idx] = (count << 3) | esyminv[j];
                [e rot:0];
                if (j%2==1) {
                    [e rot:1];
                    [e rot:2];
                }
            }
            sym2raw[count++] = i;
        }
    }
}

+(void)setPruning:(int)index val:(int)value {
    eprun[index >> 4] ^= (0x3 ^ value) << ((index & 0xf) << 1);
}

+(int)getPruning:(int)index {
    return (eprun[index >> 4] >> ((index & 0xf) << 1)) & 0x3;
}

+(int)getprun:(int)edge prun:(int)prun {
    int depm3 = [Edge3 getPruning:edge];
    if (depm3 == 0x3) {
        return MAX_DEPTH;
    }
    return (depm3 - prun + 16) % 3 + prun - 1;
}

+(int)getprun:(int)edge {
    Edge3 *e = [[Edge3 alloc] init];
    int depth = 0;
    int depm3 = [Edge3 getPruning:edge];
    if (depm3 == 0x3) {
        return MAX_DEPTH;
    }
    while (edge != 0) {
        if (depm3 == 0) {
            depm3 = 2;
        } else {
            depm3--;
        }
        int symcord1 = edge / N_RAW;
        int cord1 = sym2raw[symcord1];
        int cord2 = edge % N_RAW;
        [e set:(cord1 * N_RAW + cord2)];
        
        for (int m=0; m<17; m++) {
            int cord1x = [Edge3 getmvrot:e->edge m:(m<<3) e:4];
            int symcord1x = eraw2sym[cord1x];
            int symx = symcord1x & 0x7;
            symcord1x >>= 3;
            int cord2x = [Edge3 getmvrot:e->edge m:(m<<3)|symx e:10] % N_RAW;
            int idx = symcord1x * N_RAW + cord2x;
            if ([Edge3 getPruning:idx] == depm3) {
                depth++;
                edge = idx;
                break;
            }
        }
    }
    return depth;
}

+(void)createPrun {
    Edge3 *e = [[Edge3 alloc] init];
    Edge3 *f = [[Edge3 alloc] init];
    Edge3 *g = [[Edge3 alloc] init];
    for(int i=0; i<1937880; i++) eprun[i] = -1;
    [Edge3 setPruning:0 val:0];
    //int depth = 0;
    int done = 1;
    for(int depth=0; depth<9; depth++) {
        bool inv = depth > 9;
        int depm3 = depth % 3;
        int dep1m3 = (depth + 1) % 3;
        int find = inv ? 0x3 : depm3;
        int chk = inv ? depm3 : 0x3;
        
        for (int i_=0; i_<N_EPRUN; i_+=16) {
            int val = eprun[i_ >> 4];
            if (!inv && val == -1) continue;
            for (int i=i_, end=i_+16; i<end; i++, val>>=2) {
                if ((val & 0x3) != find) continue;
                int symcord1 = i / N_RAW;
                int cord1 = sym2raw[symcord1];
                int cord2 = i % N_RAW;
                [e set:(cord1 * N_RAW + cord2)];
                
                for (int m=0; m<17; m++) {
                    int cord1x = [Edge3 getmvrot:e->edge m:m<<3 e:4];
                    int symcord1x = eraw2sym[cord1x];
                    int symx = symcord1x & 0x7;
                    symcord1x >>= 3;
                    int cord2x = [Edge3 getmvrot:e->edge m:m<<3|symx e:10] % N_RAW;
                    int idx = symcord1x * N_RAW + cord2x;
                    if ([Edge3 getPruning:idx] != chk) continue;
                    [Edge3 setPruning:inv ? i : idx val:dep1m3];
                    done++;
                    if (inv) break;
                    int symState = symstate[symcord1x];
                    if (symState == 1) continue;
                    [f setEdge:e];
                    [f move:m];
                    [f rotate:symx];
                    for (int j=1; (symState >>= 1) != 0; j++) {
                        if ((symState & 1) != 1) continue;
                        [g setEdge:f];
                        [g rotate:j];
                        int idxx = symcord1x * N_RAW + [g get:10] % N_RAW;
                        if ([Edge3 getPruning:idxx] == chk) {
                            [Edge3 setPruning:idxx val:dep1m3];
                            done++;
                        }
                    }
                }
            }
        }
        NSLog(@"%d %d", depth, done);
    }
}

-(int) getsym {
    int cord1x = [self get:4];
    int symcord1x = eraw2sym[cord1x];
    int symx = symcord1x & 0x7;
    symcord1x >>= 3;
    [self rotate:symx];
    int cord2x = [self get:10] % N_RAW;
    return symcord1x * N_RAW + cord2x;
}

-(int) setEdgeCube:(EdgeCube *)c {
    for (int i=0; i<12; i++) {
        temp[i] = i;
        edge[i] = c->ep[FullEdgeMap[i]+12]%12;
    }
    int parity = 1;	//because of FullEdgeMap
    for (int i=0; i<12; i++) {
        while (edge[i] != i) {
            int t = edge[i];
            edge[i] = edge[t];
            edge[t] = t;
            int s = temp[i];
            temp[i] = temp[t];
            temp[t] = s;
            parity ^= 1;
        }
    }
    for (int i=0; i<12; i++) {
        edge[i] = temp[c->ep[FullEdgeMap[i]]%12];
    }
    return parity;
}

-(void) setEdge:(Edge3 *)e {
    for (int i=0; i<12; i++) {
        self->edge[i] = e->edge[i];
        self->edgeo[i] = e->edgeo[i];
    }
    isStd = e->isStd;
}

+(int) getmvrot:(int[])ep m:(int)mrIdx e:(int)end {
    //int[] movo = mvroto[mrIdx];
    //int[] mov = mvrot[mrIdx];
    int idx = 0;
    
    long long val = 0xba9876543210;
    for (int i=0; i<end; i++) {
        int mov = mvrot[mrIdx][i];
        int v = mvroto[mrIdx][ep[mov]] << 2;
        idx *= 12 - i;
        idx += (val >> v) & 0xf;
        val -= 0x111111111110L << v;
    }
    
    return idx;
}

-(void) std {
    for (int i=0; i<12; i++) {
        temp[edgeo[i]] = i;
    }
    
    for (int i=0; i<12; i++) {
        edge[i] = temp[edge[i]];
        edgeo[i] = i;
    }		
    isStd = true;
}

-(int) get:(int)end {
    if (!isStd) {
        [self std];
    }
    int idx = 0;
    int64_t val = 0xba9876543210;
    for (int i=0; i<end; i++) {
        int v = edge[i] << 2;
        idx *= 12 - i;
        idx += (val >> v) & 0xf;
        val -= 0x111111111110 << v;
    }
    return idx;
}

-(void) set:(int)idx {
    int64_t val = 0xba9876543210;
    int parity = 0;
    for (int i=0; i<11; i++) {
        int p = factX[11-i];
        int v = idx / p;
        idx = idx % p;
        parity ^= v;
        v <<= 2;
        edge[i] = (int) ((val >> v) & 0xf);
        int64_t m = ((int64_t)1 << v) - 1;
        val = (val & m) + ((val >> 4) & ~m);
    }
    if ((parity & 1) == 0) {
        edge[11] = (int) val;
    } else {
        edge[11] = edge[10];
        edge[10] = (int) val;
    }
    for (int i=0; i<12; i++) {
        edgeo[i] = i;
    }
    isStd = true;
}

-(void) move:(int)i {
    isStd = false;
    switch (i) {
        case 0:		//U
            [self circle:edge a:0 b:4 c:1 d:5];
            [self circle:edgeo a:0 b:4 c:1 d:5];
            break;
        case 14:	//u2
            [self swap:edge x:9 y:11];
            [self swap:edgeo x:8 y:10];
        case 1:		//U2
            [self swap:edge a:0 b:4 c:1 d:5];
            [self swap:edgeo a:0 b:4 c:1 d:5];
            break;
        case 2:		//U'
            [self circle:edge a:0 b:5 c:1 d:4];
            [self circle:edgeo a:0 b:5 c:1 d:4];
            break;
        case 15:	//r2
            [self swap:edge x:1 y:3];
            [self swap:edgeo x:0 y:2];
        case 3:		//R2
            [self swap:edge a:5 b:10 c:6 d:11];
            [self swap:edgeo a:5 b:10 c:6 d:11];
            break;
        case 4:		//F
            [self circle:edge a:0 b:11 c:3 d:8];
            [self circle:edgeo a:0 b:11 c:3 d:8];
            break;
        case 16:	//f2
            [self swap:edge x:5 y:7];
            [self swap:edgeo x:4 y:6];
        case 5:		//F2
            [self swap:edge a:0 b:11 c:3 d:8];
            [self swap:edgeo a:0 b:11 c:3 d:8];
            break;
        case 6:		//F'
            [self circle:edge a:0 b:8 c:3 d:11];
            [self circle:edgeo a:0 b:8 c:3 d:11];
            break;
        case 7:		//D
            [self circle:edge a:2 b:7 c:3 d:6];
            [self circle:edgeo a:2 b:7 c:3 d:6];
            break;
        case 17:	//d2
            [self swap:edge x:8 y:10];
            [self swap:edgeo x:9 y:11];
        case 8:		//D2
            [self swap:edge a:2 b:7 c:3 d:6];
            [self swap:edgeo a:2 b:7 c:3 d:6];
            break;
        case 9:		//D'
            [self circle:edge a:2 b:6 c:3 d:7];
            [self circle:edgeo a:2 b:6 c:3 d:7];
            break;
        case 18:	//l2
            [self swap:edge x:0 y:2];
            [self swap:edgeo x:1 y:3];
        case 10:	//L2
            [self swap:edge a:4 b:8 c:7 d:9];
            [self swap:edgeo a:4 b:8 c:7 d:9];
            break;
        case 11:	//B
            [self circle:edge a:1 b:9 c:2 d:10];
            [self circle:edgeo a:1 b:9 c:2 d:10];
            break;
        case 19:	//b2
            [self swap:edge x:4 y:6];
            [self swap:edgeo x:5 y:7];
        case 12:	//B2
            [self swap:edge a:1 b:9 c:2 d:10];
            [self swap:edgeo a:1 b:9 c:2 d:10];
            break;
        case 13:	//B'
            [self circle:edge a:1 b:10 c:2 d:9];
            [self circle:edgeo a:1 b:10 c:2 d:9];
            break;
    }
}

-(void) rot:(int)r {
    isStd = false;
    switch (r) {
        case 0:
            [self move:14];
            [self move:17];
            break;
        case 1:
            [self circlex:11 b:5 c:10 d:6]; //r
            [self circlex:5 b:10 c:6 d:11];
            [self circlex:1 b:2 c:3 d:0];
            [self circlex:4 b:9 c:7 d:8];   //l'
            [self circlex:8 b:4 c:9 d:7];
            [self circlex:0 b:1 c:2 d:3];
            break;
        case 2:
            [self swapx:4 y:5];     [self swapx:5 y:4];
            [self swapx:11 y:8];    [self swapx:8 y:11];
            [self swapx:7 y:6];     [self swapx:6 y:7];
            [self swapx:9 y:10];    [self swapx:10 y:9];
            [self swapx:1 y:1];     [self swapx:0 y:0];
            [self swapx:3 y:3];     [self swapx:2 y:2];
            break;
    }
}

-(void) rotate:(int)r {
    while (r >= 2) {
        r -= 2;
        [self rot:1];
        [self rot:2];
    }
    if (r != 0) {
        [self rot:0];
    }
}

-(void)circle:(int[])arr a:(int)a b:(int)b c:(int)c d:(int)d {
    int t = arr[d];
    arr[d] = arr[c];
    arr[c] = arr[b];
    arr[b] = arr[a];
    arr[a] = t;
}

-(void)swap:(int[])arr a:(int)a b:(int)b c:(int)c d:(int)d {
    int t = arr[a];
    arr[a] = arr[c];
    arr[c] = t;
    t = arr[b];
    arr[b] = arr[d];
    arr[d] = t;
}

-(void) swap:(int[])arr x:(int)x y:(int)y {
    int t = arr[x];
    arr[x] = arr[y];
    arr[y] = t;
}

-(void) swapx:(int)x y:(int)y {
    int t = edge[x];
    edge[x] = edgeo[y];
    edgeo[y] = t;
}

-(void) circlex:(int)a b:(int)b c:(int)c d:(int)d {
    int t = edgeo[d];
    edgeo[d] = edge[c];
    edge[c] = edgeo[b];
    edgeo[b] = edge[a];
    edge[a] = t;
}
@end
