//
//  Sq1Shape.h
//  DCTimer
//
//  Created by MeigenChou on 14-1-12.
//
//

#import <Foundation/Foundation.h>

@interface Sq1Shape : NSObject {
    int shape[3678];
    char prunTrn[3678];
    char prunTws[3678];
    int sol[16];
    int sollen;
}

-(NSString *) solveTrn:(NSString *)scr;
-(NSString *) solveTws:(NSString *)scr;

@end
