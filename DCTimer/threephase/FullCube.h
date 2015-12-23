//
//  FullCube.h
//  DCTimer
//
//  Created by meigen on 15/10/31.
//
//

#import <Foundation/Foundation.h>
#import "CenterCube.h"
#import "EdgeCube.h"
#import "CornerCube.h"

@interface FullCube : NSObject {
@public
    int value;
    bool add1;
    int length1;
    int length2;
    int length3;
    
    int moveBuffer[60];
    int moveLength;
    int edgeAvail;
    int centerAvail;
    int cornerAvail;
    int sym;
}
@property (nonatomic, strong) EdgeCube *edge;
@property (nonatomic, strong) CenterCube *center;
@property (nonatomic, strong) CornerCube *corner;
@property (nonatomic, strong) NSArray *rot2str;
@property (nonatomic, strong) NSArray *move2str;

-(id)initFullcube:(FullCube *)c;
-(id)initRandomCube;
-(void)copy:(FullCube *)c;
-(void)move:(int)m;
-(bool)checkEdge;
-(EdgeCube *)getEdge;
-(CenterCube *)getCenter;
-(CornerCube *)getCorner;
-(NSString *)to333Facelet;
-(int)compareTo:(FullCube *)c;
-(NSString *)getMoveString:(bool)inverse rot:(bool)rotation;
-(NSString *)toString;
-(void)print;
-(id)initCorner:(int[])cp co:(int[])co;

@end
