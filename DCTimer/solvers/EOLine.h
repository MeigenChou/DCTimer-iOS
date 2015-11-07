//
//  EOLine.h
//  DCTimer Solvers
//
//  Created by MeigenChou on 13-4-5.
//  Copyright (c) 2013年 MeigenChou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EOLine : NSObject {
    short eom[2048][6];
    short epm[132][6];
    char eod[2048];
    char epd[132];
}

- (NSString *)solveEOLine:(NSString *)scr side:(int)side;

@end
