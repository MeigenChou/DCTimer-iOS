//
//  CenterCube.h
//  DCTimer
//
//  Created by meigen on 15/10/30.
//
//

#import <Foundation/Foundation.h>

@interface CenterCube : NSObject {
@public
    int ct[24];
}
-(id)initRandomCent;
-(void)copy:(CenterCube *)c;
-(void)move:(int)m;
-(void)fill333Facelet:(char[])facelet;

@end
