//
//  FasTSeatsViewSeat.m
//  FasT-retail
//
//  Created by Albrecht Oster on 11.04.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import "FasTSeatView.h"

@interface FasTSeatView ()

- (void)reserve;
- (void)updateSeat;

@end

@implementation FasTSeatView

@synthesize state, seatId, delegate;

- (id)initWithFrame:(CGRect)frame seatId:(NSString *)sId
{
    self = [super initWithFrame:frame];
    if (self) {
		seatId = [sId retain];
		
		UITapGestureRecognizer *tapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)] autorelease];
		[self addGestureRecognizer:tapRecognizer];
    }
    return self;
}

- (void)dealloc
{
    [seatId release];
    [super dealloc];
}

#pragma mark class methods

- (void)reserve
{
    if (state == FasTSeatViewStateAvailable) {
        [self setState:FasTSeatViewStateSelected];
        
        [[self delegate] didSelectSeatView:self];
    }
}

- (void)setState:(FasTSeatViewState)s
{
    state = s;
    [self updateSeat];
}

- (void)updateSeat
{
    NSString *colorName;
    switch (state) {
        case FasTSeatViewStateSelected:
            colorName = @"yellow";
            break;
            
        case FasTSeatViewStateReserved:
            colorName = @"red";
            break;
            
        default:
            colorName = @"green";
    }
    
    SEL colorSelector = NSSelectorFromString([NSString stringWithFormat:@"%@Color", colorName]);
    UIColor *color = [UIColor performSelector:colorSelector];
	[self setBackgroundColor:color];
}

#pragma mark gesture recognizer delegate methods

- (void)tapped
{
	[self reserve];
}

@end
