//
//  cube222.m
//  DCTimer Solvers
//
//  Created by MeigenChou on 12-11-2.
//  Copyright (c) 2012年 MeigenChou. All rights reserved.
//

#import "Cube222.h"
#import "Im.h"
#import "stdlib.h"
#import "time.h"

@interface Cube222 ()
@property (nonatomic, strong) NSArray *turn;
@property (nonatomic, strong) NSArray *suf;
@property (nonatomic, strong) NSMutableString *sol;
@end

@implementation Cube222
@synthesize turn, suf, sol;
int state222[2][8];
char p2prun[5040];
short permmv[5040][3];
char t2prun[729];
short twstmv[729][3];
extern int fact[];

- (void) idxToPrm: (int[])ps p:(int)idx {
    int val = 0x6543210;
    for (int i=0; i<6; i++) {
        int p = fact[6-i];
        int v = idx / p;
        idx -= v*p;
        v <<= 2;
        ps[i] = (val >> v) & 07;
        int m = (1 << v) - 1;
        val = (val & m) + ((val >> 4) & ~m);
    }
    ps[6] = val;
}

- (int) prmToIdx: (int[]) ps {
    int idx = 0;
    int val = 0x6543210;
    for (int i=0; i<7; i++) {
        int v = ps[i] << 2;
        idx = (7 - i) * idx + ((val >> v) & 07);
        val -= 0x1111110 << v;
    }
    return idx;
}

-(void) permMove:(int[])ps m:(int)m {
    switch (m) {
        case 0: //U
            [Im cir:ps a:0 b:1 c:3 d:2];
            break;
        case 1: //R
            [Im cir:ps a:0 b:4 c:5 d:1];
            break;
        case 2: //F
            [Im cir:ps a:0 b:2 c:6 d:4];
            break;
        case 3: //D
            [Im cir:ps a:4 b:6 c:7 d:5];
            break;
        case 4: //L
            [Im cir:ps a:2 b:3 c:7 d:6];
            break;
        case 5: //B
            [Im cir:ps a:1 b:5 c:7 d:3];
            break;
    }
}

-(void) twistMove:(int[])ps m:(int)m {
    int c;
    switch (m) {
        case 0:
            [Im cir:ps a:0 b:1 c:3 d:2];    //U
            break;
        case 1:
            c=ps[0]; ps[0]=ps[4]+2; ps[4]=ps[5]+1; ps[5]=ps[1]+2; ps[1]=c+1;//R
			break;
		case 2:
			c=ps[0]; ps[0]=ps[2]+1; ps[2]=ps[6]+2; ps[6]=ps[4]+1; ps[4]=c+2;//F
			break;
        case 3:
            [Im cir:ps a:4 b:6 c:7 d:5];    //D
            break;
        case 4:
            c=ps[2]; ps[2]=ps[3]+1; ps[3]=ps[7]+2; ps[7]=ps[6]+1; ps[6]=c+2;//L
			break;
		case 5:
			c=ps[1]; ps[1]=ps[5]+2; ps[5]=ps[7]+1; ps[7]=ps[3]+2; ps[3]=c+1;//B
			break;
    }
}

-(void) doMove:(int)m n:(int)n {
    n %= 4;
    if(n>0) {
        switch (m) {
			case 0:	//U
			case 1:	//R
			case 2:	//F
			case 3:	//D
			case 4:	//L
			case 5:	//B
				for(int i=0; i<n; i++) {
					[self permMove:state222[0] m:m];
					[self twistMove:state222[1] m:m];
				}
				break;
			case 6:	//y
			case 7:	//x
			case 8:	//z
				for(int i=0; i<n; i++) {
					[self permMove:state222[0] m:m-6];
					[self twistMove:state222[1] m:m-6];
				}
				for(int i=0; i<4-n; i++) {
                    [self permMove:state222[0] m:m-3];
					[self twistMove:state222[1] m:m-3];
				}
				break;
        }
    }
}

-(void) swap:(int)first s:(int)second {
    if (first<0 || second<0 || first>7 || second>7 || first==second) {
        return;
    }
    //perm
    [Im cir:state222[0] a:first b:second];
    //twist
    [Im cir:state222[1] a:first b:second];
}

-(void) twist:(int)corner v:(int)value {
    if (value < 0) return;
    state222[1][corner] += value;
}

-(void) reset {
    for(int i=0; i<8; i++) {
        state222[0][i] = i;
        state222[1][i] = 0;
    }
}

-(void) randomEG:(int)type o:(NSString*)olls {
    [self reset];
    for(int i=0; i<3; i++)
        [self doMove:i+6 n:rand()%4];
    switch (type) {
        case 4:
            break;
        case 2:
            [self swap:4 s:6];
            break;
        case 1:
            [self swap:5 s:6];
            break;
        case 6:
            if(rand()%2 == 1)
                [self swap:4 s:5];
            break;
        case 5:
            if(rand()%2 == 1)
                [self swap:5 s:6];
            break;
        case 3:
            [self swap:4+(rand()%2) s:6];
            break;
        default:
            switch (rand()%3) {
                case 0:
                    break;
                case 1:
                    [self swap:4 s:6];
                    break;
                case 2:
                    [self swap:5 s:6];
                    break;
            }
            break;
    }
    for(int i=0; i<4; i++)
        [self swap:i s:i+rand()%(4-i)];
    if([olls isEqualToString:@""])
        [Im idxToZsOri:state222[1] i:(rand()%27) n:3 l:4];
    else if([olls isEqualToString:@"X"] || [olls isEqualToString:@"PHUTLSA"])
        [Im idxToZsOri:state222[1] i:(rand()%26)+1 n:3 l:4];
    else {
        char oll = [olls characterAtIndex:rand()%[olls length]];
        switch (oll) {
            case 'P':
                [self twist:0 v:2]; [self twist:1 v:1]; [self twist:2 v:2]; [self twist:3 v:1];
                break;
            case 'H':
                [self twist:0 v:2]; [self twist:1 v:1]; [self twist:2 v:1]; [self twist:3 v:2];
                break;
            case 'U':
                [self twist:2 v:2]; [self twist:3 v:1];
                break;
            case 'T':
                [self twist:2 v:1]; [self twist:3 v:2];
                break;
            case 'L':
                [self twist:0 v:2]; [self twist:3 v:1];
                break;
            case 'S':
                [self twist:0 v:2]; [self twist:1 v:2]; [self twist:3 v:2];
                break;
            case 'A':
                [self twist:0 v:1]; [self twist:1 v:1]; [self twist:3 v:1];
                break;
            case 'N':
                break;
        }
    }
    [self doMove:0 n:(rand()%4)];
    while (state222[0][4]!=7 && state222[0][5]!=7 && state222[0][6]!=7 && state222[0][7]!=7) {
        [self doMove:7 n:1];
    }
    while (state222[0][7]!=7) {
        [self doMove:6 n:1];
    }
    while (state222[1][7]%3 != 0) {
        [self doMove:7 n:1];
        [self doMove:6 n:1];
    }
}

- (void) randomTEG: (int)type t:(int)twst {
    [self reset];
    for(int i=0; i<3; i++)
    [self doMove:i+6 n:rand()%4];
    switch (type) {
        case 4:
            break;
        case 2:
            [self swap:4 s:6];
            break;
        case 1:
            [self swap:5 s:6];
            break;
        case 6:
            if(rand()%2 == 1)
            [self swap:4 s:5];
            break;
        case 5:
            if(rand()%2 == 1)
            [self swap:5 s:6];
            break;
        case 3:
            [self swap:4+(rand()%2) s:6];
            break;
        default:
        switch (rand()%3) {
            case 0:
            break;
            case 1:
            [self swap:4 s:6];
            break;
            case 2:
            [self swap:5 s:6];
            break;
        }
        break;
    }
    for(int i=0; i<4; i++)
        [self swap:i s:i+rand()%(4-i)];
    [Im idxToZsOri:state222[1] i:(rand()%27) n:3 l:4];
    [self twist:4 v:twst];
    [self twist:(rand()%4) v:(3-twst)];
    [self doMove:0 n:(rand()%4)];
    while (state222[0][4]!=7 && state222[0][5]!=7 && state222[0][6]!=7 && state222[0][7]!=7) {
        [self doMove:7 n:1];
    }
    while (state222[0][7]!=7) {
        [self doMove:6 n:1];
    }
    while (state222[1][7]%3 != 0) {
        [self doMove:7 n:1];
        [self doMove:6 n:1];
    }
}

- (int) getprmmv: (int)p m:(int)m {
    //given position p<5040 and move m<3, return new position number
    //convert number into array;
    int ps[8];
    [self idxToPrm:ps p:p];
    //perform move on array
    [self permMove:ps m:m];
    //convert array back to number
    return [self prmToIdx:ps];
}

- (int)gettwsmv: (int)p m:(int)m {
    //given orientation p<729 and move m<3, return new orientation number
    //convert number into array;
    int ps[7];
    [Im idxToZsOri:ps i:p n:3 l:7];
    //perform move on array
    [self twistMove:ps m:m];
    //convert array back to number
    return [Im zsOriToIdx:ps n:3 l:7];
}

- (void) calcperm {
    //calculate solving arrays
    //first permutation
    for (int p = 0; p < 5040; p++) {
        p2prun[p] = -1;
        for (int m = 0; m < 3; m++) {
            permmv[p][m] = [self getprmmv:p m:m];
        }
    }
    p2prun[0] = 0;
    for (int l = 0; l <= 6; l++)
        for (int p = 0; p < 5040; p++) {
            if (p2prun[p] == l)
                for (int m = 0; m < 3; m++) {
                    int q = p;
                    for (int c = 0; c < 3; c++) {
                        q = permmv[q][m];
                        if (p2prun[q] == -1)
                            p2prun[q] = l + 1;
                    }
                }
    }
    //then twist
    for (int p = 0; p < 729; p++) {
        t2prun[p] = -1;
        for (int m = 0; m < 3; m++) {
            twstmv[p][m] = [self gettwsmv:p m:m];
        }
    }
    t2prun[0] = 0;
    for (int l = 0; l <= 5; l++)
        for (int p = 0; p < 729; p++)
            if (t2prun[p] == l)
                for (int m = 0; m < 3; m++) {
                    int q = p;
                    for (int c = 0; c < 3; c++) {
                        q = twstmv[q][m];
                        if (t2prun[q] == -1)
                            t2prun[q] = l + 1;
                    }
                }
}

- (Cube222 *)init {
    if(self = [super init]) {
        self.turn = [[NSArray alloc] initWithObjects:@"U", @"R", @"F", nil];
        self.suf = [[NSArray alloc] initWithObjects:@"'", @"2", @"", nil];
        [self calcperm];
        srand((unsigned)time(0));
    }
    return self;
}

- (BOOL) search: (int)q t:(int)t l:(int)l lm:(int)lm {
    if (l == 0) return q == 0 && t == 0;
    if (p2prun[q] > l || t2prun[t] > l) return false;
    int p,s,a,m;
    for (m = 0; m < 3; m++) {
        if (m != lm) {
            p = q; s = t;
            for (a = 0; a < 3; a++) {
                p = permmv[p][m];
                s = twstmv[s][m];
                if ([self search:p t:s l:(l-1) lm:m]) {
                    [self.sol appendFormat:@"%@%@ ", [self.turn objectAtIndex:m], [self.suf objectAtIndex:a]];
                    return true;
                }
            }
        }
    }
    return false;
}

-(NSString *)solve:(int)q t:(int)t {
    sol = [NSMutableString string];
    
    for (int l=0; l<12; l++) {
        if ([self search:q t:t l:l lm:-1]) {
            return sol;
        }
    }
    return @"";
}

- (NSString *)scr222 {
    int p, o;
    do {
        p = rand() % 5040;
        o = rand() % 729;
    } while (p==0 && o==0);
    return [self solve:p t:o];
}

- (NSString *)scrCLL {
    [self randomEG:4 o:@"X"];
    int p = [self prmToIdx:state222[0]];
    int o = [Im zsOriToIdx:state222[1] n:3 l:7];
    return [self solve:p t:o];
}

- (NSString *)scrEG1 {
    [self randomEG:2 o:@"X"];
    int p = [self prmToIdx:state222[0]];
    int o = [Im zsOriToIdx:state222[1] n:3 l:7];
    return [self solve:p t:o];
}

- (NSString *)scrEG2 {
    [self randomEG:1 o:@"X"];
    int p = [self prmToIdx:state222[0]];
    int o = [Im zsOriToIdx:state222[1] n:3 l:7];
    return [self solve:p t:o];
}

- (NSString *)scrPBL {
    [self randomEG:0 o:@"N"];
    int p = [self prmToIdx:state222[0]];
    int o = [Im zsOriToIdx:state222[1] n:3 l:7];
    return [self solve:p t:o];
}
    
- (NSString *) scrTCLL: (int)twst {
    int p, o;
    do {
        [self randomTEG:4 t:twst];
        p = [self prmToIdx:state222[0]];
        o = [Im zsOriToIdx:state222[1] n:3 l:7];
    } while (p==0 && o==0);
    return [self solve:p t:o];
}
@end
