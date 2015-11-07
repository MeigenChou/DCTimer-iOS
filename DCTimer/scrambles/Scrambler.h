//
//  Scrambler.h
//  DCTimer scramblers
//
//  Created by MeigenChou on 12-11-2.
//  Copyright (c) 2012年 MeigenChou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Scrambler : NSObject
- (NSString *)getScrString: (int)idx;
- (NSString *)solveCross: (NSString *)scr side:(int)side;
- (NSString *)solveXcross:(NSString *)scr side:(int)side;
- (NSString *)solveEoline:(NSString *)scr side:(int)side;
- (NSString *)solveSqShape:(NSString *)scr m:(int)metric;
+ (NSMutableArray *) imageString:(int)size scr:(NSString *)scr;
- (void) initSq1;
- (int) viewType;
@end
