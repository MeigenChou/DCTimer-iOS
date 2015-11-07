//
//  Center3.h
//  DCTimer
//
//  Created by MeigenChou on 14-8-15.
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
-(void)set:(CenterCube *)c ep:(int)eXc_parity;
-(int)getct;

@end
