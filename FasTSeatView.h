//
//  FasTSeatsViewSeat.h
//  FasT-retail
//
//  Created by Albrecht Oster on 11.04.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FasTSeatingView.h"

typedef enum {
    FasTSeatViewStateAvailable,
    FasTSeatViewStateTaken,
    FasTSeatViewStateChosen
} FasTSeatViewState;

@interface FasTSeatView : UIView
{
	NSString *seatId;
    FasTSeatViewState state;
}

@property (nonatomic) FasTSeatViewState state;
@property (nonatomic, readonly) NSString *seatId;
@property (nonatomic, assign) id<FasTSeatingViewDelegate> delegate;
@property (nonatomic, readonly) UILabel *numberLabel;

- (id)initWithFrame:(CGRect)frame seatId:(NSString *)sId;

@end
