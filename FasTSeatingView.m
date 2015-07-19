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

static int      kMaxCellsX = 150;
static int      kMaxCellsY = 60;
static float    kSizeFactorsX = 2.8;
static float    kSizeFactorsY = 2.8;

@interface FasTSeatingView ()

- (FasTSeatView *)addSeat:(FasTSeat *)seat;

@end

@implementation FasTSeatingView

@synthesize delegate;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        CGSize scrollSize = CGSizeMake(self.bounds.size.width * 1.8, self.bounds.size.height);
        scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [scrollView setContentSize:scrollSize];
        [scrollView setMinimumZoomScale:1];
        [scrollView setMaximumZoomScale:1.5];
        [scrollView setDelegate:self];
        [self addSubview:scrollView];
        
        CGRect frame;
        frame.size = scrollSize;
        frame.origin = CGPointZero;
        seatsView = [[UIView alloc] initWithFrame:frame];
        [scrollView addSubview:seatsView];
        
        CGFloat stageHeight = scrollSize.height * .1, margin = 0;
        frame = CGRectMake(margin, scrollSize.height - stageHeight, scrollSize.width - margin * 2, stageHeight);
        stageView = [[UIView alloc] initWithFrame:frame];
        [stageView setBackgroundColor:[UIColor blueColor]];
        [scrollView addSubview:stageView];
        
        frame.origin.x = 0, frame.origin.y = 0;
        UILabel *stageLabel = [[[UILabel alloc] initWithFrame:frame] autorelease];
        [stageLabel setBackgroundColor:[UIColor clearColor]];
        [stageLabel setTextColor:[UIColor whiteColor]];
        [stageLabel setFont:[UIFont boldSystemFontOfSize:20]];
        [stageLabel setText:NSLocalizedStringByKey(@"stage")];
        [stageLabel setTextAlignment:NSTextAlignmentCenter];
        [stageView addSubview:stageLabel];
        
		seatViews = [[NSMutableDictionary dictionary] retain];
        
        scrollSize.height *= .9;
        grid = [@[ @(scrollSize.width / kMaxCellsX), @(scrollSize.height / kMaxCellsY) ] retain];
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
    if ([seat chosen]) {
        newState = FasTSeatViewStateChosen;
    } else if ([seat taken]) {
        newState = FasTSeatViewStateTaken;
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
	[seatsView addSubview:seatView];
    
    NSString *colorMethod = [NSString stringWithFormat:@"%@Color", @"blue"];
    UIColor *color = [[UIColor class] performSelector:NSSelectorFromString(colorMethod)];
    seatView.layer.borderColor = color.CGColor;
    seatView.layer.borderWidth = 2;
    seatView.numberLabel.text = seat.number;
    
    return seatView;
}

- (void)dealloc
{
    [grid release];
    [sizes release];
    [seatViews release];
    [stageView release];
    [scrollView release];
    [seatsView release];
    [super dealloc];
}

#pragma mark scroll view delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return seatsView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    
}

- (void)scrollViewDidZoom:(UIScrollView *)s
{
    CGRect frame = stageView.frame;
    frame.size.width = s.contentSize.width;
    frame.origin.y = s.contentSize.height - frame.size.height;
    stageView.frame = frame;
}

@end
