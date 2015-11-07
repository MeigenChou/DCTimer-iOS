//
//  DCTData.h
//  DCTimer
//
//  Created by MeigenChou on 14-1-18.
//
//

#import <Foundation/Foundation.h>

@interface DCTData : NSObject
- (void)getSessions;
- (void)getSessionName:(NSMutableArray *)ses;
- (void)query:(int)sesIdx;
- (void)insertTime:(int)time pen:(int)pen scr:(NSString *)s date:(NSString *)da;
- (void)addSession:(NSString *)name;
- (void)deleteTime:(int)idx;
- (void)deleteSession:(int)idx;
- (void)clearSession:(int)sesIdx;
- (void)updateTime:(int)idx pen:(int)pen;
- (void)updateSession:(int)idx name:(NSString *)name;
- (void)closeDB;

+ (NSString *)distimeAtIndex:(int)idx dt:(bool)d;
- (void)addTime:(int)time penalty:(int)pen scramble:(NSString *)scr datetime:(NSString *)dt;
- (void)clearTime;
- (int)numberOfSolves;
- (NSString *)getScrambleAtIndex:(int)idx;
- (int)getPenaltyAtIndex:(int)idx;
- (void)setPenalty:(int)pen atIndex:(int)idx;
- (NSString *)getDateAtIndex:(int)idx;
- (void)deleteTimeAtIndex:(int)idx;
- (void)getSessionStats;
- (NSString *)cubeSolves;
- (NSString *)getSessionMeanSD;
- (NSString *)bestTime;
- (NSString *)worstTime;
- (void)getAvgs:(int)idx;
- (NSString *)currentAvg:(int)idx;
- (NSString *)bestAvg:(int)idx;
- (int) bestAvgIdx:(int)idx;
- (void)getMean:(int)num;
- (NSString *)currentMean3;
- (NSString *)getBestMean3;
- (int)getBestMeanIdx;
- (int) getMaxIndex;
- (int) getMinIndex;
- (void)getSessionAvg;
- (NSString *)getSessionAvgSD;
- (void)getAvgs20:(int)idx;
- (NSString *)getMsgOfAvg:(int)idx num:(int)n;
- (NSString *)getMsgOfAvg20:(int)idx num:(int)n;
- (NSString *)getMsgOfMean3:(int)idx;
- (NSString *)getSessionMean;
@end
