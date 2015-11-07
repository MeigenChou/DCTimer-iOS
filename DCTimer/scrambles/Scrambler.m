//
//  Scrambler.m
//  DCTimer scramblers
//
//  Created by MeigenChou on 12-11-2.
//  Copyright (c) 2012年 MeigenChou. All rights reserved.
//

#import "Scrambler.h"
#import "Cube222.h"
#import "Pyraminx.h"
#import "Megaminx.h"
#import "Cross.h"
#import "Sq12phase.h"
#import "Tower.h"
#import "Skewb.h"
#import "TwoPhaseScrambler.h"
#import "Clock.h"
#import "SQ1.h"
#import "Gear.h"
#import "LatchCube.h"
#import "Floppy.h"
#import "RTower.h"
#import "EOLine.h"
#import "Sq1Shape.h"
#import "stdlib.h"
#import "time.h"
#import "DCTUtils.h"
//#import "Center1.h"
//#import "Center2.h"
//#import "Center3.h"
//#import "Edge3.h"
//#import "Search4.h"

@interface Scrambler()
@property (nonatomic, strong) Cube222 *cube2;
@property (nonatomic, strong) Pyraminx *pyram;
@property (nonatomic, strong) Megaminx *minx;
@property (nonatomic, strong) Clock *clock;
@property (nonatomic, strong) SQ1 *sq1o;
@property (nonatomic, strong) Cross *cross;
@property (nonatomic, strong) EOLine *eoline;
@property (nonatomic, strong) TwoPhaseScrambler *cube3;
@property (nonatomic, strong) Sq12phase *sq1;
@property (nonatomic, strong) Tower *tower;
@property (nonatomic, strong) Skewb *skewb;
@property (nonatomic, strong) Gear *gear;
@property (nonatomic, strong) LatchCube *latch;
@property (nonatomic, strong) Floppy *floppy;
@property (nonatomic, strong) RTower *rtow;
@property (nonatomic, strong) Sq1Shape *sqShape;
//@property (nonatomic, strong) Search4 *cube4;
@end

@implementation Scrambler
@synthesize cube2, pyram, minx, clock, sq1o;
@synthesize cross, eoline;
@synthesize cube3, sq1;
@synthesize tower, skewb, gear;
@synthesize latch, floppy;
@synthesize rtow, sqShape;
//@synthesize cent1;
int cubeSize;
int viewType;
NSMutableArray *scrPosit;
NSMutableArray *flat2posit;

- (id)init {
    if(self = [super init]) {
        srand((unsigned)time(0));
        //cubesuff = [[NSArray alloc] initWithObjects:@"", @"2", @"'", nil];
    }
    return self;
}

- (NSString *)scramble222: (int) type {
    if(!cube2)
        cube2 = [[Cube222 alloc] init];
    if(type==0) return [cube2 scramble];
    if(type==1) return [cube2 scrambleEG:0];
    if(type==2) return [cube2 scrambleEG:1];
    if(type==3) return [cube2 scrambleEG:2];
    if(type==4) return [cube2 scramblePBL];
    if(type==5) return [cube2 scrambleTCLL:1];
    if(type==6) return [cube2 scrambleTCLL:2];
    return @"";
}

- (NSString *)scramblePyrm {
    if(!pyram)
        pyram = [[Pyraminx alloc] init];
    return [pyram scramble];
}

- (NSString *)scrambleMinx {
    if(!minx)
        minx = [[Megaminx alloc] init];
    return [minx scramble];
}

- (NSString *)scrambleClk: (int) type {
    if(!self.clock)
        self.clock = [[Clock alloc] init];
    if(type==0)
        return [self.clock scramble];
    else if(type==1)
        return [self.clock scrambleOld: false];
    else if(type==2)
        return [self.clock scrambleOld: true];
    else return [self.clock scrambleEpo];
}

- (NSString *)scrambleSq: (int)type {
    if(!self.sq1o)
        self.sq1o = [[SQ1 alloc] init];
    if(type==0)
        return [self.sq1o sq1_scramble:1];
    else if(type==1)
        return [self.sq1o sq1_scramble:0];
    else if(type==2)
        return [self.sq1o ssq1t_scramble];
    else return [self.sq1o sq1_scramble:2];
}

- (NSString *)solveCross: (NSString *)scr side:(int)side {
    if(!self.cross)
        self.cross = [[Cross alloc] init];
    return [self.cross solveCross:scr side:side];
}

- (NSString *)solveXcross:(NSString *)scr side:(int)side {
    if(!self.cross)
        self.cross = [[Cross alloc] init];
    return [self.cross solveXcross:scr side:side];
}

- (NSString *)solveEoline:(NSString *)scr side:(int)side {
    if(!self.eoline)
        self.eoline = [[EOLine alloc] init];
    return [self.eoline solveEOLine:scr side:side];
}

- (NSString *)solveSqShape:(NSString *)scr m:(int)metric {
    if(!sqShape)
        sqShape = [[Sq1Shape alloc] init];
    if(metric==1) {
        return [sqShape solveTrn:scr];
    } else if(metric==2) {
        return [sqShape solveTws:scr];
    }
    return @"";
}

- (NSString *)scramble333: (int) type {
    if(!cube3) cube3 = [[TwoPhaseScrambler alloc] init];
    return [cube3 scramble: type];
}

/*- (NSString *)scramble444 {
    if(!cube4) cube4 = [[Search4 alloc] init];
    return [cube4 randomState];
}*/

- (NSString *)scrambleGear {
    if(!self.gear) self.gear = [[Gear alloc] init];
    NSString *scr = [self.gear scramble];
    return scr;
}

- (NSString *)megascramble: (NSArray *)turns len:(int)len suf:(NSArray *)suff sql:(int)sql {
    int donemoves[10];
    int lastaxis = -1, len2 = (int)turns.count / len, slen = (int)suff.count;
    //NSLog(@"%d %d", len2, slen);
    NSMutableString *s = [NSMutableString string];
    for (int j=0; j<sql; j++) {
        int done = 0;
        do {
            int first = rand()%len;
            int second = rand()%len2;
            if(first!=lastaxis || donemoves[second]!=1) {
                if(first!=lastaxis) {
                    for(int k=0; k<10; k++)donemoves[k]=0;
                    lastaxis = first;
                }
                donemoves[second] = 1;
                [s appendFormat:@"%@%@ ", [turns objectAtIndex:first*len2+second], [suff objectAtIndex:(rand()%slen)]];
                done = 1;
            }
        } while (done==0);
    }
    return s;
}

- (NSString *)megascramble:(NSArray *)turns suf:(NSArray *)suff sql:(int)len ia:(BOOL)isArray {
    int donemoves[10];
    int lastaxis = -1, slen = (int)suff.count;
    //NSLog(@"%d %d", len2, slen);
    NSMutableString *s = [NSMutableString string];
    for (int j=0; j<len; j++) {
        int done = 0;
        do {
            int first = rand()%turns.count;
            int second = rand()%([[turns objectAtIndex:first] count]);
            if(first!=lastaxis) {
                for(int k=0; k<10; k++)donemoves[k]=0;
                lastaxis = first;
            }
            if(donemoves[second]!=1) {
                donemoves[second] = 1;
                if(isArray)
                    [s appendFormat:@"%@%@ ", [[[turns objectAtIndex:first] objectAtIndex:second] objectAtIndex:rand()%[[[turns objectAtIndex:first] objectAtIndex:second] count]], [suff objectAtIndex:(rand()%slen)]];
                else [s appendFormat:@"%@%@ ", [[turns objectAtIndex:first] objectAtIndex:second], [suff objectAtIndex:(rand()%slen)]];
                done = 1;
            }
        } while (done==0);
    }
    return s;
}

- (NSString *)scrambleSq1 {
    if(!sq1)
        sq1 = [[Sq12phase alloc] init];
    return [sq1 scramble];
}

- (NSString *)scrambleSq1:(int)shp {
    if(!sq1)
        sq1 = [[Sq12phase alloc] init];
    return [sq1 scramble:1037];
}

- (NSString *)scrambleTow {
    if(!self.tower) self.tower = [[Tower alloc] init];
    return [self.tower scramble];
}

- (NSString *)scrambleRTow {
    if(!self.rtow) self.rtow = [[RTower alloc] init];
    return [self.rtow scramble];
}

- (NSString *)scrambleSkb {
    if(!self.skewb) self.skewb = [[Skewb alloc] init];
    return [self.skewb scramble];
}

- (NSString *)scrambleLat {
    if(!self.latch) self.latch = [[LatchCube alloc] init];
    return [self.latch scramble];
}

- (NSString *)scrambleFlpy {
    if(!floppy)
        floppy = [[Floppy alloc] init];
    return [floppy scramble];
}

- (NSString *)do15puz: (bool) mirrored {
    NSArray *moves;
    if(mirrored)moves = [[NSArray alloc] initWithObjects:@"U", @"L", @"R", @"D", nil];
    else moves = [[NSArray alloc] initWithObjects:@"D", @"R", @"L", @"U", nil];
    int effect[][2] = {{0,-1},{1,0},{-1,0},{0,1}};
    int x=0,y=3,k,r,lastr=5;
    bool done;
    NSMutableString *s = [NSMutableString string];
    for(k=0;k<80;k++){
        done=false;
        while(!done){
            r=rand()%4;
            if (x+effect[r][0]>=0 && x+effect[r][0]<=3 && y+effect[r][1]>=0 && y+effect[r][1]<=3 && r+lastr != 3) {
                done=true;
                x+=effect[r][0];
                y+=effect[r][1];
                //s.append(moves[r]+" ");
                [s appendFormat:@"%@ ", [moves objectAtIndex:r]];
                lastr=r;
            }
        }
    }
    return s;
}

- (NSString *)edgeScramble: (NSString *)start end:(NSArray *)end moves:(NSArray *)moves len:(int)len{
    int u=0,d=0;
    int movemis[10];
    int movelen = (int)moves.count;
    NSArray *triggers =[[NSArray alloc] initWithObjects:@"R",@"R'",@"R'",@"R",@"L",@"L'",@"L'",@"L",@"F'",@"F",@"F",@"F'",@"B",@"B'",@"B'",@"B", nil];
    NSArray *ud = [[NSArray alloc] initWithObjects:@"U", @"D", nil];
    NSArray *cubesuff = [[NSArray alloc] initWithObjects:@"", @"2", @"'", nil];
    NSMutableString *ss = [NSMutableString stringWithString:start];
    NSString *v;
    for (int i=0; i<movelen; i++) {
        movemis[i] = 0;
    }
    for (int i=0; i<len; i++) {
        // apply random moves
        bool done = false;
        while (!done) {
            v = @"";
            for (int j=0; j<movelen; j++) {
                int x = rand()%4;
                movemis[j] += x;
                if (x!=0) {
                    done = true;
                    v = [v stringByAppendingFormat:@" %@%@", [moves objectAtIndex:j], [cubesuff objectAtIndex:x-1]];
                    //v += " " + moves[j] + cubesuff[x-1];
                }
            }
        }
        [ss appendString:v];
        
        // apply random trigger, update U/D
        int trigger = rand()%8;
        int layer = rand()%2;
        int turn = rand()%3;
        [ss appendFormat:@" %@ %@%@ %@", [triggers objectAtIndex:trigger*2], [ud objectAtIndex:layer], [cubesuff objectAtIndex:turn], [triggers objectAtIndex:trigger*2+1]];
        //ss += " " + triggers[trigger][0] + " " + ud[layer] + cubesuff[turn] + " " + triggers[trigger][1];
        if (layer==0) u += turn+1;
        if (layer==1) d += turn+1;
    }
    // fix everything
    for (int i=0; i<movelen; i++) {
        int x = 4-(movemis[i]%4);
        if (x<4) {
            [ss appendFormat:@" %@%@", [moves objectAtIndex:i], [cubesuff objectAtIndex:x-1]];
            //ss += " " + moves[i] + cubesuff[x-1];
        }
    }
    u = 4-(u%4); d = 4-(d%4);
    if (u<4) {
        [ss appendFormat:@" U%@", [cubesuff objectAtIndex:u-1]];
        //ss += " U" + cubesuff[u-1];
    }
    if (d<4) {
        [ss appendFormat:@" D%@", [cubesuff objectAtIndex:d-1]];
        //ss += " D" + cubesuff[d-1];
    }
    [ss appendFormat:@" %@", [end objectAtIndex:(rand()%end.count)]];
    //ss += " " + rndEl(end);
    return ss;
}

- (NSString *) helicubescramble {
    int j,k;
    NSArray *faces = [[NSArray alloc] initWithObjects:@"UF", @"UR", @"UB", @"UL", @"FR", @"BR", @"BL", @"FL", @"DF", @"DR", @"DB", @"DL", nil];
    //String[] faces = {"UF", "UR", "UB", "UL", "FR", "BR", "BL", "FL", "DF", "DR", "DB", "DL"};
    int used[12];
    // adjacency table
    int adj[] = {0x9a, 0x35, 0x6a, 0xc5, 0x303, 0x606, 0xc0c, 0x909, 0xa90, 0x530, 0xa60, 0x5c0};
    // now generate the scramble(s)
    NSMutableString *s = [NSMutableString string];
    for(j=0;j<12;j++){
        used[j] = 0;
    }
    for(j=0;j<40;j++){
        bool done = false;
        do {
            int face = rand()%12;
            if (used[face] == 0) {
                [s appendFormat:@"%@ ", [faces objectAtIndex:face]];
                //s += faces[face] + " ";
                for(k=0;k<12;k++){
                    if ((adj[face]>>k&1)==1) 
                        used[k] = 0;
                }
                used[face] = 1;
                done = true;
            }
        } while (!done);
    }
    //s += s;
    return s;
}

- (NSString *) yj4x4 {
    // the idea is to keep the fixed center on U and do Rw or Lw, Fw or Bw, to not disturb it
    //String[][] turns = {{"U","D"},{"R","L","r"},{"F","B","f"}};
    NSArray *turns = [[NSArray alloc] initWithObjects:@"U", @"D", @"", @"R", @"L", @"r", @"F", @"B", @"f", nil];
    int turnlen[] = {2,3,3};
    NSArray *cubesuff = [[NSArray alloc] initWithObjects:@"", @"2", @"'", nil];
    int donemoves[3];
    int lastaxis,fpos = 0, // 0 = Ufr, 1 = Ufl, 2 = Ubl, 3 = Ubr
    j,k;
    NSMutableString *s = [NSMutableString string];
    lastaxis=-1;
    for(j=0;j<40;j++){
        int done=0;
        do{
            int first=rand()%3;
            int second=rand()%turnlen[first];
            if(first!=lastaxis||donemoves[second]==0){
                if(first==lastaxis){
                    donemoves[second]=1;
                    int rs = rand()%3;
                    if(first==0&&second==0){fpos = (fpos + 4 + rs)%4;}
                    if(first==1&&second==2){ // r or l
                        if(fpos==0||fpos==3) [s appendFormat:@"l%@ ", [cubesuff objectAtIndex:rs]];//s.append("l"+cubesuff[rs]+" ");
                        else [s appendFormat:@"r%@ ", [cubesuff objectAtIndex:rs]];//s.append("r"+cubesuff[rs]+" ");
                    } else if(first==2&&second==2){ // f or b
                        if(fpos==0||fpos==1) [s appendFormat:@"b%@ ", [cubesuff objectAtIndex:rs]];//s.append("b"+cubesuff[rs]+" ");
                        else [s appendFormat:@"f%@ ", [cubesuff objectAtIndex:rs]];//s.append("f"+cubesuff[rs]+" ");
                    } else {
                        [s appendFormat:@"%@%@ ", [turns objectAtIndex:first*3+second], [cubesuff objectAtIndex:rs]];
                        //s.append(turns[first][second]+cubesuff[rs]+" ");
                    }
                }else{
                    for(k=0;k<turnlen[first];k++){donemoves[k]=0;}
                    lastaxis=first;
                    donemoves[second]=1;
                    int rs = rand()%3;
                    if(first==0&&second==0){fpos = (fpos + 4 + rs)%4;}
                    if(first==1&&second==2){ // r or l
                        if(fpos==0||fpos==3) [s appendFormat:@"l%@ ", [cubesuff objectAtIndex:rs]];//s.append("l"+cubesuff[rs]+" ");
                        else [s appendFormat:@"r%@ ", [cubesuff objectAtIndex:rs]];//s.append("r"+cubesuff[rs]+" ");
                    } else if(first==2&&second==2){ // f or b
                        if(fpos==0||fpos==1) [s appendFormat:@"b%@ ", [cubesuff objectAtIndex:rs]];//s.append("b"+cubesuff[rs]+" ");
                        else [s appendFormat:@"f%@ ", [cubesuff objectAtIndex:rs]];//s.append("f"+cubesuff[rs]+" ");
                    } else {
                        [s appendFormat:@"%@%@ ", [turns objectAtIndex:first*3+second], [cubesuff objectAtIndex:rs]];
                        //s.append(turns[first][second]+cubesuff[rs]+" ");
                    }
                }
                done=1;
            }
        }while(done==0);
    }
    return s;
}

- (NSString *) oldminxscramble {
    int j,k;
    NSArray *minxsuff =[[NSArray alloc] initWithObjects:@"", @"2", @"'", @"2'", nil];
    NSArray *faces = [[NSArray alloc] initWithObjects:@"F", @"B", @"U", @"D", @"L", @"DBR", @"DL", @"BR", @"DR", @"BL", @"R", @"DBL", nil];
    int used[12];
    // adjacency table
    int adj[] = {0x554, 0xaa8, 0x691, 0x962, 0xa45, 0x58a, 0x919, 0x626, 0x469, 0x896, 0x1a5, 0x25a};
    // now generate the scramble(s)
    NSMutableString *s = [NSMutableString string];
    for(j=0;j<12;j++){
        used[j] = 0;
    }
    for(j=0;j<70;j++){
        bool done = false;
        do {
            int face = rand()%12;
            if (used[face] == 0) {
                [s appendFormat:@"%@%@ ", [faces objectAtIndex:face], [minxsuff objectAtIndex:(rand()%4)]];
                //s.append(faces[face] + rndEl(minxsuff) + " ");
                for(k=0;k<12;k++){
                    if ((adj[face]>>k&1)==1) 
                        used[k] = 0;
                }
                used[face] = 1;
                done = true;
            }
        } while (!done);
    }
    return s;
}

int bicD[][9] = {{0,1,2,5,8,7,6,3,4},{6,7,8,13,20,19,18,11,12},{0,3,6,11,18,17,16,9,10},{8,5,2,15,22,21,20,13,14}};
int bicStart[] = {1,1,2,3,3,2,4,4,0,5,6,7,8,9,10,10,5,6,7,8,9,11,11};
- (BOOL)canMove:(int) face {
    int u[8];
    int ulen=0, i, j, done, z=0;
    for (i=0; i<9; i++) {
        done = 0;
        for (j=0; j<ulen; j++) {
            if (u[j]==bicStart[bicD[face][i]]) done = 1;
        }
        if (done==0) {
            u[ulen++] = bicStart[bicD[face][i]];
            if (bicStart[bicD[face][i]] == 0) z = 1;
        }
    }
    return (ulen==5 && z==1);
}

- (void) doMove:(int) face amount:(int) amount {
    for (int i=0; i<amount; i++) {
        int t = bicStart[bicD[face][0]];
        bicStart[bicD[face][0]] = bicStart[bicD[face][6]];
        bicStart[bicD[face][6]] = bicStart[bicD[face][4]];
        bicStart[bicD[face][4]] = bicStart[bicD[face][2]];
        bicStart[bicD[face][2]] = t;
        t = bicStart[bicD[face][7]];
        bicStart[bicD[face][7]] = bicStart[bicD[face][5]];
        bicStart[bicD[face][5]] = bicStart[bicD[face][3]];
        bicStart[bicD[face][3]] = bicStart[bicD[face][1]];
        bicStart[bicD[face][1]] = t;
    }
}

- (NSString *) bicube {
    NSArray *move = [[NSArray alloc] initWithObjects:@"U", @"F", @"L", @"R", nil];
    NSArray *cubesuff = [[NSArray alloc] initWithObjects:@"", @"2", @"'", nil];
    NSMutableString *sb = [NSMutableString string];
    int arr[30][2];
    int poss[4];
    int arrlen=0, done, i, j, x=0, y=0;
    while (arrlen < 30) {
        for(i=0; i<4; i++)poss[i] = 1;//poss = new int[]{1,1,1,1};
        for (j=0; j<4; j++) {
            if (poss[j]==1 && ![self canMove:j])
                poss[j]=0;
        }
        done = 0;
        while (done==0) {
            x = rand()%4;
            if (poss[x]==1) {
                y = rand()%3+1;
                [self doMove:x amount:y];
                done = 1;
            }
        }
        arr[arrlen][0] = x;
        arr[arrlen++][1] = y;
        if (arrlen >= 2) {
            if (arr[arrlen-1][0] == arr[arrlen-2][0]) {
                arr[arrlen-2][1] = (arr[arrlen-2][1] + arr[arrlen-1][1])%4;
                arrlen--;//arr = arr.slice(0,arr.length - 1);
            }
        }
        if (arrlen >= 1) {
            if (arr[arrlen-1][1] == 0) {
                arrlen--;//arr = arr.slice(0,arr.length - 1);
            }
        }
    }
    for (i=0; i<30; i++) {
        [sb appendFormat:@"%@%@ ", [move objectAtIndex:arr[i][0]], [cubesuff objectAtIndex:arr[i][1]-1]];
        //sb.append( move[arr[i][0]] + cubesuff[arr[i][1]-1] + " ");
    }
    return sb;
}

- (NSString *)getScrString:(int)idx {
    NSString *scr;
    NSArray *turn, *cubesuff = [[NSArray alloc] initWithObjects:@"", @"2", @"'", nil];
    switch (idx) {
        case 0: //2x2
            scr = [self scramble222: 0]; viewType=2;
            break;
        case 1:
            turn = [[NSArray alloc] initWithObjects:@"U", @"R", @"F", nil];
            scr = [self megascramble:turn len:3 suf:cubesuff sql:15];
            viewType=2; break;
        case 2:
        {
            NSArray *turn1 = [[NSArray alloc] initWithObjects:@"U", @"D", nil];
            NSArray *turn2 = [[NSArray alloc] initWithObjects:@"L", @"R", nil];
            NSArray *turn3 = [[NSArray alloc] initWithObjects:@"F", @"B", nil];
            turn = [[NSArray alloc] initWithObjects:[[NSArray alloc] initWithObjects:turn1, nil], [[NSArray alloc] initWithObjects:turn2, nil], [[NSArray alloc] initWithObjects:turn3, nil], nil];
            scr = [self megascramble:turn suf:cubesuff sql:15 ia:YES];
            viewType=2; break;
        }
        case 3: //CLL
        case 4: //EG1
        case 5: //EG2
        case 6: //PBL
        case 7: //TCLL+
        case 8: //TCLL-
            scr = [self scramble222: idx-2]; viewType=2;
            break;
        case 32:    //3x3
            scr = [self scramble333: 0]; viewType=[scr hasPrefix:@"Error"] ? 0 : 3;
            break;
        case 33:
            turn = [[NSArray alloc] initWithObjects:@"U", @"D", @"L", @"R", @"F", @"B", nil];
            scr = [self megascramble:turn len:3 suf:cubesuff sql:25];
            viewType=3; break;
        case 34:    //F2L
        case 35:    //LL
        case 36:    //PLL
        case 37:    //corner
        case 38:    //edge
        case 39:    //LSLL
        case 40:    //ZBLL
        case 41:    //COLL
        case 42:    //ELL
        case 43:    //l6e
        case 44:    //CMLL
        case 45:    //easyCross
        case 46:    //2GLL
            scr = [self scramble333: idx-33]; viewType=[scr hasPrefix:@"Error"] ? 0 : 3;
            break;
        case 544:    //3x3 subsets
            turn = [[NSArray alloc] initWithObjects:@"R", @"U", nil];
            scr = [self megascramble:turn len:2 suf:cubesuff sql:25];
            viewType=3; break;
        case 545:    //L, U
            turn = [[NSArray alloc] initWithObjects:@"L", @"U", nil];
            scr = [self megascramble:turn len:2 suf:cubesuff sql:25];
            viewType=3; break;
        case 546:    //M, U
            turn = [[NSArray alloc] initWithObjects:@"M", @"U", nil];
            scr = [self megascramble:turn len:2 suf:cubesuff sql:25];
            viewType=3; break;
        case 547:    //F, R, U
            turn = [[NSArray alloc] initWithObjects:@"F", @"R", @"U", nil];
            scr = [self megascramble:turn len:3 suf:cubesuff sql:25];
            viewType=3; break;
        case 548:    //R, U, L
        {
            NSArray *turn1 = [[NSArray alloc] initWithObjects:@"L", @"R", nil];
            NSArray *turn2 = [[NSArray alloc] initWithObjects:@"U", nil];
            turn = [[NSArray alloc] initWithObjects:turn1, turn2, nil];
            scr = [self megascramble:turn suf:cubesuff sql:25 ia:false];
            viewType=3; break;
        }
        case 549:    //R, r, U
        {
            NSArray *turn1 = [[NSArray alloc] initWithObjects:@"R", @"r", nil];
            NSArray *turn2 = [[NSArray alloc] initWithObjects:@"U", nil];
            turn = [[NSArray alloc] initWithObjects:turn1, turn2, nil];
            scr = [self megascramble:turn suf:cubesuff sql:25 ia:false];
            viewType=3; break;
        }
        case 550:    //half turns
        {
            turn = [[NSArray alloc] initWithObjects:@"U", @"D", @"L", @"R", @"F", @"B", nil];
            NSArray *suff = [[NSArray alloc] initWithObjects:@"2", nil];
            scr = [self megascramble:turn len:3 suf:suff sql:25];
            viewType=3; break;
        }
        case 551:    //LSLL
        {
            NSArray *turn1 = [[NSArray alloc] initWithObjects:@"R U R'", @"R U2 R'", @"R U' R'", nil];
            NSArray *turn2 = [[NSArray alloc] initWithObjects:@"F' U F", @"F' U2 F", @"F' U' F", nil];
            NSArray *turn3 = [[NSArray alloc] initWithObjects:@"U", @"U2", @"U'", nil];
            turn = [[NSArray alloc] initWithObjects:[[NSArray alloc] initWithObjects:turn1, nil], [[NSArray alloc] initWithObjects:turn2, nil], [[NSArray alloc] initWithObjects:turn3, nil], nil];
            NSArray *suff = [[NSArray alloc] initWithObjects:@"", nil];
            scr = [self megascramble:turn suf:suff sql:25 ia:YES];
            viewType=3; break;
        }
        case 64:    //4x4
            turn = [[NSArray alloc] initWithObjects:@"U", @"Uw", @"D", @"L", @"Rw", @"R", @"F", @"Fw", @"B", nil];
            scr = [self megascramble:turn len:3 suf:cubesuff sql:40];
            viewType=4; break;
        case 65:
            turn = [[NSArray alloc] initWithObjects:@"U", @"u", @"D", @"L", @"r", @"R", @"F", @"f", @"B", nil];
            scr = [self megascramble:turn len:3 suf:cubesuff sql:40];
            viewType=4; break;
        case 66:
            scr = [self yj4x4];
            viewType=4; break;
        case 67:
        {
            NSArray *end = [[NSArray alloc] initWithObjects:@"Bw2 Rw'", @"Bw2 U2 Rw U2 Rw U2 Rw U2 Rw", nil];
            NSArray *moves = [[NSArray alloc] initWithObjects:@"Uw", nil];
            scr = [self edgeScramble:@"Rw Bw2" end:end moves:moves len:8];
            viewType=4; break;
        }
        case 68:
            turn = [[NSArray alloc] initWithObjects:@"U", @"u", @"R", @"r", nil];
            scr = [self megascramble:turn len:2 suf:cubesuff sql:40];
            viewType=4; break;
        /*case 69:
            [Center1 initCent1];
            [Center2 initCent2];
            [Center3 initCent3];
            [Edge3 initMvrot];
            [Edge3 initRaw2Sym];
            [Edge3 createPrun];
            scr = [self scramble444];
            viewType = 0;
            break;*/
        case 96:   //5x5
            turn = [[NSArray alloc] initWithObjects:@"U", @"Uw", @"Dw", @"D", @"L", @"Lw", @"Rw", @"R", @"F", @"Fw", @"Bw", @"B", nil];
            scr = [self megascramble:turn len:3 suf:cubesuff sql:60];
            viewType=5; break;
        case 97:
            turn = [[NSArray alloc] initWithObjects:@"U", @"u", @"d", @"D", @"L", @"l", @"r", @"R", @"F", @"f", @"b", @"B", nil];
            scr = [self megascramble:turn len:3 suf:cubesuff sql:60];
            viewType=5; break;
        case 98:
        {
            NSString *start = @"Rw R Bw B";
            NSArray *end = [[NSArray alloc] initWithObjects:@"B' Bw' R' Rw'", @"B' Bw' R' U2 Rw U2 Rw U2 Rw U2 Rw", nil];
            NSArray *moves = [[NSArray alloc] initWithObjects:@"Uw", @"Dw", nil];
            scr = [self edgeScramble:start end:end moves:moves len:9];
            viewType=5; break;
        }
        case 128:   //6x6
            turn = [[NSArray alloc] initWithObjects:@"U", @"2U", @"3U", @"2D", @"D", @"L", @"2L", @"3R", @"2R", @"R", @"F", @"2F", @"3F", @"2B", @"B", nil];
            scr = [self megascramble:turn len:3 suf:cubesuff sql:80];
            viewType=6; break;
        case 129:
            turn = [[NSArray alloc] initWithObjects:@"U", @"u", @"3u", @"d", @"D", @"L", @"l", @"3r", @"r", @"R", @"F", @"f", @"3f", @"b", @"B", nil];
            scr = [self megascramble:turn len:3 suf:cubesuff sql:80];
            viewType=6; break;
        case 130:
            turn = [[NSArray alloc] initWithObjects:@"U", @"U²", @"U³", @"D²", @"D", @"L", @"L²", @"R³", @"R²", @"R", @"F", @"F²", @"F³", @"2B", @"B", nil];
            scr = [self megascramble:turn len:3 suf:cubesuff sql:80];
            viewType=6; break;
        case 131:
        {
            NSString *start = @"3r r 3b b";
            NSArray *end = [[NSArray alloc] initWithObjects:@"3b' b' 3r' r'", @"3b' b' 3r' U2 r U2 r U2 r U2 r", @"3b' b' r' U2 3r U2 3r U2 3r U2 3r", nil];
            NSArray *moves = [[NSArray alloc] initWithObjects:@"u", @"3u", @"d", nil];
            scr = [self edgeScramble:start end:end moves:moves len:10];
            viewType=6; break;
        }
        case 160:   //7x7
            turn = [[NSArray alloc] initWithObjects:@"U", @"2U", @"3U", @"3D", @"2D", @"D", @"L", @"2L", @"3L", @"3R", @"2R", @"R", @"F", @"2F", @"3F", @"3B", @"2B", @"B", nil];
            scr = [self megascramble:turn len:3 suf:cubesuff sql:100];
            viewType=7; break;
        case 161:
            turn = [[NSArray alloc] initWithObjects:@"U", @"u", @"3u", @"3d", @"d", @"D", @"L", @"l", @"3l", @"3r", @"r", @"R", @"F", @"f", @"3f", @"3b", @"b", @"B", nil];
            scr = [self megascramble:turn len:3 suf:cubesuff sql:100];
            viewType=7; break;
        case 162:
            turn = [[NSArray alloc] initWithObjects:@"U", @"U²", @"U³", @"D³", @"D²", @"D", @"L", @"L²", @"L³", @"R³", @"R²", @"R", @"F", @"F²", @"F³", @"B³", @"B²", @"B", nil];
            scr = [self megascramble:turn len:3 suf:cubesuff sql:100];
            viewType=7; break;
        case 163:
        {
            NSString *start = @"3r r 3b b";
            NSArray *end = [[NSArray alloc] initWithObjects:@"3b' b' 3r' r'", @"3b' b' 3r' U2 r U2 r U2 r U2 r", @"3b' b' r' U2 3r U2 3r U2 3r U2 3r", nil];
            NSArray *moves = [[NSArray alloc] initWithObjects:@"u", @"3u", @"3d", @"d", nil];
            scr = [self edgeScramble:start end:end moves:moves len:11];
            viewType=7; break;
        }
        case 576:   //bandaged cube
            scr = [self bicube]; viewType=0;
            break;
        case 577:
            scr = [self scrambleSq:3]; viewType=0;
            break;
        case 288:   //clock
        case 289:
        case 290:
        case 291:
            scr = [self scrambleClk: idx-288]; viewType=11;
            break;
        case 384:   //cmetrick
        {
            NSArray *turn3 = [[NSArray alloc] initWithObjects:@"U<", @"U>", @"U2", nil];
            NSArray *turn4 = [[NSArray alloc] initWithObjects:@"D<", @"D>", @"D2", nil];
            NSArray *turn5 = [[NSArray alloc] initWithObjects:@"E<", @"E>", @"E2", nil];
            NSArray *turn1 = [[NSArray alloc] initWithObjects:turn3, turn4, turn5, nil];
            turn3 = [[NSArray alloc] initWithObjects:@"R^", @"Rv", @"R2", nil];
            turn4 = [[NSArray alloc] initWithObjects:@"L^", @"Lv", @"L2", nil];
            turn5 = [[NSArray alloc] initWithObjects:@"M^", @"Mv", @"M2", nil];
            NSArray *turn2 = [[NSArray alloc] initWithObjects:turn3, turn4, turn5, nil];
            turn = [[NSArray alloc] initWithObjects:turn1, turn2, nil];
            scr = [self megascramble:turn suf:[[NSArray alloc] initWithObjects:@"", nil] sql:25 ia:YES];
            viewType=0; break;
        }
        case 385:
        {
            NSArray *turn3 = [[NSArray alloc] initWithObjects:@"U<", @"U>", @"U2", nil];
            NSArray *turn4 = [[NSArray alloc] initWithObjects:@"D<", @"D>", @"D2", nil];
            NSArray *turn1 = [[NSArray alloc] initWithObjects:turn3, turn4, nil];
            turn3 = [[NSArray alloc] initWithObjects:@"R^", @"Rv", @"R2", nil];
            turn4 = [[NSArray alloc] initWithObjects:@"L^", @"Lv", @"L2", nil];
            NSArray *turn2 = [[NSArray alloc] initWithObjects:turn3, turn4, nil];
            turn = [[NSArray alloc] initWithObjects:turn1, turn2, nil];
            scr = [self megascramble:turn suf:[[NSArray alloc] initWithObjects:@"", nil] sql:25 ia:YES];
            viewType=0; break;
        }
        case 416:   //gear
            scr = [self scrambleGear]; viewType=0;
            break;
        case 417:
        {
            turn = [[NSArray alloc] initWithObjects:@"U", @"R", @"F", nil];
            NSArray *suff = [[NSArray alloc] initWithObjects:@"", @"2", @"3", @"4", @"5", @"6", @"'", @"2'", @"3'", @"4'", @"5'", nil];
            scr = [self megascramble:turn len:3 suf:suff sql:10];
            viewType=0; break;
        }
        case 352:   //LxMxN
            scr = [self scrambleFlpy]; viewType=0;
            break;
        case 353:   //super 133
            turn = [[NSArray alloc] initWithObjects:@"R", @"L", @"U", @"D", nil];
            scr = [self megascramble:turn len:2 suf:cubesuff sql:15];
            viewType=0; break;
        case 354:   //233
        {
            NSArray *turn1 = [[NSArray alloc] initWithObjects:@"R2", @"L2", @"R2 L2", nil];
            NSArray *turn2 = [[NSArray alloc] initWithObjects:@"F2", @"B2", @"F2 B2", nil];
            NSArray *turn3 = [[NSArray alloc] initWithObjects:@"U", @"U2", @"U'", nil];
            turn = [[NSArray alloc] initWithObjects:[[NSArray alloc] initWithObjects:turn1, nil], [[NSArray alloc] initWithObjects:turn2, nil], [[NSArray alloc] initWithObjects:turn3, nil], nil];
            scr = [self megascramble:turn suf:[[NSArray alloc] initWithObjects:@"", nil] sql:25 ia:YES];
            viewType=0; break;
        }
        case 355:   //223
            scr = [self scrambleTow]; viewType=0;
            break;
        case 356:   //224
            scr = [self scrambleRTow]; viewType=0;
            break;
        case 357:   //334
        {
            NSArray *turn1 = [[NSArray alloc] initWithObjects:@"D", @"D2", @"D'", nil];
            NSArray *turn4 = [[NSArray alloc] initWithObjects:@"U", @"U2", @"U'", nil];
            NSArray *turn5 = [[NSArray alloc] initWithObjects:@"u", @"u2", @"u'", nil];
            NSArray *turn2 = [[NSArray alloc] initWithObjects:@"R2", @"L2", @"M2", nil];
            NSArray *turn3 = [[NSArray alloc] initWithObjects:@"F2", @"B2", @"S2", nil];
            turn = [[NSArray alloc] initWithObjects:[[NSArray alloc] initWithObjects:turn4, turn5, turn1, nil], [[NSArray alloc] initWithObjects:turn2, nil], [[NSArray alloc] initWithObjects:turn3, nil], nil];
            scr = [self megascramble:turn suf:[[NSArray alloc] initWithObjects:@"", nil] sql:40 ia:YES];
            viewType=0; break;
        }
        case 358:   //335
        {
            NSArray *turn3 = [[NSArray alloc] initWithObjects:@"U", @"U2", @"U'", nil];
            NSArray *turn4 = [[NSArray alloc] initWithObjects:@"D", @"D2", @"D'", nil];
            NSArray *turn1 = [[NSArray alloc] initWithObjects:@"R2", @"L2", nil];
            NSArray *turn2 = [[NSArray alloc] initWithObjects:@"F2", @"B2", nil];
            turn = [[NSArray alloc] initWithObjects:[[NSArray alloc] initWithObjects:turn3, turn4, nil], [[NSArray alloc] initWithObjects:turn1, nil], [[NSArray alloc] initWithObjects:turn2, nil], nil];
            scr = [NSString stringWithFormat:@"%@/ %@", [self megascramble:turn suf:[[NSArray alloc] initWithObjects:@"", nil] sql:25 ia:YES], [self scramble333:0]];
            viewType=0; break;
        }
        case 359:   //336
        {
            NSArray *turn3 = [[NSArray alloc] initWithObjects:@"U", @"U2", @"U'", nil];
            NSArray *turn4 = [[NSArray alloc] initWithObjects:@"u", @"u2", @"u'", nil];
            NSArray *turn5 = [[NSArray alloc] initWithObjects:@"3u", @"3u2", @"3u'", nil];
            NSArray *turn1 = [[NSArray alloc] initWithObjects:@"R2", @"L2", @"M2", nil];
            NSArray *turn2 = [[NSArray alloc] initWithObjects:@"F2", @"B2", @"S2", nil];
            turn = [[NSArray alloc] initWithObjects:[[NSArray alloc] initWithObjects:turn3, turn4, turn5, nil], [[NSArray alloc] initWithObjects:turn1, nil], [[NSArray alloc] initWithObjects:turn2, nil], nil];
            scr = [self megascramble:turn suf:[[NSArray alloc] initWithObjects:@"", nil] sql:40 ia:YES];
            viewType=0; break;
        }
        case 360:   //337
        {
            NSArray *turn3 = [[NSArray alloc] initWithObjects:@"U", @"U2", @"U'", nil];
            NSArray *turn4 = [[NSArray alloc] initWithObjects:@"u", @"u2", @"u'", nil];
            NSArray *turn5 = [[NSArray alloc] initWithObjects:@"D", @"D2", @"D'", nil];
            NSArray *turn6 = [[NSArray alloc] initWithObjects:@"d", @"d2", @"d'", nil];
            NSArray *turn1 = [[NSArray alloc] initWithObjects:@"R2", @"L2", nil];
            NSArray *turn2 = [[NSArray alloc] initWithObjects:@"F2", @"B2", nil];
            turn = [[NSArray alloc] initWithObjects:[[NSArray alloc] initWithObjects:turn3, turn4, turn5, turn6, nil], [[NSArray alloc] initWithObjects:turn1, nil], [[NSArray alloc] initWithObjects:turn2, nil], nil];
            scr = [NSString stringWithFormat:@"%@/ %@", [self megascramble:turn suf:[[NSArray alloc] initWithObjects:@"", nil] sql:40 ia:YES], [self scramble333:0]];
            viewType=0; break;
        }
        case 361:   //8x8
        {
            turn = [[NSArray alloc] initWithObjects:@"U", @"u", @"3u", @"4u", @"3d", @"d", @"D", @"L", @"l", @"3l", @"4r", @"3r", @"r", @"R", @"F", @"f", @"3f", @"4f", @"3b", @"b", @"B", nil];
            scr = [self megascramble:turn len:3 suf:cubesuff sql:120];
            viewType = 8; break;
        }
        case 362:   //9x9
        {
            turn = [[NSArray alloc] initWithObjects:@"U", @"u", @"3u", @"4u", @"4d", @"3d", @"d", @"D", @"L", @"l", @"3l", @"4l", @"4r", @"3r", @"r", @"R", @"F", @"f", @"3f", @"4f", @"4b", @"3b", @"b", @"B", nil];
            scr = [self megascramble:turn len:3 suf:cubesuff sql:120];
            viewType = 9; break;
        }
        case 192:   //megaminx
            scr = [self scrambleMinx]; viewType=14;
            break;
        case 193:
            scr = [self oldminxscramble]; viewType=0;
            break;
        case 608:   //minx subsets
            turn = [[NSArray alloc] initWithObjects:@"R", @"U", nil];
            scr = [self megascramble:turn len:2 suf:cubesuff sql:25];
            viewType=0; break;
        case 609:
        {
            NSArray *turn1 = [[NSArray alloc] initWithObjects:@"R U R'", @"R U2 R'", @"R U' R'", @"R U2' R'", nil];
            NSArray *turn2 = [[NSArray alloc] initWithObjects:@"F' U F", @"F' U2 F", @"F' U' F", @"F' U2' F", nil];
            NSArray *turn3 = [[NSArray alloc] initWithObjects:@"U", @"U2", @"U'", @"U2'", nil];
            turn = [[NSArray alloc] initWithObjects:[[NSArray alloc] initWithObjects:turn1, nil], [[NSArray alloc] initWithObjects:turn2, nil], [[NSArray alloc] initWithObjects:turn3, nil], nil];
            NSArray *suff = [[NSArray alloc] initWithObjects:@"", nil];
            scr = [self megascramble:turn suf:suff sql:25 ia:YES];
            viewType=0; break;
        }
        case 512:   //other
            scr = [self scrambleLat]; viewType=0;
            break;
        case 513:   //heli
            scr = [self helicubescramble]; viewType=0;
            break;
        case 514:   //sq2
        {
            int i=0;
			NSMutableString *sb = [NSMutableString string];
			while (i<20) {
				int rndu = rand()%12-5;
				int rndd = rand()%12-5;
				if (rndu != 0 || rndd != 0) {
					i++;
                    [sb appendFormat:@"(%d,%d) / ", rndu, rndd];
					//sb.append( "(" + rndu + "," + rndd + ") / ");
				}
			}
            scr = sb; viewType=0;
            break;
        }
        case 515:   //super sq1
            scr = [self scrambleSq:2]; viewType=0;
            break;
        case 516:   //ufo
        {
            NSArray *turn1 = [[NSArray alloc] initWithObjects:@"A", nil];
            NSArray *turn2 = [[NSArray alloc] initWithObjects:@"B", nil];
            NSArray *turn3 = [[NSArray alloc] initWithObjects:@"C", nil];
            NSArray *turn4 = [[NSArray alloc] initWithObjects:@"U", @"U'", @"U2'", @"U2", @"U3", nil];
            turn = [[NSArray alloc] initWithObjects:[[NSArray alloc] initWithObjects:turn1, nil], [[NSArray alloc] initWithObjects:turn2, nil], [[NSArray alloc] initWithObjects:turn3, nil], [[NSArray alloc] initWithObjects:turn4, nil], nil];
            scr = [self megascramble:turn suf:[[NSArray alloc] initWithObjects:@"", nil] sql:25 ia:YES];
            viewType=0; break;
        }
        case 517:   //FTO
        {
            turn = [[NSArray alloc] initWithObjects:@"U", @"D", @"F", @"B", @"L", @"BR", @"R", @"BL", nil];
            NSArray *suff = [[NSArray alloc] initWithObjects:@"", @"'", nil];
            scr = [self megascramble:turn len:4 suf:suff sql:25];
            viewType=0; break;
        }
        case 224:   //pyraminx
            scr = [self scramblePyrm]; viewType=13;
            break;
        case 225:
        {
            int cnt=0;
            int rnd[4];
			for(int i=0;i<4;i++){
				rnd[i]=rand()%3;
				if(rnd[i]>0) cnt++;
			}
            NSArray *ss= [[NSArray alloc] initWithObjects:@"", @"b ", @"b' ", @"", @"l ", @"l' ", @"", @"u ", @"u' ", @"", @"r ", @"r' ", nil];
            turn = [[NSArray alloc] initWithObjects:@"R", @"L", @"U", @"B", nil];
            NSArray *suff = [[NSArray alloc] initWithObjects:@"", @"'", nil];
            scr = [NSString stringWithFormat:@"%@%@%@%@%@", [ss objectAtIndex:rnd[0]], [ss objectAtIndex:3+rnd[1]], [ss objectAtIndex:6+rnd[2]], [ss objectAtIndex:9+rnd[3]], [self megascramble:turn len:4 suf:suff sql:15-cnt]];
            viewType=13; break;
        }
        case 448:   //siamese
            turn = [[NSArray alloc] initWithObjects:@"R", @"r", @"U", @"u", nil];
            scr = [NSString stringWithFormat:@"%@z2 %@", [self megascramble:turn len:2 suf:cubesuff sql:25], [self megascramble:turn len:2 suf:cubesuff sql:25]];
            viewType=0; break;
        case 449:
        {
            NSArray *turn1 = [[NSArray alloc] initWithObjects:@"R", @"r", nil];
            NSArray *turn2 = [[NSArray alloc] initWithObjects:@"U", nil];
            turn = [[NSArray alloc] initWithObjects:turn1, turn2, nil];
            scr = [NSString stringWithFormat:@"%@z2 %@", [self megascramble:turn suf:cubesuff sql:25 ia:NO], [self megascramble:turn suf:cubesuff sql:25 ia:NO]];
            viewType=0; break;
        }
        case 450:
            turn = [[NSArray alloc] initWithObjects:@"R", @"U", @"F", nil];
            scr = [NSString stringWithFormat:@"%@z2 y %@", [self megascramble:turn len:3 suf:cubesuff sql:25], [self megascramble:turn len:3 suf:cubesuff sql:25]];
            viewType=0; break;
        case 320:   //skewb
            scr = [self scrambleSkb]; viewType=12;
            break;
        case 321:
        {
            turn = [[NSArray alloc] initWithObjects:@"R", @"U", @"L", @"B", nil];
            NSArray *suff = [[NSArray alloc] initWithObjects:@"", @"'", nil];
            scr = [self megascramble:turn len:4 suf:suff sql:15];
            viewType=12; break;
        }
        case 256:   //sq1
            scr = [self scrambleSq1]; viewType=10;
            break;
        case 257:
        case 258:
            scr = [self scrambleSq:idx-257];
            viewType=10; break;
        case 259:
            scr = [self scrambleSq1:1037];
            viewType = 10; break;
        case 480:   //15 puzzle
            scr = [self do15puz:false];
            viewType=0; break;
        case 481:
            scr = [self do15puz:true];
            viewType=0; break;
        default:
            scr = @"";
            break;
    }
    return scr;
}

+ (void)doslice:(int)f d:(int)d q:(int)q {
    //do move of face f, layer d, q quarter turns
    int f1=0,f2=0,f3=0,f4=0;
    int s2=cubeSize*cubeSize;
    int i,j,k;
    NSNumber *c;
    if(f>5)f-=6;
    // cycle the side facelets
    for(k=0; k<q; k++) {
        for(i=0; i<cubeSize; i++) {
            if(f==0){
                f1=6*s2-cubeSize*d-cubeSize+i;
                f2=2*s2-cubeSize*d-1-i;
                f3=3*s2-cubeSize*d-1-i;
                f4=5*s2-cubeSize*d-cubeSize+i;
            }else if(f==1){
                f1=3*s2+d+cubeSize*i;
                f2=3*s2+d-cubeSize*(i+1);
                f3=  s2+d-cubeSize*(i+1);
                f4=5*s2+d+cubeSize*i;
            }else if(f==2){
                f1=3*s2+d*cubeSize+i;
                f2=4*s2+cubeSize-1-d+cubeSize*i;
                f3=  d*cubeSize+cubeSize-1-i;
                f4=2*s2-1-d-cubeSize*i;
            }else if(f==3){
                f1=4*s2+d*cubeSize+cubeSize-1-i;
                f2=2*s2+d*cubeSize+i;
                f3=  s2+d*cubeSize+i;
                f4=5*s2+d*cubeSize+cubeSize-1-i;
            }else if(f==4){
                f1=6*s2-1-d-cubeSize*i;
                f2=cubeSize-1-d+cubeSize*i;
                f3=2*s2+cubeSize-1-d+cubeSize*i;
                f4=4*s2-1-d-cubeSize*i;
            }else if(f==5){
                f1=4*s2-cubeSize-d*cubeSize+i;
                f2=2*s2-cubeSize+d-cubeSize*i;
                f3=s2-1-d*cubeSize-i;
                f4=4*s2+d+cubeSize*i;
            }
            c = [scrPosit objectAtIndex:f1];
            [scrPosit replaceObjectAtIndex:f1 withObject:[scrPosit objectAtIndex:f2]];
            [scrPosit replaceObjectAtIndex:f2 withObject:[scrPosit objectAtIndex:f3]];
            [scrPosit replaceObjectAtIndex:f3 withObject:[scrPosit objectAtIndex:f4]];
            [scrPosit replaceObjectAtIndex:f4 withObject:c];
        }
        /* turn face */
        if(d==0) {
            for(i=0; i+i<cubeSize; i++) {
                for(j=0; j+j<cubeSize-1; j++) {
                    f1=f*s2+         i+         j*cubeSize;
                    f3=f*s2+(cubeSize-1-i)+(cubeSize-1-j)*cubeSize;
                    if(f<3){
                        f2=f*s2+(cubeSize-1-j)+         i*cubeSize;
                        f4=f*s2+         j+(cubeSize-1-i)*cubeSize;
                    }else{
                        f4=f*s2+(cubeSize-1-j)+         i*cubeSize;
                        f2=f*s2+         j+(cubeSize-1-i)*cubeSize;
                    }
                    c = [scrPosit objectAtIndex:f1];
                    [scrPosit replaceObjectAtIndex:f1 withObject:[scrPosit objectAtIndex:f2]];
                    [scrPosit replaceObjectAtIndex:f2 withObject:[scrPosit objectAtIndex:f3]];
                    [scrPosit replaceObjectAtIndex:f3 withObject:[scrPosit objectAtIndex:f4]];
                    [scrPosit replaceObjectAtIndex:f4 withObject:c];
                }
            }
        }
    }
}

+ (NSMutableArray *) imageString:(int)size scr:(NSString *)scr {
    scr = [DCTUtils replace:scr str:@"M'" with:@"r R'"];
    scr = [DCTUtils replace:scr str:@"M2" with:@"r2 R2"];
    scr = [DCTUtils replace:scr str:@"M" with:@"r' R"];
    scr = [DCTUtils replace:scr str:@"x'" with:@"r' L"];
    scr = [DCTUtils replace:scr str:@"x2" with:@"r2 L2"];
    scr = [DCTUtils replace:scr str:@"x" with:@"r L'"];
    NSArray *s = [scr componentsSeparatedByString:@" "];
    NSMutableArray *seq = [[NSMutableArray alloc] init];
    int k;
    if(s.count>0) {
        for(int i=0; i<s.count; i++) {
            int move = 0;
            k=0;
            if([[s objectAtIndex:i] length]>0) {
                switch ([[s objectAtIndex:i] characterAtIndex:0]) {
                    case '4': k=3; break;
                    case '3': k=2; break;
                    case '2': k=1; break;
                    case 'r': k = 1;
                    case 'R': move = 16; break;
                    case 'l': k = 1;
                    case 'L': move = 4; break;
                    case 'u': k = 1;
                    case 'U': move = 12; break;
                    case 'd': k = 1;
                    case 'D': move = 0; break;
                    case 'f': k = 1;
                    case 'F': move = 20; break;
                    case 'b': k = 1;
                    case 'B': move = 8; break;
                    default: break;
                }
                if([[s objectAtIndex:i] length]>1) {
                    switch ([[s objectAtIndex:i] characterAtIndex:1]) {
                        case '\'':
                            move+=2; break;
                        case '2': move++; break;
                        case 'w': move+=24; break;
                        case 179: k = 2; break;
                        case 178: k = 1; break;
                        case 'r':
                        case 'R': move = 16; break;
                        case 'l':
                        case 'L': move = 4; break;
                        case 'u':
                        case 'U': move = 12; break;
                        case 'd':
                        case 'D': move = 0; break;
                        case 'f':
                        case 'F': move = 20; break;
                        case 'b':
                        case 'B': move = 8; break;
                        default:
                            //NSLog(@"%hu", [[s objectAtIndex:i] characterAtIndex:1]);
                            break;
                    }
                    if([[s objectAtIndex:i] length]>2) {
                        switch ([[s objectAtIndex:i] characterAtIndex:2]) {
                            case '\'':
                                move+=2; break;
                            case '2': move++; break;
                            default: break;
                        } 
                    }
                }
                [seq addObject:[NSNumber numberWithInt:move+k*24]];
            }
        }
    }
    scrPosit = [[NSMutableArray alloc] init];
    cubeSize = size;
    int i,j,f,q,d=0;
    // initialise colours
    for(i=0; i<6; i++)
        for( f=0; f<size*size; f++)
            [scrPosit addObject:[NSNumber numberWithInt:i]];//posit[d++]=i;
    // do move sequence
    for(i=0; i<seq.count; i++){
        q=[[seq objectAtIndex:i] intValue]&3;
        f=[[seq objectAtIndex:i] intValue]>>2;
        d=0;
        while(f>5) { f-=6; d++; }
        do{
			[self doslice:f d:d q:q+1];//doslice(f,d,q+1);
			d--;
		} while( d>=0 );
    }
    // build lookup table
    flat2posit = [[NSMutableArray alloc] init];
    for(i=0; i<12*size*size; i++) [flat2posit addObject:[NSNumber numberWithInt:-1]];
    for(i=0; i<size; i++){
        for(j=0; j<size; j++){
            [flat2posit replaceObjectAtIndex:4*size*(3*size-i-1)+size+j withObject:[NSNumber numberWithInt:i*size+j]];
            //flat2posit[4*size*(3*size-i-1)+  size+j  ]=        i *size+j; //D
            [flat2posit replaceObjectAtIndex:4*size*(size+i)+size-j-1 withObject:[NSNumber numberWithInt:(size+i)*size+j]];
            //flat2posit[4*size*(  size+i  )+  size-j-1]=(  size+i)*size+j; //L
            [flat2posit replaceObjectAtIndex:4*size*(size+i)+4*size-j-1 withObject:[NSNumber numberWithInt:(2*size+i)*size+j]];
            //flat2posit[4*size*(  size+i  )+4*size-j-1]=(2*size+i)*size+j; //B
            [flat2posit replaceObjectAtIndex:4*size*(i)+size+j withObject:[NSNumber numberWithInt:(3*size+i)*size+j]];
            //flat2posit[4*size*(       i  )+  size+j  ]=(3*size+i)*size+j; //U
            [flat2posit replaceObjectAtIndex:4*size*(size+i)+2*size+j withObject:[NSNumber numberWithInt:(4*size+i)*size+j]];
            //flat2posit[4*size*(  size+i  )+2*size+j  ]=(4*size+i)*size+j; //R
            [flat2posit replaceObjectAtIndex:4*size*(size+i)+size+j withObject:[NSNumber numberWithInt:(5*size+i)*size+j]];
            //flat2posit[4*size*(  size+i  )+  size+j  ]=(5*size+i)*size+j; //F
        }
    }
    d=0;
    NSMutableArray *img = [[NSMutableArray alloc] init];
    int colorPerm[] = {0, 5, 1, 3, 2, 4};
    for(i=0;i<3*size;i++){
        for(f=0;f<4*size;f++){
            int fd = [[flat2posit objectAtIndex:d] intValue];
            if(fd<0){
            }else{
                int c = [[scrPosit objectAtIndex:fd] intValue];
                [img addObject:@(colorPerm[c])];
                //[img appendFormat:@"%d", colorPerm[c]];
                //img[l++]=(byte) (colors[c]);
            }
            d++;
        }
    }
    return img;
}
@end
