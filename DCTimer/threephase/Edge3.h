//
//  Edge3.h
//  DCTimer
//
//  Created by MeigenChou on 14-8-15.
//
//

#import <Foundation/Foundation.h>
#import "EdgeCube.h"

@interface Edge3 : NSObject {
@public
    int edge[12];
@private
    int edgeo[12];
    int temp[12];
    bool isStd;
}

+(void) initMvrot;
+(void) initRaw2Sym;
+(void) createPrun;
-(void) set:(int)idx;
+(int) getmvrot:(int[])ep m:(int)mrIdx e:(int)end;
+(int) getprun:(int)edge p:(int)prun;
-(int) setEdgeCube:(EdgeCube *)c;
-(int) get:(int)end;
+(int) getprun:(int)edge;
-(int) getsym;

@end
