//
//  FasTTicketPrinter.h
//  FasT-retail
//
//  Created by Albrecht Oster on 27.04.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FasTTicketPrinter : NSObject <UIPrintInteractionControllerDelegate>
{
    UIPrinter *printer;
}

+ (FasTTicketPrinter *)sharedPrinter;

- (void)printTickets:(NSArray *)tickets;

@end
