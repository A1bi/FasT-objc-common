//
//  FasTEventDate.m
//  FasT-retail
//
//  Created by Albrecht Oster on 29.04.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import "FasTEventDate.h"
#import "FasTFormatter.h"

@implementation FasTEventDate

@synthesize date, dateId;

- (id)initWithInfo:(NSDictionary *)info
{
    self = [super init];
    if (self) {
        NSInteger dateTimestamp = [info[@"date"] integerValue];
        date = [[NSDate dateWithTimeIntervalSince1970:dateTimestamp] retain];
        
        dateId = [info[@"id"] retain];
    }
    return self;
}

- (void)dealloc
{
    [date release];
    [dateId release];
    [super dealloc];
}

- (NSString *)localizedString
{
    return [FasTFormatter stringForEventDate:date];
}

@end
