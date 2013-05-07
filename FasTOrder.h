//
//  FasTOrder.h
//  FasT-retail
//
//  Created by Albrecht Oster on 14.04.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FasTEventDate;

@interface FasTOrder : NSObject
{
	FasTEventDate *date;
	NSArray *tickets;
    NSInteger numberOfTickets;
    float total;
}

@property (nonatomic, retain) FasTEventDate *date;
@property (nonatomic, retain) NSArray *tickets;
@property (nonatomic, assign) NSInteger numberOfTickets;
@property (nonatomic, assign) float total;

@end
