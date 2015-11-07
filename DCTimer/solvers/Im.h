//
//  Im.h
//  DCTimer Solvers
//
//  Created by MeigenChou on 13-2-18.
//  Copyright (c) 2013年 MeigenChou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Im : NSObject

+ (void) initCnk;

+(void)set8Perm:(int[])arr i:(int)idx;
+(int)get8Perm:(int[])arr;

//int get8Comb(int arr[]);

+(void) cir:(int[])arr a:(int)a b:(int)b c:(int)c d:(int)d;
+(void) cir2:(int[])arr a:(int)a b:(int)b c:(int)c d:(int)d;
+(void) cir:(int[])arr a:(int)a b:(int)b;
+(void) cir3:(int[])arr a:(int)a b:(int)b c:(int)c;

+(int) permToIdx:(int[])p l:(int)len;
+(void) idxToPerm:(int[])p i:(int)idx l:(int)l;

+(int) evenPermToIdx:(int[])p l:(int)len;
+(void) idxToEvenPerm:(int[])p i:(int)idx l:(int)len;

+(int)oriToIdx:(int[])o n:(int)n l:(int)len;
+(void)idxToOri:(int[])o i:(int)idx n:(int)n l:(int)len;

+(int) zsOriToIdx:(int[])o n:(int)n l:(int)len;
+(void) idxToZsOri:(int[])o i:(int)idx n:(int)n l:(int)len;

+(int) combToIdx:(bool[])comb k:(int)k l:(int)len;
+(void) idxToComb:(bool[])comb i:(int)idx k:(int)k l:(int)len;
@end
