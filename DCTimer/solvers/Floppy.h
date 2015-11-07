//
//  Floppy.h
//  DCTimer solvers
//
//  Created by MeigenChou on 13-3-14.
//  Copyright (c) 2013年 MeigenChou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Floppy : NSObject {
    char distance[24][16];
}

- (NSString *) scramble;

@end
