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

@import SocketIOClientSwift;
@import MKNetworkKit;

NSString * const FasTApiIsReadyNotification = @"FasTApiIsReadyNotification";
NSString * const FasTApiUpdatedSeatsNotification = @"FasTApiUpdatedSeatsNotification";
NSString * const FasTApiUpdatedOrdersNotification = @"FasTApiUpdatedOrdersNotification";
NSString * const FasTApiOrderExpiredNotification = @"FasTApiOrderExpiredNotification";
NSString * const FasTApiConnectingNotification = @"FasTApiConnectingNotification";
NSString * const FasTApiDisconnectedNotification = @"FasTApiDisconnectedNotification";
NSString * const FasTApiCannotConnectNotification = @"FasTApiCannotConnectNotification";

static FasTApi *defaultApi = nil;

#ifdef DEBUG
    static NSString *kFasTApiUrl = @"localhost:4000";
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
- (void)makeRequestWithAction:(NSString *)action method:(NSString *)method tickets:(NSArray *)tickets callback:(void (^)(FasTOrder *))callback;
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
    [op addHeaders:@{@"Accept": @"application/json"}];
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
    [sIO emit:@"reset" withItems:@[]];
}

- (void)unlockSeats
{
    [self makeJsonRequestWithPath:@"api/box_office/unlock_seats" method:@"POST" data:@{ @"seating_id": seatingId } callback:NULL];
}

- (void)cancelBoxOfficeOrder:(FasTOrder *)order
{
    [self makeJsonRequestWithPath:@"api/box_office/cancel_order" method:@"PATCH" data:@{ @"id": order.orderId } callback:NULL];
}

- (void)makeRequestWithAction:(NSString *)action method:(NSString *)method tickets:(NSArray *)tickets callback:(void (^)(FasTOrder *))callback
{
    NSArray *ticketIds = [self ticketIdsForTickets:tickets];
    
    [self makeJsonRequestWithPath:[NSString stringWithFormat:@"api/box_office/%@", action] method:method data:@{ @"ticket_ids": ticketIds } callback:^(NSDictionary *response) {
        FasTOrder *order = [[[FasTOrder alloc] initWithInfo:response[@"order"] event:self.event] autorelease];
        callback(order);
    }];
}

- (void)cancelTickets:(NSArray *)tickets callback:(void (^)(FasTOrder *order))callback
{
    [self makeRequestWithAction:@"cancel_tickets" method:@"PATCH" tickets:tickets callback:callback];
}

- (void)enableResaleForTickets:(NSArray *)tickets callback:(void (^)(FasTOrder *))callback
{
    [self makeRequestWithAction:@"enable_resale_for_tickets" method:@"PATCH" tickets:tickets callback:callback];
}

#pragma mark node methods

- (void)setDate:(NSString *)dateId numberOfSeats:(NSInteger)numberOfSeats callback:(FasTApiResponseBlock)callback
{
    NSDictionary *data = @{ @"date": dateId, @"numberOfSeats": @(numberOfSeats) };
    [sIO emitWithAck:@"setDateAndNumberOfSeats" withItems:@[data]](0, ^(NSArray* data) {
        NSDictionary *response = data.count > 0 ? data[0] : nil;
        callback(response);
    });
}

- (void)chooseSeatWithId:(NSString *)seatId
{
    NSDictionary *data = @{ @"seatId": seatId };
    [sIO emit:@"chooseSeat" withItems:@[data]];
}

- (void)connectToNode
{
    [sIO connect];
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
    
    NSString *scheme = kFasTApiSSL ? @"https" : @"http";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", scheme, kFasTApiUrl]];
    sIO = [[SocketIOClient alloc] initWithSocketURL:url options:@{@"log": @YES, @"path": @"/node/", @"nsp": [NSString stringWithFormat:@"/%@", clientType]}];
    
    inHibernation = YES;
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [center addObserver:self selector:@selector(disconnect) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [center addObserver:self selector:@selector(prepareNodeConnection) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self prepareNodeConnection];
    
    [sIO on:@"connect" callback:^(NSArray *args, SocketAckEmitter *ack) {
        [self killScheduledTasks];
        
        [self postNotificationWithName:FasTApiIsReadyNotification info:nil];
    }];
    
    [sIO on:@"disconnect" callback:^(NSArray *args, SocketAckEmitter *ack) {
        [self killScheduledTasks];
        if (inHibernation) return;
        
        [self postNotificationWithName:FasTApiDisconnectedNotification info:nil];
        
        [self scheduleReconnect];
    }];
    
    [sIO on:@"error" callback:^(NSArray *args, SocketAckEmitter *ack) {
        [self killScheduledTasks];
        if (inHibernation) return;
    
        [self postNotificationWithName:FasTApiCannotConnectNotification info:nil];
    
        [self scheduleReconnect];
    }];
    
    
    [sIO on:@"updateSeats" callback:^(NSArray *args, SocketAckEmitter *ack) {
        NSDictionary *seats = args[0][@"seats"];
        [event updateSeats:seats];

        [self postNotificationWithName:FasTApiUpdatedSeatsNotification info:seats];
    }];
    
    [sIO on:@"gotSeatingId" callback:^(NSArray *args, SocketAckEmitter *ack) {
        [seatingId release];
        seatingId = [args[0][@"id"] retain];
    }];
    
    //    } else if ([[packet name] isEqualToString:@"updateEvent"]) {
    //        [self initEventWithInfo:info[@"event"]];
    //
    //    } else if ([[packet name] isEqualToString:@"updateOrders"]) {
    //        [self updateOrdersWithArray:info];
    
    [sIO on:@"expired" callback:^(NSArray *args, SocketAckEmitter *ack) {
        [self postNotificationWithName:FasTApiOrderExpiredNotification info:nil];
    }];
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
//    [self performSelector:@selector(abortAndReconnect) withObject:nil afterDelay:kFasTApiTimeOut];
    
    if (inHibernation) [self postNotificationWithName:FasTApiConnectingNotification info:nil];
    inHibernation = NO;
    [self fetchCurrentEvent:^() {
        [self connectToNode];
    }];
}

- (void)disconnect
{
    inHibernation = YES;
//    [netEngine cancelAllOperations];
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
