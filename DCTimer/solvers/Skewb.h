//
//  Skewb.h
//  DCTimer solvers
//
//  Created by MeigenChou on 13-2-20.
//  Copyright (c) 2013年 MeigenChou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Skewb : NSObject {
    short ctm[360][4];
    char cpm[36][4];
    short com[2187][4];
    char ctd[360];
    char cd[2187][36];
}

-(NSString *) scramble;
+(NSMutableArray *) image:(NSString *)scr;

@end
