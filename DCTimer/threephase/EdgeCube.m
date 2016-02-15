//
//  EdgeCube.m
//  DCTimer
//
//  Created by meigen on 15/10/30.
//
//

#import "EdgeCube.h"
#import "Util4.h"

@implementation EdgeCube
const int U = 0;
const int D = 1;
const int F = 2;
const int B = 3;
const int R = 4;
const int L = 5;
int EdgeColor[][2] = {{F, U}, {L, U}, {B, U}, {R, U}, {B, D}, {L, D}, {F, D}, {R, D}, {F, L}, {B, L}, {B, R}, {F, R}};
int EdgeMap[] = {19, 37, 46, 10, 52, 43, 25, 16, 21, 50, 48, 23, 7, 3, 1, 5, 34, 30, 28, 32, 41, 39, 14, 12};
char colorMap4to3[] = {'U', 'D', 'F', 'B', 'R', 'L'};

-(id) init {
    if (self = [super init]) {
        for (int i=0; i<24; i++) {
            ep[i] = i;
        }
    }
    return self;
}

-(id) initEdge:(EdgeCube *)c {
    if (self = [super init]) {
        [self copy:c];
    }
    return self;
}

-(id)initRandomEdge {
    if (self = [super init]) {
        srand((unsigned)time(0));
        for (int i=0; i<24; i++) {
            ep[i] = i;
        }
        for (int i=0; i<23; i++) {
            int t = i + (rand() % (24 - i));
            if (t != i) {
                int m = ep[i];
                ep[i] = ep[t];
                ep[t] = m;
            }
        }
    }
    return self;
}

-(void) copy:(EdgeCube *)c {
    for (int i=0; i<24; i++) {
        self->ep[i] = c->ep[i];
    }
}

-(int) getParity {
    return [Util4 parity:ep len:24];
}

-(void) fill333Facelet:(char[])facelet {
    for (int i=0; i<24; i++) {
        facelet[EdgeMap[i]] = colorMap4to3[EdgeColor[ep[i] % 12][ep[i] / 12]];
    }
}

-(bool) checkEdge {
    int ck = 0;
    bool parity = false;
    for (int i=0; i<12; i++) {
        ck |= 1 << ep[i];
        parity = parity != ep[i] >= 12;
    }
    ck &= ck >> 12;
    return ck == 0 && !parity;
}

-(void) move:(int)m {
    int key = m % 3;
    m /= 3;
    switch (m) {
        case 6: //u
            [Util4 swap:ep a:9 b:22 c:11 d:20 k:key];
        case 0:	//U
            [Util4 swap:ep a:0 b:1 c:2 d:3 k:key];
            [Util4 swap:ep a:12 b:13 c:14 d:15 k:key];
            break;
        case 7: //r
            [Util4 swap:ep a:2 b:16 c:6 d:12 k:key];
        case 1:	//R
            [Util4 swap:ep a:11 b:15 c:10 d:19 k:key];
            [Util4 swap:ep a:23 b:3 c:22 d:7 k:key];
            break;
        case 8: //f
            [Util4 swap:ep a:3 b:19 c:5 d:13 k:key];
        case 2:	//F
            [Util4 swap:ep a:0 b:11 c:6 d:8 k:key];
            [Util4 swap:ep a:12 b:23 c:18 d:20 k:key];
            break;
        case 9: //d
            [Util4 swap:ep a:8 b:23 c:10 d:21 k:key];
        case 3:	//D
            [Util4 swap:ep a:4 b:5 c:6 d:7 k:key];
            [Util4 swap:ep a:16 b:17 c:18 d:19 k:key];
            break;
        case 10:    //l
            [Util4 swap:ep a:14 b:0 c:18 d:4 k:key];
        case 4:	//L
            [Util4 swap:ep a:1 b:20 c:5 d:21 k:key];
            [Util4 swap:ep a:13 b:8 c:17 d:9 k:key];
            break;
        case 11:    //b
            [Util4 swap:ep a:7 b:15 c:1 d:17 k:key];
        case 5:	//B
            [Util4 swap:ep a:2 b:9 c:4 d:10 k:key];
            [Util4 swap:ep a:14 b:21 c:16 d:22 k:key];
            break;
    }
}
@end
