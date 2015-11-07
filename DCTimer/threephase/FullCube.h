//
//  FullCube.h
//  DCTimer
//
//  Created by MeigenChou on 14-8-17.
//
//

#import <Foundation/Foundation.h>
#import "EdgeCube.h"
#import "CenterCube.h"
#import "CornerCube.h"

@interface FullCube : NSObject {
@public
    int value;
    int length1;
    int length2;
    bool add1;
    int sym;
@private
    int length3;
    
    int moveBuffer[60];
    int moveLength;
	int edgeAvail;
	int centerAvail;
	int cornerAvail;
}
-(id) initCube:(FullCube *)c;
-(id) initRandomCube;
-(int) compareTo:(FullCube *)c;
-(void) move:(int)m;
-(bool) checkEdge;
-(void) copy:(FullCube *)c;
-(EdgeCube *) getEdge;
-(CenterCube *) getCenter;
-(CornerCube *) getCorner;
-(NSString *)to333Facelet;
@end
