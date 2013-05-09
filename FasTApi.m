//
//  FasTApi.m
//  FasT-retail
//
//  Created by Albrecht Oster on 09.05.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import "FasTApi.h"
#import "FasTEvent.h"
#import "MKNetworkEngine.h"
#import "SocketIOPacket.h"

static FasTApi *defaultApi = nil;
static NSString *kApiUrl = @"fast.albisigns";

@interface FasTApi ()

- (void)makeRequestWithPath:(NSString *)path method:(NSString *)method data:(NSDictionary *)data callback:(FasTApiResponseBlock)callback;
- (void)makeRequestWithResource:(NSString *)resource action:(NSString *)action method:(NSString *)method data:(NSDictionary *)data callback:(FasTApiResponseBlock)callback;
- (void)connectToNode;
- (void)postNotificationWithName:(NSString *)name info:(NSDictionary *)info;
- (void)initConnections;
- (void)initEventWithInfo:(NSDictionary *)info;

@end

@implementation FasTApi

@synthesize event;

+ (FasTApi *)defaultApi
{
	if (!defaultApi) {
		defaultApi = [[super allocWithZone:NULL] init];
	}
	
	return defaultApi;
}

+ (id)allocWithZone:(NSZone *)zone
{
	return [self defaultApi];
}

- (id)init
{
	if (defaultApi) {
		return defaultApi;
	}
	
	self = [super init];
	if (self) {
        netEngine = [[MKNetworkEngine alloc] initWithHostName:kApiUrl];
        
        sIO = [[SocketIO alloc] initWithDelegate:self];
        [sIO setResource:@"node"];
        
        [self initConnections];
	}
	
	return self;
}

- (void)dealloc
{
    [netEngine release];
    [sIO release];
    [event release];
    [super dealloc];
}

#pragma mark SocketIO delegate methods

- (void)socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    NSDictionary *info = [packet dataAsJSON][@"args"][0];
    
    if ([[packet name] isEqualToString:@"updateSeats"]) {
        NSDictionary *seats = info[@"seats"];
        [event updateSeats:seats];
        
        [self postNotificationWithName:[packet name] info:seats];
        
    } else if ([[packet name] isEqualToString:@"updateEvent"]) {
        [self initEventWithInfo:info[@"event"]];
        
    } else if ([[packet name] isEqualToString:@"orderPlaced"]) {
        [self postNotificationWithName:[packet name] info:info];
    }
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
    NSString *path = (action) ? [NSString stringWithFormat:@"/api/%@/%@", resource, action] : [NSString stringWithFormat:@"/%@", resource];
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
	}];
	
	[netEngine enqueueOperation:op];
}

#pragma mark node methods

- (void)updateOrderWithStep:(NSString *)step info:(NSDictionary *)info callback:(void (^)(NSDictionary *))callback
{
    NSDictionary *data = @{ @"order": @{ @"step": step, @"info": info } };
    [sIO sendEvent:@"updateOrder" withData:data andAcknowledge:callback];
}

- (void)reserveSeatWithId:(NSString *)seatId
{
    NSDictionary *data = @{ @"seatId": seatId };
    [sIO sendEvent:@"reserveSeat" withData:data];
}

- (void)connectToNode
{
    [sIO setUseSecure:YES];
    [sIO connectToHost:kApiUrl onPort:0 withParams:@{ @"retailId": @"1" } withNamespace:@"/retail"];
}

- (void)postNotificationWithName:(NSString *)name info:(NSDictionary *)info
{
    NSNotification *notification = [NSNotification notificationWithName:name object:self userInfo:info];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

#pragma mark class methods

- (void)initConnections
{
    [self getResource:@"events" withAction:@"current" callback:^(NSDictionary *response) {
        [self initEventWithInfo:response];
        [self connectToNode];
    }];
}

- (void)initEventWithInfo:(NSDictionary *)info
{
    [self setEvent:[[FasTEvent alloc] initWithInfo:info]];
}

@end
