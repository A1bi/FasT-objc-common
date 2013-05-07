//
//  FasTSeatsView.m
//  FasT-retail
//
//  Created by Albrecht Oster on 11.04.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import "FasTSeatingView.h"
#import "FasTSeatView.h"
#import "FasTSeat.h"

static int      kMaxCellsX = 115;
static int      kMaxCellsY = 60;
static float    kSizeFactorsX = 3.5;
static float    kSizeFactorsY = 3;

@interface FasTSeatingView ()

- (FasTSeatView *)addSeat:(FasTSeat *)seat;

@end

@implementation FasTSeatingView

@synthesize delegate;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
		seatViews = [[NSMutableDictionary dictionary] retain];
        
        grid = [@[ @(self.frame.size.width / kMaxCellsX), @(self.frame.size.height / kMaxCellsY) ] retain];
        
        sizes = [@[ @([grid[0] floatValue] * kSizeFactorsX), @([grid[1] floatValue] * kSizeFactorsY) ] retain];
    }
    return self;
}

- (void)updatedSeat:(FasTSeat *)seat
{
    FasTSeatView *seatView = seatViews[[seat seatId]];
    if (!seatView) {
        seatView = [self addSeat:seat];
    }
    
    FasTSeatViewState newState = FasTSeatViewStateAvailable;
    if ([seat selected]) {
        newState = FasTSeatViewStateSelected;
    } else if ([seat reserved]) {
        newState = FasTSeatViewStateReserved;
    }
    [seatView setState:newState];
}

- (FasTSeatView *)addSeat:(FasTSeat *)seat
{
    CGRect frame;
	frame.size.width = [sizes[0] floatValue];
	frame.size.height = [sizes[1] floatValue];
	frame.origin.x = [grid[0] floatValue] * [seat posX];
	frame.origin.y = [grid[1] floatValue] * [seat posY];
	
	FasTSeatView *seatView = [[[FasTSeatView alloc] initWithFrame:frame seatId:[seat seatId]] autorelease];
    [seatView setDelegate:[self delegate]];
    seatViews[[seat seatId]] = seatView;
	[self addSubview:seatView];
    
    return seatView;
}

- (void)dealloc
{
    [grid release];
    [sizes release];
    [seatViews release];
    [super dealloc];
}

@end
