//
//  Im.m
//  DCTimer Solvers
//
//  Created by MeigenChou on 13-2-18.
//  Copyright (c) 2013年 MeigenChou. All rights reserved.
//

#import "Im.h"

@implementation Im

int fact[13] = {1, 1, 2, 6, 24, 120, 720, 5040, 40320, 362880, 3628800, 39916800, 479001600};
int Cnk[25][25];

+ (void) initCnk {
    static bool iniCnk = false;
    if(!iniCnk) {
        for (int i=0; i<25; i++) {
            Cnk[i][0] = Cnk[i][i] = 1;
            for (int j=1; j<i; j++) {
                Cnk[i][j] = Cnk[i-1][j-1] + Cnk[i-1][j];
            }
        }
        iniCnk = true;
    }
}

+(void)set8Perm:(int[])arr i:(int)idx {
    int val = 0x76543210;
    for (int i=0; i<7; i++) {
        int p = fact[7-i];
        int v = idx / p;
        idx -= v*p;
        v <<= 2;
        arr[i] = (val >> v) & 07;
        int m = (1 << v) - 1;
        val = (val & m) + ((val >> 4) & ~m);
    }
    arr[7] = val;
}

+(int)get8Perm:(int[])arr {
    int idx = 0;
    int val = 0x76543210;
    for (int i=0; i<7; i++) {
        int v = arr[i] << 2;
        idx = (8 - i) * idx + ((val >> v) & 07);
        val -= 0x11111110 << v;
    }
    return idx;
}

/*int get8Comb(int arr[]) {
	int idx = 0, r = 4;
	for (int i=0; i<8; i++) {
		if (arr[i] >= 4) {
			idx += Cnk[7-i][r--];
		}
	}
	return idx;
}*/

+(void) cir:(int[])arr a:(int)a b:(int)b c:(int)c d:(int)d {
    int temp=arr[a]; arr[a]=arr[b]; arr[b]=arr[c]; arr[c]=arr[d]; arr[d]=temp;
}

+(void) cir2:(int[])arr a:(int)a b:(int)b c:(int)c d:(int)d {
    int temp=arr[a]; arr[a]=arr[b]; arr[b]=temp;
    temp=arr[c]; arr[c]=arr[d]; arr[d]=temp;
}

+(void) cir:(int[])arr a:(int)a b:(int)b {
    int temp=arr[a]; arr[a]=arr[b]; arr[b]=temp;
}

+(void) cir3:(int[])arr a:(int)a b:(int)b c:(int)c {
    int temp=arr[a]; arr[a]=arr[b]; arr[b]=arr[c]; arr[c]=temp;
}

// permutation
+(int) permToIdx:(int[])p l:(int)len {
    int idx = 0;
    for(int i=0; i<len-1; i++) {
        idx *= len-i;
        for(int j=i+1; j<len; j++) {
            if(p[i] > p[j]) idx++;
        }
    }
    return idx;
}

+(void) idxToPerm:(int[])p i:(int)idx l:(int)l {
    p[l-1] = 0;
    for(int i=l-2; i>=0; i--) {
        p[i] = idx % (l-i);
        idx /= l-i;
        for(int j=i+1; j<l; j++)
            if(p[j] >= p[i]) p[j]++;
    }
}

// even permutation
+(int) evenPermToIdx:(int[])p l:(int)len {
    int index = 0;
    for (int i = 0; i < len - 2; i++) {
        index *= len - i;
        for (int j = i + 1; j < len; j++)
            if (p[i] > p[j]) index++;
    }
    return index;
}

+(void) idxToEvenPerm:(int[])p i:(int)idx l:(int)len {
    int sum = 0;
    p[len - 1] = 1;
    p[len - 2] = 0;
    for (int i = len - 3; i >= 0; i--) {
        p[i] = idx % (len - i);
        sum += p[i];
        idx /= len - i;
        for (int j = i + 1; j < len; j++)
            if (p[j] >= p[i]) p[j]++;
    }
    if (sum % 2 != 0) {
        int temp = p[len - 1];
        p[len - 1] = p[len - 2];
        p[len - 2] = temp;
    }
}

// orientation
+(int)oriToIdx:(int[])o n:(int)n l:(int)len {
    int index = 0;
    for (int i = 0; i < len; i++)
        index = n * index + (o[i] % n);
    return index;
}

+(void)idxToOri:(int[])o i:(int)idx n:(int)n l:(int)len {
    for (int i = len - 1; i >= 0; i--) {
        o[i] = idx % n;
        idx /= n;
    }
}

// zero sum orientation
+(int) zsOriToIdx:(int[])o n:(int)n l:(int)len {
    int index = 0;
    for (int i = 0; i < len - 1; i++)
        index = n * index + (o[i] % n);
    return index;
}

+(void) idxToZsOri:(int[])o i:(int)idx n:(int)n l:(int)len {
    o[len - 1] = 0;
    for (int i = len - 2; i >= 0; i--) {
        o[i] = idx % n;
        idx /= n;
        o[len - 1] += o[i];
    }
    o[len - 1] = (n - o[len - 1] % n) % n;
}

// combinations
int nChooseK(int n, int k) {
    int value = 1;
    for (int i = 0; i < k; i++) {
        value *= n - i;
    }
    for (int i = 0; i < k; i++) {
        value /= k - i;
    }
    return value;
}

+(int) combToIdx:(bool[])comb k:(int)k l:(int)len {
    int index = 0;
    for (int i = len - 1; i >= 0 && k > 0; i--) {
        if (comb[i]) {
            index += nChooseK(i, k--);
        }
    }
    return index;
}

+(void) idxToComb:(bool[])comb i:(int)idx k:(int)k l:(int)len {
    //boolean[] combination = new boolean[length];
    for(int i=0; i<len; i++)comb[i] = false;
    for (int i = len - 1; i >= 0 && k >= 0; i--) {
        if (idx >= nChooseK(i, k)) {
            comb[i] = true;
            idx -= nChooseK(i, k--);
        }
    }
}
@end
