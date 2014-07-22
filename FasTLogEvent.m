//
//  FasTLogEvent.m
//  FasT-box-office
//
//  Created by Albrecht Oster on 21.07.14.
//  Copyright (c) 2014 Albisigns. All rights reserved.
//

#import "FasTLogEvent.h"

@implementation FasTLogEvent

- (id)initWithInfo:(NSDictionary *)info
{
    self = [super init];
    if (self) {
        self.date = [NSDate dateWithTimeIntervalSince1970:[info[@"date"] integerValue]];
        self.message = info[@"message"];
    }
    return self;
}

- (void)dealloc
{
    [_date release];
    [_message release];
    [super dealloc];
}

@end
