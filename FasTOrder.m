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

@synthesize orderId, bunchId, number, queueNumber, date, tickets, created, numberOfTickets, total, paid, firstName, lastName;

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
        firstName = [info[@"first_name"] retain];
        lastName = [info[@"last_name"] retain];
        bunchId = [info[@"bunch_id"] retain];
        if (info[@"number_of_tickets"]) numberOfTickets = [info[@"number_of_tickets"] intValue];
        
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
    [firstName release];
    [lastName release];
    [bunchId release];
	[super dealloc];
}

- (id)valueForKey:(NSString *)key
{
    id value = [super valueForKey:key];
    if (([key isEqualToString:@"firstName"] || [key isEqualToString:@"lastName"]) && (![value isKindOfClass:[NSString class]] || [value length] < 1)) {
        value = NSLocalizedStringByKey(@"notSpecified");
    }
    return value;
}

- (NSString *)fullNameWithLastNameFirst:(BOOL)flag
{
    NSString *ln = [self valueForKey:@"lastName"], *fn = [self valueForKey:@"firstName"];
    return flag ? [NSString stringWithFormat:@"%@, %@", ln, fn] : [NSString stringWithFormat:@"%@ %@", fn, ln];
}

@end
