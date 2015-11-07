//
//  DCTUtils.h
//  DCTimer
//
//  Created by MeigenChou on 13-12-31.
//
//

#import <Foundation/Foundation.h>

@interface DCTUtils : NSObject

+ (NSString *)replace:(NSString *)s str:(NSString *)r with:(NSString *)t;
+ (int)indexOf:(NSString *)s c:(char)c;
+ (NSString *)substring:(NSString *)s s:(int)start e:(int)end;
+ (NSString *)getString:(NSString *)str;
+ (int)binarySearch:(int[])a ti:(int)toIndex key:(int)key;
+ (int)bitCount:(int)i;
+ (void)sort:(double[])ary l:(int)lo h:(int)hi;
+ (BOOL)isPad;
+ (BOOL)isPhone;
+ (BOOL)isOS7;
+ (CGSize)getFrame;
+ (CGSize)getBounds;
+ (NSArray *)getScrType;
+ (float)heightForString:(NSString *)value fontSize:(float)fontSize;
+ (NSString *)distime:(int)i;
+ (NSString *)convStr:(NSString *)s;
+ (int)convTime:(NSString *)s;
+ (NSString *)getFilePath:(NSString *)file;
+ (NSString *)getDeviceString;
+ (NSString *)getAppVersion;

@end
