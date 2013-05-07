//
//  FasTSeat.m
//  FasT-retail
//
//  Created by Albrecht Oster on 29.04.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import "FasTSeat.h"

@implementation FasTSeat

@synthesize seatId, posX, posY, reserved, selected;

- (id)initWithId:(NSString *)sId andInfo:(NSDictionary *)info
{
    self = [super init];
    if (self) {
        seatId = [sId retain];
        
        [self updateWithInfo:info];
    }
    return self;
}

- (void)dealloc
{
    [seatId release];
    [super dealloc];
}

- (void)updateWithInfo:(NSDictionary *)info
{
    NSDictionary *grid = info[@"grid"];
    posX = [grid[@"x"] intValue];
    posY = [grid[@"y"] intValue];
    
    reserved = [info[@"reserved"] boolValue];
    selected = [info[@"selected"] boolValue];
}

@end
