//
//  Center1.h
//  DCTimer
//
//  Created by MeigenChou on 14-8-2.
//
//

#import <Foundation/Foundation.h>
#import "CenterCube.h"

@interface Center1 : NSObject {
    int ct[24];
}

+(void) initCent1;
-(id) initCentUrf:(CenterCube *)c urf:(int)urf;
+(int) getSolvedSym:(CenterCube *)cube;
-(int) getsym;
@end
