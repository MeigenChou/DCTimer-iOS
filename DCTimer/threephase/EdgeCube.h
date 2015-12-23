//
//  EdgeCube.h
//  DCTimer
//
//  Created by meigen on 15/10/30.
//
//

#import <Foundation/Foundation.h>

@interface EdgeCube : NSObject {
@public
    int ep[24];
}

-(id) initRandomEdge;
-(void) copy:(EdgeCube *)c;
-(bool) checkEdge;
-(void) move:(int)m;
-(void) fill333Facelet:(char[])facelet;
-(int) getParity;

@end
