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
@property (nonatomic, strong) NSArray *dateForms;
@end

@implementation DCTData
@synthesize resultId;
@synthesize dateForms;
sqlite3 *database;
int dbLastId = 0;
int sesLastId = 0;
extern int currentSesIdx;
NSMutableArray *sesData;
NSMutableArray *resList, *penList, *scrList, *dateList;
const int MAX_VALUE = 2147483647;
const int MIN_VALUE = -2147483647;
int maxIdx, minIdx;
int sesMean, sesMSD;
int sesAvg, sesASD;
int nTotal = 0, nSolved = 0;
int curAvg[4], bestAvg[4], bestAvgIdx[4];
int numOfAvg[4] = {5, 12, 50, 100};
int curMean3, bestMean3, bestMeanIdx;
extern NSInteger accuracy;
BOOL prntScr;
bool issChange = true;
extern NSInteger dateForm;
int defScrType;

- (id)init {
    if(self = [super init]) {
        if(!resList) {
            resList = [[NSMutableArray alloc] init];
            penList = [[NSMutableArray alloc] init];
            scrList = [[NSMutableArray alloc] init];
            dateList = [[NSMutableArray alloc] init];
        }
        dateForms = [[NSArray alloc] initWithObjects:@"yyyy-MM-dd", @"MM-dd-yyyy", @"dd-MM-yyyy", nil];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        prntScr = [defaults boolForKey:@"printscr"];
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
        NSLog(@"创建分组表失败 %s", errorMsg);
        mark |= 1;
    }
    createSQL = @"create table if not exists resulttb (id integer, sesid integer, rest integer, resp integer, scr text, date text, note text)";
    if(sqlite3_exec(database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        NSLog(@"创建成绩表失败 %s", errorMsg);
        mark |= 2;
    }
    createSQL = @"create table if not exists scrtypetb (sesid integer, type integer)";
    if(sqlite3_exec(database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        NSLog(@"创建打乱表失败 %s", errorMsg);
        mark |= 4;
    }
    if(mark != 0) return @"fctb";
    return @"OK";
}

- (void)getSessions {
    NSString *msg = [self openDB];
    if([msg hasPrefix:@"f"]) {
        NSLog(@"打开数据库失败");
        return;
    }
    NSString *query = @"select rowid, name from sessiontb";
    sesData = [[NSMutableArray alloc] init];
    sqlite3_stmt *statement;
    if(sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        int row;
        while (sqlite3_step(statement) == SQLITE_ROW) {
            row = sqlite3_column_int(statement, 0);
            char *na = (char *)sqlite3_column_text(statement, 1);
            NSString *name = [[NSString alloc] initWithUTF8String:na];
            int type = -1;
            NSString *query = [NSString stringWithFormat:@"select * from scrtypetb where sesid=%d", row];
            sqlite3_stmt *stmt;
            if(sqlite3_prepare_v2(database, [query UTF8String], -1, &stmt, nil) == SQLITE_OK) {
                if(sqlite3_step(stmt) == SQLITE_ROW) {
                    type = sqlite3_column_int(stmt, 1);
                }
            }
            [sesData addObject:[[NSArray alloc] initWithObjects:@(row), name, @(type), nil]];
            sqlite3_finalize(stmt);
        }
        sesLastId = row;
    }
    defScrType = -1;
    query = @"select * from scrtypetb where sesid=0";
    if(sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        if(sqlite3_step(statement) == SQLITE_ROW) {
            defScrType = sqlite3_column_int(statement, 1);
        }
    }
    sqlite3_finalize(statement);
}

- (int)getSessionCount {
    return (int)sesData.count;
}

- (int)getSessionCount:(int)sesIdx {
    if(sesIdx > sesData.count) return 0;
    if(sesIdx!=0) sesIdx = [[[sesData objectAtIndex:sesIdx-1] objectAtIndex:0] intValue];
    NSString *sql = [NSString stringWithFormat:@"select count(*) from resulttb where sesid=%d", sesIdx];
    sqlite3_stmt *statement;
    if(sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        if(sqlite3_step(statement) == SQLITE_ROW) {
            return sqlite3_column_int(statement, 0);
        }
    }
    return 0;
}

- (NSString *)getSessionName:(int)idx {
    if(idx == 0) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        return [defaults objectForKey:@"defsesname"];
    }
    if(idx > sesData.count) return @"";
    return [[sesData objectAtIndex:idx-1] objectAtIndex:1];
}

- (void)getSessionNames:(NSMutableArray *)ses {
    if(sesData.count!=0) {
        for(int i=0; i<sesData.count; i++) {
            [ses addObject:[[sesData objectAtIndex:i] objectAtIndex:1]];
        }
    }
}

- (void)query:(int)sesIdx {
    if(sesIdx!=0) sesIdx = [[[sesData objectAtIndex:sesIdx-1] objectAtIndex:0] intValue];
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

- (int)getScrambleType:(int)sesIdx {
    if(sesIdx == 0) {
        return defScrType;
    }
    return [[[sesData objectAtIndex:sesIdx-1] objectAtIndex:2] intValue];
}

- (void)changeScrambleType:(int)type {
    if(currentSesIdx == 0)
        defScrType = type;
    else {
        NSNumber *sesId = [[sesData objectAtIndex:currentSesIdx-1] objectAtIndex:0];
        NSString *name = [[sesData objectAtIndex:currentSesIdx-1] objectAtIndex:1];
        [sesData replaceObjectAtIndex:currentSesIdx-1 withObject:[[NSArray alloc] initWithObjects:sesId, name, @(type), nil]];
    }
}

- (void)saveScrambleType:(int)type {
    sqlite3_stmt *stmt;
    int sesIdx = currentSesIdx;
    if(sesIdx != 0) sesIdx = [[[sesData objectAtIndex:sesIdx-1] objectAtIndex:0] intValue];
    int scrType = [self getScrambleType:currentSesIdx];
    //NSLog(@"打乱类型 %d %d", scrType, type);
    if(scrType == -1) {
        [self changeScrambleType:type];
        char *update = "insert into scrtypetb values (?, ?);";
        if(sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK) {
            sqlite3_bind_int(stmt, 1, sesIdx);
            sqlite3_bind_int(stmt, 2, type);
        }
        if(sqlite3_step(stmt) != SQLITE_DONE) {
            NSLog(@"插入打乱类型失败");
        }
        sqlite3_finalize(stmt);
    } else if(scrType != type) {
        [self changeScrambleType:type];
        char *update = "update scrtypetb set type=? where sesid=?";
        if(sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK) {
            sqlite3_bind_int(stmt, 1, type);
            sqlite3_bind_int(stmt, 2, sesIdx);
        }
        if(sqlite3_step(stmt) != SQLITE_DONE) {
            NSLog(@"更新打乱类型失败");
        }
        sqlite3_finalize(stmt);
    }
}

- (void)insertTime:(int)time pen:(int)pen scr:(NSString *)s date:(NSString *)da {
    [self.resultId addObject:[NSNumber numberWithInt:++dbLastId]];
    char *update = "insert into resulttb (id, sesid, rest, resp, scr, date) values (?, ?, ?, ?, ?, ?);";
    sqlite3_stmt *stmt;
    if(sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_int(stmt, 1, dbLastId);
        int session;
        if(currentSesIdx == 0) session = 0;
        else session = [[[sesData objectAtIndex:currentSesIdx-1] objectAtIndex:0] intValue];
        sqlite3_bind_int(stmt, 2, session);
        sqlite3_bind_int(stmt, 3, time);
        sqlite3_bind_int(stmt, 4, pen);
        sqlite3_bind_text(stmt, 5, [s UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 6, [da UTF8String], -1, NULL);
    }
    if(sqlite3_step(stmt) != SQLITE_DONE) {
        NSLog(@"插入时间失败");
    }
    sqlite3_finalize(stmt);
}

- (void)addSession:(NSString *)name {
    [sesData addObject:[[NSArray alloc] initWithObjects:@(++sesLastId), name, @(-1), nil]];
    char *insert = "insert into sessiontb (rowid, name) values (?, ?);";
    sqlite3_stmt *stmt;
    if(sqlite3_prepare_v2(database, insert, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_int(stmt, 1, sesLastId);
        sqlite3_bind_text(stmt, 2, [name UTF8String], -1, NULL);
    }
    if(sqlite3_step(stmt) != SQLITE_DONE) {
        NSLog(@"插入分组失败");
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
    NSNumber *sesId = [[sesData objectAtIndex:idx-1] objectAtIndex:0];
    NSNumber *type = [[sesData objectAtIndex:idx-1] objectAtIndex:2];
    [sesData replaceObjectAtIndex:idx-1 withObject:[[NSArray alloc] initWithObjects:sesId, name, type, nil]];
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

- (int)getSolved {
    return nSolved;
}

- (int)getTimeAt:(int)idx {
    if ([[penList objectAtIndex:idx] intValue] == 2) return 0;
    return [[resList objectAtIndex:idx] intValue] + 2000 * [[penList objectAtIndex:idx] intValue];
}

- (NSString *)cubeSolves {
    return [NSString stringWithFormat:@"%d/%d", nSolved, nTotal];
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
    nTotal = (int)resList.count;
    maxIdx = minIdx = sesMSD = -1;
    nSolved = 0;
    if(nTotal==0) return;
    int min = MAX_VALUE;
    int max = MIN_VALUE;
    double sum = 0, sum2 = 0;
    for(int i=0; i<nTotal; i++) {
        int p = [[penList objectAtIndex:i] intValue];
        if(p!=2) {
            nSolved++;
            int time = [[resList objectAtIndex:i] intValue] + 2000 * p;
            if(time <= min) {
                min = time;
                minIdx = i;
            }
            if(time > max) {
                max = time;
                maxIdx = i;
            }
            if(accuracy == 1) time /= 10;
            sum += time;
            sum2 += (double)time * time;
        }
    }
    if(minIdx == -1) minIdx = nTotal - 1;
    if(maxIdx == -1) maxIdx = 0;
    sesMean = round(sum / nSolved);
    if(accuracy == 1) sesMean *= 10;
    sesMSD = sqrt((sum2 - sum * sum / nSolved) / nSolved);
}

- (void)getSessionAvg {
    if(nTotal > 2) {
        NSMutableArray *data = [[NSMutableArray alloc] init];
        for(int i=0; i<nTotal; i++) {
            int p = [[penList objectAtIndex:i] intValue];
            if(p!=2) {
                int r = [[resList objectAtIndex:i] intValue] + 2000 * p;
                [data addObject:@(r)];
            }
        }
        int trim = ceil(nTotal / 20.0);
        if(data.count < nTotal - trim) {
            sesAvg = MAX_VALUE;
        } else {
            double sum = 0, sum2 = 0;
            [data sortUsingSelector:@selector(compare:)];
            for(int j=trim; j<nTotal-trim; j++) {
                int time = [[data objectAtIndex:j] intValue];
                if(accuracy == 1) time /= 10;
                sum += time;
                sum2 += (double)time * time;
            }
            int num = nTotal - 2 * trim;
            sesAvg = round(sum / num);
            if(accuracy==1) sesAvg *= 10;
            sesASD = sqrt((sum2 - sum * sum / num) / num);
        }
    }
}

- (void)getAvgs:(int)idx {
    int num = numOfAvg[idx];
    bestAvgIdx[idx] = nTotal - 1;
    bestAvg[idx] = MAX_VALUE;
    double sum = 0;
    if(nTotal >= num) {
        int cavg;
        for(int i=nTotal-1; i>=num-1; i--) {
            int nDnf = 0;
            sum = 0;
            int max = MIN_VALUE;
            int min = MAX_VALUE;
            for(int j = i-num+1; j<=i; j++) {
                int p = [[penList objectAtIndex:j] intValue];
                int r = [[resList objectAtIndex:j] intValue] + 2000 * p;
                if(p == 2) {
                    nDnf++;
                    max = MAX_VALUE;
                } else {
                    if(r > max) max = r;
                    if(r < min) min = r;
                    if(accuracy==1) r /= 10;
                    sum += r;
                }
            }
            if(nDnf > 1) cavg = MAX_VALUE;
            else {
                if(nDnf != 0) max = 0;
                if(accuracy == 1) {
                    max = max/10;
                    min = min/10;
                }
                sum -= min + max;
                cavg = round(sum / (num - 2));
                if(accuracy==1) cavg *= 10;
                if(cavg < bestAvg[idx]) {
                    bestAvg[idx] = cavg;
                    bestAvgIdx[idx] = i;
                }
            }
            if(i == nTotal - 1) curAvg[idx] = cavg;
        }
    }
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

- (void)addMaxQueue:(int[])data x:(int)x size:(int)size {
    if(size == 0)
        data[0] = x;
    else {
        int k = size;
        while (k > 0) {
            int parent = (k - 1) >> 1;
            int e = data[parent];
            if(x >= e) break;
            data[k] = e;
            k = parent;
        }
        data[k] = x;
    }
}

- (void)pollMax:(int[])data size:(int)size {
    int s = --size;
    int x = data[s];
    int half = s >> 1;
    int k = 0;
    while (half > k) {
        int child = (k << 1) + 1;
        int c = data[child];
        int right = child + 1;
        if (right < s && c > data[right])
            c = data[child = right];
        if (x <= c) break;
        data[k] = c;
        k = child;
    }
    data[k] = x;
}

- (void)addMinQueue:(int[])data x:(int)x size:(int)size {
    if(size == 0) {
        data[0] = x;
    } else {
        int k = size;
        while (k > 0) {
            int parent = (k - 1) >> 1;
            int e = data[parent];
            if(x <= e) break;
            data[k] = e;
            k = parent;
        }
        data[k] = x;
    }
}

- (void)pollMin:(int[])data size:(int)size {
    int s = --size;
    int x = data[s];
    int half = s >> 1;
    int k = 0;
    while(half > k) {
        int child = (k << 1) + 1;
        int c = data[child];
        int right = child + 1;
        if (right < s && c < data[right])
            c = data[child = right];
        if (x >= c) break;
        data[k] = c;
        k = child;
    }
    data[k] = x;
}

- (void)getAvgs20:(int)idx {
    int num = numOfAvg[idx];
    double sum = 0;
    bestAvgIdx[idx] = nTotal - 1;
    bestAvg[idx] = MAX_VALUE;
    int trim = ceil(num / 20.0);
    if(nTotal >= num) {
        int cavg;
        for(int i=nTotal-1; i>=num-1; i--) {
            int nDnf = 0;
            sum = 0;
            int max[5], min[5];
            int size = 0;
            for(int j = i-num+1; j<=i; j++) {
                int p = [[penList objectAtIndex:j] intValue];
                if(p == 2) {
                    nDnf++;
                    if(size < trim) {
                        [self addMinQueue:min x:MAX_VALUE size:size];
                        [self addMaxQueue:max x:MAX_VALUE size:size++];
                    } else if(max[0] < MAX_VALUE) {
                        [self pollMax:max size:trim];
                        [self addMaxQueue:max x:MAX_VALUE size:trim-1];
                    }
                } else {
                    int time = [[resList objectAtIndex:j] intValue] + 2000 * p;
                    if(accuracy == 1) time /= 10;
                    sum += time;
                    if(size < trim) {
                        [self addMinQueue:min x:time size:size];
                        [self addMaxQueue:max x:time size:size++];
                    } else {
                        if(time < min[0]) {
                            [self pollMin:min size:trim];
                            [self addMinQueue:min x:time size:trim-1];
                        }
                        if(time > max[0]) {
                            [self pollMax:max size:trim];
                            [self addMaxQueue:max x:time size:trim-1];
                        }
                    }
                }
            }
            if(nDnf > trim) cavg = MAX_VALUE;
            else {
                for(int j=0; j<trim; j++) {
                    sum -= min[j];
                    int maxj = max[j];
                    if(maxj != MAX_VALUE) sum -= maxj;
                }
                cavg = round(sum / (num - 2 * trim));
                if(accuracy==1) cavg *= 10;
                if(cavg < bestAvg[idx]) {
                    bestAvg[idx] = cavg;
                    bestAvgIdx[idx] = i;
                }
            }
            if(i == nTotal - 1) curAvg[idx] = cavg;
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

- (int)getBestTime {
    if (minIdx == -1) return 0;
    return [[resList objectAtIndex:minIdx] intValue] + 2000 * [[penList objectAtIndex:minIdx] intValue];
}

- (int)getWorstTime {
    if (maxIdx == -1) return 0;
    return [[resList objectAtIndex:maxIdx] intValue] + 2000 * [[penList objectAtIndex:maxIdx] intValue];
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
    if(bai == -1) return nTotal-1;
    return bai;
}

- (NSString *)standDev:(int)i {
    if(i<0)return @"N/A";
    if(accuracy==0)i/=10;
    return [NSString stringWithFormat:@"%d.%@%d", i/100, (i%100<10)?@"0":@"", i%100];
}

- (int)getSesMean {
    return sesMean;
}

- (NSString *)sessionMean {
    return [DCTUtils distime:sesMean];
}

- (NSString *)getSessionMeanSD {
    if(nSolved==0) return @"N/A";
    else return [NSString stringWithFormat:@"%@ (σ = %@)", [DCTUtils distime:sesMean], [self standDev:sesMSD]];
}

- (NSString *)getSessionAvgSD {
    if(nTotal < 3) return @"N/A";
    if(sesAvg == MAX_VALUE) return @"DNF";
    return [NSString stringWithFormat:@"%@ (σ = %@)", [DCTUtils distime:sesAvg], [self standDev:sesASD]];
}

- (void)getMean:(int)num {
    bestMeanIdx = -1;
    bestMean3 = MAX_VALUE;
    if(nTotal >= num) {
        int cavg;
        for(int i=num-1; i<nTotal; i++) {
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
            cavg = round(sum / num);
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
    if(bestMeanIdx==-1)return nTotal-1;
    return bestMeanIdx;
}

- (NSString *)getMsgOfAvg:(int)idx num:(int)n {
    NSMutableString *s = [NSMutableString stringWithString:[DCTUtils getString:@"stat_title"]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:[dateForms objectAtIndex:dateForm]];
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
        sum2 -= pow(min, 2)+ pow(max, 2);
        cavg = round(sum / (n - 2));
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
    [formatter setDateFormat:[dateForms objectAtIndex:dateForm]];
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
        cavg = round(sum/(n-trim*2));
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
    [formatter setDateFormat:[dateForms objectAtIndex:dateForm]];
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
        cavg = round(sum / 3);
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
    [formatter setDateFormat:[dateForms objectAtIndex:dateForm]];
    NSString *date = [formatter stringFromDate:[NSDate date]];
    [s appendFormat:@"%@\n%@", date, [DCTUtils getString:@"stat_solve"]];
    [s appendFormat:@"%@\n", [self cubeSolves]];
    [s appendFormat:@"%@%@\n", [DCTUtils getString:@"session_mean"], [self getSessionMeanSD]];
    [s appendFormat:@"%@%@\n", [DCTUtils getString:@"session_avg"], [self getSessionAvgSD]];
    [s appendFormat:@"%@%@\n", [DCTUtils getString:@"stat_best"], [self bestTime]];
    [s appendFormat:@"%@%@\n%@", [DCTUtils getString:@"stat_worst"], [self worstTime], [DCTUtils getString:@"stat_list"]];
    if(!prntScr)[s appendString:@"\n"];
    for(int j=0; j<nTotal; j++) {
        if(prntScr)[s appendFormat:@"\n%d. ", j+1];
        [s appendString:[DCTData distimeAtIndex:j dt:false]];
        if(!prntScr && j<nTotal-1)[s appendString:@", "];
        if(prntScr) [s appendFormat:@"  %@", [scrList objectAtIndex:j]];
    }
    return s;
}
@end
