//
//  Edge3.m
//  DCTimer
//
//  Created by MeigenChou on 14-8-15.
//
//

#import "Edge3.h"
#import "EdgeCube.h"

@implementation Edge3

const int N_SYM = 1538;
const int N_RAW = 20160;
const int N_EPRUN = N_SYM * N_RAW;
const int MAX_DEPTH = 10;
const int prunValues[] = {1, 4, 16, 55, 324, 1922, 12275, 77640, 485359, 2778197, 11742425, 27492416, 31002941, 31006080};
const bool IS_64BIT_PLATFORM = (sizeof(long) == 8);

int eprun[N_EPRUN / 16];
int esym2raw[N_SYM];
unsigned short symstate[N_SYM];
int eraw2sym[11880];
int esyminv[] = {0, 1, 6, 3, 4, 5, 2, 7};
int mvrot[160][12];
int mvroto[160][12];
int factX[] = {1, 1, 2/2, 6/2, 24/2, 120/2, 720/2, 5040/2, 40320/2, 362880/2, 3628800/2, 39916800/2, 479001600/2};
//int done;
int FullEdgeMap[] = {0, 2, 4, 6, 1, 3, 7, 5, 8, 9, 10, 11};

-(id) init {
    if (self = [super init]) {
        isStd = true;
    }
    return self;
}

+(void) initMvrot {
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

+(void) initRaw2Sym {
    Edge3 *e = [[Edge3 alloc] init];
    short occ[11880/8];
    int count = 0;
    for (int i=0; i<11880; i++) {
        if ((occ[i>>3]&(1<<(i&7))) == 0) {
            [e set:i * factX[8]];
            for (int j=0; j<8; j++) {
                int idx = [e get:4];
                if (idx == i) {
                    symstate[count] |= 1 << j;
                }
                occ[idx>>3] |= (1<<(idx&7));
                eraw2sym[idx] = count << 3 | esyminv[j];
                [e rot:0];
                if (j%2==1) {
                    [e rot:1];
                    [e rot:2];
                }
            }
            esym2raw[count++] = i;
        }
    }
}

+(void) setPruning:(int[])table i:(int)index v:(int)value {
    table[index >> 4] ^= (0x3 ^ value) << ((index & 0xf) << 1);
}

+(int) getPruning:(int[])table i:(int)index {
    return (table[index >> 4] >> ((index & 0xf) << 1)) & 0x3;
}

+(int) getprun:(int)edge p:(int)prun {
    int depm3 = [Edge3 getPruning:eprun i:edge];
    if (depm3 == 0x3) {
        return MAX_DEPTH;
    }
    return (depm3 - prun + 16) % 3 + prun - 1;
}

+(int) getprun:(int)edge {
    Edge3 *e = [[Edge3 alloc] init];
    int depth = 0;
    int depm3 = [Edge3 getPruning:eprun i:edge];
    if (depm3 == 0x3) {
        return MAX_DEPTH;
    }
    while (edge!=0) {
        if (depm3 == 0) {
            depm3 = 2;
        } else {
            depm3--;
        }
        
        int symcord1 = edge / N_RAW;
        int cord1 = esym2raw[symcord1];
        int cord2 = edge % N_RAW;
        [e set:cord1 * N_RAW + cord2];
        
        for (int m=0; m<17; m++) {
            int cord1x = [Edge3 getmvrot:e->edge m:m<<3 e:4];
            int symcord1x = eraw2sym[cord1x];
            int symx = symcord1x & 0x7;
            symcord1x >>= 3;
            int cord2x = [Edge3 getmvrot:e->edge m:m<<3|symx e:10] % N_RAW;
            int idx = symcord1x * N_RAW + cord2x;
            if ([Edge3 getPruning:eprun i:idx] == depm3) {
                depth++;
                edge = idx;
                break;
            }
        }
    }
    return depth;
}

+(void) createPrun {
    //uint64_t val = 0xba9876543210;
    NSLog(@"int: %lu", sizeof(int));
    Edge3 *e = [[Edge3 alloc] init];
    Edge3 *f = [[Edge3 alloc] init];
    Edge3 *g = [[Edge3 alloc] init];
    for (int i=0; i<1937880; i++) eprun[i] = -1;
    int depth = 0;
    int done = 1;
    [Edge3 setPruning:eprun i:0 v:0];
    while (done != N_EPRUN) {
        bool inv = depth > 9;
        int dm3 = depth % 3;
        int dp1m3 = (depth + 1) % 3;
        int find = inv ? 0x3 : dm3;
        int chk = inv ? dm3 : 0x3;
        
        if (depth >= MAX_DEPTH - 1) {
            break;
        }
        
        for (int i_=0; i_<N_EPRUN; i_+=16) {
            int val = eprun[i_ >> 4];
            if (!inv && val == -1) {
                continue;
            }
            for (int i=i_, end=i_+16; i<end; i++, val>>=2) {
                if ((val & 0x3) != find) {
                    continue;
                }
                int symcord1 = i / N_RAW;
                int cord1 = esym2raw[symcord1];
                int cord2 = i % N_RAW;
                [e set:cord1 * N_RAW + cord2];
                
                for (int m=0; m<17; m++) {
                    int cord1x = [Edge3 getmvrot:e->edge m:m<<3 e:4];
                    int symcord1x = eraw2sym[cord1x];
                    int symx = symcord1x & 0x7;
                    symcord1x >>= 3;
                    int cord2x = [Edge3 getmvrot:e->edge m:m<<3|symx e:10] % N_RAW;
                    int idx = symcord1x * N_RAW + cord2x;
                    if ([Edge3 getPruning:eprun i:idx] != chk) {
                        continue;
                    }
                    [Edge3 setPruning:eprun i:inv ? i : idx v:dp1m3];
                    done++;
                    // if ((done & 0x3ffff) == 0) {
                    // 	System.out.print(String.format("%d\r", done));
                    // }
                    if (inv) {
                        break;
                    }
                    unsigned short symState = symstate[symcord1x];
                    if (symState == 1) {
                        continue;
                    }
                    [f setEdge:e];
                    [f move:m];
                    [f rotate:symx];
                    for (int j=1; (symState >>= 1) != 0; j++) {
                        if ((symState & 1) != 1) {
                            continue;
                        }
                        [g setEdge:f];
                        [g rotate:j];
                        int idxx = symcord1x * N_RAW + [g get:10] % N_RAW;
                        if ([Edge3 getPruning:eprun i:idxx] == chk) {
                            [Edge3 setPruning:eprun i:idxx v:dp1m3];
                            done++;
                            // if ((done & 0x3ffff) == 0) {
                            // 	System.out.print(String.format("%d\r", done));
                            // }
                        }
                    }
                }
            }
        }
        depth++;
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
    //int mov[] = mvrot[mrIdx];
    int idx = 0;
    
    if(IS_64BIT_PLATFORM) {
        long val = 0xba9876543210;
        for (int i=0; i<end; i++) {
            int v = mvroto[mrIdx][ep[mvrot[mrIdx][i]]] << 2;
            idx *= 12 - i;
            idx += (val >> v) & 0xf;
            val -= (long)0x111111111110L << v;
        }
    }
    else {
        int vall = 0x76543210;
        int valh = 0xba98;
        for (int i=0; i<end; i++) {
            int v = mvroto[mrIdx][ep[mvrot[mrIdx][i]]] << 2;
            idx *= 12 - i;
            if (v >= 32) {
                idx += (valh >> (v - 32)) & 0xf;
                valh -= 0x1110 << (v - 32);
            } else {
                idx += (vall >> v) & 0xf;
                valh -= 0x1111;
                vall -= 0x11111110 << v;
            }
        }
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
    
    if(IS_64BIT_PLATFORM) {
        long val = 0xba9876543210;
        for (int i=0; i<end; i++) {
            int v = edge[i] << 2;
            idx *= 12 - i;
            idx += (val >> v) & 0xf;
            val -= (long)0x111111111110 << v;
        }
    }
    else {
        int vall = 0x76543210;
        int valh = 0xba98;
        for (int i=0; i<end; i++) {
            int v = edge[i] << 2;
            idx *= 12 - i;
            if (v >= 32) {
                idx += (valh >> (v - 32)) & 0xf;
                valh -= 0x1110 << (v - 32);
            } else {
                idx += (vall >> v) & 0xf;
                valh -= 0x1111;
                vall -= 0x11111110 << v;
            }
        }
    }
    
    return idx;
}

-(void) set:(int)idx {
    long val = 0xba9876543210;
    int parity = 0;
    for (int i=0; i<11; i++) {
        int p = factX[11-i];
        int v = idx / p;
        idx = idx % p;
        parity ^= v;
        v <<= 2;
        edge[i] = (int) ((val >> v) & 0xf);
        long long m = ((long)1 << v) - 1;
        val = (val & m) + ((val >> 4) & ~m);
    }
    if ((parity & 1) == 0) {
        edge[11] = (int)val;
    } else {
        edge[11] = edge[10];
        edge[10] = (int)val;
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
			circle(edge, 0, 4, 1, 5);
			circle(edgeo, 0, 4, 1, 5);
			break;
		case 1:		//U2
			swap2(edge, 0, 4, 1, 5);
			swap2(edgeo, 0, 4, 1, 5);
			break;
		case 2:		//U'
			circle(edge, 0, 5, 1, 4);
			circle(edgeo, 0, 5, 1, 4);
			break;
		case 3:		//R2
			swap2(edge, 5, 10, 6, 11);
			swap2(edgeo, 5, 10, 6, 11);
			break;
		case 4:		//F
			circle(edge, 0, 11, 3, 8);
			circle(edgeo, 0, 11, 3, 8);
			break;
		case 5:		//F2
			swap2(edge, 0, 11, 3, 8);
			swap2(edgeo, 0, 11, 3, 8);
			break;
		case 6:		//F'
			circle(edge, 0, 8, 3, 11);
			circle(edgeo, 0, 8, 3, 11);
			break;
		case 7:		//D
			circle(edge, 2, 7, 3, 6);
			circle(edgeo, 2, 7, 3, 6);
			break;
		case 8:		//D2
			swap2(edge, 2, 7, 3, 6);
			swap2(edgeo, 2, 7, 3, 6);
			break;
		case 9:		//D'
			circle(edge, 2, 6, 3, 7);
			circle(edgeo, 2, 6, 3, 7);
			break;
		case 10:	//L2
			swap2(edge, 4, 8, 7, 9);
			swap2(edgeo, 4, 8, 7, 9);
			break;
		case 11:	//B
			circle(edge, 1, 9, 2, 10);
			circle(edgeo, 1, 9, 2, 10);
			break;
		case 12:	//B2
			swap2(edge, 1, 9, 2, 10);
			swap2(edgeo, 1, 9, 2, 10);
			break;
		case 13:	//B'
			circle(edge, 1, 10, 2, 9);
			circle(edgeo, 1, 10, 2, 9);
			break;
		case 14:	//u2
			swap2(edge, 0, 4, 1, 5);
			swap2(edgeo, 0, 4, 1, 5);
            [self swap:edge x:9 y:11];
			[self swap:edgeo x:8 y:10];
			break;
		case 15:	//r2
			swap2(edge, 5, 10, 6, 11);
			swap2(edgeo, 5, 10, 6, 11);
            [self swap:edge x:1 y:3];
			[self swap:edgeo x:0 y:2];
			break;
		case 16:	//f2
			swap2(edge, 0, 11, 3, 8);
			swap2(edgeo, 0, 11, 3, 8);
            [self swap:edge x:5 y:7];
            [self swap:edgeo x:4 y:6];
			break;
		case 17:	//d2
			swap2(edge, 2, 7, 3, 6);
			swap2(edgeo, 2, 7, 3, 6);
            [self swap:edge x:8 y:10];
            [self swap:edgeo x:9 y:11];
			break;
		case 18:	//l2
			swap2(edge, 4, 8, 7, 9);
			swap2(edgeo, 4, 8, 7, 9);
            [self swap:edge x:0 y:2];
            [self swap:edgeo x:1 y:3];
			break;
		case 19:	//b2
			swap2(edge, 1, 9, 2, 10);
			swap2(edgeo, 1, 9, 2, 10);
            [self swap:edge x:4 y:6];
            [self swap:edgeo x:5 y:7];
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
            [self swapx:4 y:5]; [self swapx:5 y:4];
			[self swapx:11 y:8];    [self swapx:8 y:11];
            [self swapx:7 y:6]; [self swapx:6 y:7];
			[self swapx:9 y:10];    [self swapx:10 y:9];
			[self swapx:1 y:1]; [self swapx:0 y:0];
			[self swapx:3 y:3]; [self swapx:2 y:2];
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

void circle(int arr[], int a, int b, int c, int d) {
    int t = arr[d];
    arr[d] = arr[c];
    arr[c] = arr[b];
    arr[b] = arr[a];
    arr[a] = t;
}
    
void swap2(int arr[], int a, int b, int c, int d) {
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
