//
//  CornerCube.h
//  DCTimer
//
//  Created by meigen on 15/10/31.
//
//

#import <Foundation/Foundation.h>

@interface CornerCube : NSObject {
@public
    int cp[8];
    int co[8];
}

-(id)initRandomCorn;
-(void)copy:(CornerCube *)c;
-(void)fill333Facelet:(char[])facelet;
-(void)move:(int)idx;
-(int)getParity;
+(void)initMove;
-(id)initCorner:(int[])cperm co:(int[])cori;

@end
