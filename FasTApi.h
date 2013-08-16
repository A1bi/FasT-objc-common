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
    NSString *clientId;
    NSString *seatingId;
    BOOL inHibernation, nodeConnectionInitiated;
}

@property (nonatomic, retain) FasTEvent *event;
@property (nonatomic, readonly) NSString *clientType;
@property (nonatomic, readonly) NSString *clientId;

+ (FasTApi *)defaultApi;
+ (FasTApi *)defaultApiWithClientType:(NSString *)cType clientId:(NSString *)cId;

- (void)initNodeConnection;
- (void)getResource:(NSString *)resource withAction:(NSString *)action callback:(FasTApiResponseBlock)callback;
- (void)postResource:(NSString *)resource withAction:(NSString *)action data:(NSDictionary *)data callback:(FasTApiResponseBlock)callback;
- (void)setDate:(NSString *)dateId numberOfSeats:(NSInteger)numberOfSeats callback:(FasTApiResponseBlock)callback;
- (void)chooseSeatWithId:(NSString *)seatId;
- (void)resetSeating;
- (void)placeRetailOrderWithInfo:(NSDictionary *)info callback:(FasTApiResponseBlock)callback;
- (void)getOrdersForRetailStore;
- (void)getOrdersForCurrentDateWithCallback:(void (^)(NSArray *))callback;
- (void)getOrderWithNumber:(NSString *)number callback:(void (^)(FasTOrder *))callback;
- (void)markOrderAsPaid:(FasTOrder *)order withCallback:(FasTApiResponseBlock)callback;
- (void)checkInTicketWithInfo:(NSDictionary *)info in:(BOOL)goingIn callback:(FasTApiResponseBlock)callback;
- (void)finishPurchaseWithItems:(NSArray *)items total:(float)total callback:(FasTApiResponseBlock)callback;

@end
