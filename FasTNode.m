//
//  FasTNode.m
//  FasT-retail
//
//  Created by Albrecht Oster on 17.04.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import "FasTNode.h"
#import "FasTEvent.h"
#import "SocketIOPacket.h"

static FasTNode *defaultNode = nil;
static NSString *kNodeUrl = @"fast.albisigns";

@interface FasTNode ()

- (void)connect;
- (void)postNotificationWithName:(NSString *)name info:(NSDictionary *)info;

@end

@implementation FasTNode

@synthesize event;

+ (FasTNode *)defaultNode
{
	if (!defaultNode) {
		defaultNode = [[super allocWithZone:NULL] init];
	}
	
	return defaultNode;
}

+ (id)allocWithZone:(NSZone *)zone
{
	return [self defaultNode];
}

- (id)init
{
	if (defaultNode) {
		return defaultNode;
	}
	
	self = [super init];
	if (self) {
        io = [[SocketIO alloc] initWithDelegate:self];
        
        [self connect];
	}
	
	return self;
}

- (void)dealloc
{
    [io release];
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
        [self setEvent:[[FasTEvent alloc] initWithInfo:info[@"event"]]];
    
    } else if ([[packet name] isEqualToString:@"orderPlaced"]) {
        [self postNotificationWithName:[packet name] info:info];
    }
}

#pragma mark class methods

- (void)updateOrderWithStep:(NSString *)step info:(NSDictionary *)info callback:(void (^)(NSDictionary *))callback
{
    NSDictionary *data = @{ @"order": @{@"step": step, @"info": info} };
    [io sendEvent:@"updateOrder" withData:data andAcknowledge:callback];
}

- (void)reserveSeatWithId:(NSString *)seatId
{
    NSDictionary *data = @{ @"seatId": seatId };
    [io sendEvent:@"reserveSeat" withData:data];
}

- (void)connect
{
    [io setUseSecure:YES];
    [io connectToHost:kNodeUrl onPort:0 withParams:@{@"retailId": @"1"} withNamespace:@"/retail"];
}

- (void)postNotificationWithName:(NSString *)name info:(NSDictionary *)info
{
    NSNotification *notification = [NSNotification notificationWithName:name object:self userInfo:info];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

@end
