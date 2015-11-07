//
//  DCTData.m
//  DCTimer
//
//  Created by MeigenChou on 14-1-18.
//
//

#import "DCTData.h"
#import <sqlite3.h>
#import "DCTUtils.h"

@interface DCTData ()
@property (nonatomic, strong) NSMutableArray *resultId;
@end

@implementation DCTData
@synthesize resultId;
sqlite3 *database;
int dbLastId = 0;
int sesLastId = 0;
int crntSesId = 0;
NSMutableArray *sesData;
NSMutableArray *resList, *penList, *scrList, *dateList;
const int MAX_VALUE = 2147483647;
const int MIN_VALUE = -2147483647;
int maxIdx, minIdx;
int sessionMean, sessionSD;
int sessionAvg, sessionASD;
int numcube=0, solved=0;
int curAvg[4], bestAvg[4], bestAvgIdx[4];
int numOfAvg[4] = {5, 12, 50, 100};
int curMean3, bestMean3, bestMeanIdx;
extern NSInteger accuracy;
extern BOOL prntScr;
bool issChange = true;

- (id)init {
    if(self = [super init]) {
        if(!resList) {
            resList = [[NSMutableArray alloc] init];
            penList = [[NSMutableArray alloc] init];
            scrList = [[NSMutableArray alloc] init];
            dateList = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

+ (DCTData *)dbh {
    static DCTData *dbh = nil;
    if(!dbh) {
        dbh = [[DCTData alloc] init];
    }
    return dbh;
}

- (NSString *) openDB {
    if(sqlite3_open([[DCTUtils getFilePath:@"spdcube.sqlite"] UTF8String], &database) != SQLITE_OK) {
        //sqlite3_close(database);
        return @"fopn";
    }
    NSString *createSQL = @"create table if not exists sessiontb (rowid integer, name text)";
    char *errorMsg;
    int mark = 0;
    if(sqlite3_exec(database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        NSLog(@"failed %s", errorMsg);
        mark |= 1;
    }
    createSQL = @"create table if not exists resulttb (id integer, sesid integer, rest integer, resp integer, scr text, date text, note text)";
    if(sqlite3_exec(database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        NSLog(@"failed %s", errorMsg);
        mark |= 2;
    }
    //createSQL = @"create table if not exists sestypetb (id integer, type integer)";
    //if(sqlite3_exec(database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
    //    NSLog(@"failed %s", errorMsg);
    //    mark |= 4;
    //}
    if(mark != 0) return @"fctb";
    return @"OK";
}

- (void)getSessions {
    NSString *msg = [self openDB];
    if([msg hasPrefix:@"f"]) {
        NSLog(@"failed open");
        return;
    }
    NSString *query = @"select rowid, name from sessiontb";
    sqlite3_stmt *statement;
    if(sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        int row = 0;
        sesData = [[NSMutableArray alloc] init];
        while (sqlite3_step(statement) == SQLITE_ROW) {
            row = sqlite3_column_int(statement, 0);
            char *na = (char *)sqlite3_column_text(statement, 1);
            NSString *name = [[NSString alloc] initWithUTF8String:na];
            [sesData addObject:[[NSArray alloc] initWithObjects:@(row), name, nil]];
        }
        sesLastId = row;
        sqlite3_finalize(statement);
    }
}

- (int)getSessionCount {
    return (int)sesData.count;
}

- (void)getSessionName:(NSMutableArray *)ses {
    if(sesData.count!=0) {
        for(int i=0; i<sesData.count; i++) {
            [ses addObject:[[sesData objectAtIndex:i] objectAtIndex:1]];
        }
    }
}

- (void)query:(int)sesIdx {
    if(sesIdx!=0) sesIdx = [[[sesData objectAtIndex:sesIdx-1] objectAtIndex:0] intValue];
    crntSesId = sesIdx;
    [self clearTime];
    NSString *query = @"select id, sesid, rest, resp, scr, date from resulttb";
    sqlite3_stmt *statement;
    if(sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        int row = 0;
        self.resultId = [[NSMutableArray alloc] init];
        while (sqlite3_step(statement) == SQLITE_ROW) {
            row = sqlite3_column_int(statement, 0);
            int ses = sqlite3_column_int(statement, 1);
            if(ses == sesIdx) {
                int rest = sqlite3_column_int(statement, 2);
                int resp = sqlite3_column_int(statement, 3);
                char *sc = (char *)sqlite3_column_text(statement, 4);
                char *da = (char *)sqlite3_column_text(statement, 5);
                NSString *scr = [[NSString alloc] initWithUTF8String:sc];
                NSString *date = [[NSString alloc] initWithUTF8String:da];
                [self addTime:rest penalty:resp scramble:scr datetime:date];
                [self.resultId addObject:@(row)];
            }
        }
        dbLastId = row;
        NSLog(@"data:%d lastId:%d", (int)self.resultId.count, dbLastId);
        sqlite3_finalize(statement);
    }
}

- (void)insertTime:(int)time pen:(int)pen scr:(NSString *)s date:(NSString *)da {
    [self.resultId addObject:[NSNumber numberWithInt:++dbLastId]];
    char *update = "insert into resulttb (id, sesid, rest, resp, scr, date) values (?, ?, ?, ?, ?, ?);";
    sqlite3_stmt *stmt;
    if(sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_int(stmt, 1, dbLastId);
        sqlite3_bind_int(stmt, 2, crntSesId);
        sqlite3_bind_int(stmt, 3, time);
        sqlite3_bind_int(stmt, 4, pen);
        sqlite3_bind_text(stmt, 5, [s UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 6, [da UTF8String], -1, NULL);
    }
    if(sqlite3_step(stmt) != SQLITE_DONE) {
        NSLog(@"failed insert");
    }
    sqlite3_finalize(stmt);
}

- (void)addSession:(NSString *)name {
    [sesData addObject:[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:++sesLastId], name, nil]];
    char *insert = "insert into sessiontb (rowid, name) values (?, ?);";
    sqlite3_stmt *stmt;
    if(sqlite3_prepare_v2(database, insert, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_int(stmt, 1, sesLastId);
        sqlite3_bind_text(stmt, 2, [name UTF8String], -1, NULL);
    }
    if(sqlite3_step(stmt) != SQLITE_DONE) {
        NSLog(@"failed insert");
    }
    sqlite3_finalize(stmt);
}

- (void)deleteTime:(int)idx {
    char *delete = "delete from resulttb where id=?";
    sqlite3_stmt *stmt;
    if(sqlite3_prepare_v2(database, delete, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_int(stmt, 1, [[self.resultId objectAtIndex:idx] intValue]);
        NSLog(@"del time %d %d", (int)self.resultId.count, [[self.resultId objectAtIndex:idx] intValue]);
    }
    if(sqlite3_step(stmt) != SQLITE_DONE) {
        NSLog(@"failed delete time");
    }
    sqlite3_finalize(stmt);
    [self.resultId removeObjectAtIndex:idx];
}

- (void)deleteSession:(int)idx {
    int sesId =[[[sesData objectAtIndex:(idx-1)] objectAtIndex:0] intValue];
    [sesData removeObjectAtIndex:(idx-1)];
    char *delete = "delete from sessiontb where rowid=?";
    sqlite3_stmt *stmt;
    if(sqlite3_prepare_v2(database, delete, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_int(stmt, 1, sesId);
    }
    if(sqlite3_step(stmt) != SQLITE_DONE) {
        NSLog(@"failed delete ses");
    }
    sqlite3_finalize(stmt);
}

- (void)updateTime:(int)idx pen:(int)pen {
    char *update = "update resulttb set resp=? where id=?";
    sqlite3_stmt *stmt;
    if(sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_int(stmt, 1, pen);
        sqlite3_bind_int(stmt, 2, [[self.resultId objectAtIndex:idx] intValue]);
    }
    if(sqlite3_step(stmt) != SQLITE_DONE) {
        NSLog(@"failed update time");
    }
    sqlite3_finalize(stmt);
}

- (void)updateSession:(int)idx name:(NSString *)name {
    NSArray *temp = [[NSArray alloc] initWithObjects:[[sesData objectAtIndex:idx-1] objectAtIndex:0], name, nil];
    [sesData replaceObjectAtIndex:idx-1 withObject:temp];
    if(idx!=0) idx = [[[sesData objectAtIndex:idx-1] objectAtIndex:0] intValue];
    char *update = "update sessiontb set name=? where rowid=?";
    sqlite3_stmt *stmt;
    if(sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, [name UTF8String], -1, NULL);
        sqlite3_bind_int(stmt, 2, idx);
    }
    if(sqlite3_step(stmt) != SQLITE_DONE) {
        NSLog(@"failed update ses");
    }
    sqlite3_finalize(stmt);
}

- (void)clearSession:(int)sesIdx {
    if(sesIdx!=0) sesIdx = [[[sesData objectAtIndex:sesIdx-1] objectAtIndex:0] intValue];
    char *delete = "delete from resulttb where sesid=?";
    sqlite3_stmt *stmt;
    if(sqlite3_prepare_v2(database, delete, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_int(stmt, 1, sesIdx);
    }
    if(sqlite3_step(stmt) != SQLITE_DONE) {
        NSLog(@"failed clear");
    }
    sqlite3_finalize(stmt);
    [self clearTime];
}

- (void) closeDB {
    sqlite3_close(database);
}


+ (NSString *)distimeAtIndex:(int)idx dt:(bool)d {
    int p = [[penList objectAtIndex:idx] intValue];
    int r = [[resList objectAtIndex:idx] intValue];
    if(p==2) {
        if(d) return [NSString stringWithFormat:@"DNF (%@)", [DCTUtils distime:r]];
        else return @"DNF";
    }
    else if(p==1)
        return [NSString stringWithFormat:@"%@+", [DCTUtils distime:r+2000]];
    else return [DCTUtils distime:r];
}

- (void)addTime:(int)time penalty:(int)pen scramble:(NSString *)scr datetime:(NSString *)dt {
    [resList addObject:@(time)];
    [penList addObject:@(pen)];
    [scrList addObject:scr];
    [dateList addObject:dt];
    issChange = true;
    //NSLog(@"%d", resList.count);
}

- (void)clearTime {
    [resList removeAllObjects];
    [penList removeAllObjects];
    [scrList removeAllObjects];
    [dateList removeAllObjects];
    issChange = true;
}

- (int)numberOfSolves {
    return (int)resList.count;
}

- (NSString *)cubeSolves {
    return [NSString stringWithFormat:@"%d/%d", solved, numcube];
}

- (int)getPenaltyAtIndex:(int)idx {
    return [[penList objectAtIndex:idx] intValue];
}

- (void)setPenalty:(int)pen atIndex:(int)idx {
    [penList replaceObjectAtIndex:idx withObject:@(pen)];
    //[[resList objectAtIndex:idx] replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:pen]];
    issChange = true;
}

- (NSString *)getScrambleAtIndex:(int)idx {
    return [scrList objectAtIndex:idx];
}

- (NSString *)getDateAtIndex:(int)idx {
    return [dateList objectAtIndex:idx];
}

- (void)deleteTimeAtIndex:(int)idx {
    [resList removeObjectAtIndex:idx];
    [penList removeObjectAtIndex:idx];
    [scrList removeObjectAtIndex:idx];
    [dateList removeObjectAtIndex:idx];
    issChange = true;
}

- (void)getSessionStats {
    numcube = (int)resList.count;
    maxIdx = minIdx = sessionSD = -1;
    solved = 0;
    if(numcube==0) return;
    int min = MAX_VALUE;
    int max = MIN_VALUE;
    double sum = 0, sum2 = 0;
    for(int i=0; i<numcube; i++) {
        int p = [[penList objectAtIndex:i] intValue];
        if(p!=2) {
            solved++;
            int time = [[resList objectAtIndex:i] intValue] + 2000 * p;
            if(time<=min) {
                min = time;
                minIdx = i;
            }
            if(time>max) {
                max = time;
                maxIdx = i;
            }
            if(accuracy==0) {
                sum += time;
                sum2 += pow(time, 2);
            } else {
                sum += time/10;
                sum2 += pow(time/10, 2);
            }
        }
    }
    if(minIdx == -1) minIdx = numcube - 1;
    if(maxIdx == -1) maxIdx = 0;
    sessionMean = (int)(sum/solved+0.5);
    if(accuracy==1)sessionMean*=10;
    sessionSD=(int)(sqrt((sum2-sum*sum/solved)/solved));
}

- (void)getSessionAvg {
    if(numcube > 2) {
        NSMutableArray *data = [[NSMutableArray alloc] init];
        for(int i=0; i<numcube; i++) {
            int p = [[penList objectAtIndex:i] intValue];
            if(p!=2) {
                int r = [[resList objectAtIndex:i] intValue] + 2000 * p;
                [data addObject:@(r)];
            }
        }
        int trimmed = ceil(numcube/20.0);
        if(data.count < numcube - trimmed) {
            sessionAvg = MAX_VALUE;
        } else {
            double sum = 0, sum2 = 0;
            [data sortUsingSelector:@selector(compare:)];
            for(int j=trimmed; j<numcube-trimmed; j++) {
                int time = [[data objectAtIndex:j] intValue];
                if(accuracy==0) {
                    sum+=time;
                    sum2+=pow(time, 2);
                } else {
                    sum+=time/10;
                    sum2+=pow(time/10, 2);
                }
            }
            int num = numcube - 2*trimmed;
            sessionAvg = (int)(sum/num+0.5);
            if(accuracy==1)sessionAvg*=10;
            sessionASD = (int)(sqrt((sum2-sum*sum/num)/num));
        }
    }
}

- (void)getAvgs:(int)idx {
    int num = numOfAvg[idx];
    bestAvgIdx[idx] = numcube-1;
    bestAvg[idx] = MAX_VALUE;
    double sum = 0;
    if(numcube >= num) {
        int cavg;
        for(int i=numcube-1; i>=num-1; i--) {
            int nDnf=0;
            sum = 0;
            int max = MIN_VALUE;
            int min = MAX_VALUE;
            for(int j = i-num+1; j<=i; j++) {
                int p = [[penList objectAtIndex:j] intValue];
                int r = [[resList objectAtIndex:j] intValue]+2000*p;
                if(p==2) {
                    nDnf++;
                    max = MAX_VALUE;
                }
                else {
                    if(r > max) max = r;
                    if(r < min) min = r;
                    if(accuracy==0) sum += r;
                    else sum += r/10;
                }
            }
            if(nDnf>1) cavg = MAX_VALUE;
            else {
                if(nDnf!=0) max = 0;
                if(accuracy==1) {
                    max = max/10;
                    min = min/10;
                }
                sum -= min+max;
                cavg = (int)(sum/(num-2)+0.5);
                if(accuracy==1) cavg*=10;
                if(cavg < bestAvg[idx]) {
                    bestAvg[idx] = cavg; bestAvgIdx[idx] = i;
                }
            }
            if(i==numcube-1) curAvg[idx] = cavg;
        }
        //cavg = (int)(sum/(num-2)+0.5);
        
        //bestAvg[idx] = (int)(bestSum[idx]/(num-2)+0.5);
    }
}

- (void)quickSort:(NSMutableArray *)a l:(int)lo h:(int)hi {
    if(lo >= hi) return;
    int i = lo, j = hi;
    NSNumber *pivot = [a objectAtIndex:lo];
    while (i < j) {
        while (i<j && [[a objectAtIndex:j] intValue]>=[pivot intValue]) j--;
        [a replaceObjectAtIndex:i withObject:[a objectAtIndex:j]];
        while (i<j && [[a objectAtIndex:i] intValue]<=[pivot intValue]) i++;
        [a replaceObjectAtIndex:j withObject:[a objectAtIndex:i]];
    }
    [a replaceObjectAtIndex:i withObject:pivot];
    [self quickSort:a l:lo h:i-1];
    [self quickSort:a l:i+1 h:hi];
}

- (void)quickSort:(NSMutableArray *)t idx:(NSMutableArray *)i l:(int)lo0 h:(int)hi0 {
    int lo = lo0, hi = hi0;
    if (lo >= hi) return;
    bool transfer=true;
    while (lo != hi) {
        int alo = [[t objectAtIndex:lo] intValue], ahi = [[t objectAtIndex:hi] intValue];
        if (alo > ahi) {
            NSNumber *temp = [t objectAtIndex:lo];
            [t replaceObjectAtIndex:lo withObject:[t objectAtIndex:hi]];
            [t replaceObjectAtIndex:hi withObject:temp];
            temp = [i objectAtIndex:lo];
            [i replaceObjectAtIndex:lo withObject:[i objectAtIndex:hi]];
            [i replaceObjectAtIndex:hi withObject:temp];
            transfer = !transfer;
        }
        if(transfer) hi--;
        else lo++;
    }
    lo--; hi++;
    [self quickSort:t idx:i l:lo0 h:lo];
    [self quickSort:t idx:i l:hi h:hi0];
}

- (void)getAvgs20:(int)idx {
    int num = numOfAvg[idx];
    double sum = 0;
    bestAvgIdx[idx] = numcube-1;
    bestAvg[idx] = MAX_VALUE;
    int trimmed = ceil(num/20.0);
    if(numcube >= num) {
        int cavg;
        for(int i=numcube-1; i>=num-1; i--) {
            int nDnf=0;
            sum = 0;
            for(int j = i-num+1; j<=i; j++) {
                int p = [[penList objectAtIndex:j] intValue];
                if(p==2)nDnf++;
            }
            if(nDnf>trimmed) cavg = MAX_VALUE;
            else {
                NSMutableArray *data = [[NSMutableArray alloc]init];
                for(int j = i-num+1; j<=i; j++) {
                    int p = [[penList objectAtIndex:j] intValue];
                    if(p!=2) [data addObject:@([[resList objectAtIndex:j] intValue]+2000*p)];
                }
                [self quickSort:data l:0 h:(int)data.count-1];
                //[data sortUsingSelector:@selector(compare:)];
                for(int j=trimmed; j<num-trimmed; j++) {
                    sum += [[data objectAtIndex:j] intValue];
                }
                cavg = (int)(sum/(num-2*trimmed)+0.5);
                if(cavg < bestAvg[idx]) {
                    bestAvg[idx] = cavg; bestAvgIdx[idx] = i;
                }
            }
            if(i==numcube-1) curAvg[idx] = cavg;
        }
    }
}

- (NSString *)bestTime {
    return [DCTData distimeAtIndex:minIdx dt:false];
}

- (NSString *)worstTime {
    return [DCTData distimeAtIndex:maxIdx dt:false];
}

- (int) getMaxIndex {
    return maxIdx;
}

- (int) getMinIndex {
    return minIdx;
}

- (NSString *)currentAvg:(int)idx {
    int ca = curAvg[idx];
    if(ca==MAX_VALUE)return @"DNF";
    return [DCTUtils distime:ca];
}

- (NSString *)bestAvg:(int)idx {
    if(bestAvgIdx[idx]==-1)return @"DNF";
    int ba = bestAvg[idx];
    if(ba == MAX_VALUE) return @"DNF";
    return [DCTUtils distime:bestAvg[idx]];
}

- (int) bestAvgIdx:(int)idx {
    int bai = bestAvgIdx[idx];
    if(bai == -1) return numcube-1;
    return bai;
}

- (NSString *)standDev:(int)i {
    if(i<0)return @"N/A";
    if(accuracy==0)i/=10;
    return [NSString stringWithFormat:@"%d.%@%d", i/100, (i%100<10)?@"0":@"", i%100];
}

- (NSString *)getSessionMeanSD {
    if(solved==0) return @"N/A";
    else return [NSString stringWithFormat:@"%@ (σ = %@)", [DCTUtils distime:sessionMean], [self standDev:sessionSD]];
}

- (NSString *)getSessionAvgSD {
    if(numcube < 3) return @"N/A";
    if(sessionAvg == MAX_VALUE) return @"DNF";
    return [NSString stringWithFormat:@"%@ (σ = %@)", [DCTUtils distime:sessionAvg], [self standDev:sessionASD]];
}

- (void)getMean:(int)num {
    bestMeanIdx = -1;
    bestMean3 = MAX_VALUE;
    if(numcube >= num) {
        int cavg;
        for(int i=num-1; i<numcube; i++) {
            int nDnf=0;
            double sum = 0;
            for(int j = i-num+1; j<=i; j++) {
                int p = [[penList objectAtIndex:j] intValue];
                int r = [[resList objectAtIndex:j] intValue]+2000*p;
                if(p==2)nDnf++;
                else {
                    if(accuracy==0) sum+=r;
                    else sum+=r/10;
                }
            }
            if(nDnf>0){
                cavg = MAX_VALUE;
                continue;
            }
            cavg = (int)(sum/num+0.5);
            if(accuracy==1)cavg*=10;
            if(i==num-1 || cavg <= bestMean3) {
                bestMean3 = cavg; bestMeanIdx = i;
            }
        }
        curMean3 = cavg;
    }
}

- (NSString *)currentMean3 {
    if(curMean3==MAX_VALUE)return @"DNF";
    return [DCTUtils distime:curMean3];
}

- (NSString *)getBestMean3 {
    if(bestMeanIdx==-1)return @"DNF";
    return [DCTUtils distime:bestMean3];
}

- (int)getBestMeanIdx {
    if(bestMeanIdx==-1)return numcube-1;
    return bestMeanIdx;
}

- (NSString *)getMsgOfAvg:(int)idx num:(int)n {
    NSMutableString *s = [NSMutableString stringWithString:[DCTUtils getString:@"stat_title"]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString *date = [formatter stringFromDate:[NSDate date]];
    [s appendFormat:@"%@\n%@", date, [DCTUtils getString:@"stat_avg"]];
    int maxi=-1,mini=-1,dnf=0;
    int max = MIN_VALUE, min = MAX_VALUE;
    int cavg=0, csdv=-1,ind=1;
    double sum=0,sum2=0;
    bool m=false;
    for(int j=idx-n+1;j<=idx;j++) {
        int p = [[penList objectAtIndex:j] intValue];
        int r = [[resList objectAtIndex:j] intValue]+2000*p;
        if(p==2) {
            dnf++;
            max = MAX_VALUE;
            maxi = j;
        }
        else {
            if(r > max) {
                max = r;
                maxi = j;
            }
            if(r <= min) {
                min = r;
                mini = j;
            }
            if(accuracy==0) {
                sum+=r;
                sum2+=pow(r, 2);
            }
            else {
                sum+=r/10;
                sum2+=pow(r/10, 2);
            }
        }
    }
    m = dnf>1;
    if(m) {
        if(maxi==-1)maxi = idx-n+1;
        if(mini==-1)mini = idx;
        cavg = csdv = 0;
    } else {
        if(dnf!=0) max = 0;
        if(accuracy==1) {
            max = max/10;
            min = min/10;
        }
        sum -= min+max;
        sum2 -= pow(min, 2)+pow(max, 2);
        cavg = sum/(n-2)+0.5;
        if(accuracy==1)cavg*=10;
        csdv = sqrt(sum2/(n-2)-sum*sum/(n-2)/(n-2))+(accuracy?0.5:0);
    }
    [s appendFormat:@"%@ (σ = %@)\n", m?@"DNF":[DCTUtils distime:cavg], m?@"N/A":[self standDev:csdv]];
    [s appendFormat:@"%@%@\n", [DCTUtils getString:@"stat_best"], [DCTData distimeAtIndex:mini dt:false]];
    [s appendFormat:@"%@%@\n%@", [DCTUtils getString:@"stat_worst"], [DCTData distimeAtIndex:maxi dt:false], [DCTUtils getString:@"stat_list"]];
    if(!prntScr)[s appendString:@"\n"];
    for(int j=idx-n+1;j<=idx;j++) {
        if(prntScr)[s appendFormat:@"\n%d. ", ind++];
        if(j==mini || j==maxi) [s appendString:@"("];
        [s appendString:[DCTData distimeAtIndex:j dt:false]];
        if(j==mini || j==maxi) [s appendString:@")"];
        if(!prntScr && j<idx)[s appendString:@", "];
        if(prntScr) [s appendFormat:@"  %@", [scrList objectAtIndex:j]];
    }
    return s;
}

- (NSString *)getMsgOfAvg20:(int)idx num:(int)n {
    NSMutableString *s = [NSMutableString stringWithString:[DCTUtils getString:@"stat_title"]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString *date = [formatter stringFromDate:[NSDate date]];
    [s appendFormat:@"%@\n%@", date, [DCTUtils getString:@"stat_avg"]];
    int trim = ceil(n/20.0), dnf = 0;
    NSMutableArray *ts = [[NSMutableArray alloc] init], *ix = [[NSMutableArray alloc] init];
    NSMutableArray *didx = [[NSMutableArray alloc] init], *mix = [[NSMutableArray alloc] init];
    int max, min;
    int cavg=0, csdv=-1, ind=1;
    for(int j=idx-n+1;j<=idx;j++) {
        int p = [[penList objectAtIndex:j] intValue];
        int r = [[resList objectAtIndex:j] intValue]+2000*p;
        if(p==2) {
            [didx addObject:@(j)];
            dnf++;
        } else {
            [ts addObject:@(r)];
            [ix addObject:@(j)];
        }
    }
    [self quickSort:ts idx:ix l:0 h:(int)ts.count-1];
    if(n-dnf >= trim) {
        for(int j=0; j<trim; j++) [mix addObject:[ix objectAtIndex:j]];
    } else {
        for(int j=0; j<ts.count; j++) [mix addObject:[ix objectAtIndex:j]];
        for(int j=0; j<trim-n+dnf; j++) [mix addObject:[didx objectAtIndex:j]];
    }
    bool m = dnf>trim;
    min = [[mix objectAtIndex:0] intValue];
    if(m) {
        for(int j=dnf-trim; j<dnf; j++) [mix addObject:[didx objectAtIndex:j]];
    } else {
        for(int j=n-trim; j<n-dnf; j++) [mix addObject:[ix objectAtIndex:j]];
        for(int j=0; j<dnf; j++) [mix addObject:[didx objectAtIndex:j]];
        double sum=0, sum2=0;
        for(int j=trim;j<n-trim;j++) {
            if(accuracy==0)sum+=[[ts objectAtIndex:j] intValue];
            else sum+=[[ts objectAtIndex:j] intValue]/10;
            if(accuracy==0)sum2+=pow([[ts objectAtIndex:j] intValue], 2);
            else sum2+=pow([[ts objectAtIndex:j] intValue]/10, 2);
        }
        cavg = sum/(n-trim*2)+0.5;
        csdv=(int) sqrt(sum2/(n-trim*2)-sum*sum/pow(n-trim*2, 2));
        if(accuracy==1)cavg*=10;
    }
    max = [[mix objectAtIndex:mix.count-1] intValue];
    [s appendFormat:@"%@ (σ = %@)\n", m?@"DNF":[DCTUtils distime:cavg], m?@"N/A":[self standDev:csdv]];
    [s appendFormat:@"%@%@\n", [DCTUtils getString:@"stat_best"], [DCTData distimeAtIndex:min dt:false]];
    [s appendFormat:@"%@%@\n%@", [DCTUtils getString:@"stat_worst"], [DCTData distimeAtIndex:max dt:false], [DCTUtils getString:@"stat_list"]];
    for(int j=idx-n+1;j<=idx;j++) {
        if(prntScr)[s appendFormat:@"\n%d. ", ind++];
        if([mix containsObject:@(j)]) [s appendString:@"("];
        [s appendString:[DCTData distimeAtIndex:j dt:false]];
        if([mix containsObject:@(j)]) [s appendString:@")"];
        if(!prntScr && j<idx)[s appendString:@", "];
        if(prntScr) [s appendFormat:@"  %@", [scrList objectAtIndex:j]];
    }
    return s;
}

- (NSString *)getMsgOfMean3:(int)idx {
    NSMutableString *s = [NSMutableString stringWithString:[DCTUtils getString:@"stat_title"]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString *date = [formatter stringFromDate:[NSDate date]];
    [s appendFormat:@"%@\n%@", date, [DCTUtils getString:@"stat_mean"]];
    int maxi=-1,mini=-1,dnf=0;
    int max = MIN_VALUE, min = MAX_VALUE;
    int cavg=0, csdv=-1,ind=1;
    double sum=0,sum2=0;
    bool m=false;
    for(int j=idx-2;j<=idx;j++) {
        int p = [[penList objectAtIndex:j] intValue];
        int r = [[resList objectAtIndex:j] intValue]+2000*p;
        if(p==2) {
            dnf++;
            max = MAX_VALUE;
            maxi = j;
        }
        else {
            if(r > max) {
                max = r;
                maxi = j;
            }
            if(r <= min) {
                min = r;
                mini = j;
            }
            if(accuracy==0) {
                sum+=r;
                sum2+=pow(r, 2);
            }
            else {
                sum+=r/10;
                sum2+=pow(r/10, 2);
            }
        }
    }
    m = dnf>0;
    if(m) {
        if(maxi==-1)maxi = idx-2;
        if(mini==-1)mini = idx;
        cavg = csdv = 0;
    } else {
        cavg = sum/3+0.5;
        if(accuracy==1)cavg*=10;
        csdv = sqrt(sum2/3-sum*sum/9)+(accuracy?0.5:0);
    }
    [s appendFormat:@"%@ (σ = %@)\n", m?@"DNF":[DCTUtils distime:cavg], m?@"N/A":[self standDev:csdv]];
    [s appendFormat:@"%@%@\n", [DCTUtils getString:@"stat_best"], [DCTData distimeAtIndex:mini dt:false]];
    [s appendFormat:@"%@%@\n%@", [DCTUtils getString:@"stat_worst"], [DCTData distimeAtIndex:maxi dt:false], [DCTUtils getString:@"stat_list"]];
    if(!prntScr)[s appendString:@"\n"];
    for(int j=idx-2;j<=idx;j++) {
        if(prntScr)[s appendFormat:@"\n%d. ", ind++];
        [s appendString:[DCTData distimeAtIndex:j dt:false]];
        if(!prntScr && j<idx)[s appendString:@", "];
        if(prntScr) [s appendFormat:@"  %@", [scrList objectAtIndex:j]];
    }
    return s;
}

- (NSString *)getSessionMean {
    NSMutableString *s = [NSMutableString stringWithString:[DCTUtils getString:@"stat_title"]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString *date = [formatter stringFromDate:[NSDate date]];
    [s appendFormat:@"%@\n%@", date, [DCTUtils getString:@"stat_solve"]];
    [s appendFormat:@"%@\n", [self cubeSolves]];
    [s appendFormat:@"%@%@\n", [DCTUtils getString:@"ses_mean"], [self getSessionMeanSD]];
    [s appendFormat:@"%@%@\n", [DCTUtils getString:@"ses_avg"], [self getSessionAvgSD]];
    [s appendFormat:@"%@%@\n", [DCTUtils getString:@"stat_best"], [self bestTime]];
    [s appendFormat:@"%@%@\n%@", [DCTUtils getString:@"stat_worst"], [self worstTime], [DCTUtils getString:@"stat_list"]];
    if(!prntScr)[s appendString:@"\n"];
    for(int j=0; j<numcube; j++) {
        if(prntScr)[s appendFormat:@"\n%d. ", j+1];
        [s appendString:[DCTData distimeAtIndex:j dt:false]];
        if(!prntScr && j<numcube-1)[s appendString:@", "];
        if(prntScr) [s appendFormat:@"  %@", [scrList objectAtIndex:j]];
    }
    return s;
}
@end
