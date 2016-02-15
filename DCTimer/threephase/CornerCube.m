//
//  CornerCube.m
//  DCTimer
//
//  Created by meigen on 15/10/31.
//
//

#import "CornerCube.h"
#import "Util4.h"
#import "Util.h"

@implementation CornerCube

extern int cornerFacelet[][3];

NSMutableArray *moveCorner;
CornerCube *temp4 = nil;

-(id)init {
    if (self = [super init]) {
        for(int i=0; i<8; i++) {
            self->cp[i] = i;
            self->co[i] = 0;
        }
    }
    return self;
}

-(id)initRandomCorn {
    if (self = [super init]) {
        srand((unsigned)time(0));
        [self setCPerm:rand() % 40320];
        [self setTwist:rand() % 2187];
    }
    return self;
}

-(id)initCorner:(int[])cperm co:(int[])cori {
    if (self = [super init]) {
        for(int i=0; i<8; i++) {
            self->cp[i] = cperm[i];
            self->co[i] = cori[i];
        }
    }
    return self;
}

-(id)initCperm:(int)cperm twist:(int)twist {
    if (self = [super init]) {
        [self setCPerm:cperm];
        [self setTwist:twist];
    }
    return self;
}

-(id)initCorner:(CornerCube *)c {
    if (self = [super init]) {
        [self copy:c];
    }
    return self;
}

-(void)copy:(CornerCube *)c {
    for (int i=0; i<8; i++) {
        cp[i] = c->cp[i];
        co[i] = c->co[i];
    }
}

-(int)getParity {
    return [Util4 parity:cp len:8];
}

-(void)fill333Facelet:(char[])facelet {
    char ts[] = {'U', 'R', 'F', 'D', 'L', 'B'};
    for (int corn=0; corn<8; corn++) {
        int j = cp[corn];
        int ori = co[corn];
        for (int n=0; n<3; n++) {
            facelet[cornerFacelet[corn][(n + ori) % 3]] = ts[cornerFacelet[j][n]/9];
        }
    }
}

/**
 * prod = a * b, Corner Only.
 */
+(void)CornMult:(CornerCube *)a b:(CornerCube *)b prod:(CornerCube *)prod {
    for (int corn=0; corn<8; corn++) {
        prod->cp[corn] = a->cp[b->cp[corn]];
        int oriA = a->co[b->cp[corn]];
        int oriB = b->co[corn];
        int ori = oriA;
        ori += (oriA<3) ? oriB : 6-oriB;
        ori %= 3;
        if ((oriA >= 3) ^ (oriB >= 3)) {
            ori += 3;
        }
        prod->co[corn] = ori;
    }
}

-(void)setTwist:(int)idx {
    int twst = 0;
    for (int i=6; i>=0; i--) {
        twst += co[i] = idx % 3;
        idx /= 3;
    }
    co[7] = (15 - twst) % 3;
}

-(void)setCPerm:(int)idx {
    [Util set8Perm:cp i:idx];
}

-(void)move:(int)idx {
    if (temp4 == nil) {
        temp4 = [[CornerCube alloc] init];
    }
    [CornerCube CornMult:self b:[moveCorner objectAtIndex:idx] prod:temp4];
    [self copy:temp4];
}

+(void)initMove {
    moveCorner = [[NSMutableArray alloc] init];
    [moveCorner addObject:[[CornerCube alloc] initCperm:15120 twist:0]];
    [moveCorner addObject:[[CornerCube alloc] initCperm:21021 twist:1494]];
    [moveCorner addObject:[[CornerCube alloc] initCperm:8064 twist:1236]];
    [moveCorner addObject:[[CornerCube alloc] initCperm:9 twist:0]];
    [moveCorner addObject:[[CornerCube alloc] initCperm:1230 twist:412]];
    [moveCorner addObject:[[CornerCube alloc] initCperm:224 twist:137]];
    for (int a=0; a<18; a+=3) {
        for (int p=0; p<2; p++) {
            [moveCorner insertObject:[[CornerCube alloc] init] atIndex:a+p+1];
            [CornerCube CornMult:[moveCorner objectAtIndex:a+p] b:[moveCorner objectAtIndex:a] prod:[moveCorner objectAtIndex:a+p+1]];
        }
    }
}
@end
