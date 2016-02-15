//
//  Util3.h
//  DCTimer
//
//  Created by MeigenChou on 16/2/4.
//
//

#import <Foundation/Foundation.h>
#import "CubieCube.h"

@interface Util3 : NSObject
+ (void)toCubieCube:(int[])f cc:(CubieCube *)ccRet;
+ (NSString *)toFaceCube:(CubieCube *)cc;
+ (int)binarySearch:(unsigned short[])arr l:(int)length k:(int)key;
+ (void)setupUtil;
@end
