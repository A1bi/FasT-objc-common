//
//  FasTApi.m
//  FasT-retail
//
//  Created by Albrecht Oster on 09.05.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import "FasTApi.h"
#import "FasTEvent.h"
#import "FasTEventDate.h"
#import "FasTOrder.h"
#import "FasTTicket.h"
#import "FasTTicketType.h"
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
    static NSString *kFasTApiUrl = @"127.0.0.1:4000";
    static BOOL kFasTApiSSL = NO;
#else
    static NSString *kFasTApiUrl = @"www.theater-kaisersesch.de";
    static BOOL kFasTApiSSL = YES;
#endif

#define kFasTApiTimeOut 10

@interface FasTApi ()

- (id)initWithClientType:(NSString *)cType clientId:(NSString *)cId;
- (void)makeJsonRequestWithPath:(NSString *)path method:(NSString *)method data:(NSDictionary *)data callback:(FasTApiResponseBlock)callback;
- (void)makeJsonRequestWithResource:(NSString *)resource action:(NSString *)action method:(NSString *)method data:(NSDictionary *)data callback:(FasTApiResponseBlock)callback;
- (void)makeRequestWithPath:(NSString *)path method:(NSString *)method data:(NSDictionary *)data callback:(void (^)(NSData *))callback;
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
- (NSArray *)ticketIdsForTickets:(NSArray *)tickets;

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
    [self getResource:resource withAction:action data:nil callback:callback];
}

- (void)getResource:(NSString *)resource withAction:(NSString *)action data:(NSDictionary *)data callback:(FasTApiResponseBlock)callback
{
    [self makeJsonRequestWithResource:resource action:action method:@"GET" data:data callback:callback];
}

- (void)postResource:(NSString *)resource withAction:(NSString *)action data:(NSDictionary *)data callback:(FasTApiResponseBlock)callback
{
    [self makeJsonRequestWithResource:resource action:action method:@"POST" data:data callback:callback];
}

- (void)makeJsonRequestWithResource:(NSString *)resource action:(NSString *)action method:(NSString *)method data:(NSDictionary *)data callback:(FasTApiResponseBlock)callback
{
    NSString *path = (action) ? [NSString stringWithFormat:@"/%@/%@", resource, action] : [NSString stringWithFormat:@"/%@", resource];
    [self makeJsonRequestWithPath:path method:method data:data callback:callback];
}

- (void)makeJsonRequestWithPath:(NSString *)path method:(NSString *)method data:(NSDictionary *)data callback:(FasTApiResponseBlock)callback
{
	MKNetworkOperation *op = [netEngine operationWithPath:path params:data httpMethod:method ssl:kFasTApiSSL];
    [op setHeader:@"Accept" withValue:@"application/json"];
	[op setPostDataEncoding:MKNKPostDataEncodingTypeJSON];
#ifdef DEBUG
    [op setShouldContinueWithInvalidCertificate:YES];
#endif
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		if (callback) callback([completedOperation responseJSON]);
        
	} errorHandler:^(MKNetworkOperation *completedOperation, NSError* error) {
		NSLog(@"%@", error);
        if (callback) callback(nil);
	}];
	
	[netEngine enqueueOperation:op];
}

- (void)makeRequestWithPath:(NSString *)path method:(NSString *)method data:(NSDictionary *)data callback:(void (^)(NSData *))callback
{
    MKNetworkOperation *op = [netEngine operationWithPath:path params:data httpMethod:method ssl:kFasTApiSSL];
    [op setPostDataEncoding:MKNKPostDataEncodingTypeJSON];
#ifdef DEBUG
    [op setShouldContinueWithInvalidCertificate:YES];
#endif
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		if (callback) callback([completedOperation responseData]);
        
	} errorHandler:^(MKNetworkOperation *completedOperation, NSError* error) {
		NSLog(@"%@", error);
        if (callback) callback(nil);
	}];
	
	[netEngine enqueueOperation:op];
}

- (void)resetSeating
{
    [sIO sendEvent:@"reset" withData:nil];
}

- (void)unlockSeats
{
    [self makeJsonRequestWithPath:@"api/box_office/unlock_seats" method:@"POST" data:@{ @"seating_id": seatingId } callback:NULL];
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
    [sIO setUseSecure:kFasTApiSSL];
    [sIO connectToHost:kFasTApiUrl onPort:0 withParams:nil withNamespace:[NSString stringWithFormat:@"/%@", clientType]];
}

#pragma mark class methods

- (void)fetchCurrentEvent:(void (^)())callback
{
    [self getResource:@"api/box_office" withAction:@"event" callback:^(NSDictionary *response) {
        [self initEventWithInfo:response];
        if (callback) callback();
    }];
}

- (void)placeOrder:(FasTOrder *)order callback:(void (^)(FasTOrder *order))callback
{
    NSMutableDictionary *ticketsInfo = [NSMutableDictionary dictionary];
    for (FasTTicket *ticket in order.tickets) {
        NSInteger number = 0;
        if (ticketsInfo[ticket.type.typeId]) {
            number = ((NSNumber *)ticketsInfo[ticket.type.typeId]).integerValue;
        }
        number++;
        ticketsInfo[ticket.type.typeId] = @(number);
    }
    
    NSDictionary *orderInfo = @{ @"date": order.date.dateId, @"seatingId": seatingId, @"tickets": ticketsInfo };
    
    [self makeJsonRequestWithPath:@"api/box_office/place_order" method:@"POST" data:@{ @"order": orderInfo } callback:^(NSDictionary *response) {
        FasTOrder *newOrder = [[[FasTOrder alloc] initWithInfo:response[@"order"] event:event] autorelease];
        callback(newOrder);
    }];
}

- (void)fetchPrintableForTickets:(NSArray *)tickets callback:(void (^)(NSData *data))callback
{
    NSArray *ticketIds = [self ticketIdsForTickets:tickets];
    
    [self makeRequestWithPath:@"api/box_office/ticket_printable" method:@"POST" data:@{ @"ticket_ids": ticketIds } callback:^(NSData *data) {
        callback(data);
    }];
}

- (void)pickUpTickets:(NSArray *)tickets
{
    for (FasTTicket *ticket in tickets) {
        ticket.pickedUp = YES;
    }
    
    NSDictionary *data = @{ @"ticket_ids": [self ticketIdsForTickets:tickets] };
    [self makeJsonRequestWithResource:@"api/box_office" action:@"pick_up_tickets" method:@"PATCH" data:data callback:NULL];
}

- (void)finishPurchase:(NSDictionary *)data
{
    [self makeJsonRequestWithResource:@"api/box_office" action:@"purchase" method:@"POST" data:data callback:NULL];
}

- (NSString *)URLForOrder:(FasTOrder *)order
{
    NSString *scheme = kFasTApiSSL ? @"https" : @"http";
    return [NSString stringWithFormat:@"%@://%@/vorverkauf/bestellungen/%@", scheme, kFasTApiUrl, order.orderId];
}

- (NSArray *)ticketIdsForTickets:(NSArray *)tickets
{
    NSMutableArray *ticketIds = [NSMutableArray array];
    for (FasTTicket *ticket in tickets) {
        [ticketIds addObject:ticket.ticketId];
    }
    return ticketIds;
}

- (void)initNodeConnection
{
    if (nodeConnectionInitiated) return;
    nodeConnectionInitiated = true;
    
    sIO = [[SocketIO alloc] initWithDelegate:self];
    [sIO setResourceName:@"node"];
    
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
    [self fetchCurrentEvent:^() {
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
