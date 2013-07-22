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
            FasTEventDate *date = [[[FasTEventDate alloc] initWithInfo:dateInfo event:self] autorelease];
            [tmp addObject:date];
        }
        [self setDates:[NSArray arrayWithArray:tmp]];
        
        tmp = [NSMutableArray array];
        for (NSDictionary *typeInfo in info[@"ticket_types"]) {
            FasTTicketType *type = [[[FasTTicketType alloc] initWithInfo:typeInfo] autorelease];
            [tmp addObject:type];
        }
        [self setTicketTypes:[NSArray arrayWithArray:tmp]];
        
        seats = [[NSMutableDictionary dictionary] retain];
        for (FasTEventDate *date in dates) {
            NSMutableDictionary *dateSeats = [NSMutableDictionary dictionary];
            seats[[date dateId]] = dateSeats;
            
            for (NSDictionary *seatInfo in info[@"seats"]) {
                FasTSeat *seat = [[FasTSeat alloc] initWithInfo:seatInfo];
                dateSeats[[seat seatId]] = seat;
                [seat release];
            }
        }
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
        NSDictionary *dateSeats = seatsInfo[dateId];
        for (NSString *seatId in dateSeats) {
            FasTSeat *seat = seats[dateId][seatId];
            [seat updateWithInfo:dateSeats[seatId]];
        }
    }
}

- (id)objectFromArray:(NSString *)arrayName withId:(NSString *)objId usingIdName:(NSString *)idName
{
    NSArray *array = [self performSelector:NSSelectorFromString(arrayName)];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", [NSString stringWithFormat:@"%@Id", idName], objId];
    @try {
        return [array filteredArrayUsingPredicate:predicate][0];
    }
    @catch (NSException *exception) {
        return nil;
    }
}

@end
