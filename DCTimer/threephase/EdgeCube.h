//
//  EdgeCube.h
//  DCTimer
//
//  Created by MeigenChou on 14-8-16.
//
//

#import <Foundation/Foundation.h>

@interface EdgeCube : NSObject {
@public
    int ep[24];
}

-(id) initRandomEdge;
-(bool) checkEdge;
-(void) move:(int)m;
-(void) fill333Facelet:(char[])facelet;
-(int) getParity;
@end
