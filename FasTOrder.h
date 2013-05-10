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
    NSString *queueNumber;
	FasTEventDate *date;
	NSArray *tickets;
    NSDate *created;
    NSInteger numberOfTickets;
    float total;
    BOOL paid;
}

@property (nonatomic, readonly) NSString *orderId, *number, *queueNumber;
@property (nonatomic, retain) FasTEventDate *date;
@property (nonatomic, retain) NSArray *tickets;
@property (nonatomic, readonly) NSDate *created;
@property (nonatomic, assign) NSInteger numberOfTickets;
@property (nonatomic, assign) float total;
@property (nonatomic, assign) BOOL paid;

- (id)initWithInfo:(NSDictionary *)info event:(FasTEvent *)event;

@end
