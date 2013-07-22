//
//  FasTApi.h
//  FasT-retail
//
//  Created by Albrecht Oster on 09.05.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketIO.h"

FOUNDATION_EXPORT NSString * const FasTApiIsReadyNotification;
FOUNDATION_EXPORT NSString * const FasTApiUpdatedSeatsNotification;
FOUNDATION_EXPORT NSString * const FasTApiUpdatedOrdersNotification;
FOUNDATION_EXPORT NSString * const FasTApiOrderExpiredNotification;
FOUNDATION_EXPORT NSString * const FasTApiConnectingNotification;
FOUNDATION_EXPORT NSString * const FasTApiDisconnectedNotification;
FOUNDATION_EXPORT NSString * const FasTApiCannotConnectNotification;

typedef void (^FasTApiResponseBlock)(NSDictionary *response);

@class FasTEvent;
@class FasTOrder;
@class MKNetworkEngine;

@interface FasTApi : NSObject <SocketIODelegate>
{
    MKNetworkEngine *netEngine;
    SocketIO *sIO;
    FasTEvent *event;
    NSString *clientType;
    NSString *retailId;
    NSString *seatingId;
    BOOL inHibernation;
}

@property (nonatomic, retain) FasTEvent *event;
@property (nonatomic, readonly) NSString *clientType;

+ (FasTApi *)defaultApi;

- (void)initWithClientType:(NSString *)clientType retailId:(NSString *)rId;
- (void)getResource:(NSString *)resource withAction:(NSString *)action callback:(FasTApiResponseBlock)callback;
- (void)postResource:(NSString *)resource withAction:(NSString *)action data:(NSDictionary *)data callback:(FasTApiResponseBlock)callback;
- (void)setDate:(NSString *)dateId numberOfSeats:(NSInteger)numberOfSeats callback:(FasTApiResponseBlock)callback;
- (void)chooseSeatWithId:(NSString *)seatId;
- (void)resetSeating;
- (void)placeOrderWithInfo:(NSDictionary *)info callback:(FasTApiResponseBlock)callback;
- (void)getOrders;
- (void)markOrderAsPaid:(FasTOrder *)order withCallback:(FasTApiResponseBlock)callback;

@end
