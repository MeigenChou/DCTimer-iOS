//
//  DCTUtils.m
//  DCTimer
//
//  Created by MeigenChou on 13-12-31.
//
//

#import "DCTUtils.h"
#import "sys/utsname.h"

@implementation DCTUtils
extern int accuracy;
extern NSInteger timeForm;

+ (NSString *)replace:(NSString *)s str:(NSString *)r with:(NSString *)t {
    NSMutableString *string = [NSMutableString stringWithString:s];
    NSRange range = NSMakeRange(0, [s length]);
    [string replaceOccurrencesOfString:r withString:t options:NSCaseInsensitiveSearch range:range];
    return string;
}

+ (int)indexOf:(NSString *)s c:(char)c {
    NSString *idx = [NSString stringWithFormat:@"%c", c];
    NSRange rang = [s rangeOfString:idx];
    return (int)rang.location;
}

+ (NSString *)substring:(NSString *)s s:(int)start e:(int)end {
    return [s substringWithRange:NSMakeRange(start, end - start)];
}

+ (NSString *)getString:(NSString *)str {
    return NSLocalizedString(str, @"");
}

+ (int)binarySearch:(int[])a ti:(int)toIndex key:(int)key {
    int low = 0;
	int high = toIndex - 1;
	while (low <= high) {
		int mid = (low + high) >> 1;
		int midVal = a[mid];
		if (midVal < key)
			low = mid + 1;
		else if (midVal > key)
			high = mid - 1;
		else
			return mid;
	}
	return -(low + 1);
}

+ (int)bitCount:(int)i {
	// HD, Figure 5-2
	i = i - ((i >> 1) & 0x55555555);
	i = (i & 0x33333333) + ((i >> 2) & 0x33333333);
	i = (i + (i >> 4)) & 0x0f0f0f0f;
	i = i + (i >> 8);
	i = i + (i >> 16);
	return i & 0x3f;
}

+ (void)sort:(double[])ary l:(int)lo h:(int)hi {
    if(lo >= hi) return;
    int pivot = ary[lo], i = lo, j = hi;
    while (i < j) {
        while (i<j && ary[j]>=pivot) j--;
        ary[i] = ary[j];
        while (i<j && ary[i]<=pivot) i++;
        ary[j] = ary[i];
    }
    ary[i] = pivot;
    [DCTUtils sort:ary l:lo h:i-1];
    [DCTUtils sort:ary l:i+1 h:hi];
}

+ (BOOL)isPad {
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

+ (BOOL)isPhone {
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
}

+ (BOOL)isOS7 {
    return [[UIDevice currentDevice].systemVersion floatValue] >= 7.0;
}

+ (CGSize)getFrame {
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    return frame.size;
}

+ (CGSize)getBounds {
    CGRect frame = [[UIScreen mainScreen] bounds];
    return frame.size;
}

+ (NSArray *)getScrType {
    NSArray *scrType = [[NSArray alloc] initWithObjects:[DCTUtils getString:@"c2"], [DCTUtils getString:@"c3"], [DCTUtils getString:@"c4"], [DCTUtils getString:@"c5"], [DCTUtils getString:@"c6"], [DCTUtils getString:@"c7"], [DCTUtils getString:@"mx"], [DCTUtils getString:@"py"], [DCTUtils getString:@"sq"], [DCTUtils getString:@"cl"], [DCTUtils getString:@"sk"], @"LxMxN", @"Cmetrick", [DCTUtils getString:@"gr"], @"Siamese cube", @"15 puzzle", [DCTUtils getString:@"ot"], [DCTUtils getString:@"3s"], [DCTUtils getString:@"bd"], [DCTUtils getString:@"ms"], nil];
    return scrType;
}

+ (CGFloat)getScreenWidth {
    CGFloat screenWidth;
    screenWidth = [UIScreen mainScreen].applicationFrame.size.width;
    if (screenWidth == 748.0f) {
        screenWidth = 1024.0f;
    }
    return screenWidth;
}

+ (float)heightForString:(NSString *)value fontSize:(float)fontSize {
    CGSize size = [value sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake([self getScreenWidth] - 20, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    //CGSize sizeToFit = [value sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:UILineBreakModeCharacterWrap];//此处的换行类型（lineBreakMode）可根据自己的实际情况进行设置
    if(size.height < 24) return 44.0;
    return size.height+20;
}

+ (NSString *)contime:(int)hour m:(int)min s:(int)sec ms:(int)msec {
    NSMutableString *time = [NSMutableString string];
    if(hour==0) {
        if(min==0) [time appendFormat:@"%d", sec];
        else {
            if(sec<10) [time appendFormat:@"%d:0%d", min, sec];
            else [time appendFormat:@"%d:%d", min, sec];
        }
    }
    else {
        [time appendFormat:@"%d%@%d%@%d", hour, min<10?@":0":@":", min, sec<10?@":0":@":", sec];
    }
    if(accuracy == 0) {
        if(msec<10) [time appendFormat:@".00%d", msec];
        else if(msec<100) [time appendFormat:@".0%d", msec];
        else [time appendFormat:@".%d", msec];
    } else {
        if(msec<10) [time appendFormat:@".0%d", msec];
        else [time appendFormat:@".%d", msec];
    }
    return time;
}

+ (NSString *)distime:(int)i {
    bool m = i < 0;
    if(m) i = -i;
    int msec = i % 1000;
    if(accuracy == 1) msec /= 10;
    int sec = i/1000;
    int min = 0, hour = 0;
    if(timeForm < 2) {
        min = sec / 60;
        sec %= 60;
        if(timeForm < 1) {
            hour = min / 60;
            min %= 60;
        }
    }
    NSString *time = [[NSString alloc] initWithFormat:@"%@%@", m?@"-":@"", [DCTUtils contime:hour m:min s:sec ms:msec]];
    return time;
}

+ (NSString *)convStr:(NSString *)s {
    if(s == nil || s.length == 0 || [s isEqualToString:@"0"]) return @"Error";
    NSMutableString *sb = [NSMutableString string];
    int dot = 0, colon = 0, num = 0;
    bool dbc = false;
    for(int i=0; i<s.length; i++) {
        char c = [s characterAtIndex:i];
        if(c >= '0' && c <= '9') {
            [sb appendFormat:@"%c", c];
            num++;
        }
        if(c == '.' && dot < 1) {
            [sb appendString:@"."];
            dot++;
            dbc = true;
        }
        if(c == ':' && colon < 2 && !dbc) {
            [sb appendString:@":"];
            colon++;
        }
    }
    if(num == 0) return @"Error";
    [sb insertString:[NSString stringWithFormat:@"%d%d", dot, colon] atIndex:0];
    return sb;
}

+ (int)convTime:(NSString *)s {
    char c = [s characterAtIndex:1];
    if(c == '0') return (int)([[s substringFromIndex:2] doubleValue]*1000);
    int hour, min;
    double sec;
    NSArray *time = [[s substringFromIndex:2] componentsSeparatedByString:@":"];
    if(c == '1') {
        hour = 0;
        min = [[time objectAtIndex:0] length]==0 ? 0 : [[time objectAtIndex:0] intValue];
        if(time.count == 1) sec = 0;
        else sec = [[time objectAtIndex:1] length]==0 ? 0 : [[time objectAtIndex:1] doubleValue];
    } else {
        hour = [[time objectAtIndex:0] length]==0 ? 0 : [[time objectAtIndex:0] intValue];
        if(time.count == 1) min = 0;
        else min = [[time objectAtIndex:1] length]==0 ? 0 : [[time objectAtIndex:1] intValue];
        if(time.count < 3) sec = 0;
        else sec = [[time objectAtIndex:2] length]==0 ? 0 : [[time objectAtIndex:2] doubleValue];
    }
    return (int) ((hour*3600 + min*60 + sec) * 1000);
}

+ (NSString *)getFilePath:(NSString *)file {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    return [docDir stringByAppendingPathComponent:file];
}

+ (NSString *)getDeviceString {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

+ (NSString *)getAppVersion {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return [NSString stringWithFormat:@"v%@", version];
}
@end
