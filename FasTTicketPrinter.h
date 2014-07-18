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
@class FasTOrder;

@interface FasTTicketPrinter : NSObject
{
    NSString *ticketsPath;
    PKPrintSettings *printSettings;
    PKPrinter *printer;
}

+ (FasTTicketPrinter *)sharedPrinter;

- (void)printTickets:(NSArray *)tickets;

@end
