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
	FasTEventDate *date; // TODO: remove this and rework the whole ticket number part in the ordering process
    NSArray *tickets;
    NSMutableArray *logEvents;
    NSDate *created;
    float total, balance;
    BOOL paid;
}

@property (nonatomic, readonly) NSString *orderId, *number, *firstName, *lastName;
@property (nonatomic, retain) FasTEventDate *date;
@property (nonatomic, retain) NSArray *tickets;
@property (nonatomic, readonly) NSDate *created;
@property (nonatomic, assign) float total, balance;
@property (nonatomic, assign) BOOL paid;
@property (nonatomic, readonly) NSMutableArray *logEvents;

- (id)initWithInfo:(NSDictionary *)info event:(FasTEvent *)event;
- (NSString *)fullNameWithLastNameFirst:(BOOL)flag;
- (NSString *)localizedTotal;
- (NSString *)localizedBalance;
- (NSInteger)numberOfTickets;
- (BOOL)cancelled;

@end
