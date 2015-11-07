//
//  Cross.m
//  DCTimer Solvers
//
//  Created by MeigenChou on 12-11-17.
//  Copyright (c) 2012年 MeigenChou. All rights reserved.
//

#import "Cross.h"
#import "Im.h"
#import "CoordCube.h"
#import "DCTUtils.h"
@interface Cross()
@property (nonatomic, strong) NSArray *side;
@property (nonatomic, strong) NSArray *moveIdx, *rotIdx;
@property (nonatomic, strong) NSArray *turn, *suff;
@property (nonatomic, strong) NSMutableString *sol;
@end

@implementation Cross
@synthesize side, moveIdx, rotIdx, turn, suff, sol;
extern int Cnk[25][25];
int goalFeo[] = {8, 2, 4, 6};
bool inie = false;
int arrc[2][12];

-(Cross *) init {
    if(self = [super init]) {
        moveIdx = [[NSArray alloc] initWithObjects:@"UDLRFB", @"DURLFB", @"RLUDFB", @"LRDUFB", @"BFLRUD", @"FBLRDU", nil];
        side = [[NSArray alloc] initWithObjects:@"D:", @"U:", @"L:", @"R:", @"F:", @"B:", nil];
        rotIdx = [[NSArray alloc] initWithObjects:@"", @" z2", @" z'", @" z", @" x'", @" x", nil];
        turn = [[NSArray alloc] initWithObjects:@"U", @"D", @"L", @"R", @"F", @"B", nil];
        suff = [[NSArray alloc] initWithObjects:@"", @"2", @"'", nil];
        static bool inic = false;
        if(!inic) {
            [self initc];
            inic = true;
        }
    }
    return self;
}

-(void) circle:(int[])d f:(int)f h:(int)h l:(int)l n:(int)n s:(int)s {
    int q=d[f]; d[f]=d[n]^s; d[n]=d[l]^s; d[l]=d[h]^s; d[h]=q^s;
}

-(void) idxToPerm:(int[])s p:(int)p {
    int v;
    for(int q=1; 4>=q; q++){
        int t = p % q;
        for(p=p/q, v=q-2; v>=t; v--)
            s[v+1] = s[v];
        s[t] = 4 - q;
    }
}

-(int) permToIdx:(int[])s {
    int i=0, v, t;
    for(int q=0; 4>q; q++){
        for(v=t=0; 4>v&&!(s[v]==q); v++)
            if(s[v] > q) t++;
        i = i * (4-q) + t;
    }
    return i;
}

-(int) idxToComb:(int[])n s:(int[])s c:(int)c o:(int)o {
    int q=4;
    for(int t=0; 12>t; t++)
        if(c >= Cnk[11-t][q]) {
            c -= Cnk[11-t][q--];
            n[t] = s[q] << 1 | (o&1);
            o >>= 1;
        }
        else n[t] = -1;
    return o;
}

-(int) getmv:(int)c p:(int)p o:(int)o f:(int)f {
    int n[12], s[4];
    int q, t;
    [self idxToPerm:s p:p];
    q=4;
    for(t=0;12>t;t++)
        if(c>=Cnk[11-t][q]){
            c-=Cnk[11-t][q--];
            n[t]=s[q]<<1|(o&1);
            o>>=1;
        }
        else n[t]=-1;
    switch(f){
		case 0:
            [self circle:n f:0 h:1 l:2 n:3 s:0];
			break;
		case 1:
            [self circle:n f:11 h:10 l:9 n:8 s:0];
			break;
		case 2:
            [self circle:n f:1 h:4 l:9 n:5 s:0];
			break;
		case 3:
            [self circle:n f:3 h:6 l:11 n:7 s:0];
			break;
		case 4:
            [self circle:n f:0 h:7 l:8 n:4 s:1];
			break;
		case 5:
            [self circle:n f:2 h:5 l:10 n:6 s:1];
			break;
    }
    c=0;q=4;
    for(t=0;12>t;t++)
        if(0<=n[t]){
            c+=Cnk[11-t][q--];
            s[q]=n[t]>>1;
			o|=(n[t]&1)<<(3-q);
        }
    int i=[self permToIdx:s];
    return (24*c+i)<<4|o;
}

-(void) initc {
    int i,j,D,y,C;
    [Im initCnk];
    for(i=0;495>i;i++)
        for(j=0;24>j;j++){
            for(int s=0;6>s;s++){
                D=[self getmv:i p:j o:j f:s];
                pmv[24*i+j][s]=(short) (D>>4);
                if(16>j)fmv[16*i+j][s]=(short) (((D>>4)/24)<<4|(D&15));
            }
        }
    for(i=0;11880>i;i++)permPrun[i]=-1;
    permPrun[0]=0;//i=1;
    for(j=0;5>=j;j++)
        for(D=0;11880>D;D++)
            if(permPrun[D]==j)
                for(int s=0;6>s;s++)
                    for(y=D,C=0;3>C;C++){
                        y=pmv[y][s];
                        if(-1==permPrun[y]){
                            permPrun[y]=j+1;
                            //i++;
                        }
                    }
    for(i=0;7920>i;i++)flipPrun[i]=-1;
    flipPrun[0]=0;//i=1;
    for(j=0;6>=j;j++)
        for(D=0;7920>D;D++)
            if(flipPrun[D]==j)
                for(int s=0;6>s;s++){
                    y=D;
                    for(C=0;3>C;C++){
                        y=fmv[y][s];
                        if(-1==flipPrun[y])flipPrun[y]=j+1;
                        //i++;
                    }
                }
    int p[][6] = {
        {1,0,3,0,0,4},{2,1,1,5,1,0},{3,2,2,1,6,2},{0,3,7,3,2,3},
        {4,7,0,4,4,5},{5,4,5,6,5,1},{6,5,6,2,7,6},{7,6,4,7,3,7}
    };
    int o[][6] = {
        {0,0,1,0,0,2},{0,0,0,2,0,1},{0,0,0,1,2,0},{0,0,2,0,1,0},
        {0,0,2,0,0,1},{0,0,0,1,0,2},{0,0,0,2,1,0},{0,0,1,0,2,0}
    };
    for(int i=0; i<8; i++)
        for(int j=0; j<3; j++)
            for(int k=0; k<6; k++)
                fcm[i*3+j][k] = p[i][k]*3+(o[i][k]+j)%3;
    int p2[][6] = {
        {0,0,7,0,0,8},{1,1,1,9,1,4},{2,2,2,5,10,2},{3,3,11,3,6,3},
        {5,4,4,4,4,0},{6,5,5,1,5,5},{7,6,6,6,2,6},{4,7,3,7,7,7},
        {8,11,8,8,8,1},{9,8,9,2,9,9},{10,9,10,10,3,10},{11,10,0,11,11,11}
    };
    int o2[][6] = {
        {0,0,0,0,0,1},{0,0,0,0,0,1},{0,0,0,0,1,0},{0,0,0,0,1,0},
        {0,0,0,0,0,1},{0,0,0,0,0,0},{0,0,0,0,1,0},{0,0,0,0,0,0},
        {0,0,0,0,0,1},{0,0,0,0,0,0},{0,0,0,0,1,0},{0,0,0,0,0,0}
    };
    for (int i = 0; i < 12; i++)
        for (int j = 0; j < 2; j++)
            for (int k = 0; k < 6; k++)
                fem[i * 2 + j][k] = p2[i][k]*2+(o2[i][k]^j);
    for(int idx=0; idx<4; idx++) {
        for(int i=0; i<576; i++)fecd[idx][i]=-1;
        fecd[idx][idx*51+12]=0;
        for(int d=0; d<6; d++)
            for(int i=0; i<576; i++)
                if(fecd[idx][i]==d)
                    for(int j=0; j<6; j++)
                        for(int y=i,k=0; k<3; k++){
                            y=24*fem[y/24][j]+fcm[y%24][j];
                            if(fecd[idx][y]==-1)
                                fecd[idx][y]=d+1;
                        }
    }
}

-(bool) idacross:(int)ep eo:(int)eo d:(int)d lf:(int)lf {
    if(0==d)return 0==ep && 0==eo;
    if(permPrun[ep]>d || flipPrun[eo]>d)return false;
    int y,s,D;
    for(int f=0; 6>f; f++)
        if(f!=lf){
            y=ep;s=eo;
            for(D=0;3>D;D++) {
                y=pmv[y][f];s=fmv[s][f];
                if([self idacross:y eo:s d:d-1 lf:f]){
                    [self.sol insertString:[NSString stringWithFormat:@" %@%@", [self.turn objectAtIndex:f], [self.suff objectAtIndex:D]] atIndex:0];
                    //sb.insert(0, " "+turn[face][C]+suff[D]);
                    return true;
                }
            }
        }
    return false;
}

-(bool) idaxcross:(int)ep eo:(int)eo co:(int)co feo:(int)feo idx:(int)idx d:(int)depth l:(int)l {
    if (depth == 0) return ep == 0 && eo == 0 && co == (idx+4)*3 && feo == goalFeo[idx];
    if (permPrun[ep] > depth || flipPrun[eo] > depth || fecd[idx][feo*24+co] > depth) return false;
    for (int i = 0; i < 6; i++)
        if (i != l) {
            int w = co, y = ep, s = eo, t = feo;
            for (int j = 0; j < 3; j++) {
                w = fcm[w][i]; t = fem[t][i];
                y = pmv[y][i]; s = fmv[s][i];
                if ([self idaxcross:y eo:s co:w feo:t idx:idx d:depth-1 l:i]) {
                    [self.sol insertString:[NSString stringWithFormat:@" %@%@", [self.turn objectAtIndex:i], [self.suff objectAtIndex:j]] atIndex:0];
                    //sb.insert(0, " " + turn[0][i] + suff[j]);
                    return true;
                }
            }
        }
    return false;
}

-(NSString *)solveCross:(NSString *)scr side:(int)sd {
    NSArray *s = [scr componentsSeparatedByString:@" "];
    int q,D,C;
    for(q=0,D=0,C=0;C<[s count];C++) {
        if(0!=[[s objectAtIndex:C] length]){
            char i = [[s objectAtIndex:C] characterAtIndex:0];
            int o = [DCTUtils indexOf:[moveIdx objectAtIndex:sd] c:i];
            q=fmv[q][o]; D=pmv[D][o];
            if(1<[[s objectAtIndex:C] length]) {
                i = [[s objectAtIndex:C] characterAtIndex:1];
                if(i == '2') {
                    q=fmv[q][o];D=pmv[D][o];
                } else {
                    q=fmv[fmv[q][o]][o];D=pmv[pmv[D][o]][o];
                }
            }
        }
    }
    self.sol = [NSMutableString string];
    for(C=0;9>C&&![self idacross:D eo:q d:C lf:-1];C++);
    //[colorCrs objectAtIndex:side]
    NSString *solveC = [NSString stringWithFormat:@"\n%@%@%@", [self.side objectAtIndex:sd], [rotIdx objectAtIndex:sd], self.sol];
    return solveC;
}

-(NSString *) solveXcross:(NSString *)scr side:(int)sd {
    NSArray *s = [scr componentsSeparatedByString:@" "];
    int q=0, D=0, C;
    int co[4], feo[4];
    for (int i = 0; i < 4; i++) {
        co[i] = (i+4)*3; feo[i] = goalFeo[i];
    }
    for(C=0; C<[s count]; C++) {
        if(0!=[[s objectAtIndex:C] length]){
            char i = [[s objectAtIndex:C] characterAtIndex:0];
            int o = [DCTUtils indexOf:[moveIdx objectAtIndex:sd] c:i];
            for (int i = 0; i < 4; i++) {
                co[i] = fcm[co[i]][o]; feo[i] = fem[feo[i]][o];
            }
            q=fmv[q][o]; D=pmv[D][o];
            if(1<[[s objectAtIndex:C] length]) {
                i = [[s objectAtIndex:C] characterAtIndex:1];
                if(i == '2') {
                    q=fmv[q][o];D=pmv[D][o];
                    for (int i = 0; i < 4; i++) {
                        co[i] = fcm[co[i]][o]; feo[i] = fem[feo[i]][o];
                    }
                } else {
                    q=fmv[fmv[q][o]][o];D=pmv[pmv[D][o]][o];
                    for (int i = 0; i < 4; i++) {
                        co[i] = fcm[fcm[co[i]][o]][o];feo[i] = fem[fem[feo[i]][o]][o];
                    }
                }
            }
        }
    }
    self.sol = [NSMutableString string];
    for(int d=0; ; d++) {
        for(int idx=0; idx<4; idx++)
            if([self idaxcross:D eo:q co:co[idx] feo:feo[idx] idx:idx d:d l:-1])
                return [NSString stringWithFormat:@"\n%@%@%@", [self.side objectAtIndex:sd], [rotIdx objectAtIndex:sd], self.sol];
    }
}

-(void) easyCross {
    int i;
    if(!inie) {
        int ed[23760];
        for(i=0; i<23760; i++) ed[i] = -1;
        [CoordCube setPruning:ed i:0 v:0];
        //int c=1;
        int done = 0;
        for(int d=0; d<3; d++) {
            for(i=0; i<190080; i++)
                if([CoordCube getPruning:ed i:i] == d)
                    for(int s=0; s<6; s++) {
                        int y = i;
                        for(int C=0; C<3; C++) {
                            int ori = y&15;
                            int p = pmv[y>>4][s];
                            int o = fmv[y/384<<4|ori][s];
                            y = p<<4|(o&15);
                            if([CoordCube getPruning:ed i:y] == 15) {
                                [CoordCube setPruning:ed i:y v:d+1];
                                edd[done++] = y;
                                //c++;
                            }
                        }
                    }
            //NSLog(@"%d %d", d+1, c);
        }
        inie = true;
    }
    i = edd[rand()%1568];
    int comb = i/384;
    int perm = (i>>4)%24;
    int ori = i&15;
    int c[12];
    int p[4];
    [self idxToPerm:p p:perm];
    [self idxToComb:c s:p c:comb o:ori];
    int idx[] = {7,6,5,4,10,9,8,11,3,2,1,0};
    for(i=0; i<12; i++) {
        if(c[i] == -1) arrc[0][idx[i]] = arrc[1][idx[i]] = -1;
        else {
            arrc[0][idx[i]] = c[i] >> 1;
            arrc[1][idx[i]] = c[i] & 1;
        }
    }
}

@end
