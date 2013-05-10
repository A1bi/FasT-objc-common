//
//  FasTOrder.m
//  FasT-retail
//
//  Created by Albrecht Oster on 14.04.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import "FasTOrder.h"
#import "FasTTicket.h"

@implementation FasTOrder

@synthesize orderId, number, date, tickets, numberOfTickets, total, paid;

- (id)initWithInfo:(NSDictionary *)info event:(FasTEvent *)event
{
    self = [super init];
    if (self) {
        orderId = [info[@"id"] retain];
        number = [info[@"number"] retain];
        total = [info[@"total"] floatValue];
        paid = [info[@"paid"] boolValue];
        
        NSMutableArray *tmpTickets = [NSMutableArray array];
        for (NSDictionary *ticketInfo in info[@"tickets"]) {
            [tmpTickets addObject:[[FasTTicket alloc] initWithInfo:ticketInfo event:event]];
        }
        tickets = [NSArray arrayWithArray:tmpTickets];
    }
    return self;
}

- (void)dealloc
{
    [orderId release];
    [number release];
	[tickets release];
    [date release];
	[super dealloc];
}

@end
