//
//  DCTScrambleView.m
//  DCTimer
//
//  Created by MeigenChou on 13-4-8.
//
//

#import "DCTScrambleView.h"
#import "Scrambler.h"
#import "Pyraminx.h"
#import "Megaminx.h"
#import "SQ1.h"
#import "Clock.h"
#import "Skewb.h"
#import "DCTUtils.h"
#define toRadians(a) ((a) * M_PI / 180.0)

@implementation DCTScrambleView

NSMutableArray *scrImg;
extern NSString *currentScr;
extern int viewType;
extern BOOL showScr;
float rotatx[5], rotaty[5];

- (id)initWithCoder:(NSCoder *)coder
{
    if(self = [super initWithCoder:coder]) {
        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    if(!showScr) return;
    int wid = [DCTUtils isPad] ? 320 : 200;
    int a, b, d, i, j;
    switch (viewType) {
        case 13: //pyram
        {
            scrImg = [Pyraminx imageString:currentScr];
            b = (wid*3/4-15)/6; a = b*2/sqrt(3); d = (wid-a*6-14)/2;
            NSArray *colpy = [[NSArray alloc] initWithObjects:[UIColor redColor], [UIColor colorWithRed:0 green:0.6 blue:0 alpha:1], [UIColor blueColor], [UIColor yellowColor], nil];
            float arx[3], ary[3];
            int layout[] = {
                1,2,1,2,1,0,2,0,1,2,1,2,1,
                0,1,2,1,0,2,1,2,0,1,2,1,0,
                0,0,1,0,2,1,2,1,2,0,1,0,0,
                0,0,0,0,0,0,0,0,0,0,0,0,0,
                0,0,0,0,1,2,1,2,1,0,0,0,0,
                0,0,0,0,0,1,2,1,0,0,0,0,0,
                0,0,0,0,0,0,1,0,0,0,0,0,0};
            int pos[] = {
                d,d+a/2,d+a,d+3*a/2,d+2*a,d+5*a/2,d+7+5*a/2,d+7+3*a,d+14+3*a,d+14+7*a/2,d+14+4*a,d+14+9*a/2,d+14+5*a,
                d+14+11*a/2,d+a/2,d+a,d+3*a/2,d+2*a,d+7+2*a,d+7+5*a/2,d+7+3*a,d+7+7*a/2,d+14+7*a/2,d+14+4*a,d+14+9*a/2,d+14+5*a,
                0,0,d+a,d+3*a/2,d+7+3*a/2,d+7+2*a,d+7+5*a/2,d+7+3*a,d+7+7*a/2,d+7+4*a,d+14+4*a,d+14+9*a/2,0,
                0,0,0,0,0,0,0,0,0,0,0,0,0,
                0,0,0,0,d+7+3*a/2,d+7+2*a,d+7+5*a/2,d+7+3*a,d+7+7*a/2,d+7+4*a,0,0,0,
                0,0,0,0,0,d+7+2*a,d+7+5*a/2,d+7+3*a,d+7+7*a/2,0,0,0,0,
                0,0,0,0,0,0,d+7+5*a/2,d+7+3*a,0,0,0,0,0};
            for(int y=0; y<7; y++)
                for(int x=0; x<13; x++) {
                    if(layout[y*13+x] == 1) {
                        if(y<3) {
                            arx[0]=pos[y*13+x]; arx[1]=pos[y*13+x]+a; arx[2]=pos[y*13+x+1];
                            ary[0]=ary[1]=y*b+3; ary[2]=(y+1)*b+3;
                            [self drawPolygon:context cl:[colpy objectAtIndex:[[scrImg objectAtIndex:y*13+x] intValue]] x:arx y:ary len:3 stoke:true];
                        } else if(y>3) {
                            arx[0]=pos[y*13+x]; arx[1]=pos[y*13+x]+a; arx[2]=pos[y*13+x+1];
                            ary[0]=ary[1]=(y-1)*b+9; ary[2]=y*b+9;
                            [self drawPolygon:context cl:[colpy objectAtIndex:[[scrImg objectAtIndex:y*13+x] intValue]] x:arx y:ary len:3 stoke:true];
                        }
                    }
                    else if(layout[y*13+x] == 2) {
                        if(y<3) {
                            arx[0]=pos[y*13+x]; arx[1]=pos[y*13+x]+a; arx[2]=pos[y*13+x+1];
                            ary[0]=ary[1]=(y+1)*b+3; ary[2]=y*b+3;
                            [self drawPolygon:context cl:[colpy objectAtIndex:[[scrImg objectAtIndex:y*13+x] intValue]] x:arx y:ary len:3 stoke:true];
                        } else if(y>3) {
                            arx[0]=pos[y*13+x]; arx[1]=pos[y*13+x]+a; arx[2]=pos[y*13+x+1];
                            ary[0]=ary[1]=y*b+9; ary[2]=(y-1)*b+9;
                            [self drawPolygon:context cl:[colpy objectAtIndex:[[scrImg objectAtIndex:y*13+x] intValue]] x:arx y:ary len:3 stoke:true];
                        }
                    }
                }
            break;
        }
        case 14: //Minx
        {
            float edgeFrac = (1+sqrt(5))/4;
            float centerFrac = 0.5;
            NSArray *colmx = [[NSArray alloc] initWithObjects:[UIColor whiteColor], [UIColor redColor],[UIColor colorWithRed:0 green:0.62 blue:0 alpha:1], [UIColor colorWithRed:0.48 green:0 blue:0.48 alpha:1], [UIColor yellowColor], [UIColor blueColor], [UIColor colorWithRed:1 green:1 blue:0.52 alpha:1], [UIColor colorWithRed:0.26 green:0.86 blue:1 alpha:1], [UIColor colorWithRed:1 green:0.5 blue:0.15 alpha:1], [UIColor greenColor], [UIColor colorWithRed:1 green:0.5 blue:1 alpha:1], [UIColor grayColor], nil];
            float scale = wid / 350.;
            int dx = (wid - 350 * scale) / 2;
			int dy = (wid * 0.75 - 180 * scale) / 2;
            float majorR = 36 * scale;
			float minorR = majorR * edgeFrac;
			float pentR = minorR * 2;
			float cx1 = 92 * scale + dx;
			float cy1 = 80 * scale + dy;
			float cx2 = cx1 + [self c18:1]*3*pentR;
			float cy2 = cy1 + [self s18:1]*1*pentR;
            int trans[][5] = {
                {0, cx1, cy1, 0, 0},
                {36, cx1, cy1, 1, 1},
                {36+72*1, cx1, cy1, 1, 5},
                {36+72*2, cx1, cy1, 1, 9},
                {36+72*3, cx1, cy1, 1, 13},
                {36+72*4, cx1, cy1, 1, 17},
                {0, cx2, cy2, 1, 7},
                {-72*1, cx2, cy2, 1, 3},
                {-72*2, cx2, cy2, 1, 19},
                {-72*3, cx2, cy2, 1, 15},
                {-72*4, cx2, cy2, 1, 11},
                {36+72*2, cx2, cy2, 0, 0}
			};
            int d=0;
            float d2x = majorR*(1-centerFrac)/2/tan(M_PI/5);
            float aryx[5], aryy[5];
            scrImg = [Megaminx image];
            for(int side=0;side<12;side++) {
                float a = trans[side][1]+trans[side][3]*[self c18:trans[side][4]]*pentR;
				float b = trans[side][2]+trans[side][3]*[self s18:trans[side][4]]*pentR;
                for(int i=0;i<5;i++) {
                    aryx[0] = aryx[2] = 0; aryx[1] = d2x; aryx[3] = -d2x;
                    aryy[0] = -majorR; aryy[1] = aryy[3] = -majorR*(1+centerFrac)/2; aryy[2] = -majorR*centerFrac;
                    [self change:a b:b x:aryx y:aryy i:(72*i+trans[side][0]) l:4];
                    [self drawPolygon:context cl:[colmx objectAtIndex:[[scrImg objectAtIndex:d++] intValue]] x:rotatx y:rotaty len:4 stoke:true];
                }
                for(int i=0;i<5;i++) {
                    aryx[0] = [self c18:-1]*majorR-d2x; aryx[1] = d2x; aryx[2] = 0; aryx[3] = [self s18:4]*centerFrac*majorR;
                    aryy[0] = [self s18:-1]*majorR-majorR+majorR*(1+centerFrac)/2; aryy[1] = -majorR*(1+centerFrac)/2; aryy[2] = -majorR*centerFrac; aryy[3] = -[self c18:4]*centerFrac*majorR;
                    [self change:a b:b x:aryx y:aryy i:(72*i+trans[side][0]) l:4];
                    [self drawPolygon:context cl:[colmx objectAtIndex:[[scrImg objectAtIndex:d++] intValue]] x:rotatx y:rotaty len:4 stoke:true];
                }
                for(int i=0; i<5; i++) {
                    aryx[i] = [self s18:(i*4)]*centerFrac*majorR;
                    aryy[i] = -[self c18:(i*4)]*centerFrac*majorR;
                }
                [self change:a b:b x:aryx y:aryy i:trans[side][0] l:5];
                [self drawPolygon:context cl:[colmx objectAtIndex:[[scrImg objectAtIndex:d++] intValue]] x:rotatx y:rotaty len:5 stoke:true];
            }
            break;
        }
        case 10:    //SQ1
        {
            NSArray *tb = [[NSArray alloc]initWithObjects:@"3", @"3", @"3", @"3", @"3", @"3", @"3", @"3", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", nil];
            NSArray *ty = [[NSArray alloc]initWithObjects:@"c", @"e", @"c", @"e", @"c", @"e", @"c", @"e", @"e", @"c", @"e", @"c", @"e", @"c", @"e", @"c", nil];
            NSArray *col = [[NSArray alloc]initWithObjects:@"51", @"1", @"12", @"2", @"24", @"4", @"45", @"5", @"5", @"54", @"4", @"42", @"2", @"21", @"1", @"15", nil];
            NSArray *colsq = [[NSArray alloc]initWithObjects:[UIColor yellowColor], [UIColor orangeColor], [UIColor blueColor], [UIColor whiteColor], [UIColor redColor], [UIColor colorWithRed:0 green:0.6 blue:0 alpha:1], nil];
            scrImg = [SQ1 imagestr:currentScr];
            char temp[12];
            for(int i=0; i<12; i++) temp[i] = [[scrImg objectAtIndex:i] charValue];
            NSMutableArray *top_size = [self rd:temp l:12];
            for(int i=0; i<6; i++) {
                temp[i] = [[scrImg objectAtIndex:i+18] charValue];
                temp[i+6] = [[scrImg objectAtIndex:i+12] charValue];
            }
            NSMutableArray *bot_size = [self rd:temp l:12];
            NSMutableArray *eido = [[NSMutableArray alloc] init];
            for(int i=0; i<[top_size count]; i++) [eido addObject:[top_size objectAtIndex:i]];
            for(int i=0; i<[bot_size count]; i++) [eido addObject:[bot_size objectAtIndex:i]];
            NSMutableString *a2 = [NSMutableString string], *b2 = [NSMutableString string], *c2 = [NSMutableString string];
            for(int j=0; j<16; j++) {
                [a2 appendString:[ty objectAtIndex:[[eido objectAtIndex:j] intValue]]];
                [b2 appendString:[tb objectAtIndex:[[eido objectAtIndex:j] intValue]]];
                [c2 appendString:[col objectAtIndex:[[eido objectAtIndex:j] intValue]]];
            }
            NSString *stickers = [NSString stringWithFormat:@"%@%@", b2, c2];
            float z = 1.366;
            float arrx[6], arry[6];
            float sidewid = 10.98;
            int cx = 55, cy = 50;
            float rd = (cx - 16) / z;
            float w = (sidewid + rd) / rd;
            float ag[24];
            float ag2[24];
            int foo;
            for(foo=0; foo<24; foo++) {
                ag[foo] = (17.0 - foo*2) * M_PI / 12;
                [a2 appendString:@"xxxxxxxxxxxxxxxx"];
            }
            for(foo=0; foo<24; foo++) {
                ag2[foo] = (19.0 - foo*2) * M_PI / 12;
                [a2 appendString:@"xxxxxxxxxxxxxxxx"];
            }
            float h = [self sin1:1 ag:ag rd:rd]*w*z - [self sin1:1 ag:ag rd:rd]*z;
            BOOL sqMi = [[scrImg objectAtIndex:24] boolValue];
            if(sqMi) {
                for(int i=0; i<4; i++) {
                    arrx[i] = cx+[self cos1:1+i*3 ag:ag rd:rd]*w*z;
                    arry[i] = cy-[self sin1:1+i*3 ag:ag rd:rd]*w*z;
                }
                [self drawPolygon:context cl:[UIColor blackColor] w:wid x:arrx y:arry len:4 stoke:true];
                cy += 10;
                for(int i=0; i<2; i++) {
                    arrx[i] = cx+[self cos1:0 ag:ag rd:rd]*w;
                    arrx[i+2] = cx+[self cos1:1 ag:ag rd:rd]*w*z;
                    arry[i*3] = cy-[self sin1:1 ag:ag rd:rd]*w*z;
                    arry[i+1] = cy-[self sin1:1 ag:ag rd:rd]*z;
                }
                [self drawPolygon:context cl:[colsq objectAtIndex:5] w:wid x:arrx y:arry len:4 stoke:true];
                for(int i=0; i<2; i++) {
                    arrx[i] = cx+[self cos1:0 ag:ag rd:rd]*w;
                    arrx[i+2] = cx+[self cos1:10 ag:ag rd:rd]*w*z;
                    arry[i*3] = cy-[self sin1:1 ag:ag rd:rd]*w*z;
                    arry[i+1] = cy-[self sin1:1 ag:ag rd:rd]*z;
                }
                [self drawPolygon:context cl:[colsq objectAtIndex:5] w:wid x:arrx y:arry len:4 stoke:true];
                cy -= 10;
            } else {
                int tempx[] = {1, 4, 6, 9, 11, 0};
                float tempy[] = {z, z, 1, z, z, 1};
                for(int i=0; i<6; i++) {
                    arrx[i] = cx+[self cos1:tempx[i] ag:ag rd:rd]*w*tempy[i];
                    arry[i] = cy-[self sin1:tempx[i] ag:ag rd:rd]*w*tempy[i];
                }
                arry[3] = cy+[self sin1:9 ag:ag rd:rd]*w*z;
                [self drawPolygon:context cl:[UIColor blackColor] w:wid x:arrx y:arry len:6 stoke:true];
                for(int i=0; i<2; i++) {
                    arrx[i*3] = cx+[self cos1:9 ag:ag rd:rd]*w*z;
                    arrx[i+1] = cx+[self cos1:11 ag:ag rd:rd]*w*z;
                    arry[i*3] = cy+[self sin1:9 ag:ag rd:rd]*w*z-(1-i)*h;
                    arry[i+1] = cy-[self sin1:11 ag:ag rd:rd]*w*z-(1-i)*h;
                }
                [self drawPolygon:context cl:[colsq objectAtIndex:4] w:wid x:arrx y:arry len:4 stoke:true];
                cy+=10;
                for(int i=0; i<2; i++) {
                    arrx[i] = cx+[self cos1:0 ag:ag rd:rd]*w;
                    arrx[i+2] = cx+[self cos1:1 ag:ag rd:rd]*w*z;
                    arry[i*3] = cy-[self sin1:1 ag:ag rd:rd]*w*z;
                    arry[i+1] = cy-[self sin1:1 ag:ag rd:rd]*z;
                }
                [self drawPolygon:context cl:[colsq objectAtIndex:5] w:wid x:arrx y:arry len:4 stoke:true];
                for (int i=0; i<2; i++) {
                    arrx[i] = cx+[self cos1:0 ag:ag rd:rd]*w;
                    arrx[i+2] = cx+[self cos1:11 ag:ag rd:rd]*w*z;
                    arry[i] = cy-[self sin1:1 ag:ag rd:rd]*z*(i==0 ? w : 1);
                    arry[i+2] = cy-[self sin1:11 ag:ag rd:rd]*w*z+(1-i)*h;
                }
                [self drawPolygon:context cl:[colsq objectAtIndex:2] w:wid x:arrx y:arry len:4 stoke:true];
                cy-=10;
            }
            int sc = 0;
            for(foo=0; sc<12; foo++) {
                if(a2.length <= foo) sc = 12;
                if([a2 characterAtIndex:foo] == 'x') sc++;
                if([a2 characterAtIndex:foo] == 'c') {
                    arrx[0] = cx; arry[0] = cy;
                    for(int i=0; i<3; i++) {
                        arrx[i+1] = cx+[self cos1:sc+i ag:ag rd:rd]*(i==1 ? z : 1);
                        arry[i+1] = cy-[self sin1:sc+i ag:ag rd:rd]*(i==1 ? z : 1);
                    }
                    [self drawPolygon:context cl:[colsq objectAtIndex:(int)[stickers characterAtIndex:foo]-48] w:wid x:arrx y:arry len:4 stoke:true];
                    for (int i=0; i<2; i++) {
                        arrx[i*3] = cx+[self cos1:sc ag:ag rd:rd]*(i==0 ? 1 : w);
                        arrx[i+1] = cx+[self cos1:sc+1 ag:ag rd:rd]*z*(i==0 ? 1 : w);
                        arry[i*3] = cy-[self sin1:sc ag:ag rd:rd]*(i==0 ? 1 : w);
                        arry[i+1] = cy-[self sin1:sc+1 ag:ag rd:rd]*z*(i==0 ? 1 : w);
                    }
                    [self drawPolygon:context cl:[colsq objectAtIndex:(int)[stickers characterAtIndex:16+sc]-48] w:wid x:arrx y:arry len:4 stoke:true];
                    for (int i=0; i<2; i++) {
                        arrx[i*3] = cx+[self cos1:sc+2 ag:ag rd:rd]*(i==0 ? 1 : w);
                        arrx[i+1] = cx+[self cos1:sc+1 ag:ag rd:rd]*z*(i==0 ? 1 : w);
                        arry[i*3] = cy-[self sin1:sc+2 ag:ag rd:rd]*(i==0 ? 1 : w);
                        arry[i+1] = cy-[self sin1:sc+1 ag:ag rd:rd]*z*(i==0 ? 1 : w);
                    }
                    [self drawPolygon:context cl:[colsq objectAtIndex:(int)[stickers characterAtIndex:17+sc]-48] w:wid x:arrx y:arry len:4 stoke:true];
                    sc+=2;
                }
                if([a2 characterAtIndex:foo] == 'e') {
                    arrx[0] = cx; arry[0] = cy;
                    for(int i=0; i<2; i++) {
                        arrx[i+1] = cx+[self cos1:sc+i ag:ag rd:rd];
                        arry[i+1] = cy-[self sin1:sc+i ag:ag rd:rd];
                    }
                    [self drawPolygon:context cl:[colsq objectAtIndex:(int)[stickers characterAtIndex:foo]-48] w:wid x:arrx y:arry len:3 stoke:true];
                    for(int i=0; i<2; i++) {
                        arrx[i*3] = cx+[self cos1:sc ag:ag rd:rd]*(i==0 ? 1 : w);
                        arrx[i+1] = cx+[self cos1:sc+1 ag:ag rd:rd]*(i==0 ? 1 : w);
                        arry[i*3] = cy-[self sin1:sc ag:ag rd:rd]*(i==0 ? 1 : w);
                        arry[i+1] = cy-[self sin1:sc+1 ag:ag rd:rd]*(i==0 ? 1 : w);
                    }
                    [self drawPolygon:context cl:[colsq objectAtIndex:(int)[stickers characterAtIndex:16+sc]-48] w:wid x:arrx y:arry len:4 stoke:true];
                    sc++;
                }
            }
            cx *= 3;
			cy += 10;
            if(sqMi) {
                for(int i=0; i<4; i++) {
                    arrx[i] = cx+[self cos1:1+i*3 ag:ag rd:rd]*w*z;
                    arry[i] = cy-[self sin1:1+i*3 ag:ag rd:rd]*w*z;
                }
                [self drawPolygon:context cl:[UIColor blackColor] w:wid x:arrx y:arry len:4 stoke:true];
                cy -= 10;
                for(int i=0; i<2; i++) {
                    arrx[i] = cx+[self cos1:0 ag:ag rd:rd]*w;
                    arrx[i+2] = cx+[self cos1:1 ag:ag rd:rd]*w*z;
                    arry[i*3] = cy+[self sin1:1 ag:ag rd:rd]*w*z;
                    arry[i+1] = cy+[self sin1:1 ag:ag rd:rd]*z;
                }
                [self drawPolygon:context cl:[colsq objectAtIndex:5] w:wid x:arrx y:arry len:4 stoke:true];
                for(int i=0; i<2; i++) {
                    arrx[i] = cx+[self cos1:0 ag:ag rd:rd]*w;
                    arrx[i+2] = cx+[self cos1:10 ag:ag rd:rd]*w*z;
                    arry[i*3] = cy+[self sin1:1 ag:ag rd:rd]*w*z;
                    arry[i+1] = cy+[self sin1:1 ag:ag rd:rd]*z;
                }
                [self drawPolygon:context cl:[colsq objectAtIndex:5] w:wid x:arrx y:arry len:4 stoke:true];
                cy += 10;
            } else {
                int tempx[] = {1, 4, 6, 9, 11, 0};
                float tempy[] = {z, z, 1, z, z, 1};
                for(int i=0; i<6; i++) {
                    arrx[i] = cx+[self cos1:tempx[i] ag:ag rd:rd]*w*tempy[i];
                    arry[i] = cy+[self sin1:tempx[i] ag:ag rd:rd]*w*tempy[i];
                }
                arry[3] = cy-[self sin1:9 ag:ag rd:rd]*w*z;
                [self drawPolygon:context cl:[UIColor blackColor] w:wid x:arrx y:arry len:6 stoke:true];
                for(int i=0; i<2; i++) {
                    arrx[i*3] = cx+[self cos1:9 ag:ag rd:rd]*w*z;
                    arrx[i+1] = cx+[self cos1:11 ag:ag rd:rd]*w*z;
                    arry[i*3] = cy-[self sin1:9 ag:ag rd:rd]*w*z-(1-i)*10;
                    arry[i+1] = cy+[self sin1:11 ag:ag rd:rd]*w*z-(1-i)*10;
                }
                [self drawPolygon:context cl:[colsq objectAtIndex:4] w:wid x:arrx y:arry len:4 stoke:true];
                cy-=10;
                for(int i=0; i<2; i++) {
                    arrx[i] = cx+[self cos1:0 ag:ag rd:rd]*w;
                    arrx[i+2] = cx+[self cos1:1 ag:ag rd:rd]*w*z;
                    arry[i*3] = cy+[self sin1:1 ag:ag rd:rd]*w*z;
                    arry[i+1] = cy+[self sin1:1 ag:ag rd:rd]*z;
                }
                [self drawPolygon:context cl:[colsq objectAtIndex:5] w:wid x:arrx y:arry len:4 stoke:true];
                for (int i=0; i<2; i++) {
                    arrx[i] = cx+[self cos1:0 ag:ag rd:rd]*w;
                    arrx[i+2] = cx+[self cos1:11 ag:ag rd:rd]*w*z;
                    arry[i] = cy+[self sin1:1 ag:ag rd:rd]*z*(i==0 ? w : 1);
                    arry[i+2] = cy+[self sin1:11 ag:ag rd:rd]*w*z+(1-i)*10;
                }
                [self drawPolygon:context cl:[colsq objectAtIndex:2] w:wid x:arrx y:arry len:4 stoke:true];
                cy+=10;
            }
            for(sc=0; sc<12; foo++) {
                if(a2.length <= foo) sc = 12;
                if([a2 characterAtIndex:foo] == 'x') sc++;
                if([a2 characterAtIndex:foo] == 'c') {
                    arrx[0] = cx; arry[0] = cy;
                    for(int i=0; i<3; i++) {
                        arrx[i+1] = cx+[self cos1:sc+i ag:ag2 rd:rd]*(i==1 ? z : 1);
                        arry[i+1] = cy-[self sin1:sc+i ag:ag2 rd:rd]*(i==1 ? z : 1);
                    }
                    [self drawPolygon:context cl:[colsq objectAtIndex:(int)[stickers characterAtIndex:foo]-48] w:wid x:arrx y:arry len:4 stoke:true];
                    for (int i=0; i<2; i++) {
                        arrx[i*3] = cx+[self cos1:sc ag:ag2 rd:rd]*(i==0 ? 1 : w);
                        arrx[i+1] = cx+[self cos1:sc+1 ag:ag2 rd:rd]*z*(i==0 ? 1 : w);
                        arry[i*3] = cy-[self sin1:sc ag:ag2 rd:rd]*(i==0 ? 1 : w);
                        arry[i+1] = cy-[self sin1:sc+1 ag:ag2 rd:rd]*z*(i==0 ? 1 : w);
                    }
                    [self drawPolygon:context cl:[colsq objectAtIndex:(int)[stickers characterAtIndex:28+sc]-48] w:wid x:arrx y:arry len:4 stoke:true];
                    for (int i=0; i<2; i++) {
                        arrx[i*3] = cx+[self cos1:sc+2 ag:ag2 rd:rd]*(i==0 ? 1 : w);
                        arrx[i+1] = cx+[self cos1:sc+1 ag:ag2 rd:rd]*z*(i==0 ? 1 : w);
                        arry[i*3] = cy-[self sin1:sc+2 ag:ag2 rd:rd]*(i==0 ? 1 : w);
                        arry[i+1] = cy-[self sin1:sc+1 ag:ag2 rd:rd]*z*(i==0 ? 1 : w);
                    }
                    [self drawPolygon:context cl:[colsq objectAtIndex:(int)[stickers characterAtIndex:29+sc]-48] w:wid x:arrx y:arry len:4 stoke:true];
                    sc+=2;
                }
                if([a2 characterAtIndex:foo] == 'e') {
                    arrx[0] = cx; arry[0] = cy;
                    for(int i=0; i<2; i++) {
                        arrx[i+1] = cx+[self cos1:sc+i ag:ag2 rd:rd];
                        arry[i+1] = cy-[self sin1:sc+i ag:ag2 rd:rd];
                    }
                    [self drawPolygon:context cl:[colsq objectAtIndex:(int)[stickers characterAtIndex:foo]-48] w:wid x:arrx y:arry len:3 stoke:true];
                    for(int i=0; i<2; i++) {
                        arrx[i*3] = cx+[self cos1:sc ag:ag2 rd:rd]*(i==0 ? 1 : w);
                        arrx[i+1] = cx+[self cos1:sc+1 ag:ag2 rd:rd]*(i==0 ? 1 : w);
                        arry[i*3] = cy-[self sin1:sc ag:ag2 rd:rd]*(i==0 ? 1 : w);
                        arry[i+1] = cy-[self sin1:sc+1 ag:ag2 rd:rd]*(i==0 ? 1 : w);
                    }
                    [self drawPolygon:context cl:[colsq objectAtIndex:(int)[stickers characterAtIndex:28+sc]-48] w:wid x:arrx y:arry len:4 stoke:true];
                    sc++;
                }
            }
            break;
        }
        case 11:    //clock
        {
            scrImg = [Clock image];
            int face_dist = 30;
			int cx = 55;
			int cy = 55;
            CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:0.16 green:0.16 blue:0.16 alpha:1] CGColor]);
            [self drawSideBackground:context w:wid x:cx y:cy r:53 fd:29 fr:19];
            CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:0.2 green:0.4 blue:1 alpha:1] CGColor]);
            [self drawSideBackground:context w:wid x:cx y:cy r:52 fd:29 fr:18];
            int i=0;
            for(int y=cy-face_dist; y<=cy+face_dist; y+=face_dist)
				for(int x=cx-face_dist; x<=cx+face_dist; x+=face_dist)
                    [self drawClockFace:context w:wid x:x y:y c:[UIColor colorWithRed:0.53 green:0.66 blue:1 alpha:1] h:[[scrImg objectAtIndex:i++] intValue]];
            NSMutableArray *pegs = [Clock pegs];
            [self drawPeg:context w:wid x:cx-face_dist/2 y:cy-face_dist/2 v:1-[[pegs objectAtIndex:0] intValue]];
            [self drawPeg:context w:wid x:cx+face_dist/2 y:cy-face_dist/2 v:1-[[pegs objectAtIndex:1] intValue]];
            [self drawPeg:context w:wid x:cx-face_dist/2 y:cy+face_dist/2 v:1-[[pegs objectAtIndex:2] intValue]];
            [self drawPeg:context w:wid x:cx+face_dist/2 y:cy+face_dist/2 v:1-[[pegs objectAtIndex:3] intValue]];
            cx = 165;
            CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:0.16 green:0.16 blue:0.16 alpha:1] CGColor]);
            [self drawSideBackground:context w:wid x:cx y:cy r:53 fd:29 fr:19];
            CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:0.53 green:0.66 blue:1 alpha:1] CGColor]);
            [self drawSideBackground:context w:wid x:cx y:cy r:52 fd:29 fr:18];
            for(int y=cy-face_dist; y<=cy+face_dist; y+=face_dist)
				for(int x=cx-face_dist; x<=cx+face_dist; x+=face_dist)
                    [self drawClockFace:context w:wid x:x y:y c:[UIColor colorWithRed:0.2 green:0.4 blue:1 alpha:1] h:[[scrImg objectAtIndex:i++] intValue]];
            [self drawPeg:context w:wid x:cx+face_dist/2 y:cy-face_dist/2 v:[[pegs objectAtIndex:0] intValue]];
            [self drawPeg:context w:wid x:cx-face_dist/2 y:cy-face_dist/2 v:[[pegs objectAtIndex:1] intValue]];
            [self drawPeg:context w:wid x:cx+face_dist/2 y:cy+face_dist/2 v:[[pegs objectAtIndex:2] intValue]];
            [self drawPeg:context w:wid x:cx-face_dist/2 y:cy+face_dist/2 v:[[pegs objectAtIndex:3] intValue]];
            break;
        }
        case 12:    //skewb
        {
            scrImg = [Skewb image:currentScr];
            NSArray *colsk = [[NSArray alloc] initWithObjects:[UIColor whiteColor], [UIColor orangeColor], [UIColor colorWithRed:0 green:0.6 blue:0 alpha:1], [UIColor redColor], [UIColor blueColor], [UIColor yellowColor], nil];
            int b = wid / 4, a = (b/2 * sqrt(3));
            int stx = (wid - 4*a)/2, sty = (wid*0.75-3*b)/2, i, d = 0;
            float e = 3 / sqrt(3), f = 3 * sqrt(3);
            float dx[24] = {a*2, a*3-6, a+6, a*2, 3, a-3, 3, a-3, a+3, a*2-3, a+3, a*2-3,
                a*2+3, a*3-3, a*2+3, a*3-3, a*3+3, a*4-3, a*3+3, a*4-3, a+3, a*2-3, a+3, a*2-3};
            float dy[24] = {e*2, b/2, b/2, b-e*2, f, b/2+e, b-e, b*3/2-f, b/2+f, b+e, b*3/2-e, b*2-f,
                b+e, b/2+f, b*2-f, b*3/2-e, b/2+e, f, b*3/2-f, b-e, b*3/2+f, b*2+e, b*5/2-e, b*3-f};
            for(i=0; i<6; i++) {
                float x1[] = {stx+dx[i*4], stx+(dx[i*4]+dx[i*4+1])/2, stx+(dx[i*4]+dx[i*4+2])/2}, y1[] = {sty+dy[i*4], sty+(dy[i*4]+dy[i*4+1])/2, sty+(dy[i*4]+dy[i*4+2])/2};
                [self drawPolygon:context cl:[colsk objectAtIndex:[[scrImg objectAtIndex:d++] intValue]] x:x1 y:y1 len:3 stoke:true];
                float x2[] = {stx+dx[i*4+1], stx+(dx[i*4]+dx[i*4+1])/2, stx+(dx[i*4+1]+dx[i*4+3])/2}, y2[] = {sty+dy[i*4+1], sty+(dy[i*4]+dy[i*4+1])/2, sty+(dy[i*4+1]+dy[i*4+3])/2};
                [self drawPolygon:context cl:[colsk objectAtIndex:[[scrImg objectAtIndex:d++] intValue]] x:x2 y:y2 len:3 stoke:true];
                float x3[] = {stx+(dx[i*4]+dx[i*4+2])/2, stx+(dx[i*4]+dx[i*4+1])/2, stx+(dx[i*4+1]+dx[i*4+3])/2, stx+(dx[i*4+2]+dx[i*4+3])/2}, y3[] = {sty+(dy[i*4]+dy[i*4+2])/2, sty+(dy[i*4]+dy[i*4+1])/2, sty+(dy[i*4+1]+dy[i*4+3])/2, sty+(dy[i*4+2]+dy[i*4+3])/2};
                [self drawPolygon:context cl:[colsk objectAtIndex:[[scrImg objectAtIndex:d++] intValue]] x:x3 y:y3 len:4 stoke:true];
                float x4[] = {stx+dx[i*4+2], stx+(dx[i*4]+dx[i*4+2])/2, stx+(dx[i*4+2]+dx[i*4+3])/2}, y4[] = {sty+dy[i*4+2], sty+(dy[i*4]+dy[i*4+2])/2, sty+(dy[i*4+2]+dy[i*4+3])/2};
                [self drawPolygon:context cl:[colsk objectAtIndex:[[scrImg objectAtIndex:d++] intValue]] x:x4 y:y4 len:3 stoke:true];
                float x5[] = {stx+dx[i*4+3], stx+(dx[i*4+3]+dx[i*4+2])/2, stx+(dx[i*4+1]+dx[i*4+3])/2}, y5[] = {sty+dy[i*4+3], sty+(dy[i*4+3]+dy[i*4+2])/2, sty+(dy[i*4+1]+dy[i*4+3])/2};
                [self drawPolygon:context cl:[colsk objectAtIndex:[[scrImg objectAtIndex:d++] intValue]] x:x5 y:y5 len:3 stoke:true];
            }
            break;
        }
        default:
            scrImg = [Scrambler imageString:viewType scr:currentScr];
            NSArray *colsn = [[NSArray alloc] initWithObjects:[UIColor yellowColor], [UIColor blueColor], [UIColor redColor], [UIColor whiteColor], [UIColor colorWithRed:0 green:0.6 blue:0 alpha:1], [UIColor orangeColor], nil];
            float ia = (wid - 19) / (viewType * 4.0);
            d=0; b=viewType;
            for(i=0; i<b; i++)
                for(j=0; j<b; j++) {
                    int c = [[scrImg objectAtIndex:d++] intValue];
                    CGContextSetFillColorWithColor(context, [[colsn objectAtIndex:c] CGColor]);
                    CGRect curntRect = CGRectMake(7+(j+b)*ia, 1+i*ia, ia, ia);
                    CGContextAddRect(context, curntRect);
                    CGContextDrawPath(context, kCGPathFillStroke);
                }
            for(i=0; i<b; i++)
                for(j=0; j<b*4; j++) {
                    int c = [[scrImg objectAtIndex:d++] intValue];
                    CGContextSetFillColorWithColor(context, [[colsn objectAtIndex:c] CGColor]);
                    CGRect curntRect;
                    if(j>=b*3) curntRect = CGRectMake(19+j*ia, 7+(i+b)*ia, ia, ia);
                    else if(j>=b*2) curntRect = CGRectMake(13+j*ia, 7+(i+b)*ia, ia, ia);
                    else if(j>=b) curntRect = CGRectMake(7+j*ia, 7+(i+b)*ia, ia, ia);
                    else curntRect = CGRectMake(1+j*ia, 7+(i+b)*ia, ia, ia);
                    CGContextAddRect(context, curntRect);
                    CGContextDrawPath(context, kCGPathFillStroke);
                }
            for(i=0; i<b; i++)
                for(j=0; j<b; j++) {
                    int c = [[scrImg objectAtIndex:d++] intValue];
                    CGContextSetFillColorWithColor(context, [[colsn objectAtIndex:c] CGColor]);
                    CGRect curntRect = CGRectMake(7+(j+b)*ia, 13+(i+2*b)*ia, ia, ia);
                    CGContextAddRect(context, curntRect);
                    CGContextDrawPath(context, kCGPathFillStroke);
                }
            break;
    }
        
    //CGContextSetFillColorWithColor(context, curntColor.CGColor);
    //CGRect curntRect = CGRectMake(50, 50, 150, 150);
    //CGContextAddRect(context, curntRect);
    //CGContextDrawPath(context, kCGPathFillStroke);
}

- (void)drawPolygon:(CGContextRef)context cl:(UIColor *)cl x:(float[])x y:(float[])y len:(int)len stoke:(bool)stoke {
    CGContextSetFillColorWithColor(context, cl.CGColor);
    CGContextMoveToPoint(context, x[0], y[0]);
    for(int i=1; i<len; i++) {
        CGContextAddLineToPoint(context, x[i], y[i]);
    }
    CGContextClosePath(context);
    if(stoke) CGContextDrawPath(context, kCGPathFillStroke);
    else CGContextDrawPath(context, kCGPathFill);
}

- (NSArray *)scalePoint:(int)width x:(float)cx y:(float)cy {
    float scale = width / 220.0;
    float x = cx*scale + (width-(220*scale))/2;
    float y = cy*scale + (width*3/4 - (110*scale))/2;
    return [[NSArray alloc] initWithObjects:@(x), @(y), @(scale), nil];
}

- (void)drawPolygon:(CGContextRef)context cl:(UIColor *)cl w:(int)w x:(float[])x y:(float[])y len:(int)len stoke:(bool)stoke {
    CGContextSetFillColorWithColor(context, cl.CGColor);
    NSArray *d = [self scalePoint:w x:x[0] y:y[0]];
    CGContextMoveToPoint(context, [[d objectAtIndex:0] floatValue], [[d objectAtIndex:1] floatValue]);
    for (int i=1; i<len; i++) {
        d = [self scalePoint:w x:x[i] y:y[i]];
        CGContextAddLineToPoint(context, [[d objectAtIndex:0] floatValue], [[d objectAtIndex:1] floatValue]);
    }
    CGContextClosePath(context);
    if(stoke) CGContextDrawPath(context, kCGPathFillStroke);
    else CGContextDrawPath(context, kCGPathFill);
}

- (void)drawSideBackground:(CGContextRef)context w:(int)width x:(int)cx y:(int)cy r:(int)clock_radius fd:(int)face_background_dist fr:(int)face_background_radius {
    [self drawCircle:context w:width x:cx y:cy r:clock_radius];
    [self drawCircle:context w:width x:cx-face_background_dist y:cy-face_background_dist r:face_background_radius];
    [self drawCircle:context w:width x:cx-face_background_dist y:cy+face_background_dist r:face_background_radius];
    [self drawCircle:context w:width x:cx+face_background_dist y:cy-face_background_dist r:face_background_radius];
    [self drawCircle:context w:width x:cx+face_background_dist y:cy+face_background_dist r:face_background_radius];
}

- (void)drawCircle:(CGContextRef)context w:(int)w x:(int)cx y:(int)cy r:(int)rad {
    NSArray *sp = [self scalePoint:w x:cx y:cy];
    CGContextAddArc(context, [[sp objectAtIndex:0] floatValue], [[sp objectAtIndex:1] floatValue], [[sp objectAtIndex:2] floatValue]*rad, 0, 6.3, 0);
    CGContextFillPath(context);
}

- (void)drawClockFace:(CGContextRef)context w:(int)w x:(int)cx y:(int)cy c:(UIColor *)color h:(int)hour {
    NSArray *sc = [self scalePoint:w x:cx y:cy];
    CGContextSetFillColorWithColor(context, [color CGColor]);
    [self drawCircle:context w:w x:cx y:cy r:11];
    CGContextSetFillColorWithColor(context, [[UIColor redColor] CGColor]);
    [self drawCircle:context w:w x:cx y:cy r:3];
    NSArray *p1 = [self scalePoint:w x:cx y:cy-10], *p2 = [self scalePoint:w x:cx+3 y:cy-1], *p3 = [self scalePoint:w x:cx-3 y:cy-1];
    CGContextSetFillColorWithColor(context, [color CGColor]);
    for(int i=0; i<12; i++) {
        float cirx = cx + 13*cos(toRadians(i*30));
        float ciry = cy + 13*sin(toRadians(i*30));
        NSArray *sp = [self scalePoint:w x:cirx y:ciry];
        cirx = [[sp objectAtIndex:0] floatValue];
        ciry = [[sp objectAtIndex:1] floatValue];
        //float cirx = [[sc objectAtIndex:0] floatValue] + 13.2*cos(toRadians(i*30));
        //float ciry = [[sc objectAtIndex:1] floatValue] + 13.2*sin(toRadians(i*30));
        CGContextAddArc(context, cirx, ciry, 1.5, 0, 6.3, 0);
        CGContextFillPath(context);
    }
    float arx[] = {[[p1 objectAtIndex:0] floatValue], [[p2 objectAtIndex:0] floatValue], [[p3 objectAtIndex:0] floatValue]}, ary[] = {[[p1 objectAtIndex:1] floatValue], [[p2 objectAtIndex:1] floatValue], [[p3 objectAtIndex:1] floatValue]};
    [self rotate:[[sc objectAtIndex:0] floatValue] b:[[sc objectAtIndex:1] floatValue] x:arx y:ary i:30*hour l:3];
    [self drawPolygon:context cl:[UIColor redColor] x:rotatx y:rotaty len:3 stoke:false];
    CGContextSetFillColorWithColor(context, [[UIColor yellowColor] CGColor]);
    [self drawCircle:context w:w x:cx y:cy r:2];
    p1 = [self scalePoint:w x:cx y:cy-8];
    p2 = [self scalePoint:w x:cx+2 y:cy-0.5];
    p3 = [self scalePoint:w x:cx-2 y:cy-0.5];
    float arrx[] = {[[p1 objectAtIndex:0] floatValue], [[p2 objectAtIndex:0] floatValue], [[p3 objectAtIndex:0] floatValue]}, arry[] = {[[p1 objectAtIndex:1] floatValue], [[p2 objectAtIndex:1] floatValue], [[p3 objectAtIndex:1] floatValue]};
    [self rotate:[[sc objectAtIndex:0] floatValue] b:[[sc objectAtIndex:1] floatValue] x:arrx y:arry i:30*hour l:3];
    [self drawPolygon:context cl:[UIColor yellowColor] x:rotatx y:rotaty len:3 stoke:false];
}

- (void)drawPeg:(CGContextRef)context w:(int)w x:(int)cx y:(int)cy v:(int)pegValue {
    CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:0.16 green:0.16 blue:0.16 alpha:1] CGColor]);
    [self drawCircle:context w:w x:cx y:cy r:5];
    UIColor *color = (pegValue == 1) ? [UIColor yellowColor] : [UIColor colorWithRed:0.27 green:0.27 blue:0 alpha:1];
    CGContextSetFillColorWithColor(context, [color CGColor]);
    [self drawCircle:context w:w x:cx y:cy r:4];
}

- (double)c18:(int)i {
    return cos(M_PI * i / 10);
}

- (double)s18:(int)i {
    return sin(M_PI * i / 10);
}

- (double)sin1:(int)index ag:(float[])ag rd:(float)rd {
    return sin(ag[index])*rd;
}

- (double)cos1:(int)index ag:(float[])ag rd:(float)rd {
    return cos(ag[index])*rd;
}

- (void)change:(float)a b:(float)b x:(float[])x y:(float[])y i:(int)i l:(int)l {
    for(int j=0; j<l; j++) {
        rotatx[j] = x[j]*cos(toRadians(i)) - y[j]*sin(toRadians(i)) + a;
        rotaty[j] = x[j]*sin(toRadians(i)) + y[j]*cos(toRadians(i)) + b;
    }
}

- (void)rotate:(float)a b:(float)b x:(float[])x y:(float[])y i:(int)i l:(int)l {
    for(int j=0; j<l; j++) {
        rotatx[j] = (x[j]-a)*cos(toRadians(i)) - (y[j]-b)*sin(toRadians(i)) + a;
        rotaty[j] = (x[j]-a)*sin(toRadians(i)) + (y[j]-b)*cos(toRadians(i)) + b;
    }
}

- (NSMutableArray *)rd:(char[])arr l:(int)len {
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (int i=0; i<len; i++) {
        if(i==0 || arr[i]!=arr[i-1])
            [temp addObject:@(arr[i])];
    }
    return temp;
}
@end
