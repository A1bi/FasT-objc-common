//
//  FasTSeatsView.h
//  FasT-retail
//
//  Created by Albrecht Oster on 11.04.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FasTSeatingView;
@class FasTSeatView;
@class FasTSeat;

@protocol FasTSeatingViewDelegate <NSObject>

- (void)didSelectSeatView:(FasTSeatView *)seatView;

@end

@interface FasTSeatingView : UIView
{
	NSMutableDictionary *seatViews;
    NSArray *grid, *sizes;
}

@property (nonatomic, assign) IBOutlet id<FasTSeatingViewDelegate> delegate;

- (void)updatedSeat:(FasTSeat *)seat;

@end
