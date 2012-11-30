//
//  SubRipParser.h
//  Spuul
//
//  Created by honcheng on 16/10/12.
//  Copyright (c) 2012 honcheng@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SubRipItem : NSObject
@property (nonatomic, assign) int subtitleNumber;
@property (nonatomic, assign) NSTimeInterval startTime, endTime;
@property (nonatomic, copy) NSString *text;
+ (SubRipItem*)subRipItem;
@end

@interface SubRipItems : NSObject
@property (nonatomic, strong) NSArray *items;
@end

@interface SubRipParser : NSObject
@property (nonatomic, copy) NSString *subripContent;
@property (nonatomic, assign) float timeOffset;
- (id)initWithSubRipContent:(NSString*)subripContent;
- (void)parseWithBlock:(void(^)(BOOL success, SubRipItems *item))block;
@end
