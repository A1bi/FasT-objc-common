//
//  FasTOrder.h
//  FasT-retail
//
//  Created by Albrecht Oster on 14.04.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FasTEvent;
@class FasTEventDate;

@interface FasTOrder : NSObject
{
    NSString *orderId;
    NSString *number;
    NSString *firstName, *lastName;
    NSString *cancelReason;
	FasTEventDate *date; // TODO: remove this and rework the whole ticket number part in the ordering process
	NSArray *tickets, *logEvents;
    NSDate *created;
    float total;
    BOOL paid, cancelled;
}

@property (nonatomic, readonly) NSString *orderId, *number, *firstName, *lastName, *cancelReason;
@property (nonatomic, retain) FasTEventDate *date;
@property (nonatomic, retain) NSArray *tickets;
@property (nonatomic, readonly) NSDate *created;
@property (nonatomic, assign) float total;
@property (nonatomic, assign) BOOL paid, cancelled;
@property (nonatomic, readonly) NSArray *logEvents;

- (id)initWithInfo:(NSDictionary *)info event:(FasTEvent *)event;
- (NSString *)fullNameWithLastNameFirst:(BOOL)flag;
- (NSString *)localizedTotal;
- (NSInteger)numberOfTickets;

@end
