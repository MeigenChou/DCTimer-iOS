//
//  FullCube.m
//  DCTimer
//
//  Created by MeigenChou on 14-8-17.
//
//

#import "FullCube.h"
#import "CenterCube.h"
#import "EdgeCube.h"
#import "CornerCube.h"
#import "Center1.h"

@interface FullCube()
@property (nonatomic, strong) EdgeCube *edge;
@property (nonatomic, strong) CenterCube *center;
@property (nonatomic, strong) CornerCube *corner;
@end

@implementation FullCube
@synthesize edge, center, corner;
int move2rot[] = {35, 1, 34, 2, 4, 6, 22, 5, 19};
NSArray *move42str;
extern int symmove4[48][36];
extern int symmult4[48][48];
extern int syminv4[];

-(int) compareTo:(FullCube *)c {
    return value - c->value;
}

-(id) init {
    if (self = [super init]) {
        value = sym = moveLength = 0;
        add1 = false;
        length1 = length2 = length3 = 0;
        edgeAvail = centerAvail = cornerAvail = 0;
        edge = [[EdgeCube alloc] init];
        center = [[CenterCube alloc] init];
        corner = [[CornerCube alloc] init];
    }
    return self;
}

-(id) initCube:(FullCube *)c {
    if (self = [super init]) {
        [self copy:c];
    }
    return self;
}

-(id) initRandomCube {
    if (self = [super init]) {
        edge = [[EdgeCube alloc] initRandomEdge];
        center = [[CenterCube alloc] initRandomCent];
        corner = [[CornerCube alloc] initRandomCorn];
    }
    return self;
}

-(void) copy:(FullCube *)c {
    [edge copy:c.edge];
    [center copy:c.center];
    [corner copy:c.corner];
    
    value = c->value;
    add1 = c->add1;
    length1 = c->length1;
    length2 = c->length2;
    length3 = c->length3;
    sym = c->sym;
    for (int i=0; i<60; i++) {
        moveBuffer[i] = c->moveBuffer[i];
    }
    moveLength = c->moveLength;
    edgeAvail = c->edgeAvail;
    centerAvail = c->centerAvail;
    cornerAvail = c->cornerAvail;
}

-(bool) checkEdge {
    return [[self getEdge] checkEdge];
}

-(NSString *)getMoveString:(bool)inverse r:(bool)rotation {
    int *fixedMoves = (int *)calloc(moveLength - (add1 ? 2 : 0), sizeof(int));
    int idx = 0;
    for (int i=0; i<length1; i++) {
        fixedMoves[idx++] = moveBuffer[i];
    }
    int s = self->sym;
    for (int i=length1 + (add1 ? 2 : 0); i<moveLength; i++) {
        if (symmove4[s][moveBuffer[i]] >= 27) {
            fixedMoves[idx++] = symmove4[s][moveBuffer[i]] - 9;
            int rot = move2rot[symmove4[s][moveBuffer[i]] - 27];
            s = symmult4[s][rot];
        } else {
            fixedMoves[idx++] = symmove4[s][moveBuffer[i]];
        }
    }
    int finishSym = symmult4[syminv4[s]][[Center1 getSolvedSym:[self getCenter]]];
    
    if (!move42str) {
        move42str = [[NSArray alloc] initWithObjects:@"U", @"U2 ", @"U'", @"R", @"R2", @"R'", @"F", @"F2", @"F'", @"D", @"D2", @"D'", @"L", @"L2", @"L'", @"B", @"B2", @"B'", @"Uw", @"Uw2", @"Uw'", @"Rw", @"Rw2", @"Rw'", @"Fw", @"Fw2", @"Fw'", @"Dw", @"Dw2", @"Dw'", @"Lw", @"Lw2", @"Lw'", @"Bw", @"Bw2", @"Bw'", nil];
    }
    NSMutableString *sb = [NSMutableString string];
    s = finishSym;
    if (inverse) {
        for (int i=idx-1; i>=0; i--) {
            int move = fixedMoves[i];
            move = move / 3 * 3 + (2 - move % 3);
            if (symmove4[s][move] >= 27) {
                [sb appendString:[move42str objectAtIndex:symmove4[s][move] - 9]];
                [sb appendString:@" "];
                int rot = move2rot[symmove4[s][move] - 27];
                s = symmult4[s][rot];
            } else {
                [sb appendString:[move42str objectAtIndex:symmove4[s][move]]];
                [sb appendString:@" "];
            }
        }
        if (rotation) {
            //cube rotation after solution. for wca scramble, it should be omitted.
            //sb.append(Center1.rot2str[syminv4[s]] + " ");
        }
    } else {
        for (int i=0; i<idx; i++) {
            [sb appendString:[move42str objectAtIndex:fixedMoves[i]]];
            [sb appendString:@" "];
        }
        if (rotation) {
            //sb.append(Center1.rot2str[finishSym]);//cube rotation after solution.
        }
    }
    return sb;
}

-(NSString *)to333Facelet {
    char ret[54];
    [[self getEdge] fill333Facelet:ret];
    [[self getCenter] fill333Facelet:ret];
    [[self getCorner] fill333Facelet:ret];
    return [[NSString alloc] initWithCString:(const char*)ret encoding:NSASCIIStringEncoding];
}

-(void) move:(int)m {
    moveBuffer[moveLength++] = m;
}

-(void) doMove:(int)m {
    [[self getEdge] move:m];
    [[self getCenter] move:m];
    [[self getCorner] move:m % 18];
}

-(EdgeCube *) getEdge {
    while (edgeAvail < moveLength) {
        [edge move:moveBuffer[edgeAvail++]];
    }
    return edge;
}

-(CenterCube *) getCenter {
    while (centerAvail < moveLength) {
        [center move:moveBuffer[centerAvail++]];
    }
    return center;
}

-(CornerCube *) getCorner {
    while (cornerAvail < moveLength) {
        [corner move:moveBuffer[cornerAvail++] % 18];
    }
    return corner;
}

@end
