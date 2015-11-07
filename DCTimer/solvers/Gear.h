//
//  Gear.h
//  DCTimer solvers
//
//  Created by MeigenChou on 13-3-3.
//  Copyright (c) 2013年 MeigenChou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Gear : NSObject {
    char cpm[24][3], epm[24][3], eom[27][3];
    char pd[3][576];
}

-(NSString *) scramble;

@end
