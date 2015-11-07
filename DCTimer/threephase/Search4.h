//
//  Search4.h
//  DCTimer
//
//  Created by MeigenChou on 14-8-17.
//
//

#import <Foundation/Foundation.h>

@interface Search4 : NSObject {
    int move1[20];
    int move2[15];
    int move3[15];
    int length1;
    int length2;
    int maxlen2;
    bool add1;
    int valid1;
    NSString *solution;
    int arr2idx;
    int p1SolsCnt;
}

-(NSString *) randomState;

@end
