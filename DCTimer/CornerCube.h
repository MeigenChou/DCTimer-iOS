//
//  CornerCube.h
//  DCTimer
//
//  Created by meigen on 14-12-9.
//
//

#import <Foundation/Foundation.h>

@interface CornerCube : NSObject {
    int cp[8];
    int co[8];
}

-(id) initRandomCorn;
-(void) move:(int)idx;
-(void) fill333Facelet:(char[])facelet;
-(int) getParity;

@end
