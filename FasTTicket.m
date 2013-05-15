//
//  FasTTicket.m
//  FasT-retail-checkout
//
//  Created by Albrecht Oster on 10.05.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import "FasTTicket.h"
#import "FasTOrder.h"
#import "FasTEvent.h"
#import "FasTEventDate.h"
#import "FasTTicketType.h"
#import "FasTSeat.h"

@implementation FasTTicket

@synthesize ticketId, number, order, date, type, seat, price;

- (id)initWithInfo:(NSDictionary *)info date:(FasTEventDate *)d order:(FasTOrder *)o
{
    self = [super init];
    if (self) {
        order = [o retain];
        date = [d retain];
        
        ticketId = [info[@"id"] retain];
        number = [info[@"number"] retain];
        price = [info[@"price"] floatValue];
        
        FasTEvent *event = [date event];
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
    [order release];
    [super dealloc];
}

@end