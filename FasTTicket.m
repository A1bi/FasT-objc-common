//
//  FasTTicket.m
//  FasT-retail-checkout
//
//  Created by Albrecht Oster on 10.05.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import "FasTTicket.h"
#import "FasTEvent.h"
#import "FasTEventDate.h"
#import "FasTTicketType.h"
#import "FasTSeat.h"

@implementation FasTTicket

@synthesize ticketId, number, date, type, seat, price;

- (id)initWithInfo:(NSDictionary *)info event:(FasTEvent *)event
{
    self = [super init];
    if (self) {
        ticketId = [info[@"id"] retain];
        number = [info[@"number"] retain];
        price = [info[@"price"] floatValue];
        
        date = [[event objectFromArray:@"dates" withId:info[@"dateId"] usingIdName:@"date"] retain];
        type = [[event objectFromArray:@"ticketTypes" withId:info[@"typeId"] usingIdName:@"type"] retain];
        seat = [[event seats][[date dateId]][info[@"seatId"]] retain];
    }
    return self;
}

- (void)dealloc
{
    [ticketId release];
    [number release];
    [date release];
    [type release];
    [seat release];
    [super dealloc];
}

@end
