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
FOUNDATION_EXPORT NSString * const FasTApiPlacedOrderNotification;
FOUNDATION_EXPORT NSString * const FasTApiUpdatedOrdersNotification;

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
}

@property (nonatomic, retain) FasTEvent *event;
@property (nonatomic, readonly) NSString *clientType;

+ (FasTApi *)defaultApi;

- (void)initWithClientType:(NSString *)clientType;
- (void)getResource:(NSString *)resource withAction:(NSString *)action callback:(FasTApiResponseBlock)callback;
- (void)postResource:(NSString *)resource withAction:(NSString *)action data:(NSDictionary *)data callback:(FasTApiResponseBlock)callback;
- (void)updateOrderWithStep:(NSString *)step info:(NSDictionary *)info callback:(void (^)(NSDictionary *))callback;
- (void)reserveSeatWithId:(NSString *)seatId;
- (void)getOrders;
- (void)markOrderAsPaid:(FasTOrder *)order withCallback:(FasTApiResponseBlock)callback;

@end
