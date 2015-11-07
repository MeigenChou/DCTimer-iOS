//
//  DCTUtils.m
//  DCTimer
//
//  Created by MeigenChou on 13-12-31.
//
//

#import "DCTUtils.h"

@implementation DCTUtils
extern int accuracy;
extern bool clkFormat;

+ (NSString *)replace:(NSString *)s str:(NSString *)r with:(NSString *)t {
    NSMutableString *string = [NSMutableString stringWithString:s];
    NSRange range = NSMakeRange(0, [s length]);
    [string replaceOccurrencesOfString:r withString:t options:NSCaseInsensitiveSearch range:range];
    return string;
}

+ (int)indexOf:(NSString *)s c:(char)c {
    NSString *idx = [NSString stringWithFormat:@"%c", c];
    NSRange rang = [s rangeOfString:idx];
    return rang.location;
}

+ (NSString *)substring:(NSString *)s s:(int)start e:(int)end {
    return [s substringWithRange:NSMakeRange(start, end - start)];
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
    NSArray *scrType = [[NSArray alloc] initWithObjects:NSLocalizedString(@"c2", @""), NSLocalizedString(@"c3", @""), NSLocalizedString(@"c4", @""), NSLocalizedString(@"c5", @""), NSLocalizedString(@"c6", @""), NSLocalizedString(@"c7", @""), NSLocalizedString(@"mx", @""), NSLocalizedString(@"py", @""), NSLocalizedString(@"sq", @""), NSLocalizedString(@"cl", @""), NSLocalizedString(@"sk", @""), @"LxMxN", @"Cmetrick", NSLocalizedString(@"gr", @""), @"Siamese cube", @"15 puzzle", NSLocalizedString(@"ot", @""), NSLocalizedString(@"3s", @""), NSLocalizedString(@"bd", @""), NSLocalizedString(@"ms", @""), nil];
    return scrType;
}

+ (CGFloat) getScreenWidth {
    CGFloat screenWidth;
    screenWidth = [UIScreen mainScreen].applicationFrame.size.width;
    if (screenWidth == 748.0f) {
        screenWidth = 1024.0f;
    }
    return screenWidth;
}

+ (float) heightForString:(NSString *)value fontSize:(float)fontSize {
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
    bool m = i<0;
    if(m)i = -i;
    int msec=i%1000;
    if(accuracy == 1)msec/=10;
    int sec=clkFormat?(i/1000)%60:i/1000;
    int min=clkFormat?(i/60000)%60:0;
    int hour=clkFormat?i/3600000:0;
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
@end
