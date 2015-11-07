//
//  RTower.m
//  DCTimer solvers
//
//  Created by MeigenChou on 13-3-17.
//  Copyright (c) 2013年 MeigenChou. All rights reserved.
//

#import "RTower.h"
#import "Im.h"
#import "stdlib.h"
#import "time.h"

@interface RTower ()
@property (nonatomic, strong) NSArray *turn1;
@property (nonatomic, strong) NSArray *turn2;
@property (nonatomic, strong) NSArray *suff;
@end

@implementation RTower
@synthesize turn1, turn2, suff;

- (id) init {
    if(self = [super init]) {
        turn1 = [[NSArray alloc] initWithObjects:@"R", @"F", @"Uw", @"L", @"B", nil];
        turn2 = [[NSArray alloc] initWithObjects:@"R", @"F", @"U", @"D", nil];
        suff = [[NSArray alloc] initWithObjects:@"'", @"2", @"", nil];
        [self initRTow];
        srand((unsigned)time(0));
    }
    return self;
}

- (void) initRTow {
    faces[0] = faces[1] = 1;
    faces[2] = faces[3] = 3;
    int arr[8];
    int idx[] = {3,0,1,2};
    for (int i = 0; i < 40320; i++) {
        for (int j = 0; j < 6; j++) {
            [Im set8Perm:arr i:i];
            switch(j) {
				case 0: [Im cir:arr a:4 b:5 c:6 d:7]; break;	//D
				case 1: [Im cir:arr a:1 b:2 c:6 d:5]; break;	//R
				case 2: [Im cir:arr a:2 b:3 c:7 d:6]; break;	//F
				case 3: [Im cir:arr a:0 b:3 c:2 d:1]; break;	//U
				case 4: [Im cir:arr a:0 b:4 c:7 d:3]; break;	//L
				case 5: [Im cir:arr a:0 b:1 c:5 d:4]; break;	//B
            }
            if(j>0) epm[i][j-1] = [Im get8Perm:arr];
            switch(j){
				case 1: [Im cir:arr a:1 b:2 c:6 d:5]; break;	//R
				case 2: [Im cir:arr a:2 b:3 c:7 d:6]; break;	//F
            }
            if(j<4) cpm[i][idx[j]]= [Im get8Perm:arr];
        }
    }
    for (int i = 0; i < 2187; i++) {
        for (int j = 0; j < 5; j++) {
            [Im idxToZsOri:arr i:i n:3 l:8];
            switch(j) {
				case 2: [Im cir:arr a:0 b:3 c:2 d:1]; break;	//U
				case 0: [Im cir:arr a:1 b:2 c:6 d:5];
                    arr[1]++; arr[2]+=2; arr[6]++; arr[5]+=2;
                    break;	//R
				case 1: [Im cir:arr a:2 b:3 c:7 d:6];
                    arr[2]++; arr[3]+=2; arr[7]++; arr[6]+=2;
                    break;	//F
				case 3: [Im cir:arr a:0 b:4 c:7 d:3];
                    arr[3]++; arr[0]+=2; arr[4]++; arr[7]+=2;
                    break;	//L
				case 4: [Im cir:arr a:0 b:1 c:5 d:4];
                    arr[0]++; arr[1]+=2; arr[5]++; arr[4]+=2;
                    break;	//B
            }
            eom[i][j] = [Im zsOriToIdx:arr n:3 l:8];
        }
    }
    for (int i = 1; i < 40320; i++)
        cpd[i]=epd[i]=-1;
    cpd[0]=epd[0]=0;
    //int nVisited=1;
    for(int d=0; d<13; d++) {
        //nVisited = 0;
        for (int i = 0; i < 40320; i++)
            if (cpd[i] == d)
                for (int k = 0; k < 4; k++)
                    for(int y = i, m = 0; m < faces[k]; m++) {
                        y = cpm[y][k];
                        if (cpd[y] < 0) {
                            cpd[y] = d + 1;
                            //nVisited++;
                        }
                    }
        //System.out.println(d+1+" "+nVisited);
    }
    for(int d=0; d<7; d++) {
        //nVisited = 0;
        for (int i = 0; i < 40320; i++)
            if (epd[i] == d)
                for (int k = 0; k < 5; k++)
                    for(int y = i, m = 0; m < 3; m++) {
                        y = epm[y][k];
                        if (epd[y] < 0) {
                            epd[y] = d + 1;
                            //nVisited++;
                        }
                    }
        //System.out.println(d+" "+nVisited);
    }
    for (int i = 1; i < 2187; i++)
        eod[i]=-1;
    eod[0]=0;
    for(int d=0; d<6; d++) {
        //nVisited = 0;
        for (int i = 0; i < 2187; i++) 
            if (eod[i] == d) {
                for (int k = 0; k < 5; k++)
                    for(int y = i, m = 0; m < 3; m++) {
                        y = eom[y][k];
                        if (eod[y] < 0) {
                            eod[y] = d + 1;
                            //nVisited++;
                        }
                    }
            }
        //System.out.println(d+" "+nVisited);
    }
}

- (bool)search2:(int)cp ep:(int)ep d:(int)d lf:(int)lf {
    if (d == 0) return cp == 0 && ep == 0;
    if (epd[ep] > d || cpd[cp] > d) return false;
    for (int i = 0; i < 4; i++) {
        if (i != lf) {
            int y = cp, s = ep;
            for(int k = 0; k < faces[i]; k++){
                y = cpm[y][i]; if(i<2)s = epm[epm[s][i]][i];
                if([self search2:y ep:s d:d-1 lf:i]){
                    //sb.insert(0, turn2[i]+(i<2?"2":suff[k])+" ");
                    seq[d + len1] = i*3+(i<2?1:k);
                    return true;
                }
            }
        }
    }
    return false;
}

- (NSString *)solve2:(int)cp lf:(int)lf {
    for(int i=len1; i>0; i--) {
        int t = seq[i]/3, s = seq[i]%3;
        cp = epm[cp][t];
        if(s>0) {
            cp = epm[cp][t];
            if(s>1) cp = epm[cp][t];
        }
    }
    for (int depth = 0; ; depth++) {
        if([self search2:cp ep:0 d:depth lf:lf]) {
            NSMutableString *sb = [NSMutableString string];
            for(int i=len1+1; i<=depth+len1; i++) 
                [sb appendFormat:@"%@%@ ", [self.turn2 objectAtIndex:seq[i]/3], [self.suff objectAtIndex:seq[i]%3]];
                //sb.append(turn2[seq[i]/3]+suff[seq[i]%3]+" ");
            for(int i=1; i<=len1; i++)
                [sb appendFormat:@"%@%@ ", [self.turn1 objectAtIndex:seq[i]/3], [self.suff objectAtIndex:seq[i]%3]];
                //sb.append(turn1[seq[i]/3]+suff[seq[i]%3]+" ");
            return sb;
        }
    }
}

- (bool)search1:(int)ep eo:(int)eo d:(int)d lf:(int)lf {
    if (d == 0) return eo == 0 && ep == 0;
    if (epd[ep] > d || eod[eo] > d) return false;
    for (int i = 0; i < 5; i++) {
        if (lf==-1 || i%3!=lf%3) {
            int y=eo, s=ep;
            for(int j=0; j<3; j++){
                y=eom[y][i]; s=epm[s][i];
                if ([self search1:s eo:y d:d-1 lf:i]) {
                    //sb.insert(0, turn1[i]+suff[j]+" ");
                    seq[d] = i*3+j;
                    return true;
                }
            }
        }
    }
    return false;
}

- (NSString *)scramble {
    int eo = rand()%2187;
    int ep = rand()%40320;
    int cp = rand()%40320;
    for (int depth = 0; depth < 20; depth++) {
        if([self search1:ep eo:eo d:depth lf:-1]) {
            len1 = depth;
            int lf = seq[1]/3;
            if(lf > 2) lf = -1;
            //System.out.print(sb.toString()+".");
            return [self solve2:cp lf:lf];
        }
    }
    return @"";
}
@end
