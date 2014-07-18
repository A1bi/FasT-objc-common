//
//  FasTTicket.h
//  FasT-retail-checkout
//
//  Created by Albrecht Oster on 10.05.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FasTEventDate;
@class FasTTicketType;
@class FasTOrder;
@class FasTSeat;

@interface FasTTicket : NSObject
{
    NSString *ticketId;
    NSString *number;
    NSString *cancelReason;
    FasTOrder *order;
    FasTEventDate *date;
    FasTTicketType *type;
    FasTSeat *seat;
    float price;
    BOOL canCheckIn, cancelled, paid;
    NSArray *checkinErrors;
}

@property (nonatomic, readonly) NSString *ticketId, *number, *cancelReason;
@property (nonatomic, readonly) FasTOrder *order;
@property (nonatomic, readonly) FasTEventDate *date;
@property (nonatomic, readonly) FasTTicketType *type;
@property (nonatomic, readonly) FasTSeat *seat;
@property (nonatomic, readonly) float price;
@property (nonatomic) BOOL canCheckIn, cancelled, paid, pickedUp;
@property (nonatomic, readonly) NSArray *checkinErrors;

- (id)initWithInfo:(NSDictionary *)info date:(FasTEventDate *)date order:(FasTOrder *)order;

@end
