//
//  FasTEventDate.m
//  FasT-retail
//
//  Created by Albrecht Oster on 29.04.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import "FasTEventDate.h"
#import "FasTEvent.h"
#import "FasTFormatter.h"

@implementation FasTEventDate

@synthesize date, dateId, event;

- (id)initWithInfo:(NSDictionary *)info event:(FasTEvent *)e
{
    self = [super init];
    if (self) {
        event = [e retain];
        
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
    [event release];
    [super dealloc];
}

- (NSString *)localizedString
{
    return [FasTFormatter stringForEventDate:date];
}

@end
