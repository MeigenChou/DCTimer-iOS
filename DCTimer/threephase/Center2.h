//
//  Center2.h
//  DCTimer
//
//  Created by MeigenChou on 14-8-14.
//
//

#import <Foundation/Foundation.h>
#import "CenterCube.h"

@interface Center2 : NSObject {
    int rl[8];
    int ct[16];
    int parity;
}
+(void) initCent2;
-(void) set:(CenterCube *)c ep:(int)edgeParity;
-(int) getct;
-(int) getrl;
@end
