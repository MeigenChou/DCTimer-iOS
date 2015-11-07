//
//  Util4.m
//  DCTimer
//
//  Created by MeigenChou on 14-8-2.
//
//

#import "Util4.h"

@implementation Util4

char colorMap4to3[] = {'U', 'D', 'F', 'B', 'R', 'L'};

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
@end
