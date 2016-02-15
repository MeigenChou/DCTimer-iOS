//
//  LatchCube.h
//  DCTimer scramblers
//
//  Created by MeigenChou on 13-3-3.
//  Copyright (c) 2013年 MeigenChou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LatchCube : NSObject {
    int moveCount;
    int currentMove;
    int currentFace;
    int currentTime;
    int movableFaceCount;
    bool bothDirections;
    int moveFaces[25];
    int moveTimes[25];
    int moveSeq[25];
    int movableFaces[6];
    int specialForbiddenFaces[6];
    int label[6][4];
}

- (NSString *)scramble;

@end
