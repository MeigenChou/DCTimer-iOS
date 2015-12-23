//
//  Center2.h
//  DCTimer
//
//  Created by meigen on 15/10/30.
//
//

#import <Foundation/Foundation.h>
#import "CenterCube.h"

@interface Center2 : NSObject {
    int rl[8];
    int ct[16];
    int parity;
}

+(void)initRL;
+(void)initMove;
+(void)initPrun;
-(void)set:(CenterCube *)c ep:(int)edgeParity;
-(int)getct;
-(int)getrl;

@end
