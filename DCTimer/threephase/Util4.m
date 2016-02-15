//
//  Util4.m
//  DCTimer
//
//  Created by meigen on 15/10/30.
//
//

#import "Util4.h"

@implementation Util4

+(void) swap:(int[])arr a:(int)a b:(int)b c:(int)c d:(int)d k:(int)key {
    int temp;
    switch (key) {
        case 0:
            temp = arr[d];
            arr[d] = arr[c];
            arr[c] = arr[b];
            arr[b] = arr[a];
            arr[a] = temp;
            return;
        case 1:
            temp = arr[a];
            arr[a] = arr[c];
            arr[c] = temp;
            temp = arr[b];
            arr[b] = arr[d];
            arr[d] = temp;
            return;
        case 2:
            temp = arr[a];
            arr[a] = arr[b];
            arr[b] = arr[c];
            arr[c] = arr[d];
            arr[d] = temp;
            return;
    }
}

+(int) parity:(int[])arr len:(int)len {
    int parity = 0;
    for (int i=0; i<len; i++) {
        for (int j=i; j<len; j++) {
            if (arr[i] > arr[j]) {
                parity ^= 1;
            }
        }
    }
    return parity;
}

+(NSMutableArray *)tomove:(NSString *)s {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    int axis = -1;
    for (int i=0, length=(int)[s length]; i<length; i++) {
        switch ([s characterAtIndex:i]) {
            case 'U':	axis = 0;	break;
            case 'R':	axis = 3;	break;
            case 'F':	axis = 6;	break;
            case 'D':	axis = 9;	break;
            case 'L':	axis = 12;	break;
            case 'B':	axis = 15;	break;
            case 'u':	axis = 18;	break;
            case 'r':	axis = 21;	break;
            case 'f':	axis = 24;	break;
            case 'd':	axis = 27;	break;
            case 'l':	axis = 30;	break;
            case 'b':	axis = 33;	break;
            case ' ':
                if (axis != -1)
                    [arr addObject:@(axis)];
                axis = -1;
                break;
            case '2':	axis++;	break;
            case '\'':	axis+=2; break;
            case 'w':	axis+=18;	break;
            default:	continue;
        }
    }
    if (axis != -1) [arr addObject:@(axis)];
    return arr;
}
@end
