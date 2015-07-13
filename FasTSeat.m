//
//  FasTSeat.m
//  FasT-retail
//
//  Created by Albrecht Oster on 29.04.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import "FasTSeat.h"

@implementation FasTSeat

@synthesize seatId, number, row, blockName, blockColor, posX, posY, taken, chosen;

- (id)initWithInfo:(NSDictionary *)info
{
    self = [super init];
    if (self) {
        seatId = [info[@"id"] retain];
        number = [info[@"number"] retain];
        row = [info[@"row"] retain];
        blockName = [info[@"block"][@"name"] retain];
        blockColor = [info[@"block"][@"color"] retain];
        
        NSDictionary *grid = info[@"grid"];
        posX = [grid[@"x"] intValue];
        posY = [grid[@"y"] intValue];
    }
    return self;
}

- (void)dealloc
{
    [seatId release];
    [number release];
    [row release];
    [blockName release];
    [blockColor release];
    [super dealloc];
}

- (void)updateWithInfo:(NSDictionary *)info
{
    taken = [info[@"t"] boolValue];
    chosen = [info[@"c"] boolValue];
}

@end
