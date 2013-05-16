//
//  FasTOrder.m
//  FasT-retail
//
//  Created by Albrecht Oster on 14.04.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import "FasTOrder.h"
#import "FasTEvent.h"
#import "FasTEventDate.h"
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
            FasTEventDate *d = [event objectFromArray:@"dates" withId:ticketInfo[@"dateId"] usingIdName:@"date"];
            FasTTicket *ticket = [[[FasTTicket alloc] initWithInfo:ticketInfo date:d order:self] autorelease];
            [tmpTickets addObject:ticket];
        }
        tickets = [[NSArray arrayWithArray:tmpTickets] retain];
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
