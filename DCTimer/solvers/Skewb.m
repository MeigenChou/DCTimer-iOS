//
//  Skewb.m
//  DCTimer solvers
//
//  Created by MeigenChou on 13-2-20.
//  Copyright (c) 2013年 MeigenChou. All rights reserved.
//

#import "Skewb.h"
#import "Im.h"
#import "DCTUtils.h"
#import "stdlib.h"
#import "time.h"

@interface Skewb ()
@property (nonatomic, strong) NSArray *turn;
@property (nonatomic, strong) NSArray *suf;
@property (nonatomic, strong) NSMutableString *sol;
@end

@implementation Skewb
@synthesize turn, suf, sol;
short ctmSk[360][4];
char cpmSk[36][4];
char comSk[81][4];
char fcmSk[27][4];
char ctdSk[360];
char cdSk[36][81][27];

int imgSk[30];

- (void)initSkb {
    int arr[6];
    // move tables
    for (int i=0; i<360; i++)
        for (int j=0; j<4; j++) {
            [Im idxToEvenPerm:arr i:i l:6];
            switch(j){
				case 0: [Im cir3:arr a:2 b:5 c:3]; break;
				case 1: [Im cir3:arr a:0 b:3 c:4]; break;
				case 2: [Im cir3:arr a:1 b:4 c:5]; break;
				case 3: [Im cir3:arr a:3 b:5 c:4]; break;
            }
            ctmSk[i][j] = [Im evenPermToIdx:arr l:6];
        }
    int arr2[3];
    for (int i=0; i<12; i++) {
        for (int j=0; j<3; j++) {
            for (int k=0; k<4; k++) {
                [Im idxToEvenPerm:arr i:i l:4];
                [Im idxToEvenPerm:arr2 i:j l:3];
                switch (k) {
                    case 0:
                        [Im cir3:arr a:1 b:2 c:3]; break;
                    case 1:
                        [Im cir3:arr a:0 b:1 c:3]; break;
                    case 2:
                        [Im cir3:arr a:2 b:0 c:3]; break;
                    case 3:
                        [Im cir3:arr2 a:0 b:2 c:1]; break;
                }
                cpmSk[i*3+j][k] = [Im evenPermToIdx:arr l:4] * 3 + [Im evenPermToIdx:arr2 l:3];
            }
        }
    }
    for (int i = 0; i < 81; i++)
        for (int j = 0; j < 4; j++) {
            [Im idxToOri:arr i:i n:3 l:4];
            switch(j) {
				case 0: [Im cir3:arr a:1 b:2 c:3]; arr[1] += 2;
                    arr[2] += 2; arr[3] += 2; break;
				case 1: [Im cir3:arr a:0 b:1 c:3]; arr[0] += 2;
                    arr[1] += 2; arr[3] += 2; break;
				case 2: [Im cir3:arr a:2 b:0 c:3]; arr[0] += 2;
                    arr[2] += 2; arr[3] += 2; break;
				case 3: arr[3]++; break;
            }
            comSk[i][j] = [Im oriToIdx:arr n:3 l:4];
        }
    for (int i = 0; i < 27; i++)
        for (int j = 0; j < 4; j++) {
            [Im idxToOri:arr i:i n:3 l:3];
            switch (j) {
                case 0: arr[2]++; break;
                case 1: arr[0]++; break;
                case 2: arr[1]++; break;
                case 3: [Im cir3:arr a:0 b:2 c:1]; arr[0] += 2;
                    arr[1] += 2; arr[2] += 2; break;
            }
            fcmSk[i][j] = [Im oriToIdx:arr n:3 l:3];
        }
    
    // distance table
    for (int i = 0; i < 360; i++)
        ctdSk[i]=-1;
    for (int j = 0; j < 36; j++)
        for(int k = 0; k < 81; k++)
            for(int l = 0; l < 27; l++)
                cdSk[j][k][l] = -1;
    ctdSk[0] = 0; cdSk[0][0][0] = 0;
    //int c = 1;
    for(int d = 0; d < 5; d++) {
        //c = 0;
        for (int i = 0; i < 360; i++)
            if (ctdSk[i] == d)
                for (int m = 0; m < 4; m++) {
                    int p = i;
                    for(int n = 0; n < 2; n++){
                        p = ctmSk[p][m];
                        if (ctdSk[p] == -1) {
                            ctdSk[p] = d + 1;
                            //c++;
                        }
                    }
                }
        //NSLog(@"%d %d", d+1, c);
    }
    //c = 1;
    for(int d = 0; d < 7; d++) {
        //c = 0;
        for (int j = 0; j < 36; j++)
            for (int k = 0; k < 81; k++)
                for (int l = 0; l< 27; l++)
                    if (cdSk[j][k][l] == d)
                        for (int m = 0; m < 4; m++) {
                            int p = j, q = k, r = l;
                            for(int n = 0; n < 2; n++){
                                p = cpmSk[p][m];
                                q = comSk[q][m];
                                r = fcmSk[r][m];
                                if (cdSk[p][q][r] == -1) {
                                    cdSk[p][q][r] = d + 1;
                                    //c++;
                                }
                            }
                        }
        //NSLog(@"%d %d", d+1, c);
    }
}

-(Skewb *) init {
    if(self = [super init]) {
        self.turn = [[NSArray alloc] initWithObjects:@"R", @"U", @"L", @"B", nil];
        self.suf = [[NSArray alloc] initWithObjects:@"'", @"", nil];
        [self initSkb];
        srand((unsigned)time(0));
    }
    return self;
}

- (bool)search:(int)fp cp:(int)cp co:(int)co fco:(int)fco d:(int)d l:(int)l {
    if(d==0)return ctdSk[fp] == 0 && cdSk[cp][co][fco] == 0;
    if(ctdSk[fp] > d || cdSk[cp][co][fco] > d)return false;
    for(int k = 0; k < 4; k++)
        if(k != l){
            int p=fp, q=cp, r=co, s=fco;
            for(int m=0; m<2; m++){
                p=ctmSk[p][k]; q=cpmSk[q][k]; r=comSk[r][k]; s=fcmSk[s][k];
                if([self search:p cp:q co:r fco:s d:d-1 l:k]) {
                    [self.sol appendFormat:@"%@%@ ", [self.turn objectAtIndex:k], [self.suf objectAtIndex:m]];
                    return true;
                }
            }
        }
    return false;
}

- (NSString *)scrSkb {
    int fp = rand()%360;
    int cp, co, fco;
    do{
        cp = rand()%36;
        co = rand()%81;
        fco = rand()%27;
    }
    while (cdSk[cp][co][fco] < 0);
    self.sol = [NSMutableString string];
    for (int d = 0; d < 13; d++) {
        if([self search:fp cp:cp co:co fco:fco d:d l:-1]) {
            return self.sol;
        }
    }
    return @"";
}

+ (void)initColor {
    for(int i=0; i<5; i++)
        for(int j=0; j<6; j++) imgSk[j*5+i] = j;
}

+ (void)move:(int)turn {
    switch (turn) {
        case 0: //R
            [Im cir3:imgSk a:17 b:27 c:22];
            [Im cir3:imgSk a:19 b:29 c:23];
            [Im cir3:imgSk a:1 b:14 c:8];
            [Im cir3:imgSk a:20 b:18 c:28];
            [Im cir3:imgSk a:16 b:26 c:24];
            break;
        case 1: //U
            [Im cir3:imgSk a:2 b:22 c:7];
            [Im cir3:imgSk a:0 b:21 c:5];
            [Im cir3:imgSk a:3 b:20 c:8];
            [Im cir3:imgSk a:10 b:16 c:28];
            [Im cir3:imgSk a:6 b:1 c:24];
            break;
        case 2: //L
            [Im cir3:imgSk a:12 b:7 c:27];
            [Im cir3:imgSk a:13 b:9 c:25];
            [Im cir3:imgSk a:3 b:24 c:18];
            [Im cir3:imgSk a:10 b:8 c:26];
            [Im cir3:imgSk a:6 b:28 c:14];
            break;
        case 3: //B
            [Im cir3:imgSk a:22 b:27 c:7];
            [Im cir3:imgSk a:24 b:28 c:8];
            [Im cir3:imgSk a:0 b:19 c:13];
            [Im cir3:imgSk a:5 b:23 c:25];
            [Im cir3:imgSk a:21 b:29 c:9];
            break;
    }
}

+ (NSMutableArray *)image:(NSString *)scr {
    [Skewb initColor];
    NSString *moveIdx = @"RULB";
    NSArray *s = [scr componentsSeparatedByString:@" "];
    for(int i=0; i<s.count; i++) {
        if([[s objectAtIndex:i] length] > 0) {
            int mov = [DCTUtils indexOf:moveIdx c:[[s objectAtIndex:i] characterAtIndex:0]];
            [Skewb move:mov];
            if([[s objectAtIndex:i] length] > 1) [Skewb move:mov];
        }
    }
    NSMutableArray *img = [[NSMutableArray alloc] init];
    for(int i=0; i<30; i++) [img addObject:@(imgSk[i])];
    return img;
}
@end
