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

@synthesize orderId, number, queueNumber, date, tickets, created, numberOfTickets, total, paid;

- (id)initWithInfo:(NSDictionary *)info event:(FasTEvent *)event
{
    self = [super init];
    if (self) {
        orderId = [info[@"id"] retain];
        number = [info[@"number"] retain];
        queueNumber = [info[@"queue_number"] retain];
        total = [info[@"total"] floatValue];
        paid = [info[@"paid"] boolValue];
        created = [[NSDate dateWithTimeIntervalSince1970:[info[@"created"] intValue]] retain];
        
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
    [queueNumber release];
	[tickets release];
    [date release];
    [created release];
	[super dealloc];
}

@end
