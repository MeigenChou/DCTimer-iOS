//
//  Center3.h
//  DCTimer
//
//  Created by meigen on 15/10/30.
//
//

#import <Foundation/Foundation.h>
#import "CenterCube.h"

@interface Center3 : NSObject {
    int ud[8];
    int rl[8];
    int fb[8];
    int parity;
}

+(void) initCent3;
+(void)initMove;
+(void)initPrun;
-(void)set:(CenterCube *)c ep:(int)eXc_parity;
-(int)getct;

@end
