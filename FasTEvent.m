//
//  FasTEvent.m
//  FasT-retail
//
//  Created by Albrecht Oster on 15.04.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import "FasTEvent.h"
#import "FasTEventDate.h"
#import "FasTTicketType.h"
#import "FasTSeat.h"

@implementation FasTEvent

@synthesize name, dates, ticketTypes, seats;

- (id)initWithInfo:(NSDictionary *)info
{
    self = [super init];
    if (self) {
        [self setName:info[@"name"]];
        
        NSMutableArray *tmp = [NSMutableArray array];
        for (NSDictionary *dateInfo in info[@"dates"]) {
            FasTEventDate *date = [[[FasTEventDate alloc] initWithInfo:dateInfo] autorelease];
            [tmp addObject:date];
        }
        [self setDates:[NSArray arrayWithArray:tmp]];
        
        tmp = [NSMutableArray array];
        for (NSDictionary *typeInfo in info[@"ticketTypes"]) {
            FasTTicketType *type = [[[FasTTicketType alloc] initWithInfo:typeInfo] autorelease];
            [tmp addObject:type];
        }
        [self setTicketTypes:[NSArray arrayWithArray:tmp]];
        
        seats = [[NSMutableDictionary dictionary] retain];
        [self updateSeats:info[@"seats"]];
    }
    return self;
}

- (void)dealloc
{
    [name release];
    [dates release];
    [ticketTypes release];
    [seats release];
    [super dealloc];
}

#pragma mark class methods

- (void)updateSeats:(NSDictionary *)seatsInfo
{
    for (NSString *dateId in seatsInfo) {
        NSMutableDictionary *eventDateSeats = seats[dateId];
        if (!eventDateSeats) {
            eventDateSeats = [NSMutableDictionary dictionary];
            seats[dateId] = eventDateSeats;
        }
        
        NSDictionary *dateSeats = seatsInfo[dateId];
        for (NSString *seatId in dateSeats) {
            FasTSeat *seat = eventDateSeats[seatId];
            if (!seat) {
                seat = [[FasTSeat alloc] initWithId:seatId andInfo:dateSeats[seatId]];
                eventDateSeats[seatId] = seat;
            } else {
                [seat updateWithInfo:dateSeats[seatId]];
            }
        }
    }
}

@end
