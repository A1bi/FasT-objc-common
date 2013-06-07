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

static int      kMaxCellsX = 100;
static int      kMaxCellsY = 60;
static float    kSizeFactorsX = 3;
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
        CGFloat stageHeight = self.frame.size.height * .1, margin = 10;
        CGRect frame = CGRectMake(margin, self.frame.size.height - stageHeight, self.frame.size.width - margin * 2, stageHeight);
        UIView *stageView = [[[UIView alloc] initWithFrame:frame] autorelease];
        [stageView setBackgroundColor:[UIColor blueColor]];
        [self addSubview:stageView];
        
        frame.origin.x = 0, frame.origin.y = 0;
        UILabel *stageLabel = [[[UILabel alloc] initWithFrame:frame] autorelease];
        [stageLabel setBackgroundColor:[UIColor clearColor]];
        [stageLabel setTextColor:[UIColor whiteColor]];
        [stageLabel setFont:[UIFont boldSystemFontOfSize:20]];
        [stageLabel setText:NSLocalizedStringByKey(@"stage")];
        [stageLabel setTextAlignment:NSTextAlignmentCenter];
        [stageView addSubview:stageLabel];
        
		seatViews = [[NSMutableDictionary dictionary] retain];
        
        grid = [@[ @(self.frame.size.width / (kMaxCellsX + 1)), @((self.frame.size.height - stageHeight) / (kMaxCellsY + 1)) ] retain];
        
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
