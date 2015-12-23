//
//  Util4.h
//  DCTimer
//
//  Created by meigen on 15/10/30.
//
//

#import <Foundation/Foundation.h>

@interface Util4 : NSObject

+(void) swap:(int[])arr a:(int)a b:(int)b c:(int)c d:(int)d k:(int)key;
+(int) parity:(int[])arr len:(int)len;
+(NSMutableArray *)tomove:(NSString *)s;

@end
