//
//  Sq12phase.h
//  DCTimer Scrambles
//
//  Created by MeigenChou on 13-2-8.
//  Copyright (c) 2013年 ShuangChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Sq12phase : NSObject {
    int ShapeIdx[3678];
    char ShapePrun[3768 * 2];
    
    int spTopMove[3678 * 2];
    int spBottomMove[3678 * 2];
    int spTwistMove[3678 * 2];
    
    int top;
    int bottom;
    int parity;
    
    int edgeperm;
    int cornperm;
    bool topEdgeFirst;
    bool botEdgeFirst;
    int sqml;
    
    char SquarePrun[40320 * 2];
    unsigned short sqTwistMove[40320];
    unsigned short sqTopMove[40320];
    unsigned short sqBottomMove[40320];
    
    int ul, ur, dl, dr, ml;
    int rul, rur, rdl, rdr, rml;
    
    int sqMove[70];
    int len1;
    int maxlen2;
    int sol_len;
}

-(NSString *) scramble;
-(NSString *) scramble:(int)shp;
@end
