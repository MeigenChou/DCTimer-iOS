//
//  Pyraminx.h
//  DCTimer Solvers
//
//  Created by MeigenChou on 12-11-3.
//  Copyright (c) 2012年 MeigenChou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Pyraminx : NSObject {
    char perm[360];
    char twst[2592];
    short permmv[360][4];
    char twstmv[81][4];
    char flipmv[32][4];
}

-(NSString *) scramble;
+(NSMutableArray *) image:(NSString *)scr;

@end
