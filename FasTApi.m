//
//  FasTApi.m
//  FasT-retail
//
//  Created by Albrecht Oster on 09.05.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import "FasTApi.h"
#import "FasTEvent.h"
#import "FasTOrder.h"
#import "MKNetworkEngine.h"
#import "SocketIOPacket.h"

NSString * const FasTApiIsReadyNotification = @"FasTApiIsReadyNotification";
NSString * const FasTApiUpdatedSeatsNotification = @"FasTApiUpdatedSeatsNotification";
NSString * const FasTApiUpdatedOrdersNotification = @"FasTApiUpdatedOrdersNotification";
NSString * const FasTApiOrderExpiredNotification = @"FasTApiOrderExpiredNotification";
NSString * const FasTApiConnectingNotification = @"FasTApiConnectingNotification";
NSString * const FasTApiDisconnectedNotification = @"FasTApiDisconnectedNotification";
NSString * const FasTApiCannotConnectNotification = @"FasTApiCannotConnectNotification";

static FasTApi *defaultApi = nil;

#ifdef DEBUG
    static NSString *kFasTApiUrl = @"fast.albisigns";
#else
    static NSString *kFasTApiUrl = @"theater-kaisersesch.de";
#endif

#define kFasTApiTimeOut 10

@interface FasTApi ()

- (id)initWithClientType:(NSString *)cType clientId:(NSString *)cId;
- (void)makeRequestWithPath:(NSString *)path method:(NSString *)method data:(NSDictionary *)data callback:(FasTApiResponseBlock)callback;
- (void)makeRequestWithResource:(NSString *)resource action:(NSString *)action method:(NSString *)method data:(NSDictionary *)data callback:(FasTApiResponseBlock)callback;
- (void)connectToNode;
- (void)postNotificationWithName:(NSString *)name info:(NSDictionary *)info;
- (void)prepareNodeConnection;
- (void)disconnect;
- (void)scheduleReconnect;
- (void)abortAndReconnect;
- (void)killScheduledTasks;
- (void)initEventWithInfo:(NSDictionary *)info;
- (void)updateOrdersWithArray:(NSDictionary *)info;
- (void)appWillResignActive;

@end

@implementation FasTApi

@synthesize event, clientType, clientId;

+ (FasTApi *)defaultApi
{
	if (!defaultApi) {
        [NSException raise:@"FasTApiNotInitiatedException" format:@"FasTApi has to be initiated by sending initWithClientType: first."];
        return nil;
    }
	
	return defaultApi;
}

+ (FasTApi *)defaultApiWithClientType:(NSString *)cType clientId:(NSString *)cId
{
    if (!defaultApi) {
        defaultApi = [[super allocWithZone:NULL] initWithClientType:cType clientId:cId];
    }
    return defaultApi;
}

+ (id)allocWithZone:(NSZone *)zone
{
	return [[self defaultApi] retain];
}

- (id)init
{
    return defaultApi;
}

- (id)initWithClientType:(NSString *)cType clientId:(NSString *)cId
{
    self = [super init];
    if (self) {
        netEngine = [[MKNetworkEngine alloc] initWithHostName:kFasTApiUrl];
        
        clientType = [cType retain];
        clientId = [cId retain];
    }
    return self;
}

- (void)dealloc
{
    [netEngine release];
    [sIO release];
    [event release];
    [clientType release];
    [clientId release];
    [super dealloc];
}

#pragma mark SocketIO delegate methods

- (void)socketIODidConnect:(SocketIO *)socket
{
    [self killScheduledTasks];
    
    [self postNotificationWithName:FasTApiIsReadyNotification info:nil];
}

- (void)socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    NSDictionary *info = [packet dataAsJSON][@"args"][0];
    
    if ([[packet name] isEqualToString:@"updateSeats"]) {
        NSDictionary *seats = info[@"seats"];
        [event updateSeats:seats];
        
        [self postNotificationWithName:FasTApiUpdatedSeatsNotification info:seats];
        
    } else if ([[packet name] isEqualToString:@"gotSeatingId"]) {
        [seatingId release];
        seatingId = [info[@"id"] retain];
        
    } else if ([[packet name] isEqualToString:@"updateEvent"]) {
        [self initEventWithInfo:info[@"event"]];
        
    } else if ([[packet name] isEqualToString:@"updateOrders"]) {
        [self updateOrdersWithArray:info];
        
    } else if ([[packet name] isEqualToString:@"expired"]) {
        [self postNotificationWithName:FasTApiOrderExpiredNotification info:nil];
    }
}

- (void)socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
    [self killScheduledTasks];
    if (inHibernation) return;
    
    [self postNotificationWithName:FasTApiDisconnectedNotification info:nil];
    
    [self scheduleReconnect];
}

- (void)socketIO:(SocketIO *)socket onError:(NSError *)error
{
    [self killScheduledTasks];
    if (inHibernation) return;
    
    [self postNotificationWithName:FasTApiCannotConnectNotification info:nil];
    
    [self scheduleReconnect];
}

#pragma mark - rails api methods

- (void)getResource:(NSString *)resource withAction:(NSString *)action callback:(FasTApiResponseBlock)callback
{
    [self makeRequestWithResource:resource action:action method:@"GET" data:nil callback:callback];
}

- (void)postResource:(NSString *)resource withAction:(NSString *)action data:(NSDictionary *)data callback:(FasTApiResponseBlock)callback
{
    [self makeRequestWithResource:resource action:action method:@"POST" data:data callback:callback];
}

- (void)makeRequestWithResource:(NSString *)resource action:(NSString *)action method:(NSString *)method data:(NSDictionary *)data callback:(FasTApiResponseBlock)callback
{
    NSString *path = (action) ? [NSString stringWithFormat:@"/api/%@/%@", resource, action] : [NSString stringWithFormat:@"/api/%@", resource];
    [self makeRequestWithPath:path method:method data:data callback:callback];
}

- (void)makeRequestWithPath:(NSString *)path method:(NSString *)method data:(NSDictionary *)data callback:(FasTApiResponseBlock)callback
{
	MKNetworkOperation *op = [netEngine operationWithPath:path params:data httpMethod:method ssl:YES];
	[op setPostDataEncoding:MKNKPostDataEncodingTypeJSON];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		if (callback) callback([completedOperation responseJSON]);
        
	} errorHandler:^(MKNetworkOperation *completedOperation, NSError* error) {
		NSLog(@"%@", error);
        if (callback) callback(nil);
	}];
	
	[netEngine enqueueOperation:op];
}

- (void)placeRetailOrderWithInfo:(NSDictionary *)info callback:(FasTApiResponseBlock)callback
{
    NSMutableDictionary *orderInfo = [NSMutableDictionary dictionaryWithDictionary:info];
    orderInfo[@"seatingId"] = seatingId;
    NSDictionary *data = @{
        @"order": orderInfo,
        @"retailId": clientId
    };
    [self postResource:@"orders" withAction:nil data:data callback:callback];
}

- (void)getOrdersForRetailStore
{
    [self getResource:@"orders" withAction:[NSString stringWithFormat:@"retail/%@", clientId] callback:^(NSDictionary *response) {
        [self updateOrdersWithArray:response];
    }];
}

- (void)getOrdersForCurrentDateWithCallback:(void (^)(NSArray *))callback
{
    [self getResource:@"orders" withAction:@"current_date" callback:^(NSDictionary *response) {
        if (!response[@"orders"]) callback(nil);
        
        NSMutableArray *orders = [NSMutableArray array];
        for (NSDictionary *orderInfo in response[@"orders"]) {
            FasTOrder *order = [[[FasTOrder alloc] initWithInfo:orderInfo event:event] autorelease];
            [orders addObject:order];
        }
        
        callback([NSArray arrayWithArray:orders]);
    }];
}

- (void)getOrderWithNumber:(NSString *)number callback:(void (^)(FasTOrder *))callback
{
    [self getResource:@"orders" withAction:[NSString stringWithFormat:@"number/%@", number] callback:^(NSDictionary *response) {
        FasTOrder *order = nil;
        if (response && response[@"order"]) {
            order = [[[FasTOrder alloc] initWithInfo:response[@"order"] event:event] autorelease];
        }
        callback(order);
    }];
}

- (void)markOrderAsPaid:(FasTOrder *)order withCallback:(FasTApiResponseBlock)callback
{
    [self postResource:@"orders" withAction:[NSString stringWithFormat:@"%@/mark_paid", [order orderId]] data:nil callback:callback];
}

- (void)resetSeating
{
    [sIO sendEvent:@"reset" withData:nil];
}

- (void)checkInTicketWithInfo:(NSDictionary *)info in:(BOOL)goingIn callback:(FasTApiResponseBlock)callback
{
    NSMutableDictionary *data = [info mutableCopy];
    [data addEntriesFromDictionary:@{ @"checkpoint": clientId, @"in": @(goingIn) }];
    [self postResource:@"tickets" withAction:@"check_in" data:data callback:callback];
}

- (void)finishPurchaseWithItems:(NSArray *)items total:(float)total callback:(FasTApiResponseBlock)callback
{
    NSDictionary *data = @{ @"box_office": clientId, @"items": items, @"total": @(total) };
    [self postResource:@"purchases" withAction:@"" data:data callback:callback];
}

#pragma mark node methods

- (void)setDate:(NSString *)dateId numberOfSeats:(NSInteger)numberOfSeats callback:(FasTApiResponseBlock)callback
{
    NSDictionary *data = @{ @"date": dateId, @"numberOfSeats": @(numberOfSeats) };
    [sIO sendEvent:@"setDateAndNumberOfSeats" withData:data andAcknowledge:callback];
}

- (void)chooseSeatWithId:(NSString *)seatId
{
    NSDictionary *data = @{ @"seatId": seatId };
    [sIO sendEvent:@"chooseSeat" withData:data];
}

- (void)connectToNode
{
    [sIO setUseSecure:YES];
    [sIO connectToHost:kFasTApiUrl onPort:0 withParams:nil withNamespace:[NSString stringWithFormat:@"/%@", clientType]];
}

#pragma mark class methods

- (void)initNodeConnection
{
    if (nodeConnectionInitiated) return;
    nodeConnectionInitiated = true;
    
    sIO = [[SocketIO alloc] initWithDelegate:self];
    [sIO setResource:@"node"];
    
    inHibernation = YES;
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [center addObserver:self selector:@selector(disconnect) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [center addObserver:self selector:@selector(prepareNodeConnection) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self prepareNodeConnection];
}

- (void)postNotificationWithName:(NSString *)name info:(NSDictionary *)info
{
    NSNotification *notification = [NSNotification notificationWithName:name object:self userInfo:info];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)prepareNodeConnection
{
    if (!clientType) return;
    
    [self killScheduledTasks];
    [self performSelector:@selector(abortAndReconnect) withObject:nil afterDelay:kFasTApiTimeOut];
    
    if (inHibernation) [self postNotificationWithName:FasTApiConnectingNotification info:nil];
    inHibernation = NO;
    [self getResource:@"events" withAction:@"current" callback:^(NSDictionary *response) {
        [self initEventWithInfo:response];
        [self connectToNode];
    }];
}

- (void)disconnect
{
    inHibernation = YES;
    [netEngine cancelAllOperations];
    [sIO disconnect];
}

- (void)abortAndReconnect
{
    [self disconnect];
    inHibernation = NO;
    [self scheduleReconnect];
    
    [self postNotificationWithName:FasTApiCannotConnectNotification info:nil];
}

- (void)killScheduledTasks
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)scheduleReconnect
{
    [self performSelector:@selector(prepareNodeConnection) withObject:nil afterDelay:5];
}

- (void)initEventWithInfo:(NSDictionary *)info
{
    FasTEvent *ev = [[[FasTEvent alloc] initWithInfo:info] autorelease];
    [self setEvent:ev];
}

- (void)updateOrdersWithArray:(NSDictionary *)info
{
    NSMutableArray *orders = [NSMutableArray array];
    for (NSDictionary *orderInfo in info) {
        FasTOrder *order = [[[FasTOrder alloc] initWithInfo:orderInfo event:event] autorelease];
        [orders addObject:order];
    }
    
    [self postNotificationWithName:FasTApiUpdatedOrdersNotification info:@{ @"orders": [NSArray arrayWithArray:orders] }];
}

- (void)appWillResignActive
{
    [self killScheduledTasks];
}

@end
