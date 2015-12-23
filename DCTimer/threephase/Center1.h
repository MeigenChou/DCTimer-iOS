//
//  Center1.h
//  DCTimer
//
//  Created by meigen on 15/10/30.
//
//

#import <Foundation/Foundation.h>
#import "CenterCube.h"

@interface Center1 : NSObject {
    int ct[24];
}

-(id) initCentUrf:(CenterCube *)c urf:(int)urf;
+(int)getSolvedSym:(CenterCube *)cube;
-(int)getsym;
+(void)initSym;
+(void)initSym2Raw;
+(void)createMoveTable;
+(void)createPrun;

@end
