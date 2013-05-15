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
    FasTOrder *order;
    FasTEventDate *date;
    FasTTicketType *type;
    FasTSeat *seat;
    float price;
}

@property (nonatomic, readonly) NSString *ticketId, *number;
@property (nonatomic, readonly) FasTOrder *order;
@property (nonatomic, readonly) FasTEventDate *date;
@property (nonatomic, readonly) FasTTicketType *type;
@property (nonatomic, readonly) FasTSeat *seat;
@property (nonatomic, readonly) float price;

- (id)initWithInfo:(NSDictionary *)info date:(FasTEventDate *)date order:(FasTOrder *)order;

@end