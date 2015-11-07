/*
 *  Sq12phase.m
 *  DCTimer scramblers
 *
 *  Created by MeigenChou on 13-2-8.
 *  Copyright (c) 2013年 ShuangChen. All rights reserved.
 */

#import "Sq12phase.h"
#import "stdlib.h"
#import "time.h"
#import "Im.h"
#import "DCTUtils.h"

@implementation Sq12phase

-(Sq12phase *) init {
    if(self = [super init]) {
        srand((unsigned)time(0));
    }
    return self;
}

//Shape
//1 = corner, 0 = edge.
int halflayer[] = {0x00, 0x03, 0x06, 0x0c, 0x0f, 0x18, 0x1b, 0x1e, 
    0x30, 0x33, 0x36, 0x3c, 0x3f};
int ShapeIdx[3678];
char ShapePrun[3768 * 2];

int spTopMove[3678 * 2];
int spBottomMove[3678 * 2];
int spTwistMove[3678 * 2];

int top;
int bottom;
int parity;

- (int)getShape2Idx:(int)shp {
	int ret = [DCTUtils binarySearch:ShapeIdx ti:3678 key:shp & 0xffffff]<<1 | shp>>24;
	return ret;
}

- (int)getIdx {
	int ret = [DCTUtils binarySearch:ShapeIdx ti:3678 key:top<<12|bottom]<<1|parity;
	return ret;
}

- (void)setIdx:(int)idx {
	parity = idx & 1;
	top = ShapeIdx[idx >> 1];
	bottom = top & 0xfff;
	top >>= 12;
}

- (int)topMove {
	int move = 0;
	int moveParity = 0;
	do {
		if ((top & 0x800) == 0) {
			move += 1;
			top = top << 1;
		} else {
			move += 2;
			top = (top << 2) ^ 0x3003;
		}
		moveParity = 1 - moveParity;
	} while (([DCTUtils bitCount:top & 0x3f] & 1) != 0);
	if (([DCTUtils bitCount:top]&2)==0) {
		parity ^= moveParity;
	}
	return move;
}

- (int)bottomMove {
	int move = 0;
	int moveParity = 0;
	do {
		if ((bottom & 0x800) == 0) {
			move +=1;
			bottom = bottom << 1;
		} else {
			move +=2;
			bottom = (bottom << 2) ^ 0x3003;
		}
		moveParity = 1 - moveParity;
	} while (([DCTUtils bitCount:bottom & 0x3f] & 1) != 0);
	if (([DCTUtils bitCount:bottom]&2)==0) {
		parity ^= moveParity;
	}
	return move;
}

- (void)twistMove {
	int temp = top & 0x3f;
	int p1 = [DCTUtils bitCount:temp];
	int p3 = [DCTUtils bitCount:bottom&0xfc0];
	parity ^= 1 & ((p1&p3)>>1);
	
	top = (top & 0xfc0) | ((bottom >> 6) & 0x3f);
	bottom = (bottom & 0x3f) | temp << 6;
}

- (void)initp {
	int i;
	int count = 0;
	for (i=0; i<13*13*13*13; i++) {
		int dr = halflayer[i % 13];
		int dl = halflayer[i / 13 % 13];
		int ur = halflayer[i / 13 / 13 % 13];
		int ul = halflayer[i / 13 / 13 / 13];
		int value = ul<<18|ur<<12|dl<<6|dr;
		if ([DCTUtils bitCount:value] == 16) {
			ShapeIdx[count++] = value;
		}
	}
    //NSLog(@"%d", count);
	for (i=0; i<3678*2; i++) {
		[self setIdx:i];
		spTopMove[i] = [self topMove];
		spTopMove[i] |= [self getIdx] << 4;
		[self setIdx:i];
		spBottomMove[i] = [self bottomMove];
		spBottomMove[i] |= [self getIdx] << 4;
		[self setIdx:i];
		[self twistMove];
		spTwistMove[i] = [self getIdx];
	}
	for (i=0; i<3768*2; i++) {
		ShapePrun[i] = -1;
	}
	//0 110110110110 011011011011
	//1 110110110110 110110110110
	//1 011011011011 011011011011
	//0 011011011011 110110110110
	ShapePrun[[self getShape2Idx:0x0db66db]] = 0;
	ShapePrun[[self getShape2Idx:0x1db6db6]] = 0;
	ShapePrun[[self getShape2Idx:0x16db6db]] = 0;
	ShapePrun[[self getShape2Idx:0x06dbdb6]] = 0;
	int done = 4;
	int depth;
	for (depth=0; depth<18; depth++) {
        //NSLog(@"%d %d", depth, done);
		for (i=0; i<3768*2; i++) {
			if (ShapePrun[i] == depth) {
				// try top
				int m = 0;
				int idx = i;
				do {
					idx = spTopMove[idx];
					m += idx & 0xf;
					idx >>= 4;
					if (ShapePrun[idx] == -1) {
						++done;
						ShapePrun[idx] = depth + 1;
					}
				} while (m != 12);
				// try bottom
				m = 0;
				idx = i;
				do {
					idx = spBottomMove[idx];
					m += idx & 0xf;
					idx >>= 4;
					if (ShapePrun[idx] == -1) {
						++done;
						ShapePrun[idx] = depth + 1;
					}
				} while (m != 12);
				// try twist
				idx = spTwistMove[i];
				if (ShapePrun[idx] == -1) {
					++done;
					ShapePrun[idx] = depth + 1;
				}
			}
		}
	}
}

//Square
int edgeperm;
int cornperm;
bool topEdgeFirst;
bool botEdgeFirst;
int qml;

char SquarePrun[40320 * 2];
unsigned short sqTwistMove[40320];
unsigned short sqTopMove[40320];
unsigned short sqBottomMove[40320];

- (void)initq {
	int i,m;
    
	int pos[8];
	int temp;
	for(i=0;i<40320;i++){
		//twist
		[Im set8Perm:pos i:i];
		temp=pos[2]; pos[2]=pos[4]; pos[4]=temp;
		temp=pos[3]; pos[3]=pos[5]; pos[5]=temp;
		sqTwistMove[i] = [Im get8Perm:pos];
		//top layer turn
		[Im set8Perm:pos i:i];
		temp=pos[0]; pos[0]=pos[1]; pos[1]=pos[2]; pos[2]=pos[3]; pos[3]=temp;
		sqTopMove[i] = [Im get8Perm:pos];
		//bottom layer turn
		[Im set8Perm:pos i:i];
		temp=pos[4]; pos[4]=pos[5]; pos[5]=pos[6]; pos[6]=pos[7]; pos[7]=temp;
		sqBottomMove[i] = [Im get8Perm:pos];
	}	
	
	for (i=0; i<40320*2; i++) {
		SquarePrun[i] = -1;
	}
	SquarePrun[0] = 0;
	int depth = 0;
	int done = 1;
	bool isBreak=false;
	while (done < 40320 * 2) {
		bool inv = depth >= 11;
		int find = inv ? -1 : depth;
		int check = inv ? depth : -1;
		++depth;
        //NSLog(@"%d %d", depth, done);
		for (int i=0; i<40320*2; i++) {
			if (SquarePrun[i] == find) {
				int idx = i >> 1;
				int ml = i & 1;
				//try twist
				int idxx = sqTwistMove[idx]<<1 | (1-ml);
				if(SquarePrun[idxx] == check) {
					++done;
					SquarePrun[inv ? i : idxx] = depth;
					if (inv) continue;
				}
				//try turning top layer
				idxx = idx;
				for(m=0; m<4; m++) {
					idxx = sqTopMove[idxx];
					if(SquarePrun[idxx<<1|ml] == check){
						++done;
						SquarePrun[inv ? i : (idxx<<1|ml)] = depth;
						if (inv) {
							isBreak=true;
							break;
						}
					}
				}
				if(isBreak) {
					isBreak=false;
					continue;
				}
				//try turning bottom layer
				for(m=0; m<4; m++) {
					idxx = sqBottomMove[idxx];
					if(SquarePrun[idxx<<1|ml] == check){
						++done;
						SquarePrun[inv ? i : (idxx<<1|ml)] = depth;
						if (inv) break;
					}
				}
			}
		}
	}
}

//FullCube
int ul = 0x011233;
int ur = 0x455677;
int dl = 0x998bba;
int dr = 0xddcffe;
int ml = 0;
int rul, rur, rdl, rdr, rml;

- (void)doMove:(int)move {
	move <<= 2;
	if (move > 24) {
		move = 48 - move;
		int temp = ul;
		ul = (ul>>move | ur<<(24-move)) & 0xffffff;
		ur = (ur>>move | temp<<(24-move)) & 0xffffff;
	} else if (move > 0) {
		int temp = ul;
		ul = (ul<<move | ur>>(24-move)) & 0xffffff;
		ur = (ur<<move | temp>>(24-move)) & 0xffffff;		
	} else if (move == 0) {
		int temp = ur;
		ur = dl;
		dl = temp;
		ml = 1-ml;
	} else if (move >= -24) {
		move = -move;
		int temp = dl;
		dl = (dl<<move | dr>>(24-move)) & 0xffffff;
		dr = (dr<<move | temp>>(24-move)) & 0xffffff;				
	} else if (move < -24) {
		move = 48 + move;
		int temp = dl;
		dl = (dl>>move | dr<<(24-move)) & 0xffffff;
		dr = (dr>>move | temp<<(24-move)) & 0xffffff;		
	}
}

- (int)pieceAt:(int)idx {
	int ret;
	if (idx < 6) {
		ret = ul >> ((5-idx) << 2);
	} else if (idx < 12) {
		ret = ur >> ((11-idx) << 2);		
	} else if (idx < 18) {
		ret = dl >> ((17-idx) << 2);
	} else {
		ret = dr >> ((23-idx) << 2);
	}
	return ret & 0x0f;
}

- (void)setPiece:(int)idx value:(int)value {
	if (idx < 6) {
		ul &= ~(0xf << ((5-idx) << 2));
		ul |= value << ((5-idx) << 2);
	} else if (idx < 12) {
		ur &= ~(0xf << ((11-idx) << 2));
		ur |= value << ((11-idx) << 2);
	} else if (idx < 18) {
		dl &= ~(0xf << ((17-idx) << 2));
		dl |= value << ((17-idx) << 2);
	} else {
		dr &= ~(0xf << ((23-idx) << 2));
		dr |= value << ((23-idx) << 2);
	}	
}

int arr[16];
- (int)getParity {
	int cnt = 0;
	arr[0] = [self pieceAt:0];
	for (int i=1; i<24; i++) {
		if ([self pieceAt:i] != arr[cnt]) {
			arr[++cnt] = [self pieceAt:i];
		}
	}
	int p = 0;
	for (int a=0; a<16; a++){
		for(int b=a+1 ; b<16 ; b++){
			if (arr[a] > arr[b]) p^=1;
		}
	}
	return p;
}

-(int)getShapeIdx {
	int urx = ur & 0x111111;
	urx |= urx >> 3;
	urx |= urx >> 6;
	urx = (urx&0xf) | ((urx>>12)&0x30);
	int ulx = ul & 0x111111;
	ulx |= ulx >> 3;
	ulx |= ulx >> 6;
	ulx = (ulx&0xf) | ((ulx>>12)&0x30);
	int drx = dr & 0x111111;
	drx |= drx >> 3;
	drx |= drx >> 6;
	drx = (drx&0xf) | ((drx>>12)&0x30);
	int dlx = dl & 0x111111;
	dlx |= dlx >> 3;
	dlx |= dlx >> 6;
	dlx = (dlx&0xf) | ((dlx>>12)&0x30);
	return [self getShape2Idx:[self getParity]<<24 | ulx<<18 | urx<<12 | dlx<<6 | drx];
}

int prm[8];
- (void)getSquare {
	int a, b;
	for (a=0;a<8;a++) {
		prm[a] = [self pieceAt:a*3+1]>>1;
	}
	cornperm = [Im get8Perm:prm];
	topEdgeFirst = [self pieceAt:0]==[self pieceAt:1];
	a = topEdgeFirst ? 2 : 0;
	for(b=0; b<4; a+=3, b++) prm[b]=[self pieceAt:a]>>1;
	botEdgeFirst = [self pieceAt:12]==[self pieceAt:13];
	a = botEdgeFirst ? 14 : 12;
	for( ; b<8; a+=3, b++) prm[b]=[self pieceAt:a]>>1;
	edgeperm = [Im get8Perm:prm];
	qml = ml;
}

- (void)randomCube:(int)shape {
    //int test = 1037;
	//int test = rand()%3678;
	shape = ShapeIdx[shape];
	int corner = 0x01234567 << 1 | 0x11111111;
	int edge = 0x01234567 << 1;
	int n_corner = 8, n_edge = 8;
	int rnd, m, temp;
	for (int i=0; i<24; i++) {
		if (((shape >> i) & 1) == 0) {//edge
            temp = n_edge<2 ? 0 : rand()%n_edge;
			rnd = temp << 2;
			[self setPiece:23-i value:(edge >> rnd) & 0xf];
			m = (1 << rnd) - 1;
			edge = (edge & m) + ((edge >> 4) & ~m);
			--n_edge;
		} else {//corner
            temp = n_corner<2 ? 0 : rand()%n_corner;
			rnd = temp << 2;
			[self setPiece:23-i value:(corner >> rnd) & 0xf];
			[self setPiece:22-i value:(corner >> rnd) & 0xf];
			m = (1 << rnd) - 1;
			corner = (corner & m) + ((corner >> 4) & ~m);
			--n_corner;
			++i;				
		}
	}
	ml = rand()%2;
}

//Search
int sqMove[70];
int sqLength1;
int sqMaxlen2;
int sqSol_len;

-(bool) sqPhase2:(int)edge c:(int)corner te:(bool)topEdgeFirst be:(bool)botEdgeFirst ml:(int)ml m:(int)maxl d:(int)depth l:(int)lm {
    if (maxl == 0 && !topEdgeFirst && botEdgeFirst) {
        return true;
    }
    
    //try each possible move. First twist;
    if(lm!=0 && topEdgeFirst == botEdgeFirst) {
        int edgex = sqTwistMove[edge];
        int cornerx = sqTwistMove[corner];
        if (SquarePrun[edgex<<1|(1-ml)] < maxl && SquarePrun[cornerx<<1|(1-ml)] < maxl) {
            sqMove[depth] = 0;
            if ([self sqPhase2:edgex c:cornerx te:topEdgeFirst be:botEdgeFirst ml:(1-ml) m:(maxl-1) d:(depth+1) l:0]) {
                return true;
            }
        }
    }
    
    //Try top layer
    if (lm <= 0){
        bool topEdgeFirstx = !topEdgeFirst;
        int edgex = topEdgeFirstx ? sqTopMove[edge] : edge;
        int cornerx = topEdgeFirstx ? corner : sqTopMove[corner];
        int m = topEdgeFirstx ? 1 : 2;
        int prun1 = SquarePrun[(edgex<<1)|ml];
        int prun2 = SquarePrun[(cornerx<<1)|ml];
        while (m < 12 && prun1 <= maxl && prun1 <= maxl) {
            if (prun1 < maxl && prun2 < maxl) {
                sqMove[depth] = m;
                if ([self sqPhase2:edgex c:cornerx te:topEdgeFirstx be:botEdgeFirst ml:ml m:(maxl-1) d:(depth+1) l:1]) {
                    return true;
                }
            }
            topEdgeFirstx = !topEdgeFirstx;
            if (topEdgeFirstx) {
                edgex = sqTopMove[edgex];
                prun1 = SquarePrun[(edgex<<1)|ml];
                m += 1;
            } else {
                cornerx = sqTopMove[cornerx];
                prun2 = SquarePrun[(cornerx<<1)|ml];
                m += 2;
            }
        }
    }
    
    //Try bottom layer
    if (lm <= 1){
        bool botEdgeFirstx = !botEdgeFirst;
        int edgex = botEdgeFirstx ? sqBottomMove[edge] : edge;
        int cornerx = botEdgeFirstx ? corner : sqBottomMove[corner];
        int m = botEdgeFirstx ? 1 : 2;
        int prun1 = SquarePrun[(edgex<<1)|ml];
        int prun2 = SquarePrun[(cornerx<<1)|ml];
        while (m < (maxl > 6 ? 6 : 12) && prun1 <= maxl && prun1 <= maxl) {
            if (prun1 < maxl && prun2 < maxl) {
                sqMove[depth] = -m;
                if ([self sqPhase2:edgex c:cornerx te:topEdgeFirst be:botEdgeFirstx ml:ml m:(maxl-1) d:(depth+1) l:2]) {
                    return true;
                }
            }
            botEdgeFirstx = !botEdgeFirstx;
            if (botEdgeFirstx) {
                edgex = sqBottomMove[edgex];
                prun1 = SquarePrun[(edgex<<1)|ml];
                m += 1;
            } else {
                cornerx = sqBottomMove[cornerx];
                prun2 = SquarePrun[(cornerx<<1)|ml];
                m += 2;
            }
        }
    }
    return false;
}

-(bool)sqInit2 {
    ul=rul; ur=rur; dl=rdl; dr=rdr; ml=rml;
    for (int i=0; i<sqLength1; i++) {
        [self doMove:sqMove[i]];
    }
    [self getSquare];
    int edge = edgeperm;
    int corner = cornperm;
    int ml = qml;
    int prun = MAX(SquarePrun[edgeperm<<1|ml], SquarePrun[cornperm<<1|ml]);
    for (int i=prun; i<sqMaxlen2; i++) {
        if ([self sqPhase2:edge c:corner te:topEdgeFirst be:botEdgeFirst ml:ml m:i d:sqLength1 l:0]) {
            sqSol_len = i + sqLength1;
            return true;
        }
    }
    return false;
}

- (bool)sqPhase1:(int)shape p:(int)prunvalue m:(int)maxl d:(int)depth l:(int)lm {
    if (prunvalue==0 && maxl<4) {
        return maxl==0 && [self sqInit2];
    }
    
    //try each possible move. First twist;
    if (lm != 0) {
        int shapex = spTwistMove[shape];
        int prunx = ShapePrun[shapex];
        if (prunx < maxl) {
            sqMove[depth] = 0;
            if ([self sqPhase1:shapex p:prunx m:maxl-1 d:depth+1 l:0]) {
                return true;
            }				
        }
    }
    
    //Try top layer
    int shapex = shape;
    if(lm <= 0){
        int m = 0;
        while (true) {
            m += spTopMove[shapex];
            shapex = m >> 4;
            m &= 0x0f;
            if (m >= 12) {
                break;
            }
            int prunx = ShapePrun[shapex];
            if (prunx > maxl) {
                break;
            } else if (prunx < maxl) {
                sqMove[depth] = m;
                if ([self sqPhase1:shapex p:prunx m:maxl-1 d:depth+1 l:1]) {
                    return true;
                }
            }
        }
    }
    
    shapex = shape;
    //Try bottom layer
    if(lm <= 1){
        int m = 0;
        while (true) {
            m += spBottomMove[shapex];
            shapex = m >> 4;
            m &= 0x0f;
            if (m >= 6) {
                break;
            }
            int prunx = ShapePrun[shapex];
            if (prunx > maxl) {
                break;
            } else if (prunx < maxl) {
                sqMove[depth] = -m;
                if ([self sqPhase1:shapex p:prunx m:maxl-1 d:depth+1 l:2]) {
                    return true;
                }
            }
        }
    }
    return false;
}

-(void) initsq {
    //NSLog(@"init sq");
    [self initp];
    [self initq];
    //NSLog(@"sq OK");
}

- (NSString *) scrSq1 {
    return [self scrSq1:(rand()%3678)];
}

- (NSString *) scrSq1:(int)shp {
    [self randomCube:shp];
    rul=ul; rur=ur; rdl=dl; rdr=dr; rml=ml;
    int shape = [self getShapeIdx];
    //NSLog(@"%d %d %d %d %d, %d %d", ul, ur, dl, dr, ml, shape, ShapePrun[shape]);
    for (sqLength1=ShapePrun[shape]; sqLength1<70; sqLength1++) {
        sqMaxlen2 = MIN(34 - sqLength1, 17);
        if ([self sqPhase1:shape p:ShapePrun[shape] m:sqLength1 d:0 l:-1]) {
            break;
        }
    }
    //NSLog(@"%d", sqSol_len);
    NSString *s = @"";
    int top = 0, bottom = 0;
    for (int i=sqSol_len-1; i>=0; i--) {
        int val = sqMove[i];
        if (val > 0) {
            val = 12 - val;
            top = (val > 6) ? (val-12) : val;
        } else if (val < 0) {
            val = 12 + val;
            bottom = (val > 6) ? (val-12) : val;
        } else {
            if (top == 0 && bottom == 0) {
                s = [s stringByAppendingString:@" / "];
            } else {
                s = [s stringByAppendingFormat:@"(%d,%d) / ", top, bottom];
            }
            top = bottom = 0;
        }
    }
    if (top == 0 && bottom == 0) {
    } else {
        s = [s stringByAppendingFormat:@"(%d,%d)", top, bottom];
    }
    return s;// + " (" + len + "t)";
}

@end
