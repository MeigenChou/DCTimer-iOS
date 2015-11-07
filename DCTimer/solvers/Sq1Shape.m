//
//  Sq1Shape.m
//  DCTimer
//
//  Created by MeigenChou on 14-1-12.
//
//

#import "Sq1Shape.h"
#import "DCTUtils.h"

@implementation Sq1Shape
int halfLayer[] = {0x15, 0x17, 0x1B, 0x1D, 0x1F, 0x2B, 0x2D, 0x2F, 0x35, 0x37, 0x3B, 0x3D, 0x3F};
int shape[3678];
char prunTrn[3678];
char prunTws[3678];
int sol[16];
int sollen;
int goalIdx = 7191405;

- (id)init {
    if(self = [super init]) {
        int count = 0;
        for (int i=0; i<28561; i++) {
			int dr = halfLayer[i % 13];
			int dl = halfLayer[i / 13 % 13];
			int ur = halfLayer[i / 13 / 13 % 13];
			int ul = halfLayer[i / 13 / 13 / 13];
			int value = ul<<18|ur<<12|dl<<6|dr;
			if ([DCTUtils bitCount:value] == 16) {
				shape[count++] = value;
			}
		}
    }
    for (int i = 0; i < 3678; i++) {
        prunTrn[i] = -1;
        prunTws[i] = -1;
    }
    prunTrn[[self getShape2Idx:goalIdx]] = 0;
    for(int d=0; d<14; d++) {
        for (int i = 0; i < 3678; i++) {
            if (prunTrn[i] == d) {
                int state = shape[i];
                // twist
                if ([self isTwistable:state]) {
                    int next = [self twist:state];
                    int temp = [self getShape2Idx:next];
                    if (prunTrn[temp] == -1) {
                        prunTrn[temp] = d + 1;
                    }
                }
                // rotate top
                int nextTop = shape[i];
                for (int j = 0; j < 11; j++) {
                    nextTop = [self rotateTop:nextTop];
                    if([self isTwistable:nextTop]){
                        int temp = [self getShape2Idx:nextTop];
                        if (prunTrn[temp] == -1) {
                            prunTrn[temp] = d + 1;
                        }
                    }
                }
                // rotate bottom
                int nextBottom = shape[i];
                for (int j = 0; j < 11; j++) {
                    nextBottom = [self rotateBottom:nextBottom];
                    if([self isTwistable:nextBottom]){
                        int temp = [self getShape2Idx:nextBottom];
                        if (prunTrn[temp] == -1) {
                            prunTrn[temp] = d + 1;
                        }
                    }
                }
            }
        }
    }
    prunTws[1170] = prunTws[1192] = prunTws[2640] = prunTws[2662] = 0;
    for(int d=0; d<7; d++) {
        //int count = 0;
        for(int i=0; i<3678; i++)
            if(prunTws[i] == d) {
                int next = [self twist:shape[i]];
                if(prunTws[[self getShape2Idx:next]] == -1) {
                    prunTws[[self getShape2Idx:next]] = d+1;
                    //count++;
                    for(int a=0; a<13; a++) {
                        for(int b=0; b<13; b++) {
                            if([self isTwistable:next]) {
                                int temp = [self getShape2Idx:next];
                                if(prunTws[temp] == -1) {
                                    prunTws[temp] = d+1;
                                    //count++;
                                }
                            }
                            next = [self rotateBottom:next];
                        }
                        next = [self rotateTop:next];
                    }
                }
            }
        //System.out.println(d+1+" "+count);
    }
    return self;
}

- (int)getShape2Idx:(int)shp {
    return [DCTUtils binarySearch:shape ti:3678 key:shp];
}

- (int)rotate:(int)layer {
    return ((layer << 1) & 0xFFE) | ((layer >> 11) & 1);
}

- (int)getTop:(int)index {
    return index & 0xFFF;
}

- (int)getBottom:(int)index {
    return (index >> 12) & 0xFFF;
}

- (int)rotateTop:(int)idx {
    return ([self getBottom:idx] << 12) | [self rotate:[self getTop:idx]];
}

- (int)rotateBottom:(int)idx {
    return ([self rotate:[self getBottom:idx]] << 12) | [self getTop:idx];
}

- (int)twist:(int)idx {
    int newTop = ([self getTop:idx] & 0xF80) | ([self getBottom:idx] & 0x7F);
    int newBottom = ([self getBottom:idx] & 0xF80) | ([self getTop:idx] & 0x7F);
    return (newBottom << 12) | newTop;
}

- (bool)isTwistable:(int)idx {
    int top = [self getTop:idx];
    int bottom = [self getBottom:idx];
    return (top & (1 << 0)) != 0 && (top & (1 << 6)) != 0 && (bottom & (1 << 0)) != 0 && (bottom & (1 << 6)) != 0;
}

- (int)applyMove:(int)state m:(NSString *)move {
    if([move isEqualToString:@"/"]) {
        state = [self twist:state];
    } else if(move.length != 0) {
        NSArray *s = [[DCTUtils substring:move s:1 e:move.length-1] componentsSeparatedByString:@","];
        int top = [[s objectAtIndex:0] intValue];
        for(int i=0; i<top+12; i++)
            state = [self rotateTop:state];
        int bottom = [[s objectAtIndex:1] intValue];
        for(int i=0; i<bottom+12; i++)
            state = [self rotateBottom:state];
    }
    return state;
}

- (int)applySequence:(NSString *)sequence {
    int state = goalIdx;
    NSArray *seq = [sequence componentsSeparatedByString:@" "];
    for(int i=0; i<seq.count; i++) {
        state = [self applyMove:state m:[seq objectAtIndex:i]];
    }
    return state;
}

- (bool)searchTws:(int)shape d:(int)d l:(int)lm {
    if(d==0) return shape == goalIdx;//prunTws[getShape2Idx(shape)] == 0;
    if(prunTws[[self getShape2Idx:shape]] > d) return false;
    //top move
    for(int i=0; i<12; i++) {
        if(i!=0) sol[sollen++] = i;
        //bottom move
        for(int j=0; j<12; j++) {
            if(j!=0) sol[sollen++] = -j;
            //twist
            if((lm!=0 || (i!=0 || j!=0)) && [self isTwistable:shape]) {
                int next = [self twist:shape];
                sol[sollen++] = 0;
                if([self searchTws:next d:(d-1) l:0]) {
                    return true;
                }
                sollen--;
            }
            if(j!=0) sollen--;
            shape = [self rotateBottom:shape];
        }
        if(i!=0) sollen--;
        shape = [self rotateTop:shape];
    }
    return false;
}

- (NSString *)move2string {
    NSMutableString *sb = [NSMutableString string];
    int top = 0, bottom = 0;
    for(int i=0; i<sollen; i++) {
        int val = sol[i];
        if (val > 0) {
            top = (val > 6) ? (val-12) : val;
        } else if (val < 0) {
            bottom = (val < -6) ? (-12-val) : -val;
        } else {
            if (top == 0 && bottom == 0) {
                [sb appendString:@" / "];
            } else {
                [sb appendFormat:@"(%d,%d) / ", top, bottom];
            }
            top = bottom = 0;
        }
    }
    if(top!=0 || bottom!=0) {
        [sb appendFormat:@"(%d,%d)", top, bottom];
    }
    return sb;
}

- (NSString *)solveTrn:(NSString *)scr {
    int state = [self applySequence:scr];
    NSMutableString *seq = [NSMutableString string];
    while (prunTrn[[self getShape2Idx:state]] > 0) {
        // twist
        if ([self isTwistable:state]) {
            int next = [self twist:state];
            if (prunTrn[[self getShape2Idx:next]] == prunTrn[[self getShape2Idx:state]] - 1) {
                [seq appendString:@"/ "];
                state = next;
            }
        }
        // rotate top
        int x = 0;
        int nextTop = state;
        for (int i = 0; i < 12; i++) {
            int temp = [self getShape2Idx:nextTop];
            if (temp>=0 && prunTrn[temp] == prunTrn[[self getShape2Idx:state]] - 1) {
                x = i;
                state = nextTop;
                break;
            }
            nextTop = [self rotateTop:nextTop];
        }
        // rotate bottom
        int y = 0;
        int nextBottom = state;
        for (int j = 0; j < 12; j++) {
            int temp = [self getShape2Idx:nextBottom];
            if (temp>=0 && prunTrn[temp] == prunTrn[[self getShape2Idx:state]] - 1) {
                y = j;
                state = nextBottom;
                break;
            }
            nextBottom = [self rotateBottom:nextBottom];
        }
        if (x != 0 || y != 0) {
            [seq appendFormat:@"(%d,%d) ", (x <= 6 ? x : x - 12), (y <= 6 ? y : y - 12)];
        }
    }
    return [NSString stringWithFormat:@"\n%@", seq];
}

- (NSString *)solveTws:(NSString *)scr {
    int state = [self applySequence:scr];
    sollen = 0;
    for(int d=0; d<20; d++) {
        if([self searchTws:state d:d l:-1])
            return [NSString stringWithFormat:@"\n%@", [self move2string]];
    }
    return @"";
}
@end
