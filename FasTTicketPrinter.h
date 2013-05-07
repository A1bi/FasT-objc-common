//
//  FasTTicketPrinter.h
//  FasT-retail
//
//  Created by Albrecht Oster on 27.04.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PKPrintSettings;
@class PKPrinter;
@class FasTEvent;

@interface FasTTicketPrinter : NSObject
{
    CGFloat posX, posY;
    CGFloat ticketWidth, ticketHeight;
    CGContextRef context;
    NSDictionary *fonts;
    NSString *ticketsPath;
    PKPrintSettings *printSettings;
    PKPrinter *printer;
    NSDictionary *orderInfo;
    FasTEvent *event;
}

- (id)initWithEvent:(FasTEvent *)e;
- (void)printTicketsForOrderWithInfo:(NSDictionary *)info;

@end
