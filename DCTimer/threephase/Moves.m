//
//  Moves.m
//  DCTimer
//
//  Created by meigen on 15/10/30.
//
//

#import "Moves.h"

@implementation Moves

extern int Ux1, Ux2, Ux3, Rx1, Rx2, Rx3, Fx1, Fx2, Fx3;
extern int Dx1, Dx2, Dx3, Lx1, Lx2, Lx3, Bx1, Bx2, Bx3;
const int ux1 = 18;
const int ux2 = 19;
const int ux3 = 20;
const int rx1 = 21;
const int rx2 = 22;
const int rx3 = 23;
const int fx1 = 24;
const int fx2 = 25;
const int fx3 = 26;
const int dx1 = 27;
const int dx2 = 28;
const int dx3 = 29;
const int lx1 = 30;
const int lx2 = 31;
const int lx3 = 32;
const int bx1 = 33;
const int bx2 = 34;
const int bx3 = 35;
const int eomv = 36;

int move2std[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17,
    ux2, rx1, rx2, rx3, fx2, dx2, lx1, lx2, lx3, bx2, eomv};
int move3std[] = {0, 1, 2, 4, 6, 7, 8, 9, 10, 11, 13, 15, 16, 17,
    ux2, rx2, fx2, dx2, lx2, bx2, eomv};

int ckmv[37][36];
int ckmv2[29][28];
int ckmv3[21][20];

int skipAxis[36];
int skipAxis2[28];
int skipAxis3[20];

+(void)initMoves {
    for (int i=0; i<36; i++) {
        for (int j=0; j<36; j++) {
            ckmv[i][j] = (i/3 == j/3) || ((i/3%3 == j/3%3) && (i>j));
        }
        ckmv[36][i] = false;
    }
    for (int i=0; i<29; i++) {
        for (int j=0; j<28; j++) {
            ckmv2[i][j] = ckmv[move2std[i]][move2std[j]];
        }
    }
    for (int i=0; i<21; i++) {
        for (int j=0; j<20; j++) {
            ckmv3[i][j] = ckmv[move3std[i]][move3std[j]];
        }
    }
    for (int i=0; i<36; i++) {
        skipAxis[i] = 36;
        for (int j=i; j<36; j++) {
            if (!ckmv[i][j]) {
                skipAxis[i] = j - 1;
                break;
            }
        }
    }
    for (int i=0; i<28; i++) {
        skipAxis2[i] = 28;
        for (int j=i; j<28; j++) {
            if (!ckmv2[i][j]) {
                skipAxis2[i] = j - 1;
                break;
            }
        }
    }
    for (int i=0; i<20; i++) {
        skipAxis3[i] = 20;
        for (int j=i; j<20; j++) {
            if (!ckmv3[i][j]) {
                skipAxis3[i] = j - 1;
                break;
            }
        }
    }
}
@end
