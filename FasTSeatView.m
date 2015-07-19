//
//  FasTSeatsViewSeat.m
//  FasT-retail
//
//  Created by Albrecht Oster on 11.04.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import "FasTSeatView.h"
#import <QuartzCore/QuartzCore.h>

@interface FasTSeatView ()

- (void)choose;
- (void)updateSeat;
- (void)initSeat;

@end

@implementation FasTSeatView

@synthesize state, seatId, delegate;

- (id)initWithFrame:(CGRect)frame seatId:(NSString *)sId
{
    self = [super initWithFrame:frame];
    if (self) {
		seatId = [sId retain];
		[self initSeat];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initSeat];
    }
    return self;
}

- (void)initSeat
{
    UITapGestureRecognizer *tapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)] autorelease];
    [self addGestureRecognizer:tapRecognizer];
    
    _numberLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _numberLabel.font = [UIFont systemFontOfSize:14];
    _numberLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_numberLabel];
}

- (void)dealloc
{
    [seatId release];
    [_numberLabel release];
    [super dealloc];
}

#pragma mark class methods

- (void)choose
{
    if (state == FasTSeatViewStateAvailable) {
        [self setState:FasTSeatViewStateChosen];
        
        [[self delegate] didChooseSeatView:self];
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
        case FasTSeatViewStateChosen:
            colorName = @"yellow";
            break;
            
        case FasTSeatViewStateTaken:
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
	if (delegate) [self choose];
}

@end
