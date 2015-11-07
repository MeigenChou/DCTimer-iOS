//
//  CornerCube.m
//  DCTimer
//
//  Created by meigen on 14-12-9.
//
//

#import "CornerCube.h"
#import "Im.h"
#import "Util4.h"

@implementation CornerCube 

NSMutableArray *moveCorn;
extern int cornerFacelet[][3];
char coFaces[] = {'U', 'R', 'F', 'D', 'L', 'B'};
CornerCube *tempc = nil;

-(id) init {
    if (self = [super init]) {
        for (int i=0; i<8; i++) {
            cp[i] = i;
            co[i] = 0;
        }
    }
    return self;
}

-(id) initCorner:(CornerCube *)c {
    if (self = [super init]) {
        [self copy:c];
    }
    return self;
}

-(id) initRandomCorn {
    if (self = [super init]) {
        srand((unsigned)time(0));
        [self setCPerm:rand() % 40320];
        [self setTwist:rand() % 2187];
    }
    return self;
}

-(id) initWithPerm:(int)cperm twist:(int)twist {
    if (self = [super init]) {
        [self setCPerm:cperm];
        [self setTwist:twist];
    }
    return self;
}

-(void) copy:(CornerCube *)c {
    for (int i=0; i<8; i++) {
        self->cp[i] = c->cp[i];
        self->co[i] = c->co[i];
    }
}

-(int) getParity {
    return [Util4 parity:cp len:8];
}

-(void) fill333Facelet:(char[])facelet {
    for (int corn=0; corn<8; corn++) {
        int j = self->cp[corn];
        int ori = self->co[corn];
        for (int n=0; n<3; n++) {
            facelet[cornerFacelet[corn][(n + ori) % 3]] = coFaces[cornerFacelet[j][n]/9];
        }
    }
}

+(void) cornMult:(CornerCube *)a b:(CornerCube *)b prod:(CornerCube *)prod {
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

-(void) setTwist:(int)idx {
    int twst = 0;
    for (int i=6; i>=0; i--) {
        twst += co[i] = idx % 3;
        idx /= 3;
    }
    co[7] = (15 - twst) % 3;
}

-(void) setCPerm:(int)idx {
    [Im set8Perm:cp i:idx];
}

-(void) move:(int)idx {
    if (tempc == nil) {
        tempc = [[CornerCube alloc] init];
    }
    [CornerCube cornMult:self b:[moveCorn objectAtIndex:idx] prod:tempc];
    [self copy:tempc];
}

+(void) initMove {
    moveCorn = [[NSMutableArray alloc] init];
    [moveCorn addObject:[[CornerCube alloc] initWithPerm:15120 twist:0]];
    [moveCorn addObject:[[CornerCube alloc] initWithPerm:21021 twist:1494]];
    [moveCorn addObject:[[CornerCube alloc] initWithPerm:8064 twist:1236]];
    [moveCorn addObject:[[CornerCube alloc] initWithPerm:9 twist:0]];
    [moveCorn addObject:[[CornerCube alloc] initWithPerm:1230 twist:412]];
    [moveCorn addObject:[[CornerCube alloc] initWithPerm:224 twist:137]];
    for (int a=0; a<18; a+=3) {
        for (int p=0; p<2; p++) {
            CornerCube *newMove = [[CornerCube alloc] init];
            [moveCorn insertObject:newMove atIndex:a+p+1];
            [CornerCube cornMult:[moveCorn objectAtIndex:(a+p)] b:[moveCorn objectAtIndex:a] prod:[moveCorn objectAtIndex:(a+p+1)]];
        }
    }
}

@end
