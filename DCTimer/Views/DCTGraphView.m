//
//  DCTGraphView.m
//  DCTimer
//
//  Created by meigen on 15-1-4.
//
//

#import "DCTGraphView.h"
#import "DCTUtils.h"
#import "DCTData.h"

@implementation DCTGraphView

int divisions[] = {100, 200, 500, 1000, 2000, 5000, 10000, 20000, 30000, 60000, 90000, 120000, 300000, 600000, 1200000, 1800000, 3600000};
extern int graphType;
extern int graphLength;

- (id)initWithCoder:(NSCoder *)coder
{
    if(self = [super initWithCoder:coder]) {
        
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    
    CGSize frame = [DCTUtils getFrame];
    int hei = frame.height;
    int wid = frame.width;
    if (hei == 1024) {
        hei = 748;
        wid = 1024;
    }
    int dlt = [DCTUtils isOS7] ? 64 : 0;
    //if ([DCTUtils isOS7])
    hei -= 44;
    DCTData *rest = [DCTData dbh];
    int max = [rest getWorstTime];
    int min = [rest getBestTime];
    //int wBase = 75;
    int wBar = 30;
    UIFont *font = [UIFont systemFontOfSize:[DCTUtils isPad] ? 16 : 14];
    if (graphType == 0) {   //直方图
        int bins[32];
        int start, end;
        int len = hei * 1.0 / wBar - 0.5;
        int divi = [self getDivision:(max - min) / len];
        int mean = (min & max) + ((min ^ max) >> 1);
        mean = (mean + divi / 2) / divi * divi;
        if ((len & 1) == 1) mean += divi / 2;
        start = mean - divi * len / 2;
        end = mean + divi * len / 2;
        for (int i=0; i<len; i++) {
            bins[i] = 0;
        }
        for (int i=0; i<[rest numberOfSolves]; i++) {
            int time = [rest getTimeAt:i];
            if (time != 0) {
                int bin = (int)(len * (time - start) / (end - start));
                if (bin >= 0 && bin < len)
                    bins[bin]++;
            }
        }
        
        int binInterval = (end - start) / len;
        int temp = start + len * binInterval;
        NSString *text = [self distime:temp];
        int wBase = [DCTUtils getStringWidth:text font:font] + 20;
        
        CGContextMoveToPoint(context, wBase, dlt);
        CGContextAddLineToPoint(context, wBase, dlt+hei);
        CGContextStrokePath(context);
        
        for (int i=0; i<=len; i++) {
            int y = (i + 0.5) * wBar;
            CGContextMoveToPoint(context, wBase - 4, y + dlt);
            CGContextAddLineToPoint(context, wBase + 4, y + dlt);
            CGContextStrokePath(context);
            int value = start + i * binInterval;
            text = [self distime:value];
            int tw = [DCTUtils getStringWidth:text font:font];
            [text drawAtPoint:CGPointMake(wBase - 5 - tw, y + dlt - 10) withFont:font];
        }
        int maxValue = 0;
        for (int i = 0; i < len; i++) {
            if (bins[i] > maxValue)
                maxValue = bins[i];
        }
        if (maxValue > 0) {
            for (int i=0; i<len; i++) {
                int y = (int)((i + 0.5) * wBar) + dlt;
                //int y2 = (int)((i + 1.5) * wBar) + dlt;
                float height = bins[i] * (wid - wBase - 20.0) / maxValue;
                CGContextAddRect(context, CGRectMake(wBase, y, height, wBar));
                CGContextDrawPath(context, kCGPathStroke);
                if(bins[i] != 0) {
                    text = [NSString stringWithFormat:@"%d", bins[i]];
                    int tw = [DCTUtils getStringWidth:text font:font];
                    if (height < tw + 10) {
                        [text drawAtPoint:CGPointMake(wBase + height + 5, y + 6) withFont:font];
                    } else [text drawAtPoint:CGPointMake(wBase + height - tw - 5, y + 6) withFont:font];
                }
                
            }
        }
    } else {    //折线图
        int len = (hei - 40.0) / wBar - 0.5;
        int divi = [self getDivision:(max-min)/len];
        int mean = (min & max) + ((min ^ max) >> 1);
        mean = ((mean + divi / 2) / divi) * divi;
        //NSLog(@"%d, %d, %d", len, divi, mean);
        int up = mean, down = mean;
        while (up < max) {
            up += divi;
        }
        while (down > min) {
            down -= divi;
        }
        mean = [rest getSesMean];
        int blk = (up - down) / divi;
        wBar = (hei - 80) / blk;
        NSString *text = [self distime:up];
        int wBase = [DCTUtils getStringWidth:text font:font] + 14;
        int right = 14;
        
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1].CGColor);
        for (int i = 1; i < blk; i++) {
            int y = i * wBar + 60;
            CGContextMoveToPoint(context, wBase, y + dlt);
            CGContextAddLineToPoint(context, wid - right, y + dlt);
            CGContextStrokePath(context);
        }
        CGContextAddRect(context, CGRectMake(wBase, 60 + dlt, wid - right - wBase, wBar * blk));
        CGContextDrawPath(context, kCGPathStroke);
        CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
        float y = (up * 1.0 - mean) / divi * wBar + 60;
        CGContextMoveToPoint(context, wBase, y + dlt);
        CGContextAddLineToPoint(context, wid - right, y + dlt);
        CGContextStrokePath(context);
        CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
        for (int i=0; i<=blk; i++) {
            int value = up - i * divi;
            y = i * wBar + 60;
            text = [self distime:value];
            int tw = [DCTUtils getStringWidth:text font:font];
            [text drawAtPoint:CGPointMake(wBase - 5 - tw, y + dlt - 10) withFont:font];
        }
        //int count = 0;
        //for (int i=0; i<[rest numberOfSolves]; i++) {
        //    if ([rest getTimeAt:i] != 0) count++;
        //}
        float rsp = (wid - 21.0 - wBase) / (graphLength-1);
        int count = 0;
        float lastX = -1, lastY = -1;
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.1 green:0.2 blue:0.8 alpha:0.7].CGColor);
        //CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0 alpha:0.8].CGColor);
        for (int i=[rest numberOfSolves]-1; i>=0; i--) {
            int time = [rest getTimeAt:i];
            if (time != 0) {
                float x = (float)(wid - 18.0 - (count++) * rsp);
                y = (float) ((up * 1.0 - time) / divi * wBar + 60);
                //CGContextAddEllipseInRect(context, CGRectMake(x-1.5, y-1.5+dlt, 3, 3));
                CGContextDrawPath(context, kCGPathFillStroke);
                if (lastX != -1) {
                    CGContextMoveToPoint(context, lastX, lastY + dlt);
                    CGContextAddLineToPoint(context, x, y + dlt);
                    CGContextStrokePath(context);
                }
                lastX = x; lastY = y;
                if(count >= graphLength) break;
            }
        }
    }
}

- (int)getDivision:(int)dv {
    if(dv <= divisions[0]) return 100;
    for(int i=1; i<17; i++)
        if(dv <= divisions[i]) return divisions[i];
    return (dv/1000+1)*1000;
}

- (NSString *)distime:(int)i {
    bool m = i < 0;
    i = abs(i) + 5;
    int ms = (i % 1000) / 100;
    int s = (i / 1000) % 60;
    int mi = (i / 60000) % 60;
    int h = i / 3600000;
    NSMutableString *time = [NSMutableString string];
    if (m) [time appendString:@"-"];
    if(h==0) {
        if(mi==0) [time appendFormat:@"%d", s];
        else [time appendFormat:@"%d:%02d", mi, s];
    } else [time appendFormat:@"%d:%02d:%02d", h, mi, s];
    [time appendFormat:@".%d", ms];
    return time;
}

@end
