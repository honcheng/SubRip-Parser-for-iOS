//
//  SubRipParser.m
//  Spuul
//
//  Created by honcheng on 16/10/12.
//  Copyright (c) 2012 honcheng@gmail.com. All rights reserved.
//

#import "SubRipParser.h"

@implementation SubRipItem

+ (SubRipItem*)subRipItem
{
    return [[SubRipItem alloc] init];
}

- (NSString*)description
{
    NSMutableString *text = [NSMutableString string];
    [text appendFormat:@"%f-->%f : %@", self.startTime, self.endTime, self.text];
    return text;
}

@end

@implementation SubRipItems

- (NSString*)description
{
    NSMutableString *text = [NSMutableString string];
    [text appendFormat:@"SubRipItems: number of items %i, ", [self.items count]];
    
    SubRipItem *lastItem = [self.items lastObject];
    NSTimeInterval timeInterval = lastItem.endTime;
    int minute = timeInterval/60;
    [text appendFormat:@"%i minutes", minute];
    
    return text;
}

@end

@interface SubRipParser()
- (SubRipItem*)parseSubRipItem:(NSString*)text;
- (NSTimeInterval)timeIntervalFromSubRipTimeString:(NSString*)text;
@end

@implementation SubRipParser

- (id)initWithSubRipContent:(NSString*)subripContent
{
    self = [super init];
    if (self)
    {
        _subripContent = subripContent;
    }
    return self;
}

- (void)parseWithBlock:(void (^)(BOOL, SubRipItems *))block
{
    dispatch_async(dispatch_queue_create("parse subrip file", 0), ^{
        
        self.subripContent = [self.subripContent stringByReplacingOccurrencesOfString:@"\n\r\n" withString:@"\n\n"];
        self.subripContent = [self.subripContent stringByReplacingOccurrencesOfString:@"\n\n\n" withString:@"\n\n"];
        NSArray *textBlocks = [self.subripContent componentsSeparatedByString:@"\n\n"];
        NSMutableArray *items = [NSMutableArray array];
        for (NSString *text in textBlocks)
        {
            SubRipItem *subRipItem = [self parseSubRipItem:text];
            if (subRipItem)
            {
                [items addObject:subRipItem];
            }
        }
        
        SubRipItems *subRipItems = [[SubRipItems alloc] init];
        [subRipItems setItems:items];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(YES, subRipItems);
        });
    });
}

- (SubRipItem*)parseSubRipItem:(NSString*)text
{
    NSArray *lines = [text componentsSeparatedByString:@"\n"];
    // SubRipt format requires at least 3 lines
    
    if ([lines count]>=3)
    {
        SubRipItem *subRipItem = [SubRipItem subRipItem];
        subRipItem.subtitleNumber = [lines[0] intValue];
        
        NSArray *timeRange = [lines[1] componentsSeparatedByString:@"-->"];
        // there will always be 2 items in time range
        if ([timeRange count]==2)
        {
            NSString *startTimeString = [timeRange[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *endTimeString = [timeRange[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

            subRipItem.startTime = [self timeIntervalFromSubRipTimeString:startTimeString] + self.timeOffset;
            subRipItem.endTime = [self timeIntervalFromSubRipTimeString:endTimeString] + self.timeOffset;
            
        }
        else
        {
            return nil;
        }
        
        NSMutableString *text = [NSMutableString string];
        for (int i=2; i<[lines count]; i++)
        {
            [text appendFormat:@"%@\n", lines[i]];
        }
        subRipItem.text = text;
        return subRipItem;
    }
    else
    {
        return nil;
    }
}

- (NSTimeInterval)timeIntervalFromSubRipTimeString:(NSString*)text
{
    NSArray *components = [text componentsSeparatedByString:@","];
    int miliseconds = 0;
    if ([components count]==2) miliseconds = [components[1] intValue];
    
    NSArray *hourMinSec = [components[0] componentsSeparatedByString:@":"];
    int hour = [hourMinSec[0] intValue];
    int minute = [hourMinSec[1] intValue];
    int second = [hourMinSec[2] intValue];
    
    NSTimeInterval timeInterval = hour*60*60 + minute*60 + second + miliseconds/1000.0;
    return timeInterval;
}

@end
