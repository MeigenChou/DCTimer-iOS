//
//  SQ1.m
//  DCTimer scramblers
//
//  Created by MeigenChou on 13-3-3.
//  Copyright (c) 2013年 MeigenChou. All rights reserved.
//

#import "SQ1.h"
#import "DCTUtils.h"
#import "stdlib.h"
#import "time.h"

@implementation SQ1
int sqPosit[24];

- (id)init {
    if(self = [super init]) {
        srand((unsigned)time(0));
    }
    return self;
}

+ (void)initPosit {
    int newPosit[] = {0,0,1,2,2,3,4,4,5,6,6,7,8,9,9,10,11,11,12,13,13,14,15,15};
    for(int i=0; i<24; i++) sqPosit[i] = newPosit[i];
}

- (bool)sq1_domove:(int[])p x:(int)x y:(int)y {
    int i, temp;
    if (x == 7) {
        for (i=0; i<6; i++) {
            temp = p[i+6];
            p[i+6] = p[i+12];
            p[i+12] = temp;
        }
        return true;
    } else {
        if (p[(17-x)%12]!=0 || p[(11-x)%12]!=0 || p[12+(17-y)%12]!=0 || p[12+(11-y)%12]!=0) {
            return false;
        } else {
            // do the move itself
            int px[12], py[12];
            for(int j=0;j<12;j++)px[j]=p[j];
            for(int j=12;j<24;j++)py[j-12]=p[j];
            for (i=0; i<12; i++) {
                p[i] = px[(12+i-x)%12];
                p[i+12] = py[(12+i-y)%12];
            }
            return true;
        }
    }
}

- (void)sq1_getseq:(NSMutableArray *)seq type:(int)type len:(int)len {
    int p[] = {1,0,0,1,0,0,1,0,0,1,0,0,0,1,0,0,1,0,0,1,0,0,1,0};
    int cnt = 0;
    while (cnt < len) {
        int x = rand() % 12 - 5;
        int y = (type==2) ? 0 : rand() % 12 - 5;
        int size = (x==0?0:1) + (y==0?0:1);
        if ((cnt + size <= len || type != 1) && (size > 0 || cnt == 0)) {
            if ([self sq1_domove:p x:x y:y]) {
                if (type == 1) cnt += size;
                if (size > 0) {
                    NSArray *m = [[NSArray alloc] initWithObjects:@(x), @(y), nil];
                    //seq[seql][0] = x;
                    //seq[seql++][1] = y;
                    [seq addObject:m];
                }
                if (cnt < len || type != 1) {
                    cnt++;
                    NSArray *n = [[NSArray alloc] initWithObjects:@(7), @(0), nil];
                    //seq[seql][0] = 7;
                    //seq[seql++][1] = 0;
                    [seq addObject:n];
                    //seq[n][seql++] = new byte[]{7,0};
                    [self sq1_domove:p x:7 y:0];
                }
            }
        }
    }
}

- (NSString *) sq1_scramble: (int)type {
    NSMutableArray *seq = [[NSMutableArray alloc] init];//int seq[40][2];
    int i, len = type==1?40:20;
    //byte[] k;
    [self sq1_getseq:seq type:type len:len];
    NSMutableString *s = [NSMutableString string];
    for(i=0; i<seq.count; i++){
        //k=seq[0][i];
        if([[[seq objectAtIndex:i] objectAtIndex:0] intValue] == 7) {
            [s appendString:@"/ "];
        } else {
            [s appendFormat:@"(%d,%d) ", [[[seq objectAtIndex:i] objectAtIndex:0] intValue], [[[seq objectAtIndex:i] objectAtIndex:1] intValue]];
            //s.append("(" + seq[0][i][0] + "," + seq[0][i][1] + ") ");
        }
    }
    return s;
}

- (NSString *) ssq1t_scramble {
    NSMutableArray *seq = [[NSMutableArray alloc] init];
    NSMutableArray *seq1 = [[NSMutableArray alloc] init];
    int i;
    [self sq1_getseq:seq type:0 len:20];
    [self sq1_getseq:seq1 type:0 len:20];
    NSMutableString *u = [NSMutableString string];
    //int[][] temp={{0,0}};
    int st = 0, st1 = 0;
    if ([[[seq objectAtIndex:0] objectAtIndex:0] intValue] == 7) {
        st = 1;
    }
    if ([[[seq1 objectAtIndex:0] objectAtIndex:0] intValue]==7) {
        st1 = 1;
    }
    for(i=0;i<20;i++){
        [u appendFormat:@"(%d,%d,%d,%d) / ", [[[seq objectAtIndex:2*i+st] objectAtIndex:0] intValue], [[[seq1 objectAtIndex:2*i+st] objectAtIndex:0] intValue], [[[seq1 objectAtIndex:2*i+st] objectAtIndex:1] intValue], [[[seq objectAtIndex:2*i+st] objectAtIndex:1] intValue]];
        //u.append("(" + s[2*i][0] + "," + t[2*i][0] + "," + t[2*i][1] + "," + s[2*i][1] + ") / ");
    }
    return u;
}

+ (bool)doMove:(int)m {
    int i,c,f=m;
    char t[12];
    //do move f
    if(f==0){
        for(i=0; i<6; i++){
            c=sqPosit[i+12];
            sqPosit[i+12]=sqPosit[i+6];
            sqPosit[i+6] = c;
        }
    }else if(f>0){
        f=12-f;
        if( sqPosit[f]==sqPosit[f-1] ) return true;
        if( f<6 && sqPosit[f+6]==sqPosit[f+5] ) return true;
        if( f>6 && sqPosit[f-6]==sqPosit[f-7] ) return true;
        if( f==6 && sqPosit[0]==sqPosit[11] ) return true;
        for(i=0;i<12;i++) t[i]=sqPosit[i];
        c=f;
        for(i=0;i<12;i++){
            sqPosit[i]=t[c];
            if(c==11)c=0; else c++;
        }
    }else if(f<0){
        f=-f;
        if( sqPosit[f+12]==sqPosit[f+11] ) return true;
        if( f<6 && sqPosit[f+18]==sqPosit[f+17] ) return true;
        if( f>6 && sqPosit[f+6]==sqPosit[f+5] ) return true;
        if( f==6 && sqPosit[12]==sqPosit[23] ) return true;
        for(i=0;i<12;i++) t[i]=sqPosit[i+12];
        c=f;
        for(i=0;i<12;i++){
            sqPosit[i+12]=t[c];
            if(c==11)c=0; else c++;
        }
    }
    return false;
}

+ (NSMutableArray *)imagestr:(NSString *)s {
    NSArray *scr = [s componentsSeparatedByString:@" "];
    [SQ1 initPosit];
    BOOL sqMi = YES;
    for (int i=0; i<[scr count]; i++) {
        if ([[scr objectAtIndex:i] isEqualToString:@"/"]) {
            [SQ1 doMove:0];
            sqMi = !sqMi;
        } else {
            NSString *s = [scr objectAtIndex:i];
            if (s.length != 0) {
                NSArray *p = [[DCTUtils substring:s s:1 e:(int)s.length-1] componentsSeparatedByString:@","];
                int top = [[p objectAtIndex:0] intValue];
                if(top > 0) [SQ1 doMove:top];
                else if(top < 0) [SQ1 doMove:(top+12)];
                int bottom = [[p objectAtIndex:1] intValue];
                if(bottom > 0) [SQ1 doMove:(bottom-12)];
                else if(bottom < 0) [SQ1 doMove:bottom];
            }
        }
    }
    NSMutableArray *img = [[NSMutableArray alloc] init];
    for (int i=0; i<24; i++)
        [img addObject:@(sqPosit[i])];
    [img addObject:@(sqMi)];
    return img;
}
@end
