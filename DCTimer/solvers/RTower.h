//
//  RTower.h
//  DCTimer solvers
//
//  Created by MeigenChou on 13-3-17.
//  Copyright (c) 2013年 MeigenChou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RTower : NSObject {
    unsigned short cpm[40320][4];
    unsigned short epm[40320][4];
    unsigned short eom[2187][5];
    char cpd[40320];
    char epd[40320];
    char eod[2187];
    int faces[4];
    int seq[40];
    int len1;
}

-(NSString *) scramble;

@end
