//
//  CenterCube.h
//  DCTimer
//
//  Created by MeigenChou on 14-8-15.
//
//

#import <Foundation/Foundation.h>

@interface CenterCube : NSObject {
@public
    int ct[24];
}

-(id) initRandomCent;
-(void) move:(int)m;
-(void) fill333Facelet:(char[])facelet;

@end
