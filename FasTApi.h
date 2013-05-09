//
//  FasTApi.h
//  FasT-retail
//
//  Created by Albrecht Oster on 09.05.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketIO.h"

typedef void (^FasTApiResponseBlock)(NSDictionary *response);

@class FasTEvent;
@class MKNetworkEngine;

@interface FasTApi : NSObject <SocketIODelegate>
{
    MKNetworkEngine *netEngine;
    SocketIO *sIO;
    FasTEvent *event;
}

@property (nonatomic, retain) FasTEvent *event;

+ (FasTApi *)defaultApi;

- (void)getResource:(NSString *)resource withAction:(NSString *)action callback:(FasTApiResponseBlock)callback;
- (void)postResource:(NSString *)resource withAction:(NSString *)action data:(NSDictionary *)data callback:(FasTApiResponseBlock)callback;
- (void)updateOrderWithStep:(NSString *)step info:(NSDictionary *)info callback:(void (^)(NSDictionary *))callback;
- (void)reserveSeatWithId:(NSString *)seatId;

@end
