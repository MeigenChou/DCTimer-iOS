//
//  Search.m
//  DCTimer Scramblers
//
//  Adapted from Shuang Chen's min2phase implementation of the Kociemba algorithm, as obtained from https://github.com/ChenShuang/min2phase
//
//  Copyright (c) 2013, Shuang Chen
//  All rights reserved.
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//  Neither the name of the creator nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "Search.h"
#import "CubieCube.h"
#import "CoordCube.h"
#import "Util3.h"
#import "DCTUtils.h"
#import "Sys/time.h"

@implementation Search
@synthesize move2str;
@synthesize cc;

int urfMove[6][18] = {{0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17},
    {6, 7, 8, 0, 1, 2, 3, 4, 5,15,16,17, 9,10,11,12,13,14},
    {3, 4, 5, 6, 7, 8, 0, 1, 2,12,13,14,15,16,17, 9,10,11},
    {2, 1, 0, 5, 4, 3, 8, 7, 6,11,10, 9,14,13,12,17,16,15},
    {8, 7, 6, 2, 1, 0, 5, 4, 3,17,16,15,11,10, 9,14,13,12},
    {5, 4, 3, 8, 7, 6, 2, 1, 0,14,13,12,17,16,15,11,10, 9}};
extern unsigned short MtoEPerm[];

extern unsigned short UDSliceMove[495][18];
extern unsigned short TwistMove[324][18];
extern unsigned short FlipMove[336][18];
extern unsigned short UDSliceConj[495][8];
extern int UDSliceTwistPrun[];
extern int UDSliceFlipPrun[];

extern int SymMult[16][16];
extern int SymMove[16][18];
extern int Sym8Mult[8][8];
extern int Sym8Move[8][18];
extern int SymMoveUD[16][10];
extern int permMult[24][24];

extern unsigned short CPermMove[2768][18];
extern unsigned short EPermMove[2768][10];
extern unsigned short MPermMove[24][10];
extern unsigned short MPermConj[24][16];
extern int MCPermPrun[];
extern int MEPermPrun[];

extern int std2ud[18];
extern int ud2std[];
extern bool ckmov2[11][10];

- (id)init {
    if (self = [super init]) {
        cc = [[CubieCube alloc] init];
        move2str = [[NSArray alloc] initWithObjects:@"U", @"U2", @"U'", @"R", @"R2", @"R'", @"F", @"F2", @"F'", @"D", @"D2", @"D'", @"L", @"L2", @"L'", @"B", @"B2", @"B'", nil];
    }
    return self;
}

static bool inited3 = false;
+ (void)initTable {
    if (inited3) return;
    NSLog(@"init 3x3...");
    [CubieCube initMove];
    [CubieCube initSym];
    [CubieCube initFlipSym2Raw];
    [CubieCube initTwistSym2Raw];
    [CubieCube initPermSym2Raw];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *path = [DCTUtils getFilePath:@"twophase.dat"];
    if ([fileMgr fileExistsAtPath:path]) {
        NSData *reader = [NSData dataWithContentsOfFile:path];
        [reader getBytes:&TwistMove length:11664];
        [reader getBytes:&FlipMove range:NSMakeRange(11664, 12096)];
        [reader getBytes:&UDSliceMove range:NSMakeRange(23760, 17820)];
        [reader getBytes:&UDSliceConj range:NSMakeRange(41580, 7920)];
        [reader getBytes:&CPermMove range:NSMakeRange(49500, 99648)];
        [reader getBytes:&EPermMove range:NSMakeRange(149148, 55360)];
        [reader getBytes:&MPermMove range:NSMakeRange(204508, 480)];
        [reader getBytes:&MPermConj range:NSMakeRange(204988, 768)];
        [reader getBytes:&UDSliceTwistPrun range:NSMakeRange(205756, 80192)];
        [reader getBytes:&UDSliceFlipPrun range:NSMakeRange(285948, 83160)];
        [reader getBytes:&MCPermPrun range:NSMakeRange(369108, 33216)];
        [reader getBytes:&MEPermPrun range:NSMakeRange(402324, 33216)];
    } else {
        NSLog(@"init coord...");
        [CoordCube initFlipMove];
        [CoordCube initTwistMove];
        [CoordCube initUDSliceMoveConj];
        [CoordCube initCPermMove];
        [CoordCube initEPermMove];
        [CoordCube initMPermMoveConj];
        [CoordCube initSliceTwistPrun];
        [CoordCube initSliceFlipPrun];
        [CoordCube initMEPermPrun];
        [CoordCube initMCPermPrun];
        NSMutableData *writer = [[NSMutableData alloc] init];
        [writer appendBytes:&TwistMove length:11664];
        [writer appendBytes:&FlipMove length:12096];
        [writer appendBytes:&UDSliceMove length:17820];
        [writer appendBytes:&UDSliceConj length:7920];
        [writer appendBytes:&CPermMove length:99648];
        [writer appendBytes:&EPermMove length:55360];
        [writer appendBytes:&MPermMove length:480];
        [writer appendBytes:&MPermConj length:768];
        [writer appendBytes:&UDSliceTwistPrun length:80192];
        [writer appendBytes:&UDSliceFlipPrun length:83160];
        [writer appendBytes:&MCPermPrun length:33216];
        [writer appendBytes:&MEPermPrun length:33216];
        [writer writeToFile:path atomically:YES];
    }
    NSLog(@"init done");
    inited3 = true;
}

static unsigned long currentTimeMillis() {
    struct timeval time;
    gettimeofday(&time, NULL);
    return (time.tv_sec * 1000) + (time.tv_usec / 1000);
    //return [[NSDate date] timeIntervalSince1970]*1000;
}

/**
 *     Verbose_Mask determines if a " . " separates the phase1 and phase2 parts of the solver string like in F' R B R L2 F .
 *     U2 U D for example.<br>
 */
static const int USE_SEPARATOR = 0x1;

/**
 *     Verbose_Mask determines if the solution will be inversed to a scramble/state generator.
 */
static const int INVERSE_SOLUTION = 0x2;

/**
 *     Verbose_Mask determines if a tag such as "(21f)" will be appended to the solution.
 */
static const int APPEND_LENGTH = 0x4;

- (int)verify:(char*)facelets {
    int count = 0;
    char center[6] = {
        facelets[4],
        facelets[13],
        facelets[22],
        facelets[31],
        facelets[40],
        facelets[49]};
    for (int i=0; i<54; i++) {
        char *pos = strchr(center, facelets[i]);
        long index = pos ? pos - center : -1;
        f[i] = (int)index;
        if (f[i] == -1) {
            return -1;
        }
        count += 1 << (f[i] << 2);
    }
    
    if (count != 0x999999) {
        return -1;
    }
    [Util3 toCubieCube:f cc:cc];
    return [cc verify];
}

- (bool)phase2:(int)eidx es:(int)esym ci:(int)cidx cs:(int)csym mid:(int)mid m:(int)maxl d:(int)depth l:(int)lm {
    if (eidx==0 && cidx==0 && mid==0) {
        return true;
    }
    for (int m=0; m<10; m++) {
        if (ckmov2[lm][m]) {
            continue;
        }
        int midx = MPermMove[mid][m];
        int cidxx = CPermMove[cidx][SymMove[csym][ud2std[m]]];
        int csymx = SymMult[cidxx & 15][csym];
        cidxx >>= 4;
        if ([CoordCube getPruning:MCPermPrun i:cidxx * 24 + MPermConj[midx][csymx]] >= maxl) {
            continue;
        }
        int eidxx = EPermMove[eidx][SymMoveUD[esym][m]];
        int esymx = SymMult[eidxx & 15][esym];
        eidxx >>= 4;
        if ([CoordCube getPruning:MEPermPrun i:eidxx * 24 + MPermConj[midx][esymx]] >= maxl) {
            continue;
        }
        if ([self phase2:eidxx es:esymx ci:cidxx cs:csymx mid:midx m:(maxl-1) d:(depth+1) l:m]) {
            move[depth] = ud2std[m];
            return true;
        }
    }
    return false;
}

- (NSString *)solutionToString {
    NSMutableString *solution = [NSMutableString string];
    int urf = (verbose & INVERSE_SOLUTION) != 0 ? (urfIdx + 3) % 6 : urfIdx;
    if (urf < 3) {
        for (int s=0; s<depth1; s++) {
            [solution appendFormat:@"%@ ",[move2str objectAtIndex:(urfMove[urf][move[s]])]];
        }
        if ((verbose & USE_SEPARATOR) != 0) {
            [solution appendString:@". "];
        }
        for (int s=depth1; s<sol; s++) {
            [solution appendFormat:@"%@ ",[move2str objectAtIndex:(urfMove[urf][move[s]])]];
        }
    } else {
        for (int s=sol-1; s>=depth1; s--) {
            [solution appendFormat:@"%@ ",[move2str objectAtIndex:(urfMove[urf][move[s]])]];
        }
        if ((verbose & USE_SEPARATOR) != 0) {
            [solution appendString:@". "];
        }
        for (int s=depth1-1; s>=0; s--) {
            [solution appendFormat:@"%@ ",[move2str objectAtIndex:(urfMove[urf][move[s]])]];
        }
    }
    if ((verbose & APPEND_LENGTH) != 0) {
        [solution appendFormat:@"(%df)", sol];
    }
    //NSLog(@"%@", solution);
    return solution;
}

/**
 * @return
 * 		0: Found or Timeout
 * 		1: Try Next Power
 * 		2: Try Next Axis
 */
- (int)initPhase2 {
    if (currentTimeMillis() >= (solStr == nil ? timeOut : timeMin)) {
        return 0;
    }
    valid2 = MIN(valid2, valid1);
    int cidx = corn[valid1] >> 4;
    int csym = corn[valid1] & 0xf;
    for (int i=valid1; i<depth1; i++) {
        int m = move[i];
        cidx = CPermMove[cidx][SymMove[csym][m]];
        csym = SymMult[cidx & 0xf][csym];
        cidx >>= 4;
        corn[i+1] = cidx << 4 | csym;
        
        int cx = UDSliceMove[mid4[i] & 0x1ff][m];
        mid4[i+1] = permMult[mid4[i]>>9][cx>>9]<<9|(cx&0x1ff);
    }
    valid1 = depth1;
    int mid = mid4[depth1]>>9;
    int prn = [CoordCube getPruning:MCPermPrun i:cidx * 24 + MPermConj[mid][csym]];
    if (prn >= maxDep2) {
        return prn > maxDep2 ? 2 : 1;
    }
    
    int u4e = ud8e[valid2] >> 16;
    int d4e = ud8e[valid2] & 0xffff;
    for (int i=valid2; i<depth1; i++) {
        int m = move[i];
        
        int cx = UDSliceMove[u4e & 0x1ff][m];
        u4e = permMult[u4e>>9][cx>>9]<<9|(cx&0x1ff);
        
        cx = UDSliceMove[d4e & 0x1ff][m];
        d4e = permMult[d4e>>9][cx>>9]<<9|(cx&0x1ff);
        
        ud8e[i+1] = u4e << 16 | d4e;
    }
    valid2 = depth1;
    
    int edge = MtoEPerm[494 - (u4e&0x1ff) + (u4e>>9) * 70 + (d4e >> 9) * 1680];
    int esym = edge & 15;
    edge >>= 4;
    
    prn = MAX([CoordCube getPruning:MEPermPrun i:edge * 24 + MPermConj[mid][esym]], prn);
    if (prn >= maxDep2) {
        return prn > maxDep2 ? 2 : 1;
    }
    
    int lm = depth1==0 ? 10 : std2ud[move[depth1-1]/3*3+1];
    for (int depth2=prn; depth2<maxDep2; depth2++) {
        if ([self phase2:edge es:esym ci:cidx cs:csym mid:mid m:depth2 d:depth1 l:lm]) {
            //NSLog(@"d %d", depth2);
            sol = depth1 + depth2;
            maxDep2 = MIN(12, sol-depth1);
            solStr = [self solutionToString];
            return currentTimeMillis() >= timeMin ? 0 : 1;
        }
    }
    return 1;
}

/**
 * @return
 * 		0: Found or Timeout
 * 		1: Try Next Power
 * 		2: Try Next Axis
 */
- (int)phase1:(int)twst ts:(int)tsym f:(int)flp fs:(int)fsym s:(int)slc m:(int)maxl l:(int)lm {
    if (twst==0 && flp==0 && slc==0 && maxl<5) {
        return maxl==0 ? [self initPhase2] : 1;
    }
    for (int axis=0; axis<18; axis+=3) {
        if (axis == lm || axis == lm-9) {
            continue;
        }
        for (int power=0; power<3; power++) {
            int m = axis + power;
            
            int slicex = UDSliceMove[slc][m] & 0x1ff;
            int twistx = TwistMove[twst][Sym8Move[tsym][m]];
            int tsymx = Sym8Mult[twistx & 7][tsym];
            twistx >>= 3;
            int prn = [CoordCube getPruning:UDSliceTwistPrun i:twistx * 495 + UDSliceConj[slicex][tsymx]];
            if (prn > maxl) {
                break;
            } else if (prn == maxl) {
                continue;
            }
            int flipx = FlipMove[flp][Sym8Move[fsym][m]];
            int fsymx = Sym8Mult[flipx & 7][fsym];
            flipx >>= 3;
            
            prn = [CoordCube getPruning:UDSliceFlipPrun i:flipx * 495 + UDSliceConj[slicex][fsymx]];
            if (prn > maxl) {
                break;
            } else if (prn == maxl) {
                continue;
            }
            move[depth1-maxl] = m;
            valid1 = MIN(valid1, depth1-maxl);
            int ret = [self phase1:twistx ts:tsymx f:flipx fs:fsymx s:slicex m:(maxl-1) l:axis];
            if (ret != 1) {
                return ret >> 1;
            }
        }
    }
    return 1;
}

- (NSString *)solve:(CubieCube *)c {
    //[c print];
    int conjMask = 0;
    for (int i=0; i<6; i++) {
        twist[i] = [c getTwistSym];
        flip[i] = [c getFlipSym];
        slice[i] = [c getUDSlice];
        corn0[i] = [c getCPermSym];
        ud8e0[i] = [c getU4Comb] << 16 | [c getD4Comb];
        
        for (int j=0; j<i; j++) {	//If S_i^-1 * C * S_i == C, It's unnecessary to compute it again.
            if (twist[i] == twist[j] && flip[i] == flip[j] && slice[i] == slice[j]
                && corn0[i] == corn0[j] && ud8e0[i] == ud8e0[j]) {
                conjMask |= 1 << i;
                break;
            }
        }
        if ((conjMask & (1 << i)) == 0) {
            prun[i] = MAX(MAX([CoordCube getPruning:UDSliceTwistPrun i:(twist[i]>>3) * 495 + UDSliceConj[slice[i]&0x1ff][twist[i]&7]], [CoordCube getPruning:UDSliceFlipPrun i:(flip[i]>>3) * 495 + UDSliceConj[slice[i]&0x1ff][flip[i]&7]]), 0);
        }
        [c URFConjugate];
        if (i==2) {
            [c invCubieCube];
        }
    }
    for (depth1=0; depth1<sol; depth1++) {
        //NSLog(@"3x3 d:%d", depth1);
        maxDep2 = MIN(12, sol-depth1);
        for (urfIdx=0; urfIdx<6; urfIdx++) {
            if ((conjMask & (1 << urfIdx)) != 0) {
                continue;
            }
            corn[0] = corn0[urfIdx];
            mid4[0] = slice[urfIdx];
            ud8e[0] = ud8e0[urfIdx];
            valid1 = 0;
            if ((prun[urfIdx] <= depth1)
                && [self phase1:twist[urfIdx]>>3 ts:twist[urfIdx]&7 f:flip[urfIdx]>>3 fs:flip[urfIdx]&7 s:slice[urfIdx]&0x1ff m:depth1 l:-1] == 0) {
                return solStr == nil ? @"Error 8" : solStr;
            }
        }
    }
    return solStr == nil ? @"Error 7" : solStr;
}

/**
 * Computes the solver string for a given cube.
 *
 * @param facelets
 * 		is the cube definition string format.<br>
 * The names of the facelet positions of the cube:
 * <pre>
 *             |************|
 *             |*U1**U2**U3*|
 *             |************|
 *             |*U4**U5**U6*|
 *             |************|
 *             |*U7**U8**U9*|
 *             |************|
 * ************|************|************|************|
 * *L1**L2**L3*|*F1**F2**F3*|*R1**R2**F3*|*B1**B2**B3*|
 * ************|************|************|************|
 * *L4**L5**L6*|*F4**F5**F6*|*R4**R5**R6*|*B4**B5**B6*|
 * ************|************|************|************|
 * *L7**L8**L9*|*F7**F8**F9*|*R7**R8**R9*|*B7**B8**B9*|
 * ************|************|************|************|
 *             |************|
 *             |*D1**D2**D3*|
 *             |************|
 *             |*D4**D5**D6*|
 *             |************|
 *             |*D7**D8**D9*|
 *             |************|
 * </pre>
 * A cube definition string "UBL..." means for example: In position U1 we have the U-color, in position U2 we have the
 * B-color, in position U3 we have the L color etc. according to the order U1, U2, U3, U4, U5, U6, U7, U8, U9, R1, R2,
 * R3, R4, R5, R6, R7, R8, R9, F1, F2, F3, F4, F5, F6, F7, F8, F9, D1, D2, D3, D4, D5, D6, D7, D8, D9, L1, L2, L3, L4,
 * L5, L6, L7, L8, L9, B1, B2, B3, B4, B5, B6, B7, B8, B9 of the enum constants.
 *
 * @param maxDepth
 * 		defines the maximal allowed maneuver length. For random cubes, a maxDepth of 21 usually will return a
 * 		solution in less than 0.02 seconds on average. With a maxDepth of 20 it takes about 0.1 seconds on average to find a
 * 		solution, but it may take much longer for specific cubes.
 *
 * @param timeOut
 * 		defines the maximum computing time of the method in milliseconds. If it does not return with a solution, it returns with
 * 		an error code.
 *
 * @param timeMin
 * 		defines the minimum computing time of the method in milliseconds. So, if a solution is found within given time, the
 * 		computing will continue to find shorter solution(s). Btw, if timeMin > timeOut, timeMin will be set to timeOut.
 *
 * @param verbose
 * 		determins the format of the solution(s). see USE_SEPARATOR, INVERSE_SOLUTION, APPEND_LENGTH
 *
 * @return The solution string or an error code:<br>
 * 		Error 1: There is not exactly one facelet of each colour<br>
 * 		Error 2: Not all 12 edges exist exactly once<br>
 * 		Error 3: Flip error: One edge has to be flipped<br>
 * 		Error 4: Not all corners exist exactly once<br>
 * 		Error 5: Twist error: One corner has to be twisted<br>
 * 		Error 6: Parity error: Two corners or two edges have to be exchanged<br>
 * 		Error 7: No solution exists for the given maxDepth<br>
 * 		Error 8: Timeout, no solution within given time
 */
- (NSString *)solutionForFacelets:(NSString *)facelets md:(int)maxDepth nt:(long)newTimeOut tm:(long)newTimeMin v:(int)newVerbose {
    [Search initTable];
    //NSLog(@"%@", facelets);
    int check = [self verify:(char*)[facelets UTF8String]];
    if (check != 0) {
        return [NSString stringWithFormat:@"Error %d", ABS(check)];
    }
    sol = maxDepth+1;
    timeOut = currentTimeMillis() + newTimeOut;
    timeMin = timeOut + MIN(newTimeMin - newTimeOut, 0);
    verbose = newVerbose;
    solStr = nil;
    return [self solve:cc];
}
@end
