//
//  LatchCube.m
//  DCTimer scramblers
//
//  Created by MeigenChou on 13-3-3.
//  Copyright (c) 2013年 MeigenChou. All rights reserved.
//

#import "LatchCube.h"
#import "stdlib.h"
#import "time.h"

@interface LatchCube ()
@property (nonatomic, strong) NSArray *turn;
@property (nonatomic, strong) NSArray *suff;
@end

@implementation LatchCube
@synthesize turn, suff;

- (id)init {
    if(self = [super init]) {
        self.turn = [[NSArray alloc] initWithObjects:@"U", @"D", @"L", @"R", @"F", @"B", nil];
        self.suff = [[NSArray alloc] initWithObjects:@"", @"2", @"3", @"'", @"2'", @"3'", nil];
        srand((unsigned)time(0));
    }
    return self;
}

- (bool)check:(int)face {
    int sum = 0;
    int count = 0;
    for (int i = 0; i < 4; ++i) {
        sum += label[face][i];
        count += ABS(label[face][i]);
    }
    sum = ABS(sum);
    
    return sum == count;
}

- (bool)isCounterClockwise:(int)face {
    int sum = 0;
    for (int i = 0; i < 4; ++i) {
        sum += label[face][i];
    }
    bothDirections = sum == 0;
    
    return sum < 0;
}

- (void)determineMovableFaces {
    movableFaceCount = 0;
    for (int i = 0; i < 6; ++i) {
        movableFaces[i] = (([self check:i]) ? i : -1);
    }
    for (int i = 0; i < 6; ++i) {
        if (specialForbiddenFaces[i] == i) {
            movableFaces[i] = -1;
        }
    }
    for (int i = 0; i < 6; ++i)
        movableFaceCount += ((movableFaces[i] >= 0) ? 1 : 0);
}

- (bool)moveU:(int)times {
    int i = 0;
    for (i = 0; i < times; ++i) {
        int tmp = label[0][0];
        label[0][0] = label[0][1];
        label[0][1] = label[0][3];
        label[0][3] = label[0][2];
        label[0][2] = tmp;
        
        tmp = label[4][0];
        label[4][0] = label[3][0];
        label[3][0] = label[5][0];
        label[5][0] = label[2][0];
        label[2][0] = tmp;
    }
    return true;
}

- (bool)moveD:(int)times {
    int i = 0;
    for (i = 0; i < times; ++i) {
        int tmp = label[1][0];
        label[1][0] = label[1][1];
        label[1][1] = label[1][3];
        label[1][3] = label[1][2];
        label[1][2] = tmp;
        
        tmp = label[4][3];
        label[4][3] = label[2][3];
        label[2][3] = label[5][3];
        label[5][3] = label[3][3];
        label[3][3] = tmp;
    }
    return true;
}

- (bool)moveL:(int)times {
    int i = 0;
    for (i = 0; i < times; ++i) {
        int tmp = label[2][0];
        label[2][0] = label[2][1];
        label[2][1] = label[2][3];
        label[2][3] = label[2][2];
        label[2][2] = tmp;
        
        tmp = label[0][1];
        label[0][1] = label[5][2];
        label[5][2] = label[1][1];
        label[1][1] = label[4][1];
        label[4][1] = tmp;
    }
    return true;
}

- (bool)moveR:(int)times {
    int i = 0;
    for (i = 0; i < times; ++i) {
        int tmp = label[3][0];
        label[3][0] = label[3][1];
        label[3][1] = label[3][3];
        label[3][3] = label[3][2];
        label[3][2] = tmp;
        
        tmp = label[0][2];
        label[0][2] = label[4][2];
        label[4][2] = label[1][2];
        label[1][2] = label[5][1];
        label[5][1] = tmp;
    }
    return true;
}

- (bool)moveF:(int)times {
    int i = 0;
    for (i = 0; i < times; ++i) {
        int tmp = label[4][0];
        label[4][0] = label[4][1];
        label[4][1] = label[4][3];
        label[4][3] = label[4][2];
        label[4][2] = tmp;
        
        tmp = label[0][3];
        label[0][3] = label[2][2];
        label[2][2] = label[1][0];
        label[1][0] = label[3][1];
        label[3][1] = tmp;
    }
    return true;
}

- (bool)moveB:(int)times {
    int i = 0;
    for (i = 0; i < times; ++i) {
        int tmp = label[5][0];
        label[5][0] = label[5][1];
        label[5][1] = label[5][3];
        label[5][3] = label[5][2];
        label[5][2] = tmp;
        
        tmp = label[0][0];
        label[0][0] = label[3][2];
        label[3][2] = label[1][3];
        label[1][3] = label[2][1];
        label[2][1] = tmp;
    }
    return true;
}

- (void)reset {
    int i;
    int labelNew[][4] = { { 0, -1, -1, 0 }, { 0, 1, 1, 0 }, { 0, -1, -1, 0 },
        { 0, 1, 1, 0 }, { -1, 0, 0, -1 }, { 1, 0, 0, 1 } };
    for(i=0; i<6; i++) {
        for(int j=0; j<4; j++)
            label[i][j] = labelNew[i][j];
    }
    for(i=0; i<25; i++) {
        moveFaces[i] = -1;
        moveTimes[i] = 0;
        moveSeq[i] = -1;
    }
    currentMove = -1;
    currentFace = -1;
    currentTime = 0;
    movableFaceCount = 0;
    for(i=0; i<6; i++) {
        movableFaces[i] = i;
        specialForbiddenFaces[i] = -1;
    }
    moveCount = 0;
    bothDirections = false;
}

- (void)undoLastMove {
    switch (moveFaces[(moveCount - 1)]) {
		case 0:
            [self moveU:(4 - moveTimes[moveCount - 1]) % 4];
			break;
		case 1:
            [self moveD:(4 - moveTimes[moveCount - 1]) % 4];
			break;
		case 2:
            [self moveL:(4 - moveTimes[moveCount - 1]) % 4];
			break;
		case 3:
            [self moveR:(4 - moveTimes[moveCount - 1]) % 4];
			break;
		case 4:
            [self moveF:(4 - moveTimes[moveCount - 1]) % 4];
			break;
		case 5:
            [self moveB:(4 - moveTimes[moveCount - 1]) % 4];
            break;
    }
    
    moveFaces[moveCount - 1] = -1;
    moveTimes[moveCount - 1] = 0;
    moveSeq[moveCount - 1] = -1;
    moveCount -= 1;
}

- (void)addMove:(int)face time:(int)time {
    switch (face) {
		case 0:
            [self moveU:time];
			moveSeq[moveCount] = 0;//"U"
			break;
		case 1:
			[self moveD:time];
			moveSeq[moveCount] = 6;//"D"
			break;
		case 2:
			[self moveL:time];
			moveSeq[moveCount] = 12;//"L"
			break;
		case 3:
			[self moveR:time];
			moveSeq[moveCount] = 18;//"R"
			break;
		case 4:
			[self moveF:time];
			moveSeq[moveCount] = 24;//"F"
			break;
		case 5:
			[self moveB:time];
			moveSeq[moveCount] = 30;//"B"
    }
    
    if ([self isCounterClockwise:face])
        time -= 4;
    moveFaces[moveCount] = face;
    moveTimes[moveCount] = time;
    switch (time) {
		case -3:
			moveSeq[moveCount] += 5;// "3' "
			break;
		case -2:
			moveSeq[moveCount] += 4;// "2' "
			break;
		case -1:
			moveSeq[moveCount] += 3;// "' "
			break;
		
		case 2:
			moveSeq[moveCount] += 1;// "2 "
			break;
		case 3:
			if (bothDirections) {
				moveSeq[moveCount] += 3;// "' "
			}
			else moveSeq[moveCount] += 2;// "3 "
    }
}

- (NSString *) scramble {
    [self reset];
    
    for (int i = 0; i < 25; moveCount++) {
        [self determineMovableFaces];
        currentMove = rand()%18;
        currentFace = currentMove / 3;
        currentTime = currentMove % 3 + 1;
        if (movableFaces[currentFace] == -1) {
            --i;
            moveCount--;
        }
        else if (movableFaceCount < 2) {
            [self undoLastMove];
            --i;
            --i;
            moveCount--;
        }
        else if ((movableFaceCount < 3) && 
                 (moveCount > 1) && 
                 (moveFaces[moveCount - 1] / 2 == moveFaces[moveCount - 2] / 2)) {
            [self undoLastMove];
            [self undoLastMove];
            i -= 3;
            moveCount--;
        }
        else if ((moveCount > 0) && (currentFace == moveFaces[moveCount - 1])) {
            --i;
            moveCount--;
        }
        else if ((moveCount > 1) && 
                 (currentFace / 2 == moveFaces[moveCount - 1] / 2) && 
                 (currentFace / 2 == moveFaces[moveCount - 2] / 2)) {
            --i;
            moveCount--;
        }
        else {
            [self addMove:currentFace time:currentTime];
        }
        ++i;
    }
    NSMutableString *seq = [NSMutableString string];
    for (int i = 0; i < 25; ++i) {
        [seq appendFormat:@"%@%@ ", [self.turn objectAtIndex:moveSeq[i]/6], [self.suff objectAtIndex:moveSeq[i]%6]];
        //sequence.append(moveNames[i]);
    }
    return seq;
}

@end
