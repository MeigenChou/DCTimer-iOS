//
//  Cross.h
//  DCTimer Solvers
//
//  Created by MeigenChou on 12-11-17.
//  Copyright (c) 2012年 MeigenChou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Cross : NSObject {
    short pmv[11880][6], fmv[7920][6];
    char permPrun[11880], flipPrun[7920];
    char fcm[24][6], fem[24][6];
    char fecd[4][576];
    int edd[1568];
}

- (NSString *)solveCross:(NSString *)scr side:(int)sd;
- (NSString *)solveXcross:(NSString *)scr side:(int)sd;
- (void)easyCross;

@end
